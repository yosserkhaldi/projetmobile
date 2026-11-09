import { randomInt } from 'node:crypto';
import { readFile } from 'node:fs/promises';

import { Prisma } from '@prisma/client';
import { Router } from 'express';

import { HttpError, isUniqueViolation } from '../../lib/errors.js';
import {
  AUTO_APPROVE_MATCH,
  CENTER_MAX_YAW,
  SAME_PERSON_MATCH,
  TURN_MIN_YAW,
  faceEngine,
  similarity,
} from '../../lib/face.js';
import { notifier } from '../../lib/notifier.js';
import {
  arabicMatchesLatin,
  documentReader,
  nameInMrz,
  sameName,
} from '../../lib/ocr.js';
import { prisma } from '../../lib/prisma.js';
import {
  signLivenessChallenge,
  verifyLivenessChallenge,
} from '../../lib/tokens.js';
import {
  assertImage,
  deleteImage,
  imageArray,
  imagePath,
  saveImage,
  singleImage,
} from '../../lib/uploads.js';
import { requireAuth, requireRole } from '../../middleware/auth.js';
import { aiQuota } from '../../middleware/quota.js';
import {
  publicUser,
  revokeOtherSessions,
  revokeSession,
  withCompany,
} from './auth.service.js';
import {
  biometricConsentSchema,
  documentTypeSchema,
  idParams,
  identityFileParams,
  identitySideParams,
  identitySubmitSchema,
  livenessFramesSchema,
  rejectIdentitySchema,
  sessionParams,
} from './users.schemas.js';

// Module 1 : sécurité du compte (appareils, historique) et vérification
// d'identité (pièce + visage). Monté sur /api/users avec les autres routes du module.
const router = Router();

// ---------------------------------------------------------------------------
// Appareils connectés et historique

router.get('/me/sessions', requireAuth, async (req, res) => {
  const now = new Date();
  // Une session vivante a encore un jeton de rafraîchissement valable.
  const sessions = await prisma.session.findMany({
    where: {
      userId: req.user.id,
      revokedAt: null,
      refreshTokens: { some: { revokedAt: null, expiresAt: { gt: now } } },
    },
    orderBy: { lastUsedAt: 'desc' },
  });
  res.json({
    items: sessions.map((s) => ({
      id: s.id,
      deviceName: s.deviceName,
      ip: s.ip,
      createdAt: s.createdAt,
      lastUsedAt: s.lastUsedAt,
      current: s.id === req.sessionId,
    })),
  });
});

router.delete('/me/sessions/:sessionId', requireAuth, async (req, res) => {
  const { sessionId } = sessionParams.parse(req.params);
  await revokeSession(req.user.id, sessionId);
  res.status(204).end();
});

router.post('/me/sessions/revoke-others', requireAuth, async (req, res) => {
  const revoked = await revokeOtherSessions(req.user.id, req.sessionId);
  res.json({ revoked });
});

router.get('/me/login-events', requireAuth, async (req, res) => {
  const events = await prisma.loginEvent.findMany({
    where: { userId: req.user.id },
    orderBy: { createdAt: 'desc' },
    take: 30,
  });
  res.json({
    items: events.map(({ userId: _, ...event }) => event),
  });
});

// ---------------------------------------------------------------------------
// Vérification d'identité : pièce (CIN, permis, passeport) + visage par l'IA

const IDENTITY_FOLDER = 'identity';
const FILES = {
  front: 'cinFrontFile',
  back: 'cinBackFile',
  selfie: 'identitySelfieFile',
};
const LOCKED = ['PENDING', 'VERIFIED'];
/** Analyses par l'IA : 30 par heure et par compte. */
const ai = aiQuota({ max: 30 });
/** La vérification du visage reste valable le temps de finir la demande. */
const LIVENESS_VALIDITY_MS = 30 * 60 * 1000;
const TURNS = ['left', 'right'];

