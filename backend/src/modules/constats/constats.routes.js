import { createHash } from 'node:crypto';
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';
import { Router } from 'express';
import { z } from 'zod';

import { constatSealedEmail } from '../../lib/emails.js';
import { HttpError } from '../../lib/errors.js';
import { notifier } from '../../lib/notifier.js';
import { prisma } from '../../lib/prisma.js';
import { filePath, savePdf, singlePdf } from '../../lib/uploads.js';
import { requireAuth, requireRole } from '../../middleware/auth.js';

const router = Router();

const constatSchema = z.object({
  accidentId: z.string().uuid().optional(),
  sha256Hash: z.string().length(64).regex(/^[a-f0-9]{64}$/i),
  driverAName: z.string().trim().min(2).max(100),
  driverAPlate: z.string().trim().min(2).max(20),
  driverAInsurer: z.string().trim().min(2).max(100),
  driverAPolicy: z.string().trim().max(100).optional(),
  companyAId: z.string().uuid().optional(),
  driverBName: z.string().trim().min(2).max(100),
  driverBEmail: z.string().email().optional().or(z.literal('')),
  driverBPhone: z.string().trim().max(30).optional(),
  driverBPlate: z.string().trim().min(2).max(20),
  driverBInsurer: z.string().trim().min(2).max(100),
  driverBPolicy: z.string().trim().max(100).optional(),
  companyBId: z.string().uuid().optional(),
  place: z.string().trim().min(2).max(500),
  occurredAt: z.iso.datetime({ offset: true }),
  circumstancesA: z.array(z.string()).default([]),
  circumstancesB: z.array(z.string()).default([]),
  impactZones: z.array(z.string()).default([]),
  observations: z.string().trim().max(2000).optional(),
  sketchData: z.unknown().optional(),
  driverASignedAt: z.iso.datetime({ offset: true }).optional(),
  driverBSignedAt: z.iso.datetime({ offset: true }).optional(),
});

function publicConstat(constat) {
  return {
    id: constat.id,
    accidentId: constat.accidentId,
    userId: constat.userId,
    status: constat.status,
    sha256Hash: constat.sha256Hash,
    pdfUrl: `/api/constats/${constat.id}/pdf`,
    driverAName: constat.driverAName,
    driverAPlate: constat.driverAPlate,
    driverAInsurer: constat.driverAInsurer,
    driverAPolicy: constat.driverAPolicy,
    companyAId: constat.companyAId,
    driverBName: constat.driverBName,
    driverBEmail: constat.driverBEmail,
    driverBPhone: constat.driverBPhone,
    driverBPlate: constat.driverBPlate,
    driverBInsurer: constat.driverBInsurer,
    driverBPolicy: constat.driverBPolicy,
    companyBId: constat.companyBId,
    place: constat.place,
    occurredAt: constat.occurredAt,
    circumstancesA: constat.circumstancesA,
    circumstancesB: constat.circumstancesB,
    impactZones: constat.impactZones,
    observations: constat.observations,
    sketchData: constat.sketchData,
    driverASignedAt: constat.driverASignedAt,
    driverBSignedAt: constat.driverBSignedAt,
    createdAt: constat.createdAt,
    updatedAt: constat.updatedAt,
  };
}

async function findAuthorizedConstat(id, user) {
  const constat = await prisma.constat.findUnique({ where: { id } });
  if (!constat) {
    throw new HttpError(404, 'NOT_FOUND', 'Constat introuvable.');
  }
  if (user.role === 'ADMIN') return constat;
  if (user.role === 'DRIVER') {
    if (constat.userId !== user.id) {
      throw new HttpError(403, 'FORBIDDEN', 'Accès refusé à ce constat.');
    }
    return constat;
  }
  if (user.role === 'AGENT') {
    if (
      constat.companyAId !== user.companyId &&
      constat.companyBId !== user.companyId
    ) {
      throw new HttpError(403, 'FORBIDDEN', 'Ce constat ne concerne pas votre compagnie.');
    }
    return constat;
  }
  throw new HttpError(403, 'FORBIDDEN', 'Accès refusé.');
}

