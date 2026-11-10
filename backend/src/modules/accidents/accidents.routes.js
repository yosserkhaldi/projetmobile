import { Router } from 'express';
import { z } from 'zod';

import { HttpError } from '../../lib/errors.js';
import { faceEngine } from '../../lib/face.js';
import { documentReader } from '../../lib/ocr.js';
import { prisma } from '../../lib/prisma.js';
import { singleImage } from '../../lib/uploads.js';
import { requireAuth, requireRole } from '../../middleware/auth.js';
import { aiQuota } from '../../middleware/quota.js';

const router = Router();

const payloadSchema = z.record(z.string(), z.unknown());
const draftSchema = z.object({
  clientId: z.string().trim().min(1).max(100),
  currentStep: z.number().int().min(0).max(6),
  place: z.string().trim().min(1).max(500),
  occurredAt: z.iso.datetime({ offset: true }),
  payload: payloadSchema,
});
const updateSchema = draftSchema
  .omit({ clientId: true })
  .partial()
  .extend({ revision: z.number().int().positive() });

const publicAccident = (accident) => ({
  id: accident.id,
  clientId: accident.clientId,
  status: accident.status,
  currentStep: accident.currentStep,
  place: accident.place,
  occurredAt: accident.occurredAt,
  payload: accident.payload,
  revision: accident.revision,
  submittedAt: accident.submittedAt,
  createdAt: accident.createdAt,
  updatedAt: accident.updatedAt,
});

async function ownedAccident(id, userId) {
  const accident = await prisma.accident.findFirst({ where: { id, userId } });
  if (!accident) {
    throw new HttpError(404, 'NOT_FOUND', 'Déclaration introuvable.');
  }
  return accident;
}

router.use(requireAuth, requireRole('DRIVER'));

/**
 * Permis du conducteur B, lu par la même IA que celui du profil (module 1) :
 * photo remise à l'endroit, libellés de la carte, formats 2017 et ancien.
 * Rien n'est enregistré : la lecture remplit le formulaire, que le
 * conducteur vérifie. Une pièce qui n'est pas un permis est refusée.
 */
router.post('/license-scan', aiQuota({ max: 30 }), singleImage('photo'), async (req, res) => {
  const buffer = req.file.buffer;
  const face = await faceEngine.analyze(buffer).catch(() => ({}));
  const read = await documentReader.read(buffer, 'LICENSE', face);
  const looksLikeLicense =
    read.kind === 'LICENSE' || /^\d{2}\/\d{5,8}$/.test(read.number ?? '');
  if (!looksLikeLicense) {
    throw new HttpError(
      422,
      'NOT_A_LICENSE',
      read.kind === 'PASSPORT'
        ? 'Cette photo montre un passeport, pas un permis de conduire.'
        : read.kind === 'CIN'
          ? "Cette photo montre une carte d'identité, pas un permis de conduire."
          : 'Aucun permis de conduire reconnu sur cette photo. Reprenez-la à plat, bien éclairée, la carte entière dans le cadre.',
    );
  }
  res.json({
    license: {
      lastName: read.lastName ?? null,
      firstName: read.firstName ?? null,
      number: read.number ?? null,
      categories: read.categories ?? [],
      issuedAt: read.issuedAt ?? null,
      expiresAt: read.expiresAt ?? null,
      birthDate: read.birthDate ?? null,
    },
  });
});

router.get('/', async (req, res) => {
  const status = req.query.status?.toString().toUpperCase();
  if (status && !['DRAFT', 'SUBMITTED'].includes(status)) {
    throw new HttpError(400, 'VALIDATION_ERROR', 'Statut invalide.');
  }
  const accidents = await prisma.accident.findMany({
    where: { userId: req.user.id, ...(status && { status }) },
    orderBy: { updatedAt: 'desc' },
  });
  res.json({ accidents: accidents.map(publicAccident) });
});

router.get('/:id', async (req, res) => {
  const accident = await ownedAccident(req.params.id, req.user.id);
  res.json({ accident: publicAccident(accident) });
});

// Une répétition avec le même clientId actualise le brouillon existant :
// une coupure réseau ne crée donc jamais de doublon.
router.post('/', async (req, res) => {
  const data = draftSchema.parse(req.body);
  const existing = await prisma.accident.findUnique({
    where: {
      userId_clientId: { userId: req.user.id, clientId: data.clientId },
    },
  });
  if (existing?.status === 'SUBMITTED') {
    throw new HttpError(
      409,
      'ACCIDENT_LOCKED',
      'Une déclaration transmise ne peut plus être modifiée.',
    );
  }
  const values = {
    currentStep: data.currentStep,
    place: data.place,
    occurredAt: new Date(data.occurredAt),
    payload: data.payload,
  };
  const accident = existing
    ? await prisma.accident.update({
        where: { id: existing.id },
        data: { ...values, revision: { increment: 1 } },
      })
    : await prisma.accident.create({
        data: { ...values, clientId: data.clientId, userId: req.user.id },
      });
  res.status(existing ? 200 : 201).json({ accident: publicAccident(accident) });
});

router.patch('/:id', async (req, res) => {
  const data = updateSchema.parse(req.body);
  const current = await ownedAccident(req.params.id, req.user.id);
  if (current.status === 'SUBMITTED') {
    throw new HttpError(
      409,
      'ACCIDENT_LOCKED',
      'Une déclaration transmise ne peut plus être modifiée.',
    );
  }
  if (current.revision !== data.revision) {
    throw new HttpError(
      409,
      'SYNC_CONFLICT',
      'Le brouillon a été modifié sur un autre appareil.',
    );
  }
  const { revision: _revision, occurredAt, ...changes } = data;
  const accident = await prisma.accident.update({
    where: { id: current.id },
    data: {
      ...changes,
      ...(occurredAt && { occurredAt: new Date(occurredAt) }),
      revision: { increment: 1 },
    },
  });
  res.json({ accident: publicAccident(accident) });
});

router.post('/:id/submit', async (req, res) => {
  const current = await ownedAccident(req.params.id, req.user.id);
  if (current.status === 'SUBMITTED') {
    return res.json({ accident: publicAccident(current) });
  }
  const accident = await prisma.accident.update({
    where: { id: current.id },
    data: {
      status: 'SUBMITTED',
      currentStep: 6,
      submittedAt: new Date(),
      revision: { increment: 1 },
    },
  });
  return res.json({ accident: publicAccident(accident) });
});

router.delete('/:id', async (req, res) => {
  const current = await ownedAccident(req.params.id, req.user.id);
  if (current.status === 'SUBMITTED') {
    throw new HttpError(
      409,
      'ACCIDENT_LOCKED',
      'Une déclaration transmise ne peut pas être supprimée.',
    );
  }
  await prisma.accident.delete({ where: { id: current.id } });
  res.status(204).end();
});

export default router;
