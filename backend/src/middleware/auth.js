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
  const user = await prisma.user.findUnique({
    where: { id: payload.sub },
    include: { company: { select: { id: true, name: true } } },
  });
  if (!user || !user.active) {
    throw new HttpError(401, 'TOKEN_INVALID', 'Jeton invalide ou expiré.');
  }
  req.user = user;
  next();
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
