import { HttpError } from '../../lib/errors.js';
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

// Le canal temps réel ne reçoit qu'un signal : le jeton suffit.
export function identifySocket({ token }) {
  try {
    const { sub, role } = verifyAccessToken(token);
    return { id: sub, role: role.toLowerCase() };
  } catch {
    throw new HttpError(401, 'TOKEN_INVALID', 'Jeton invalide ou expiré.');
  }
}
