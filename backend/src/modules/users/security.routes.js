import { Router } from 'express';

import { HttpError, isUniqueViolation } from '../../lib/errors.js';
import { notifier } from '../../lib/notifier.js';
import { prisma } from '../../lib/prisma.js';
import {
  deleteImage,
  imagePath,
  saveImage,
  singleImage,
} from '../../lib/uploads.js';
import { requireAuth, requireRole } from '../../middleware/auth.js';
import {
  publicUser,
  revokeOtherSessions,
  revokeSession,
  withCompany,
} from './auth.service.js';
import {
  cinSchema,
  idParams,
  identitySideParams,
  rejectIdentitySchema,
  sessionParams,
} from './users.schemas.js';

// Module 1 : sécurité du compte (appareils, historique) et vérification
// d'identité par la CIN. Monté sur /api/users avec les autres routes du module.
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
// Vérification d'identité (CIN)

const IDENTITY_FOLDER = 'identity';
const SIDES = { front: 'cinFrontFile', back: 'cinBackFile' };
const LOCKED = ['PENDING', 'VERIFIED'];

function refuseIfLocked(user) {
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

router.put('/me/identity/:side', requireAuth, singleImage('photo'), async (req, res) => {
  const { side } = identitySideParams.parse(req.params);
  refuseIfLocked(req.user);
  const column = SIDES[side];
  const name = await saveImage(req.file, IDENTITY_FOLDER);
  const user = await prisma.user.update({
    where: { id: req.user.id },
    data: { [column]: name },
    include: withCompany,
  });
  await deleteImage(req.user[column], IDENTITY_FOLDER);
  res.json({ user: publicUser(user) });
});

// Le titulaire et les administrateurs seulement.
router.get('/:id/identity/:side', requireAuth, async (req, res) => {
  const { id } = idParams.parse({ id: req.params.id });
  const { side } = identitySideParams.parse({ side: req.params.side });
  if (req.user.id !== id && req.user.role !== 'ADMIN') {
    throw new HttpError(403, 'FORBIDDEN', 'Accès refusé.');
  }
  const user = await prisma.user.findUnique({ where: { id } });
  const file = user?.[SIDES[side]];
  if (!file) throw new HttpError(404, 'NOT_FOUND', 'Aucune photo.');
  res.set('Cache-Control', 'private, max-age=86400');
  res.sendFile(imagePath(file, IDENTITY_FOLDER));
});

router.post('/me/identity/submit', requireAuth, async (req, res) => {
  const { cinNumber } = cinSchema.parse(req.body);
  refuseIfLocked(req.user);
  if (!req.user.cinFrontFile || !req.user.cinBackFile) {
    throw new HttpError(
      400,
      'IDENTITY_PHOTOS_REQUIRED',
      'Ajoutez le recto et le verso de votre CIN.',
    );
  }
  const user = await prisma.user
    .update({
      where: { id: req.user.id },
      data: {
        cinNumber,
        identityStatus: 'PENDING',
        identitySubmittedAt: new Date(),
        identityReviewedAt: null,
        identityReviewerId: null,
        identityRejectionReason: null,
      },
      include: withCompany,
    })
    .catch((err) => {
      throw isUniqueViolation(err)
        ? new HttpError(409, 'CIN_IN_USE', 'Ce numéro de CIN est déjà utilisé.')
        : err;
    });
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

async function decide(req, data) {
  const { id } = idParams.parse(req.params);
  const { count } = await prisma.user.updateMany({
    where: { id, identityStatus: 'PENDING' },
    data: {
      ...data,
      identityReviewedAt: new Date(),
      identityReviewerId: req.user.id,
    },
  });
  if (count === 0) {
    throw new HttpError(
      409,
      'IDENTITY_NOT_PENDING',
      "Cette demande n'est pas en attente de vérification.",
    );
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

router.post('/:id/identity/reject', requireAuth, requireRole('ADMIN'), async (req, res) => {
  const { reason } = rejectIdentitySchema.parse(req.body);
  const user = await decide(req, {
    identityStatus: 'REJECTED',
    identityRejectionReason: reason,
  });
  res.json({ user: publicUser(user) });
});

export default router;
