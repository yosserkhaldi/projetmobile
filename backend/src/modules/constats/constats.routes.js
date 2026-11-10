import { createHash } from 'node:crypto';
import { existsSync } from 'node:fs';
import { readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { Router } from 'express';
import { z } from 'zod';

import { constatSealedEmail } from '../../lib/emails.js';
import { HttpError } from '../../lib/errors.js';
import { CONSTAT_PUBLIC_JWK, generateConstatQr, signConstatJws } from '../../lib/jws.js';
import { notifier } from '../../lib/notifier.js';
import { hasPdfSignature, signPdfBuffer } from '../../lib/pdf-signature.js';
import { prisma } from '../../lib/prisma.js';
import { filePath, savePdf, singlePdf } from '../../lib/uploads.js';
import { requireAuth, requireRole } from '../../middleware/auth.js';

const router = Router();
const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const FINALIZATION_WINDOW_MS = 120_000;
const pendingFinalizations = new Map();

function rememberPendingSignaturesHash(constatId, signaturesHash) {
  const cutoff = Date.now() - 10 * 60_000;
  for (const [key, entry] of pendingFinalizations.entries()) {
    if (entry.createdAtMs < cutoff) pendingFinalizations.delete(key);
  }
  pendingFinalizations.set(constatId, {
    signaturesHash: signaturesHash || null,
    createdAtMs: Date.now(),
  });
}

const constatSchema = z.object({
  accidentId: z.string().uuid().optional(),
  sha256Hash: z.string().length(64).regex(/^[a-f0-9]{64}$/i),
  signaturesHash: z.string().length(64).regex(/^[a-f0-9]{64}$/i).optional(),
  deferEmail: z.boolean().optional().default(false),
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
      accidentId: true,
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
      circumstancesA: true,
      circumstancesB: true,
      impactZones: true,
      observations: true,
      sketchData: true,
      driverASignedAt: true,
      driverBSignedAt: true,
      createdAt: true,
    },
  });

  if (!constat) {
    throw new HttpError(404, 'NOT_FOUND', 'Aucun constat ne correspond à cette empreinte.');
  }

  const { jws } = signConstatJws(constat);
  const { qrCodeBase64, verifierUrl } = await generateConstatQr(jws);

  res.json({
    valid: true,
    constat,
    jwsToken: jws,
    qrCodeBase64,
    verifierUrl,
  });
});

// Clé publique ECDSA P-256 pour les auditeurs et le vérificateur autonome
router.get('/public-key', (req, res) => {
  res.json({ jwk: CONSTAT_PUBLIC_JWK });
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

async function extractVerifiedPdfBuffer(req, data, bodyData) {
  if (req.file) {
    verifyBufferHash(req.file.buffer, data.sha256Hash);
    return { buffer: req.file.buffer, fileForSave: req.file };
  }
  if (bodyData.pdfBase64) {
    const fileBuffer = Buffer.from(bodyData.pdfBase64, 'base64');
    verifyBufferHash(fileBuffer, data.sha256Hash);
    return { buffer: fileBuffer, fileForSave: { buffer: fileBuffer } };
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
  const normalizedSha256 = data.sha256Hash.toLowerCase();

  const { buffer: rawPdfBuffer, fileForSave } = await extractVerifiedPdfBuffer(
    req,
    data,
    bodyData,
  );

  const existingWithHash = await prisma.constat.findUnique({
    where: { sha256Hash: normalizedSha256 },
  });
  if (existingWithHash) {
    throw new HttpError(
      409,
      'CONSTAT_ALREADY_SEALED',
      'Ce constat a déjà été scellé et enregistré.',
    );
  }

  const pdfFileName = await savePdf(fileForSave, 'constats');
  await linkAccident(data.accidentId, req.user.id);

  const constat = await prisma.constat.create({
    data: {
      userId: req.user.id,
      accidentId: data.accidentId,
      sha256Hash: normalizedSha256,
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

  const pdfDiskPath = resolve(filePath(pdfFileName, 'constats'));
  if (data.deferEmail) {
    rememberPendingSignaturesHash(constat.id, data.signaturesHash);
  } else {
    const signedPdfBuffer = signPdfBuffer(rawPdfBuffer, {
      constatId: constat.id,
      contentSha256: constat.sha256Hash,
      signaturesSha256: data.signaturesHash || null,
      signedAt: constat.createdAt,
    });
    await writeFile(pdfDiskPath, signedPdfBuffer);
    sendSealedNotifications(constat, data, signedPdfBuffer, req.user);
  }

  const { jws } = signConstatJws({
    ...constat,
    signaturesHash: data.signaturesHash || null,
  });
  const { qrCodeBase64, verifierUrl } = await generateConstatQr(jws);

  res.status(201).json({
    constat: {
      ...publicConstat(constat),
      qrCodeBase64,
      jwsToken: jws,
      verifierUrl,
    },
    jwsToken: jws,
    qrCodeBase64,
    verifierUrl,
  });
});

// ── 6. Finalisation unique : scellement ECDSA du PDF avec QR Code intégré ───
router.post('/:id/finalize-pdf', requireRole('DRIVER'), singlePdf('pdf'), async (req, res) => {
  const { id } = req.params;
  if (!UUID_REGEX.test(id)) {
    throw new HttpError(400, 'INVALID_ID', 'Identifiant de constat invalide.');
  }

  const constat = await findAuthorizedConstat(id, req.user);
  if (constat.userId !== req.user.id) {
    throw new HttpError(403, 'FORBIDDEN', 'Seul le conducteur déclarant peut finaliser ce PDF.');
  }

  if (!req.file) {
    throw new HttpError(400, 'PDF_REQUIRED', 'Le document PDF estampillé est requis.');
  }
  const uploaded = req.file.buffer;
  if (uploaded.length < 4 || uploaded.subarray(0, 4).toString('ascii') !== '%PDF') {
    throw new HttpError(415, 'UNSUPPORTED_FILE', 'Format accepté : PDF uniquement.');
  }

  const pdfDiskPath = resolve(filePath(constat.pdfFile, 'constats'));
  if (!existsSync(pdfDiskPath)) {
    throw new HttpError(404, 'PDF_NOT_FOUND', 'Fichier PDF introuvable sur le serveur.');
  }

  const existingDiskPdf = await readFile(pdfDiskPath);
  if (hasPdfSignature(existingDiskPdf)) {
    throw new HttpError(
      409,
      'PDF_ALREADY_FINALIZED',
      'Le PDF scellé de ce constat est déjà signé et verrouillé.',
    );
  }

  if (Date.now() - constat.createdAt.getTime() > FINALIZATION_WINDOW_MS) {
    throw new HttpError(
      409,
      'FINALIZATION_WINDOW_EXPIRED',
      'La fenêtre de finalisation du PDF est expirée.',
    );
  }

  const pending = pendingFinalizations.get(constat.id);
  pendingFinalizations.delete(constat.id);

  const signedPdfBuffer = signPdfBuffer(uploaded, {
    constatId: constat.id,
    contentSha256: constat.sha256Hash,
    signaturesSha256: pending?.signaturesHash || null,
    signedAt: constat.createdAt,
  });

  await writeFile(pdfDiskPath, signedPdfBuffer);
  sendSealedNotifications(constat, constat, signedPdfBuffer, req.user);

  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader(
    'Content-Disposition',
    `inline; filename="constat-${constat.sha256Hash.slice(0, 10)}.pdf"`,
  );
  res.status(200).send(signedPdfBuffer);
});

export default router;
