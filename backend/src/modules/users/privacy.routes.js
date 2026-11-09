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
    signIns7Days: {
      success: count(logins, 'success', true),
      failed: count(logins, 'success', false),
    },
    companies,
    agencies,
    signups,
  });
});

export default router;