// ── 1. Vérification publique d'authenticité par empreinte SHA-256 ───────────
router.get('/verify/:hash', async (req, res) => {
  const hash = req.params.hash?.trim().toLowerCase();
  if (!hash || !/^[a-f0-9]{64}$/.test(hash)) {
    throw new HttpError(400, 'INVALID_HASH', 'Format de hash SHA-256 invalide.');
  }

  const constat = await prisma.constat.findUnique({
    where: { sha256Hash: hash },
    select: {
      id: true,
      sha256Hash: true,
      status: true,
      place: true,
      occurredAt: true,
      driverAName: true,
      driverAPlate: true,
      driverAInsurer: true,
      driverBName: true,
      driverBPlate: true,
      driverBInsurer: true,
      driverASignedAt: true,
      driverBSignedAt: true,
      createdAt: true,
    },
  });

  if (!constat) {
    throw new HttpError(404, 'NOT_FOUND', 'Aucun constat ne correspond à cette empreinte.');
  }

  res.json({
    valid: true,
    constat,
  });
});

// Toutes les autres routes requièrent d'être authentifié
router.use(requireAuth);

// ── 2. Liste des constats ──────────────────────────────────────────────────
router.get('/', async (req, res) => {
  let where = {};
  if (req.user.role === 'DRIVER') {
    where = { userId: req.user.id };
  } else if (req.user.role === 'AGENT') {
    if (!req.user.companyId) {
      throw new HttpError(403, 'AGENT_WITHOUT_COMPANY', "Compte agent non rattaché.");
    }
    where = {
      OR: [
        { companyAId: req.user.companyId },
        { companyBId: req.user.companyId },
      ],
    };
  }

  const constats = await prisma.constat.findMany({
    where,
    orderBy: { createdAt: 'desc' },
  });

  res.json({ constats: constats.map(publicConstat) });
});

// ── 3. Détail d'un constat ─────────────────────────────────────────────────
router.get('/:id', async (req, res) => {
  const constat = await findAuthorizedConstat(req.params.id, req.user);
  res.json({ constat: publicConstat(constat) });
});

// ── 4. Téléchargement du PDF scellé ────────────────────────────────────────
router.get('/:id/pdf', async (req, res) => {
  const constat = await findAuthorizedConstat(req.params.id, req.user);
  const pdfPath = resolve(filePath(constat.pdfFile, 'constats'));

  if (!existsSync(pdfPath)) {
    throw new HttpError(404, 'PDF_NOT_FOUND', 'Fichier PDF introuvable sur le serveur.');
  }

  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader(
    'Content-Disposition',
    `inline; filename="constat-${constat.sha256Hash.slice(0, 10)}.pdf"`,
  );
  res.sendFile(pdfPath);
});

function parseBodyData(req) {
  if (typeof req.body?.data === 'string') {
    try {
      return JSON.parse(req.body.data);
    } catch {
      throw new HttpError(400, 'INVALID_PAYLOAD', 'Le champ data doit être un JSON valide.');
    }
  }
  return req.body;
}

function verifyBufferHash(buffer, expectedHash) {
  const computedHash = createHash('sha256').update(buffer).digest('hex');
  if (computedHash.toLowerCase() !== expectedHash.toLowerCase()) {
    throw new HttpError(
      400,
      'HASH_MISMATCH',
      'L’empreinte SHA-256 fournie ne correspond pas au contenu PDF.',
    );
  }
}

async function extractAndVerifyPdf(req, data, bodyData) {
  if (req.file) {
    verifyBufferHash(req.file.buffer, data.sha256Hash);
    const pdfFileName = await savePdf(req.file, 'constats');
    return { fileBuffer: req.file.buffer, pdfFileName };
  }
  if (bodyData.pdfBase64) {
    const fileBuffer = Buffer.from(bodyData.pdfBase64, 'base64');
    verifyBufferHash(fileBuffer, data.sha256Hash);
    const pdfFileName = await savePdf({ buffer: fileBuffer }, 'constats');
    return { fileBuffer, pdfFileName };
  }
  throw new HttpError(400, 'PDF_REQUIRED', 'Le document PDF signé est requis.');
}

