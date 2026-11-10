import { Prisma } from '@prisma/client';
import { Router } from 'express';

import {
  HttpError,
  isForeignKeyViolation,
  isUniqueViolation,
} from '../../lib/errors.js';
import { faceEngine } from '../../lib/face.js';
import { documentReader, sameName } from '../../lib/ocr.js';
import { prisma } from '../../lib/prisma.js';
import {
  deleteImage,
  imagePath,
  saveImage,
  singleImage,
} from '../../lib/uploads.js';
import { requireAuth, requireRole } from '../../middleware/auth.js';
import { aiQuota } from '../../middleware/quota.js';
import {
  hashPassword,
  publicUser,
  revokeSessions,
  withCompany,
} from './auth.service.js';
import {
  adminLicenseSchema,
  createAgentSchema,
  idParams,
  rejectLicenseSchema,
  listUsersQuery,
  updateProfileSchema,
  updateRoleSchema,
  updateStatusSchema,
} from './users.schemas.js';

// Module 1 : profil et administration des comptes.
const router = Router();

function rethrowConflict(err) {
  if (isUniqueViolation(err)) {
    throw new HttpError(
      409,
      'ALREADY_EXISTS',
      'E-mail ou téléphone déjà utilisé.',
    );
  }
  if (isForeignKeyViolation(err)) {
    throw new HttpError(400, 'COMPANY_NOT_FOUND', 'Compagnie introuvable.');
  }
  throw err;
}

// Un administrateur ne peut pas se retirer ses propres droits :
// la plateforme garde toujours au moins un administrateur actif.
function refuseSelfChange(req, id) {
  if (req.user.id === id) {
    throw new HttpError(
      409,
      'SELF_CHANGE',
      'Impossible de modifier votre propre rôle ou statut.',
    );
  }
}

router.use(requireAuth);

router.get('/me', (req, res) => {
  res.json({ user: publicUser(req.user) });
});

router.patch('/me', async (req, res) => {
  const { licenseIssuedAt, ...data } = updateProfileSchema.parse(req.body);
  if (licenseIssuedAt !== undefined) {
    data.licenseIssuedAt = licenseIssuedAt ? new Date(licenseIssuedAt) : null;
  }
  // Un nouveau numéro doit être vérifié à nouveau.
  if (data.phone && data.phone !== req.user.phone) data.phoneVerifiedAt = null;
  // Numéro de permis tapé à la main, différent de celui lu sur la photo :
  // un administrateur vérifie.
  const read = req.user.licenseReading?.number;
  const compact = (value) => value?.replace(/[\s/]/g, '');
  if (data.licenseNumber && read && compact(data.licenseNumber) !== compact(read)) {
    data.licenseStatus = 'TO_REVIEW';
    data.licenseChecks = {
      ...(req.user.licenseChecks ?? {}),
      numberMatchesReading: false,
    };
  }

  const user = await prisma.user
    .update({ where: { id: req.user.id }, data, include: withCompany })
    .catch(rethrowConflict);
  res.json({ user: publicUser(user) });
});

// Photo de profil et photo du permis : champ multipart `photo`.
const PHOTOS = {
  photo: 'photoFile',
  'license-photo': 'licensePhotoFile',
};
const PHOTO_FOLDER = 'users';
// La photo du permis passe par l'OCR : même quota que la vérification d'identité.
const ocrQuota = aiQuota({ max: 30 });

/**
 * Lecture du permis par l'OCR. La photo du titulaire donne le sens de la
 * carte : une photo prise de travers est remise à l'endroit. En panne :
 * null, le formulaire reste à remplir.
 */
async function readLicense(buffer) {
  try {
    const face = await faceEngine.analyze(buffer);
    const read = await documentReader.read(buffer, 'LICENSE', face);
    const { number, categories, issuedAt, expiresAt, birthDate } = read;
    const { lastName, firstName, cinNumber, kind } = read;
    // Un passeport ou une CIN n'est pas un permis : refusé, rien n'est
    // enregistré. Dans le doute (kind null), on laisse passer.
    if (kind && kind !== 'LICENSE') {
      throw new HttpError(
        422,
        'NOT_A_LICENSE',
        kind === 'PASSPORT'
          ? 'Cette photo montre un passeport, pas un permis de conduire.'
          : "Cette photo montre une carte d'identité, pas un permis de conduire.",
      );
    }
    return {
      number,
      categories,
      issuedAt,
      expiresAt,
      birthDate,
      lastName,
      firstName,
      cinNumber,
    };
  } catch (err) {
    if (err instanceof HttpError) throw err;
    console.error('Lecture du permis', err);
    return null;
  }
}

/**
 * Contrôles croisés du permis avec le compte : nom du titulaire, et date de
 * naissance et numéro de CIN de la pièce d'identité. null : pas comparable.
 */
