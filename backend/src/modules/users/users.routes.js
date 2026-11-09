import { Router } from 'express';

import {
  HttpError,
  isForeignKeyViolation,
  isUniqueViolation,
} from '../../lib/errors.js';
import { documentReader } from '../../lib/ocr.js';
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
  createAgentSchema,
  idParams,
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

/** Lecture du permis par l'OCR. En panne : null, le formulaire reste à remplir. */
async function readLicense(buffer) {
  try {
    const { number, categories, issuedAt, expiresAt } =
      await documentReader.read(buffer, 'LICENSE');
    return { number, categories, issuedAt, expiresAt };
  } catch (err) {
    console.error('Lecture du permis', err);
    return null;
  }
}

for (const [route, column] of Object.entries(PHOTOS)) {
  router.put(`/me/${route}`, ocrQuota, singleImage('photo'), async (req, res) => {
    const name = await saveImage(req.file, PHOTO_FOLDER);
    const user = await prisma.user.update({
      where: { id: req.user.id },
      data: { [column]: name },
      include: withCompany,
    });
    await deleteImage(req.user[column], PHOTO_FOLDER);
    // Permis : l'IA lit la carte (numéro, catégories, dates) pour remplir le
    // formulaire. L'utilisateur vérifie avant d'enregistrer.
    const extracted =
      route === 'license-photo' ? await readLicense(req.file.buffer) : undefined;
    res.json({ user: publicUser(user), extracted });
  });

  router.delete(`/me/${route}`, async (req, res) => {
    const user = await prisma.user.update({
      where: { id: req.user.id },
      data: { [column]: null },
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