/** Refus permis avant blocage, et délai entre deux demandes. */
export const MAX_REFUSALS = 3;
export const RETRY_DELAY_MS = 24 * 60 * 60 * 1000;

function refuseIfLocked(user) {
  if (user.identityBlocked) {
    throw new HttpError(
      403,
      'IDENTITY_BLOCKED',
      'La vérification de votre identité est bloquée. Contactez le support.',
    );
  }
  if (user.identityRetryAt && user.identityRetryAt > new Date()) {
    throw new HttpError(
      429,
      'IDENTITY_RETRY_LATER',
      `Nouvelle demande possible à partir du ${user.identityRetryAt.toLocaleString('fr-FR', { timeZone: 'Africa/Tunis' })}.`,
    );
  }
  if (LOCKED.includes(user.identityStatus)) {
    throw new HttpError(
      409,
      'IDENTITY_LOCKED',
      user.identityStatus === 'PENDING'
        ? 'Votre identité est en cours de vérification.'
        : 'Votre identité est déjà vérifiée.',
    );
  }
}

/** Analyse par l'IA. Moteur en panne : 503, l'utilisateur pourra réessayer. */
async function analyze(buffer) {
  try {
    return await faceEngine.analyze(buffer);
  } catch (err) {
    console.error('Analyse du visage', err);
    throw new HttpError(
      503,
      'FACE_ENGINE_UNAVAILABLE',
      "L'analyse du visage est indisponible. Réessayez dans un instant.",
    );
  }
}

/** Lecture de la pièce par l'OCR. En panne, la demande continue : le numéro
 * ne pourra pas être confirmé et l'administrateur décidera. */
async function readDocument(buffer, documentType, face = {}) {
  try {
    return await documentReader.read(buffer, documentType, {
      box: face.box,
      rotation: face.rotation,
    });
  } catch (err) {
    console.error('Lecture de la pièce', err);
    return null;
  }
}

/**
 * Recto : il porte la photo du titulaire. Sans visage, il est refusé tout de
 * suite ; sinon l'IA lit la pièce (numéro, nom, naissance) pour pré-remplir
 * la demande et la vérifier.
 */
async function checkFront(buffer, documentType) {
  const face = await analyze(buffer);
  if (face.faces === 0) {
    throw new HttpError(
      422,
      'NO_FACE_ON_DOCUMENT',
      'Aucun visage détecté sur la pièce. Reprenez la photo à plat, bien éclairée et sans reflet.',
    );
  }
  return readDocument(buffer, documentType, face);
}

/**
 * Verso. Une seule règle bloquante : aucun visage (sinon c'est un recto,
 * peut-être celui d'une autre carte). Le reste (code-barres ou date de
 * délivrance de la CIN, catégories du permis) est un indice : reconnu,
 * l'IA peut valider seule ; sinon la demande va à l'administrateur.
 * Vérifié à l'envoi de la photo et de nouveau à la demande.
 * Renvoie true (reconnu), false (pas reconnu) ou null (lecture en panne).
 */
async function checkBack(buffer, documentType) {
  if ((await analyze(buffer)).faces > 0) {
    throw new HttpError(
      422,
      'BACK_HAS_FACE',
      'Cette photo montre un recto. Photographiez le verso de la même pièce.',
    );
  }
  try {
    return (await documentReader.readBack(buffer, documentType)).recognized;
  } catch (err) {
    console.error('Lecture du verso', err);
    return null;
  }
}

async function saveFront(req, file, documentType, extracted) {
  const name = await saveImage(file, IDENTITY_FOLDER);
  const user = await prisma.user.update({
    where: { id: req.user.id },
    data: {
      cinFrontFile: name,
      identityDocument: documentType,
      identityExtracted: extracted ?? Prisma.DbNull,
    },
    include: withCompany,
  });
  await deleteImage(req.user.cinFrontFile, IDENTITY_FOLDER);
  return user;
}