function licenseChecks(user, extracted) {
  const identity = user.identityExtracted;
  const compare = (a, b) => (a && b ? a === b : null);
  const names = [
    extracted?.lastName && sameName(extracted.lastName, user.lastName),
    extracted?.firstName &&
      sameName(extracted.firstName.split(' ')[0], user.firstName.split(' ')[0]),
  ].filter((result) => result !== undefined && result !== null && result !== '');
  return {
    nameMatchesAccount: names.length ? names.every(Boolean) : null,
    birthDateMatchesIdentity: compare(extracted?.birthDate, identity?.birthDate),
    cinMatchesIdentity:
      user.identityDocument === 'CIN'
        ? compare(extracted?.cinNumber, user.cinNumber)
        : null,
  };
}

/**
 * Décision sur le permis selon les contrôles croisés :
 * - deux contrôles ou plus en échec : ce n'est pas le permis du titulaire
 *   (celui d'un proche, par exemple), refusé, rien n'est enregistré ;
 * - un seul en échec, ou rien de comparable (photo illisible, identité pas
 *   encore vérifiée) : enregistré, à vérifier par un administrateur ;
 * - sinon : validé par l'IA.
 * Un seul écart peut venir d'une erreur de lecture, deux ne le peuvent pas.
 */
function licenseDecision(checks) {
  const results = Object.values(checks);
  const failed = results.filter((result) => result === false).length;
  if (failed >= 2) {
    throw new HttpError(
      422,
      'LICENSE_NOT_YOURS',
      "Ce permis ne semble pas être le vôtre : le nom, la date de naissance ou le numéro de CIN ne correspondent pas à votre compte. Il n'a pas été enregistré.",
    );
  }
  const confirmed = results.some((result) => result === true);
  return failed === 0 && confirmed ? 'VERIFIED' : 'TO_REVIEW';
}

// Ce qui part avec le permis : photo, lecture, contrôles et décision.
const LICENSE_CLEARED = {
  licensePhotoFile: null,
  licenseReading: Prisma.DbNull,
  licenseChecks: Prisma.DbNull,
  licenseStatus: null,
  licenseRejectionReason: null,
  licenseReviewedAt: null,
};

for (const [route, column] of Object.entries(PHOTOS)) {
  router.put(`/me/${route}`, ocrQuota, singleImage('photo'), async (req, res) => {
    const isLicense = route === 'license-photo';
    // Permis : l'IA lit la carte (numéro, catégories, dates) pour remplir le
    // formulaire. L'utilisateur vérifie avant d'enregistrer.
    const extracted = isLicense ? await readLicense(req.file.buffer) : undefined;
    // Contrôles croisés : le permis doit être au nom du compte, avec la date
    // de naissance et le numéro de CIN de la pièce d'identité. Refusé avant
    // d'enregistrer quoi que ce soit si ce n'est clairement pas le sien.
    const checks = isLicense ? licenseChecks(req.user, extracted) : undefined;
    const status = isLicense ? licenseDecision(checks) : undefined;
    const name = await saveImage(req.file, PHOTO_FOLDER);
    const user = await prisma.user.update({
      where: { id: req.user.id },
      data: {
        [column]: name,
        ...(isLicense && {
          licenseReading: extracted ?? Prisma.DbNull,
          licenseChecks: checks,
          licenseStatus: status,
          licenseRejectionReason: null,
          licenseReviewedAt: status === 'VERIFIED' ? new Date() : null,
        }),
      },
      include: withCompany,
    });
    await deleteImage(req.user[column], PHOTO_FOLDER);
    res.json({
      user: publicUser(user),
      extracted: extracted && { ...extracted, ...checks },
    });
  });

  router.delete(`/me/${route}`, async (req, res) => {
    const user = await prisma.user.update({
      where: { id: req.user.id },
      data: route === 'license-photo' ? LICENSE_CLEARED : { [column]: null },
      include: withCompany,
    });
    await deleteImage(req.user[column], PHOTO_FOLDER);
    res.json({ user: publicUser(user) });
  });

  // Le titulaire et les administrateurs seulement. Le module 5 pourra ouvrir
  // l'accès à l'agent chargé du dossier.
  router.get(`/:id/${route}`, async (req, res) => {
    const { id } = idParams.parse(req.params);
    if (req.user.id !== id && req.user.role !== 'ADMIN') {
      throw new HttpError(403, 'FORBIDDEN', 'Accès refusé.');
    }
    const user = await prisma.user.findUnique({ where: { id } });
    if (!user?.[column]) {
      throw new HttpError(404, 'NOT_FOUND', 'Aucune photo.');
    }
    res.set('Cache-Control', 'private, max-age=86400');
    res.sendFile(imagePath(user[column], PHOTO_FOLDER));
  });
}

// Tout ce qui suit est réservé aux administrateurs.
router.use(requireRole('ADMIN'));

