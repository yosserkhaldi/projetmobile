import bcrypt from 'bcryptjs';

import { newLoginEmail, passwordResetEmail } from '../../lib/emails.js';
import { HttpError, isUniqueViolation } from '../../lib/errors.js';
import { notifier } from '../../lib/notifier.js';
import { prisma } from '../../lib/prisma.js';
import {
  hashCode,
  hashToken,
  newCode,
  newRefreshToken,
  signAccessToken,
} from '../../lib/tokens.js';

const BCRYPT_ROUNDS = 10;
// Haché de référence : un e-mail inconnu prend autant de temps qu'un mauvais mot de passe.
const DUMMY_HASH = bcrypt.hashSync('compte-inexistant', BCRYPT_ROUNDS);

const MAX_FAILED_LOGINS = 5;
const LOCK_MS = 15 * 60_000;
// Chaque rafraîchissement prolonge la session : elle expire après 30 min d'inactivité.
const SESSION_MS = 30 * 60_000;
// La clé biométrique dure 30 jours et change à chaque utilisation.
const DEVICE_KEY_MS = 30 * 24 * 60 * 60_000;

const CODE_TTL_MS = {
  PHONE_VERIFICATION: 10 * 60_000,
  PASSWORD_RESET: 15 * 60_000,
};
const CODE_COOLDOWN_MS = 60_000;
const MAX_CODE_ATTEMPTS = 5;

export const withCompany = { company: { select: { id: true, name: true } } };

export const hashPassword = (password) => bcrypt.hash(password, BCRYPT_ROUNDS);

/** Ce que l'API expose d'un utilisateur. Ne jamais renvoyer l'objet Prisma brut. */
export function publicUser(user) {
  return {
    id: user.id,
    firstName: user.firstName,
    lastName: user.lastName,
    email: user.email,
    phone: user.phone,
    phoneVerified: user.phoneVerifiedAt !== null,
    role: user.role,
    active: user.active,
    language: user.language,
    licenseNumber: user.licenseNumber,
    licenseCategory: user.licenseCategory,
    licenseIssuedAt: user.licenseIssuedAt?.toISOString().slice(0, 10) ?? null,
    company: user.company ?? null,
    // Identifiants opaques : changent à chaque nouvelle photo (cache côté app).
    photoId: user.photoFile ?? null,
    licensePhotoId: user.licensePhotoFile ?? null,
    identity: {
      status: user.identityStatus,
      cinNumber: user.cinNumber,
      frontId: user.cinFrontFile ?? null,
      backId: user.cinBackFile ?? null,
      submittedAt: user.identitySubmittedAt?.toISOString() ?? null,
      rejectionReason: user.identityRejectionReason,
    },
  };
}

/**
 * Ouvre une session pour un appareil, ou la prolonge (`sessionId`).
 * `device` vient des en-têtes X-Device-Id et X-Device-Name de l'application.
 */
async function openSession(user, device = {}, sessionId = null) {
  const now = new Date();
  const session = sessionId
    ? await prisma.session.update({
        where: { id: sessionId },
        data: { lastUsedAt: now, ip: device.ip ?? undefined },
      })
    : await prisma.session.create({
        data: {
          userId: user.id,
          deviceId: device.deviceId,
          deviceName: device.deviceName,
          ip: device.ip,
        },
      });
  const refreshToken = newRefreshToken();
  await prisma.refreshToken.create({
    data: {
      userId: user.id,
      sessionId: session.id,
      tokenHash: hashToken(refreshToken),
      expiresAt: new Date(now.getTime() + SESSION_MS),
    },
  });
  return {
    user: publicUser(user),
    accessToken: signAccessToken(user, session.id),
    refreshToken,
  };
}

/** Ferme toutes les sessions et désactive la connexion biométrique. */
export const revokeSessions = (userId) => {
  const revokedAt = new Date();
  return prisma.$transaction([
    prisma.session.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt },
    }),
    prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt },
    }),
    prisma.deviceKey.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt },
    }),
  ]);
};