router.put('/me/identity/:side', requireAuth, ai, singleImage('photo'), async (req, res) => {
  const { side } = identitySideParams.parse(req.params);
  const { documentType } = documentTypeSchema.parse(req.body ?? {});
  refuseIfLocked(req.user);
  assertImage(req.file);
  if (side === 'front') {
    const extracted = await checkFront(req.file.buffer, documentType);
    const user = await saveFront(req, req.file, documentType, extracted);
    return res.json({ user: publicUser(user) });
  }
  await checkBack(req.file.buffer, documentType);
  const name = await saveImage(req.file, IDENTITY_FOLDER);
  const user = await prisma.user.update({
    where: { id: req.user.id },
    data: { cinBackFile: name },
    include: withCompany,
  });
  await deleteImage(req.user.cinBackFile, IDENTITY_FOLDER);
  res.json({ user: publicUser(user) });
});

// Permis déjà enregistré dans le profil : sa photo sert de recto, sans
// nouvelle prise de vue.
router.post('/me/identity/front/from-license', requireAuth, ai, async (req, res) => {
  refuseIfLocked(req.user);
  if (!req.user.licensePhotoFile) {
    throw new HttpError(
      400,
      'LICENSE_PHOTO_MISSING',
      'Aucune photo de permis dans votre profil.',
    );
  }
  const buffer = await readFile(imagePath(req.user.licensePhotoFile, 'users'));
  const extracted = await checkFront(buffer, 'LICENSE');
  const extension = req.user.licensePhotoFile.split('.').pop();
  const user = await saveFront(
    req,
    { buffer, originalname: `permis.${extension}` },
    'LICENSE',
    extracted,
  );
  res.json({ user: publicUser(user) });
});

// Le titulaire et les administrateurs seulement.
router.get('/:id/identity/:side', requireAuth, async (req, res, next) => {
  // « attempts » : l'historique, route suivante.
  if (req.params.side === 'attempts') return next('route');
  const { id } = idParams.parse({ id: req.params.id });
  const { side } = identityFileParams.parse({ side: req.params.side });
  if (req.user.id !== id && req.user.role !== 'ADMIN') {
    throw new HttpError(403, 'FORBIDDEN', 'Accès refusé.');
  }
  const user = await prisma.user.findUnique({ where: { id } });
  const file = user?.[FILES[side]];
  if (!file) throw new HttpError(404, 'NOT_FOUND', 'Aucune photo.');
  res.set('Cache-Control', 'private, max-age=86400');
  res.sendFile(imagePath(file, IDENTITY_FOLDER));
});

// Vérification du visage (« liveness ») : le serveur tire l'ordre des
// consignes au hasard, l'application prend une photo par consigne. Une photo
// imprimée ou un écran ne tourne pas la tête dans l'ordre demandé.
router.post('/me/identity/liveness', requireAuth, ai, async (req, res) => {
  refuseIfLocked(req.user);
  // Loi n° 2004-63 : le visage est une donnée sensible, accord explicite à
  // chaque vérification, daté.
  biometricConsentSchema.parse(req.body ?? {});
  await prisma.user.update({
    where: { id: req.user.id },
    data: { identityBiometricConsentAt: new Date() },
  });
  const turns = randomInt(2) === 0 ? TURNS : [...TURNS].reverse();
  const steps = ['center', ...turns];
  res.json({ token: signLivenessChallenge(req.user.id, steps), steps });
});

const livenessError = (code, message) => new HttpError(422, code, message);