async function linkAccident(accidentId, userId) {
  if (!accidentId) return;
  const accident = await prisma.accident.findFirst({
    where: { id: accidentId, userId },
  });
  if (accident) {
    await prisma.accident.update({
      where: { id: accidentId },
      data: { status: 'SUBMITTED', submittedAt: new Date() },
    });
  }
}

function sendSealedNotifications(constat, data, fileBuffer, user) {
  const dateFormatted = new Date(data.occurredAt).toLocaleString('fr-TN', {
    dateStyle: 'medium',
    timeStyle: 'short',
    timeZone: 'Africa/Tunis',
  });
  const attachment = [
    {
      filename: `constat-${constat.sha256Hash.slice(0, 10)}.pdf`,
      content: fileBuffer,
    },
  ];

  const mailA = constatSealedEmail({
    name: data.driverAName,
    place: data.place,
    date: dateFormatted,
    sha256Hash: constat.sha256Hash,
    language: user.language || 'FR',
  });
  notifier
    .sendMail(user.email, mailA.subject, mailA.text, mailA.html, attachment)
    .catch((err) => console.error('Erreur envoi email conducteur A :', err));

  if (data.driverBEmail) {
    const mailB = constatSealedEmail({
      name: data.driverBName,
      place: data.place,
      date: dateFormatted,
      sha256Hash: constat.sha256Hash,
      language: 'FR',
    });
    notifier
      .sendMail(data.driverBEmail, mailB.subject, mailB.text, mailB.html, attachment)
      .catch((err) => console.error('Erreur envoi email conducteur B :', err));
  }
}

// ── 5. Enregistrement et scellement d'un nouveau constat ────────────────────
router.post('/', requireRole('DRIVER'), singlePdf('pdf'), async (req, res) => {
  const bodyData = parseBodyData(req);
  const data = constatSchema.parse(bodyData);

  const { fileBuffer, pdfFileName } = await extractAndVerifyPdf(req, data, bodyData);

  const existingWithHash = await prisma.constat.findUnique({
    where: { sha256Hash: data.sha256Hash },
  });
  if (existingWithHash) {
    throw new HttpError(
      409,
      'CONSTAT_ALREADY_SEALED',
      'Ce constat a déjà été scellé et enregistré.',
    );
  }

  await linkAccident(data.accidentId, req.user.id);

  const constat = await prisma.constat.create({
    data: {
      userId: req.user.id,
      accidentId: data.accidentId,
      sha256Hash: data.sha256Hash.toLowerCase(),
      pdfFile: pdfFileName,
      driverAName: data.driverAName,
      driverAPlate: data.driverAPlate,
      driverAInsurer: data.driverAInsurer,
      driverAPolicy: data.driverAPolicy,
      companyAId: data.companyAId,
      driverBName: data.driverBName,
      driverBEmail: data.driverBEmail || null,
      driverBPhone: data.driverBPhone,
      driverBPlate: data.driverBPlate,
      driverBInsurer: data.driverBInsurer,
      driverBPolicy: data.driverBPolicy,
      companyBId: data.companyBId,
      place: data.place,
      occurredAt: new Date(data.occurredAt),
      circumstancesA: data.circumstancesA,
      circumstancesB: data.circumstancesB,
      impactZones: data.impactZones,
      observations: data.observations,
      sketchData: data.sketchData ?? undefined,
      driverASignedAt: data.driverASignedAt ? new Date(data.driverASignedAt) : new Date(),
      driverBSignedAt: data.driverBSignedAt ? new Date(data.driverBSignedAt) : new Date(),
    },
  });

  sendSealedNotifications(constat, data, fileBuffer, req.user);

  res.status(201).json({ constat: publicConstat(constat) });
});

export default router;