router.get('/', async (req, res) => {
  const { q, role, page, pageSize } = listUsersQuery.parse(req.query);
  const where = {
    // Les comptes supprimés (anonymisés) ne sont plus listés.
    deletedAt: null,
    ...(role && { role }),
    ...(q && {
      OR: ['firstName', 'lastName', 'email', 'phone'].map((field) => ({
        [field]: { contains: q, mode: 'insensitive' },
      })),
    }),
  };
  const [items, total] = await prisma.$transaction([
    prisma.user.findMany({
      where,
      include: withCompany,
      orderBy: [{ lastName: 'asc' }, { firstName: 'asc' }, { id: 'asc' }],
      skip: (page - 1) * pageSize,
      take: pageSize,
    }),
    prisma.user.count({ where }),
  ]);
  res.json({ items: items.map(publicUser), total, page, pageSize });
});

// Permis à vérifier : un contrôle croisé a échoué, ou rien n'a pu être lu.
router.get('/licenses/review', async (_req, res) => {
  const users = await prisma.user.findMany({
    where: { licenseStatus: 'TO_REVIEW', deletedAt: null },
    include: withCompany,
    orderBy: { updatedAt: 'asc' },
  });
  res.json({ items: users.map(publicUser) });
});

// Dossier complet d'un compte : identité et permis, même validés par l'IA.
router.get('/:id', async (req, res) => {
  const { id } = idParams.parse(req.params);
  const user = await prisma.user.findUnique({
    where: { id },
    include: withCompany,
  });
  if (!user || user.deletedAt) {
    throw new HttpError(404, 'NOT_FOUND', 'Compte introuvable.');
  }
  res.json({ user: publicUser(user) });
});

/** Met à jour le permis d'un compte ; renvoie aussi l'ancienne photo. */
async function updateLicense(req, data) {
  const { id } = idParams.parse(req.params);
  const before = await prisma.user.findUnique({ where: { id } });
  if (!before || before.deletedAt) {
    throw new HttpError(404, 'NOT_FOUND', 'Compte introuvable.');
  }
  const user = await prisma.user.update({
    where: { id },
    data,
    include: withCompany,
  });
  return { user, oldPhoto: before.licensePhotoFile };
}

router.post('/:id/license/approve', async (req, res) => {
  const { user } = await updateLicense(req, {
    licenseStatus: 'VERIFIED',
    licenseRejectionReason: null,
    licenseReviewedAt: new Date(),
  });
  res.json({ user: publicUser(user) });
});

// Refus : la photo et les informations du permis sont effacées ; le
// conducteur voit le motif et en ajoute un autre depuis son profil.
router.post('/:id/license/reject', async (req, res) => {
  const { reason } = rejectLicenseSchema.parse(req.body);
  const { user, oldPhoto } = await updateLicense(req, {
    ...LICENSE_CLEARED,
    licenseNumber: null,
    licenseCategory: null,
    licenseIssuedAt: null,
    licenseStatus: 'REJECTED',
    licenseRejectionReason: reason,
    licenseReviewedAt: new Date(),
  });
  await deleteImage(oldPhoto, PHOTO_FOLDER);
  res.json({ user: publicUser(user) });
});

// Correction par un administrateur (numéro mal lu, catégorie oubliée).
router.patch('/:id/license', async (req, res) => {
  const { licenseIssuedAt, ...data } = adminLicenseSchema.parse(req.body);
  if (licenseIssuedAt !== undefined) {
    data.licenseIssuedAt = licenseIssuedAt ? new Date(licenseIssuedAt) : null;
  }
  const { user } = await updateLicense(req, data);
  res.json({ user: publicUser(user) });
});

// Suppression complète du permis d'un compte.
router.delete('/:id/license', async (req, res) => {
  const { user, oldPhoto } = await updateLicense(req, {
    ...LICENSE_CLEARED,
    licenseNumber: null,
    licenseCategory: null,
    licenseIssuedAt: null,
  });
  await deleteImage(oldPhoto, PHOTO_FOLDER);
  res.json({ user: publicUser(user) });
});

router.post('/agents', async (req, res) => {
  const { password, language: _, ...data } = createAgentSchema.parse(
    req.body,
  );
  const user = await prisma.user
    .create({
      data: {
        ...data,
        role: 'AGENT',
        passwordHash: await hashPassword(password),
      },
      include: withCompany,
    })
    .catch(rethrowConflict);
  res.status(201).json({ user: publicUser(user) });
});

router.patch('/:id/role', async (req, res) => {
  const { id } = idParams.parse(req.params);
  const { role, companyId } = updateRoleSchema.parse(req.body);
  refuseSelfChange(req, id);
  const user = await prisma.user
    .update({
      where: { id },
      data: { role, companyId: role === 'AGENT' ? companyId : null },
      include: withCompany,
    })
    .catch(rethrowConflict);
  res.json({ user: publicUser(user) });
});

router.patch('/:id/status', async (req, res) => {
  const { id } = idParams.parse(req.params);
  const { active } = updateStatusSchema.parse(req.body);
  refuseSelfChange(req, id);
  const user = await prisma.user.update({
    where: { id },
    data: { active },
    include: withCompany,
  });
  if (!active) await revokeSessions(id);
  res.json({ user: publicUser(user) });
});

export default router;