/** Contrôles sur les trois photos analysées, dans l'ordre du défi. */
function checkLiveness(steps, results) {
  results.forEach((r, index) => {
    if (r.faces === 0) {
      throw livenessError(
        'LIVENESS_NO_FACE',
        `Visage introuvable sur la photo ${index + 1}. Placez votre visage dans l'ovale.`,
      );
    }
    if (r.faces > 1) {
      throw livenessError(
        'LIVENESS_MANY_FACES',
        'Une seule personne doit être devant la caméra.',
      );
    }
  });
  const at = (step) => results[steps.indexOf(step)];
  const [center, left, right] = [at('center'), at('left'), at('right')];
  if (Math.abs(center.yaw) > CENTER_MAX_YAW) {
    throw livenessError(
      'LIVENESS_NOT_CENTERED',
      'Regardez la caméra bien de face pour la première photo.',
    );
  }
  // Le sens exact dépend du miroir de la caméra : on exige deux rotations
  // nettes, de sens opposés.
  const turned =
    Math.abs(left.yaw) >= TURN_MIN_YAW &&
    Math.abs(right.yaw) >= TURN_MIN_YAW &&
    Math.sign(left.yaw) !== Math.sign(right.yaw);
  if (!turned) {
    throw livenessError(
      'LIVENESS_NO_TURN',
      'Tournez davantage la tête quand la consigne le demande.',
    );
  }
  for (const other of [left, right]) {
    if (similarity(center.descriptor, other.descriptor) < SAME_PERSON_MATCH) {
      throw livenessError(
        'LIVENESS_DIFFERENT_FACES',
        'Les photos ne montrent pas la même personne.',
      );
    }
  }
}

router.post(
  '/me/identity/selfie',
  requireAuth,
  ai,
  imageArray('frames', 3),
  async (req, res) => {
    refuseIfLocked(req.user);
    const { token } = livenessFramesSchema.parse(req.body ?? {});
    let challenge;
    try {
      challenge = verifyLivenessChallenge(token);
    } catch {
      throw livenessError(
        'LIVENESS_EXPIRED',
        'Le défi a expiré. Recommencez la vérification du visage.',
      );
    }
    if (challenge.sub !== req.user.id) {
      throw new HttpError(403, 'FORBIDDEN', 'Accès refusé.');
    }
    const frames = req.files ?? [];
    if (frames.length !== challenge.steps.length) {
      throw new HttpError(
        400,
        'FRAMES_REQUIRED',
        'Une photo par consigne est attendue.',
      );
    }
    frames.forEach(assertImage);

    // Une image après l'autre : le moteur travaille sur un seul fil.
    const results = [];
    for (const frame of frames) results.push(await analyze(frame.buffer));
    checkLiveness(challenge.steps, results);

    // Seule la photo de face est gardée, jusqu'à la décision.
    const name = await saveImage(
      frames[challenge.steps.indexOf('center')],
      IDENTITY_FOLDER,
    );
    const user = await prisma.user.update({
      where: { id: req.user.id },
      data: { identitySelfieFile: name, identityLivenessAt: new Date() },
      include: withCompany,
    });
    await deleteImage(req.user.identitySelfieFile, IDENTITY_FOLDER);
    res.json({ user: publicUser(user) });
  },
);

/** Ressemblance entre la photo de la pièce et le visage, ou null quand l'IA
 * ne peut pas conclure : un administrateur décidera. */
async function faceMatch(user, document) {
  try {
    const selfie = await readFile(
      imagePath(user.identitySelfieFile, IDENTITY_FOLDER),
    );
    const a = await faceEngine.analyze(document);
    const b = await faceEngine.analyze(selfie);
    if (a.faces === 0 || b.faces === 0) return { match: null, face: a };
    return { match: similarity(a.descriptor, b.descriptor), face: a };
  } catch (err) {
    console.error('Comparaison des visages', err);
    return { match: null };
  }
}

const compact = (value) => value.toUpperCase().replace(/[^A-Z0-9]/g, '');

/**
 * Contrôles de la pièce, d'après ce que l'OCR a lu. Chaque contrôle vaut
 * true, false, ou null quand la pièce n'a pas pu être lue.
 */
