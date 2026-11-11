import { randomBytes } from 'node:crypto';

import { Prisma } from '@prisma/client';
import bcrypt from 'bcryptjs';
import { Router } from 'express';

import { HttpError } from '../../lib/errors.js';
import { prisma } from '../../lib/prisma.js';
import { deleteImage } from '../../lib/uploads.js';
import { requireAuth, requireRole } from '../../middleware/auth.js';
import { hashPassword, publicUser, revokeSessions } from './auth.service.js';
import { deleteAccountSchema, statsQuery } from './users.schemas.js';

// Module 1 : données personnelles (loi n° 2004-63) et statistiques des comptes.
const router = Router();

// ---------------------------------------------------------------------------
// Export des données (droit d'accès)

router.get('/me/export', requireAuth, async (req, res) => {
  const id = req.user.id;
  const [user, sessions, logins] = await Promise.all([
    prisma.user.findUnique({
      where: { id },
      include: { company: { select: { id: true, name: true } } },
    }),
    prisma.session.findMany({
      where: { userId: id },
      orderBy: { createdAt: 'desc' },
    }),
    prisma.loginEvent.findMany({
      where: { userId: id },
      orderBy: { createdAt: 'desc' },
    }),
  ]);
  res.set(
    'Content-Disposition',
    'attachment; filename="mes-donnees-mon-constat.json"',
  );
  res.json({
    exportedAt: new Date().toISOString(),
    legalBasis: 'Loi organique n° 2004-63 du 27 juillet 2004',
    account: {
      ...publicUser(user),
      createdAt: user.createdAt,
      consentAt: user.consentAt,
      phoneVerifiedAt: user.phoneVerifiedAt,
    },
    devices: sessions.map((s) => ({
      deviceName: s.deviceName,
      ip: s.ip,
      createdAt: s.createdAt,
      lastUsedAt: s.lastUsedAt,
      signedOutAt: s.revokedAt,
    })),
    signIns: logins.map((e) => ({
      success: e.success,
      method: e.method,
      reason: e.reason,
      deviceName: e.deviceName,
      ip: e.ip,
      at: e.createdAt,
    })),
  });
});

// ---------------------------------------------------------------------------
// Suppression du compte (droit à l'effacement)

/**
 * Le compte est anonymisé plutôt que supprimé : les accidents, constats et
 * sinistres des autres modules gardent leur lien, mais plus rien ne permet de
 * retrouver la personne. Les photos sont effacées du disque.
 */
router.delete('/me', requireAuth, async (req, res) => {
  const { password } = deleteAccountSchema.parse(req.body ?? {});
  const user = req.user;
  if (!(await bcrypt.compare(password, user.passwordHash))) {
    throw new HttpError(401, 'INVALID_CREDENTIALS', 'Mot de passe incorrect.');
  }
  if (user.role === 'ADMIN') {
    throw new HttpError(
      409,
      'ADMIN_CANNOT_DELETE',
      'Un administrateur ne peut pas supprimer son compte ici.',
    );
  }
  const unusable = await hashPassword(randomBytes(32).toString('hex'));
  await prisma.$transaction([
    prisma.user.update({
      where: { id: user.id },
      data: {
        firstName: 'Compte',
        lastName: 'supprimé',
        email: `deleted-${user.id}@deleted.invalid`,
        phone: `deleted-${user.id}`,
        passwordHash: unusable,
        active: false,
        phoneVerifiedAt: null,
        licenseNumber: null,
        licenseCategory: null,
        licenseIssuedAt: null,
        photoFile: null,
        licensePhotoFile: null,
        licenseReading: Prisma.DbNull,
        cinNumber: null,
        cinFrontFile: null,
        cinBackFile: null,
        identityStatus: 'UNVERIFIED',
        identityRejectionReason: null,
        identitySelfieFile: null,
        identityLivenessAt: null,
        identityFaceMatch: null,
        identityAutoVerified: false,
        identityExtracted: Prisma.DbNull,
        identityChecks: Prisma.DbNull,
        identityRefusals: 0,
        identityRetryAt: null,
        identityBlocked: false,
        identityBiometricConsentAt: null,
        deletedAt: new Date(),
      },
    }),
    prisma.loginEvent.deleteMany({ where: { userId: user.id } }),
    prisma.identityAttempt.deleteMany({ where: { userId: user.id } }),
    prisma.verificationCode.deleteMany({ where: { userId: user.id } }),
  ]);
  await revokeSessions(user.id);
  await Promise.all([
    deleteImage(user.photoFile, 'users'),
    deleteImage(user.licensePhotoFile, 'users'),
    deleteImage(user.cinFrontFile, 'identity'),
    deleteImage(user.cinBackFile, 'identity'),
    deleteImage(user.identitySelfieFile, 'identity'),
  ]);
  res.status(204).end();
});

