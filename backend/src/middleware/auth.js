import { HttpError } from '../lib/errors.js';
import { prisma } from '../lib/prisma.js';
import { verifyAccessToken } from '../lib/tokens.js';

/**
 * Exige un jeton d'accès valide et place l'utilisateur dans `req.user`.
 * L'utilisateur est relu en base : une suspension ou un changement de rôle
 * s'applique immédiatement.
 */
export async function requireAuth(req, _res, next) {
  const [scheme, token] = (req.headers.authorization ?? '').split(' ');
  if (scheme !== 'Bearer' || !token) {
    throw new HttpError(401, 'UNAUTHENTICATED', 'Authentification requise.');
  }
  let payload;
  try {
    payload = verifyAccessToken(token);
  } catch {
    throw new HttpError(401, 'TOKEN_INVALID', 'Jeton invalide ou expiré.');
  }
  const [user, session] = await Promise.all([
    prisma.user.findUnique({
      where: { id: payload.sub },
      include: { company: { select: { id: true, name: true } } },
    }),
    payload.sid
      ? prisma.session.findUnique({ where: { id: payload.sid } })
      : null,
  ]);
  // Un appareil déconnecté depuis « Mes appareils » perd l'accès tout de suite.
  if (!user || !user.active || !session || session.revokedAt) {
    throw new HttpError(401, 'TOKEN_INVALID', 'Jeton invalide ou expiré.');
  }
  req.user = user;
  req.sessionId = session.id;
  next();
}

/**
 * Exige une identité vérifiée par un administrateur (après `requireAuth`).
 * Par exemple pour signer un constat (module 4).
 */
export function requireVerifiedIdentity(req, _res, next) {
  if (req.user.identityStatus !== 'VERIFIED') {
    throw new HttpError(
      403,
      'IDENTITY_NOT_VERIFIED',
      "Votre identité doit être vérifiée avant cette action.",
    );
  }
  next();
}

/** Appareil qui fait la requête, d'après les en-têtes envoyés par l'application. */
export function deviceFrom(req) {
  const header = (name) => {
    const value = req.get(name);
    return value ? value.trim().slice(0, 100) : undefined;
  };
  return {
    deviceId: header('X-Device-Id'),
    deviceName: header('X-Device-Name'),
    ip: req.ip,
  };
}

/** À placer après `requireAuth` : `requireRole('ADMIN')`. */
export const requireRole =
  (...roles) =>
  (req, _res, next) => {
    if (!roles.includes(req.user.role)) {
      throw new HttpError(403, 'FORBIDDEN', 'Accès refusé pour ce rôle.');
    }
    next();
  };