function documentChecks(user, number, extracted, documentType) {
  // Passeport : plusieurs lectures possibles, validées par le chiffre de contrôle.
  const readings = extracted?.numberCandidates?.length
    ? extracted.numberCandidates
    : [extracted?.number].filter(Boolean);
  const typed = compact(number);
  const matching = readings.find((reading) => compact(reading) === typed);
  const today = new Date().toISOString().slice(0, 10);
  // Contrôle croisé : même date de naissance sur le permis du profil.
  const licenseBirth =
    documentType !== 'LICENSE' ? user.licenseReading?.birthDate : null;
  return {
    numberRead: matching ?? readings[0] ?? null,
    numberMatches: readings.length ? Boolean(matching) : null,
    nameMatches: nameCheck(user, extracted),
    notExpired: extracted?.expiresAt ? extracted.expiresAt >= today : null,
    birthDateMatches:
      extracted?.birthDate && licenseBirth
        ? extracted.birthDate === licenseBirth
        : null,
  };
}

/**
 * Nom du compte sur la pièce. Passeport : nom et prénom dans la MRZ. CIN :
 * nom et prénom lus en arabe, comparés par leurs consonnes (الطرابلسي ≈
 * Trabelsi). null si rien n'a pu être lu.
 */
function nameCheck(user, extracted) {
  if (extracted?.nameLine) {
    return (
      nameInMrz(extracted.nameLine, user.lastName) &&
      nameInMrz(extracted.nameLine, user.firstName)
    );
  }
  if (extracted?.lastName) return sameName(extracted.lastName, user.lastName);
  // Prénoms composés : la carte peut en porter plus que le compte.
  const firstWord = (value) => value?.split(/\s+/)[0];
  const results = [
    arabicMatchesLatin(extracted?.lastNameAr, user.lastName),
    arabicMatchesLatin(extracted?.firstNameAr, user.firstName) ||
      arabicMatchesLatin(firstWord(extracted?.firstNameAr), user.firstName),
  ].filter((result) => result !== null);
  return results.length ? results.every(Boolean) : null;
}

router.post('/me/identity/submit', requireAuth, ai, async (req, res) => {
  const { documentType, number } = identitySubmitSchema.parse(req.body);
  refuseIfLocked(req.user);
  const needsBack = documentType !== 'PASSPORT';
  if (!req.user.cinFrontFile || (needsBack && !req.user.cinBackFile)) {
    throw new HttpError(
      400,
      'IDENTITY_PHOTOS_REQUIRED',
      needsBack
        ? 'Ajoutez le recto et le verso de la pièce.'
        : 'Ajoutez la page photo du passeport.',
    );
  }
  const livenessAt = req.user.identityLivenessAt?.getTime() ?? 0;
  if (
    !req.user.identitySelfieFile ||
    Date.now() - livenessAt > LIVENESS_VALIDITY_MS
  ) {
    throw new HttpError(
      400,
      'SELFIE_REQUIRED',
      'Faites la vérification du visage avant d’envoyer la demande.',
    );
  }

  const front = await readFile(
    imagePath(req.user.cinFrontFile, IDENTITY_FOLDER),
  );
  const { match, face } = await faceMatch(req.user, front);
  // Pièce lue pour un autre type (choix changé après la photo) : on relit.
  let extracted = req.user.identityExtracted;
  if (extracted?.type !== documentType) {
    extracted = await readDocument(front, documentType, face);
  }
  // Verso revérifié : une photo envoyée avant une mise à jour des règles,
  // ou d'un autre type de pièce, ne passe pas.
  const backRecognized = needsBack
    ? await checkBack(
        await readFile(imagePath(req.user.cinBackFile, IDENTITY_FOLDER)),
        documentType,
      )
    : null;
  const checks = {
    ...documentChecks(req.user, number, extracted, documentType),
    backRecognized,
  };
  // L'IA ne valide seule que si tout concorde : visage, numéro lu sur la
  // pièce, verso reconnu, et pour un passeport le nom et la validité.
  const automatic =
    match !== null &&
    match >= AUTO_APPROVE_MATCH &&
    checks.numberMatches === true &&
    checks.nameMatches !== false &&
    checks.notExpired !== false &&
    (!needsBack || backRecognized === true);
  const now = new Date();
  const decision = automatic
    ? {
        // Visage reconnu : validée par l'IA, la photo du visage est effacée.
        identityStatus: 'VERIFIED',
        identityReviewedAt: now,
        identityAutoVerified: true,
        identitySelfieFile: null,
      }
    : {
        // Doute : un administrateur compare les photos.
        identityStatus: 'PENDING',
        identityReviewedAt: null,
        identityAutoVerified: false,
      };
  const user = await prisma.user
    .update({
      where: { id: req.user.id },
      data: {
        cinNumber: number,
        identityDocument: documentType,
        identityFaceMatch: match,
        identityExtracted: extracted ?? Prisma.DbNull,
        identityChecks: checks,
        identitySubmittedAt: now,
        identityReviewerId: null,
        identityRejectionReason: null,
        ...decision,
      },
      include: withCompany,
    })
    .catch((err) => {
      throw isUniqueViolation(err)
        ? new HttpError(409, 'CIN_IN_USE', 'Ce numéro de pièce est déjà utilisé.')
        : err;
    });
  await prisma.identityAttempt.create({
    data: {
      userId: req.user.id,
      documentType,
      number,
      faceMatch: match,
      checks,
      outcome: automatic ? 'AUTO_VERIFIED' : 'PENDING',
      decidedAt: automatic ? now : null,
    },
  });
  if (automatic) {
    await deleteImage(req.user.identitySelfieFile, IDENTITY_FOLDER);
    notifyDecision(user);
  }
  res.json({ user: publicUser(user) });
});