// ---------------------------------------------------------------------------
// Statistiques des comptes (tableau de bord administrateur)

const DAY_MS = 24 * 60 * 60_000;

/**
 * Bilan de la vérification d'identité par l'IA sur la période : demandes,
 * part validée sans administrateur, refus, ressemblance moyenne, comptes
 * bloqués. Pour le tableau de bord et la soutenance.
 */
async function identityAiStats(since) {
  const window = { createdAt: { gte: since } };
  const [byOutcome, average, blocked] = await Promise.all([
    prisma.identityAttempt.groupBy({
      by: ['outcome'],
      where: window,
      _count: true,
    }),
    prisma.identityAttempt.aggregate({
      where: { ...window, faceMatch: { not: null } },
      _avg: { faceMatch: true },
    }),
    prisma.user.count({ where: { deletedAt: null, identityBlocked: true } }),
  ]);
  const of = (outcome) =>
    byOutcome.find((row) => row.outcome === outcome)?._count ?? 0;
  const requests = byOutcome.reduce((sum, row) => sum + row._count, 0);
  const auto = of('AUTO_VERIFIED');
  return {
    requests,
    autoVerified: auto,
    adminVerified: of('VERIFIED'),
    rejected: of('REJECTED'),
    pending: of('PENDING'),
    // Part des demandes validées par l'IA seule, de 0 à 1.
    autoRate: requests ? Math.round((auto / requests) * 100) / 100 : null,
    averageMatch:
      average._avg.faceMatch === null
        ? null
        : Math.round(average._avg.faceMatch * 100) / 100,
    blocked,
  };
}

router.get('/stats', requireAuth, requireRole('ADMIN'), async (req, res) => {
  const { days } = statsQuery.parse(req.query);
  const live = { deletedAt: null };
  const since = new Date(Date.now() - (days - 1) * DAY_MS);
  since.setHours(0, 0, 0, 0);
  const weekAgo = new Date(Date.now() - 7 * DAY_MS);

  const [
    byRole,
    byIdentity,
    active,
    phoneVerified,
    recent,
    logins,
    companies,
    agencies,
    autoVerified,
    aiStats,
    licensesToReview,
  ] = await Promise.all([
    prisma.user.groupBy({ by: ['role'], where: live, _count: true }),
    prisma.user.groupBy({
      by: ['identityStatus'],
      where: { ...live, role: 'DRIVER' },
      _count: true,
    }),
    prisma.user.count({ where: { ...live, active: true } }),
    prisma.user.count({ where: { ...live, phoneVerifiedAt: { not: null } } }),
    prisma.user.findMany({
      where: { ...live, createdAt: { gte: since } },
      select: { createdAt: true },
    }),
    prisma.loginEvent.groupBy({
      by: ['success'],
      where: { createdAt: { gte: weekAgo } },
      _count: true,
    }),
    prisma.company.count(),
    prisma.agency.count(),
    prisma.user.count({
      where: { ...live, identityStatus: 'VERIFIED', identityAutoVerified: true },
    }),
    identityAiStats(since),
    prisma.user.count({ where: { ...live, licenseStatus: 'TO_REVIEW' } }),
  ]);

  const count = (rows, key, value) =>
    rows.find((r) => r[key] === value)?._count ?? 0;
  const total = byRole.reduce((sum, r) => sum + r._count, 0);

  // Une case par jour, même vide, pour que le graphique ne saute pas de jours.
  const signups = Array.from({ length: days }, (_, i) => {
    const day = new Date(since.getTime() + i * DAY_MS);
    return { date: day.toISOString().slice(0, 10), count: 0 };
  });
  for (const { createdAt } of recent) {
    const index = Math.floor((createdAt - since) / DAY_MS);
    if (index >= 0 && index < days) signups[index].count += 1;
  }

  res.json({
    users: {
      total,
      active,
      suspended: total - active,
      phoneVerified,
      byRole: {
        DRIVER: count(byRole, 'role', 'DRIVER'),
        AGENT: count(byRole, 'role', 'AGENT'),
        ADMIN: count(byRole, 'role', 'ADMIN'),
      },
    },
    identity: Object.fromEntries(
      ['UNVERIFIED', 'PENDING', 'VERIFIED', 'REJECTED'].map((s) => [
        s,
        count(byIdentity, 'identityStatus', s),
      ]),
    ),
    // Identités validées par la reconnaissance faciale, sans administrateur.
    identityAutoVerified: autoVerified,
    identityAi: aiStats,
    // Permis dont un contrôle croisé a échoué : à vérifier.
    licensesToReview,
    signIns7Days: {
      success: count(logins, 'success', true),
      failed: count(logins, 'success', false),
    },
    companies,
    agencies,
    signups,
    activity: await activityStats(),
  });
});

