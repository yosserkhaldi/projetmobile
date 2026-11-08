import { HttpError } from '../../lib/errors.js';
import { prisma } from '../../lib/prisma.js';
import { verifyAccessToken } from '../../lib/tokens.js';
import { requireAuth } from '../../middleware/auth.js';

export { requireRole } from '../../middleware/auth.js';

// L'identité vient du module 1. Le module 5 garde les rôles en minuscules,
// comme dans ses tables et côté Flutter.
export async function requireUser(req, res, next) {
  await requireAuth(req, res, () => {});
  const { id, role, firstName, lastName } = req.user;
  req.user = { id, role: role.toLowerCase(), name: `${firstName} ${lastName}` };
  next();
}

// Le canal temps réel applique les mêmes contrôles que requireAuth : compte
// actif et session d'appareil non révoquée depuis « Mes appareils ».
export async function identifySocket({ token }) {
  const invalid = new HttpError(401, 'TOKEN_INVALID', 'Jeton invalide ou expiré.');
  let payload;
  try {
    payload = verifyAccessToken(token);
  } catch {
    throw invalid;
  }
  const [user, session] = await Promise.all([
    prisma.user.findUnique({ where: { id: payload.sub } }),
    payload.sid ? prisma.session.findUnique({ where: { id: payload.sid } }) : null,
  ]);
  if (!user || !user.active || !session || session.revokedAt) throw invalid;
  return { id: user.id, role: user.role.toLowerCase() };
}