// ---------------------------------------------------------------------------
// File de vérification (administrateurs)

const DECISION_TEXTS = {
  FR: {
    approved: 'Mon Constat : votre identité est vérifiée. Vous pouvez signer vos constats.',
    rejected: (reason) =>
      `Mon Constat : votre vérification d'identité a été refusée. Motif : ${reason}. Vous pouvez envoyer de nouvelles photos depuis votre profil.`,
  },
  EN: {
    approved: 'Mon Constat: your identity is verified. You can now sign your accident reports.',
    rejected: (reason) =>
      `Mon Constat: your identity check was declined. Reason: ${reason}. You can send new photos from your profile.`,
  },
  AR: {
    approved: 'Mon Constat: تم التحقق من هويتك. يمكنك الآن توقيع المعاينات.',
    rejected: (reason) =>
      `Mon Constat: تم رفض التحقق من هويتك. السبب: ${reason}. يمكنك إرسال صور جديدة من ملفك الشخصي.`,
  },
};

function notifyDecision(user) {
  const t = DECISION_TEXTS[user.language] ?? DECISION_TEXTS.FR;
  const text =
    user.identityStatus === 'VERIFIED'
      ? t.approved
      : t.rejected(user.identityRejectionReason);
  // Sans attendre : la décision est enregistrée même si l'envoi échoue.
  void Promise.allSettled([
    notifier.sendToPhone(user.phone, text),
    notifier.sendMail(user.email, 'Mon Constat', text),
  ]).then((results) => {
    for (const r of results) {
      if (r.status === 'rejected') console.error('Décision d’identité', r.reason);
    }
  });
}

router.get('/identity/pending', requireAuth, requireRole('ADMIN'), async (_req, res) => {
  const users = await prisma.user.findMany({
    where: { identityStatus: 'PENDING' },
    include: withCompany,
    orderBy: { identitySubmittedAt: 'asc' },
  });
  res.json({ items: users.map(publicUser) });
});