/**
 * Tableau de bord, accidents et sinistres (modules 3 et 5) : volumes, statut,
 * gravité, compagnie, mois, délai de clôture, indemnisations, et points GPS
 * des déclarations pour la carte des zones à risque.
 */
async function activityStats() {
  const [claims, companies, accidents, closings] = await Promise.all([
    prisma.claim.findMany({
      select: {
        status: true,
        severity: true,
        type: true,
        companyId: true,
        indemnity: true,
        createdAt: true,
      },
    }),
    prisma.company.findMany({ select: { id: true, name: true } }),
    prisma.accident.findMany({
      where: { status: 'SUBMITTED' },
      select: { place: true, payload: true, occurredAt: true },
      orderBy: { occurredAt: 'desc' },
      take: 300,
    }),
    prisma.claimEvent.findMany({
      where: { label: 'Clôturé' },
      select: { createdAt: true, claim: { select: { createdAt: true } } },
    }),
  ]);
  const tally = (key) => {
    const counts = {};
    for (const claim of claims) counts[claim[key]] = (counts[claim[key]] ?? 0) + 1;
    return counts;
  };
  const names = new Map(companies.map((c) => [c.id, c.name]));
  const byCompany = {};
  for (const claim of claims) {
    const name = names.get(claim.companyId) ?? 'Sans compagnie';
    byCompany[name] = (byCompany[name] ?? 0) + 1;
  }
  // Six derniers mois, même vides.
  const now = new Date();
  const months = Array.from({ length: 6 }, (_, i) => {
    const d = new Date(now.getFullYear(), now.getMonth() - 5 + i, 1);
    return { month: `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`, count: 0 };
  });
  for (const claim of claims) {
    const d = claim.createdAt;
    const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
    const slot = months.find((m) => m.month === key);
    if (slot) slot.count += 1;
  }
  const delays = closings.map(
    (e) => (e.createdAt - e.claim.createdAt) / (24 * 3600 * 1000),
  );
  const finished = new Set(['Clôturé', 'Rejeté']);
  const points = [];
  for (const accident of accidents) {
    const lat = Number(accident.payload?.latitude);
    const lng = Number(accident.payload?.longitude);
    if (Number.isFinite(lat) && Number.isFinite(lng) && (lat || lng)) {
      points.push({ lat, lng, place: accident.place });
    }
  }
  return {
    claims: claims.length,
    open: claims.filter((c) => !finished.has(c.status)).length,
    closed: claims.filter((c) => c.status === 'Clôturé').length,
    averageDaysToClose: delays.length
      ? Math.round((delays.reduce((a, b) => a + b, 0) / delays.length) * 10) / 10
      : null,
    indemnityTotal: claims.reduce((sum, c) => sum + (c.indemnity ?? 0), 0),
    byStatus: tally('status'),
    bySeverity: tally('severity'),
    byType: tally('type'),
    byCompany,
    byMonth: months,
    declarations: accidents.length,
    points,
  };
}

export default router;