/** Déconnecte un appareil : sa session et ses jetons. */
export async function revokeSession(userId, sessionId) {
  const revokedAt = new Date();
  const { count } = await prisma.session.updateMany({
    where: { id: sessionId, userId, revokedAt: null },
    data: { revokedAt },
  });
  if (count === 0) {
    throw new HttpError(404, 'NOT_FOUND', 'Appareil introuvable.');
  }
  await prisma.refreshToken.updateMany({
    where: { sessionId, revokedAt: null },
    data: { revokedAt },
  });
}

export async function revokeOtherSessions(userId, currentSessionId) {
  const revokedAt = new Date();
  const others = { userId, revokedAt: null, id: { not: currentSessionId } };
  const ids = (
    await prisma.session.findMany({ where: others, select: { id: true } })
  ).map((s) => s.id);
  await prisma.$transaction([
    prisma.session.updateMany({ where: others, data: { revokedAt } }),
    prisma.refreshToken.updateMany({
      where: { sessionId: { in: ids }, revokedAt: null },
      data: { revokedAt },
    }),
  ]);
  return ids.length;
}

async function recordLogin(userId, method, device, success, reason = null) {
  await prisma.loginEvent
    .create({
      data: {
        userId,
        method,
        success,
        reason,
        deviceName: device.deviceName,
        ip: device.ip,
      },
    })
    .catch((err) => console.error('Historique de connexion', err));
}

/**
 * Prévient le titulaire, sur WhatsApp et par e-mail, d'une connexion depuis
 * un appareil jamais vu sur son compte.
 */
async function alertIfNewDevice(user, device) {
  if (!device.deviceId) return;
  const known = await prisma.session.count({
    where: { userId: user.id, deviceId: device.deviceId },
  });
  if (known > 0) return;
  const message = newLoginEmail({
    firstName: user.firstName,
    language: user.language,
    deviceName: device.deviceName,
    when: new Date(),
  });
  // Sans attendre : l'alerte ne doit jamais ralentir ni bloquer la connexion.
  Promise.allSettled([
    notifier.sendToPhone(user.phone, message.text),
    notifier.sendMail(user.email, message.subject, message.text, message.html),
  ]).then((results) => {
    for (const r of results) {
      if (r.status === 'rejected') console.error('Alerte de connexion', r.reason);
    }
  });
}

/**
 * Enregistre un nouveau code, ce qui invalide les précédents.
 * Renvoie null si un code vient déjà d'être envoyé.
 */
async function createCode(userId, purpose) {
  const now = Date.now();
  const recent = await prisma.verificationCode.findFirst({
    where: {
      userId,
      purpose,
      consumedAt: null,
      createdAt: { gt: new Date(now - CODE_COOLDOWN_MS) },
    },
  });
  if (recent) return null;

  const code = newCode();
  await prisma.$transaction([
    prisma.verificationCode.updateMany({
      where: { userId, purpose, consumedAt: null },
      data: { consumedAt: new Date(now) },
    }),
    prisma.verificationCode.create({
      data: {
        userId,
        purpose,
        codeHash: hashCode(userId, purpose, code),
        expiresAt: new Date(now + CODE_TTL_MS[purpose]),
      },
    }),
  ]);
  return code;
}

/** Consomme le code s'il est valide. Chaque essai est compté, même en parallèle. */
async function consumeCode(userId, purpose, code) {
  const row = await prisma.verificationCode.findFirst({
    where: { userId, purpose, consumedAt: null, expiresAt: { gt: new Date() } },
    orderBy: { createdAt: 'desc' },
  });
  if (!row) return false;

  const counted = await prisma.verificationCode.updateMany({
    where: {
      id: row.id,
      consumedAt: null,
      attempts: { lt: MAX_CODE_ATTEMPTS },
    },
    data: { attempts: { increment: 1 } },
  });
  if (counted.count === 0 || row.codeHash !== hashCode(userId, purpose, code)) {
    return false;
  }
  const consumed = await prisma.verificationCode.updateMany({
    where: { id: row.id, consumedAt: null },
    data: { consumedAt: new Date() },
  });
  return consumed.count === 1;
}

async function sendPhoneCode(user) {
  const code = await createCode(user.id, 'PHONE_VERIFICATION');
  if (!code) return false;
  await notifier.sendToPhone(
    user.phone,
    `Mon Constat Digital : votre code est ${code}.`,
  );
  return true;
}