async function decide(req, data, attempt = {}) {
  const { id } = idParams.parse(req.params);
  const before = await prisma.user.findUnique({
    where: { id },
    select: {
      identitySelfieFile: true,
      cinFrontFile: true,
      cinBackFile: true,
      identityRefusals: true,
    },
  });
  if (typeof data === 'function') data = data(before);
  const { count } = await prisma.user.updateMany({
    where: { id, identityStatus: 'PENDING' },
    data: {
      ...data,
      identityReviewedAt: new Date(),
      identityReviewerId: req.user.id,
      identityAutoVerified: false,
      identitySelfieFile: null,
    },
  });
  if (count === 0) {
    throw new HttpError(
      409,
      'IDENTITY_NOT_PENDING',
      "Cette demande n'est pas en attente de vérification.",
    );
  }
  // Décision prise : la photo du visage n'a plus de raison d'être gardée.
  await deleteImage(before?.identitySelfieFile, IDENTITY_FOLDER);
  // Refus : les photos de la pièce partent aussi, il faudra en reprendre.
  if (data.identityStatus === 'REJECTED') {
    await deleteImage(before?.cinFrontFile, IDENTITY_FOLDER);
    await deleteImage(before?.cinBackFile, IDENTITY_FOLDER);
  }
  // La demande en attente la plus récente reçoit la décision.
  const pending = await prisma.identityAttempt.findFirst({
    where: { userId: id, outcome: 'PENDING' },
    orderBy: { createdAt: 'desc' },
  });
  if (pending) {
    await prisma.identityAttempt.update({
      where: { id: pending.id },
      data: {
        outcome: data.identityStatus,
        decidedAt: new Date(),
        ...attempt,
      },
    });
  }
  const user = await prisma.user.findUnique({
    where: { id },
    include: withCompany,
  });
  notifyDecision(user);
  return user;
}

router.post('/:id/identity/approve', requireAuth, requireRole('ADMIN'), async (req, res) => {
  const user = await decide(req, { identityStatus: 'VERIFIED' });
  res.json({ user: publicUser(user) });
});

/**
 * Refus. Un refus grave (visage différent, pièce non valable) bloque toute
 * nouvelle demande ; sinon 24 h d'attente, et blocage au 3e refus. Les
 * photos de la pièce sont effacées : il faudra les reprendre.
 */
router.post('/:id/identity/reject', requireAuth, requireRole('ADMIN'), async (req, res) => {
  const { reason, severe } = rejectIdentitySchema.parse(req.body);
  const user = await decide(
    req,
    (before) => {
      const refusals = (before?.identityRefusals ?? 0) + 1;
      const blocked = severe || refusals >= MAX_REFUSALS;
      return {
        identityStatus: 'REJECTED',
        identityRejectionReason: reason,
        identityRefusals: refusals,
        identityBlocked: blocked,
        identityRetryAt: blocked ? null : new Date(Date.now() + RETRY_DELAY_MS),
        cinFrontFile: null,
        cinBackFile: null,
        identityExtracted: Prisma.DbNull,
        identityLivenessAt: null,
      };
    },
    { reason, severe },
  );
  res.json({ user: publicUser(user) });
});

// Débloquer : l'administrateur rend une nouvelle demande possible tout de suite.
router.post('/:id/identity/unblock', requireAuth, requireRole('ADMIN'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  const user = await prisma.user
    .update({
      where: { id },
      data: { identityBlocked: false, identityRefusals: 0, identityRetryAt: null },
      include: withCompany,
    })
    .catch(() => {
      throw new HttpError(404, 'NOT_FOUND', 'Compte introuvable.');
    });
  res.json({ user: publicUser(user) });
});

// Historique des demandes d'un compte (administrateurs).
router.get('/:id/identity/attempts', requireAuth, requireRole('ADMIN'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  const attempts = await prisma.identityAttempt.findMany({
    where: { userId: id },
    orderBy: { createdAt: 'desc' },
  });
  res.json({ items: attempts.map(({ userId: _, ...attempt }) => attempt) });
});

export default router;