export async function register(
  { password, consent: _, ...data },
  device = {},
) {
  let user;
  try {
    user = await prisma.user.create({
      data: {
        ...data,
        passwordHash: await hashPassword(password),
        consentAt: new Date(),
      },
      include: withCompany,
    });
  } catch (err) {
    if (isUniqueViolation(err)) {
      throw new HttpError(
        409,
        'ALREADY_EXISTS',
        'E-mail ou téléphone déjà utilisé.',
      );
    }
    throw err;
  }
  // Le compte reste créé si le SMS échoue : l'utilisateur peut redemander un code.
  await sendPhoneCode(user).catch((err) =>
    console.error('Envoi du SMS impossible', err),
  );
  await recordLogin(user.id, 'register', device, true);
  return openSession(user, device);
}

export async function login({ identifier, password }, device = {}) {
  const invalid = new HttpError(
    401,
    'INVALID_CREDENTIALS',
    'Identifiant ou mot de passe incorrect.',
  );
  const user = await prisma.user.findUnique({
    where: identifier,
    include: withCompany,
  });
  if (!user) {
    await bcrypt.compare(password, DUMMY_HASH);
    throw invalid;
  }
  if (user.lockedUntil && user.lockedUntil > new Date()) {
    await recordLogin(user.id, 'password', device, false, 'locked');
    throw new HttpError(
      423,
      'ACCOUNT_LOCKED',
      'Compte bloqué pendant 15 minutes après 5 échecs. Réessayez plus tard.',
    );
  }
  if (!(await bcrypt.compare(password, user.passwordHash))) {
    const { failedLogins } = await prisma.user.update({
      where: { id: user.id },
      data: { failedLogins: { increment: 1 } },
    });
    if (failedLogins >= MAX_FAILED_LOGINS) {
      await prisma.user.update({
        where: { id: user.id },
        data: { failedLogins: 0, lockedUntil: new Date(Date.now() + LOCK_MS) },
      });
    }
    await recordLogin(user.id, 'password', device, false, 'wrong_password');
    throw invalid;
  }
  // Vérifié après le mot de passe : seul le titulaire apprend que le compte est suspendu.
  if (!user.active) {
    await recordLogin(user.id, 'password', device, false, 'suspended');
    throw new HttpError(403, 'ACCOUNT_SUSPENDED', 'Ce compte est suspendu.');
  }
  await prisma.user.update({
    where: { id: user.id },
    data: { failedLogins: 0, lockedUntil: null },
  });
  await recordLogin(user.id, 'password', device, true);
  await alertIfNewDevice(user, device);
  return openSession(user, device);
}

export async function refresh(token, device = {}) {
  const expired = new HttpError(
    401,
    'SESSION_EXPIRED',
    'Session expirée. Reconnectez-vous.',
  );
  const row = await prisma.refreshToken.findUnique({
    where: { tokenHash: hashToken(token) },
    include: { user: { include: withCompany }, session: true },
  });
  if (!row) throw expired;

  // Appareil déconnecté à distance : seule cette session est concernée.
  if (row.session.revokedAt) throw expired;

  // Un jeton déjà utilisé qui revient peut avoir été volé : toutes les sessions tombent.
  if (row.revokedAt || row.expiresAt <= new Date() || !row.user.active) {
    await revokeSessions(row.userId);
    throw expired;
  }
  const rotated = await prisma.refreshToken.updateMany({
    where: { id: row.id, revokedAt: null },
    data: { revokedAt: new Date() },
  });
  if (rotated.count === 0) {
    await revokeSessions(row.userId);
    throw expired;
  }
  return openSession(row.user, device, row.sessionId);
}

export async function logout(token) {
  const row = await prisma.refreshToken.findUnique({
    where: { tokenHash: hashToken(token) },
  });
  if (!row) return;
  const revokedAt = new Date();
  await prisma.$transaction([
    prisma.refreshToken.updateMany({
      where: { sessionId: row.sessionId, revokedAt: null },
      data: { revokedAt },
    }),
    prisma.session.updateMany({
      where: { id: row.sessionId, revokedAt: null },
      data: { revokedAt },
    }),
  ]);
}

export async function resendPhoneCode(user) {
  if (user.phoneVerifiedAt) {
    throw new HttpError(409, 'ALREADY_VERIFIED', 'Ce numéro est déjà vérifié.');
  }
  if (!(await sendPhoneCode(user))) {
    throw new HttpError(
      429,
      'CODE_COOLDOWN',
      'Attendez une minute avant de redemander un code.',
    );
  }
}

export async function verifyPhone(user, code) {
  if (!(await consumeCode(user.id, 'PHONE_VERIFICATION', code))) {
    throw new HttpError(400, 'INVALID_CODE', 'Code incorrect ou expiré.');
  }
  return prisma.user.update({
    where: { id: user.id },
    data: { phoneVerifiedAt: new Date() },
    include: withCompany,
  });
}

/** La réponse est la même que l'e-mail existe ou non. */
export async function forgotPassword(email) {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) return;
  const code = await createCode(user.id, 'PASSWORD_RESET');
  if (!code) return;
  const message = passwordResetEmail({
    firstName: user.firstName,
    language: user.language,
    code,
  });
  await notifier
    .sendMail(user.email, message.subject, message.text, message.html)
    .catch((err) => console.error("Envoi de l'e-mail impossible", err));
}

export async function resetPassword({ email, code, password }) {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user || !(await consumeCode(user.id, 'PASSWORD_RESET', code))) {
    throw new HttpError(400, 'INVALID_CODE', 'Code incorrect ou expiré.');
  }
  await prisma.user.update({
    where: { id: user.id },
    data: {
      passwordHash: await hashPassword(password),
      failedLogins: 0,
      lockedUntil: null,
    },
  });
  await revokeSessions(user.id);
}

async function issueDeviceKey(userId) {
  const deviceToken = newRefreshToken();
  const expiresAt = new Date(Date.now() + DEVICE_KEY_MS);
  await prisma.deviceKey.create({
    data: { userId, tokenHash: hashToken(deviceToken), expiresAt },
  });
  return { deviceToken, expiresAt: expiresAt.toISOString() };
}

/** Active la connexion biométrique sur l'appareil qui fait la demande. */
export const enableBiometric = (user) => issueDeviceKey(user.id);

/**
 * Connexion après une empreinte ou une reconnaissance faciale réussie sur
 * l'appareil. La clé est remplacée à chaque usage, comme le jeton de session.
 */
export async function biometricLogin(deviceToken, device = {}) {
  const invalid = new HttpError(
    401,
    'BIOMETRIC_INVALID',
    'Connexion biométrique expirée. Connectez-vous avec votre mot de passe.',
  );
  const key = await prisma.deviceKey.findUnique({
    where: { tokenHash: hashToken(deviceToken) },
    include: { user: { include: withCompany } },
  });
  if (!key) throw invalid;
  if (key.revokedAt) {
    // Une clé déjà utilisée qui revient peut avoir été copiée.
    if (key.lastUsedAt) await revokeSessions(key.userId);
    throw invalid;
  }
  if (key.expiresAt <= new Date()) throw invalid;
  if (!key.user.active) {
    throw new HttpError(403, 'ACCOUNT_SUSPENDED', 'Ce compte est suspendu.');
  }
  const rotated = await prisma.deviceKey.updateMany({
    where: { id: key.id, revokedAt: null },
    data: { revokedAt: new Date(), lastUsedAt: new Date() },
  });
  if (rotated.count === 0) throw invalid;

  await recordLogin(key.userId, 'biometric', device, true);
  await alertIfNewDevice(key.user, device);
  const session = await openSession(key.user, device);
  return { ...session, ...(await issueDeviceKey(key.userId)) };
}

/** Désactive la connexion biométrique : sur un appareil, ou partout. */
export async function disableBiometric(user, deviceToken) {
  await prisma.deviceKey.updateMany({
    where: {
      userId: user.id,
      revokedAt: null,
      ...(deviceToken && { tokenHash: hashToken(deviceToken) }),
    },
    data: { revokedAt: new Date() },
  });
}
