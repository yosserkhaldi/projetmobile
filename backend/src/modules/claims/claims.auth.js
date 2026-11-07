import jwt from 'jsonwebtoken';

import { forbidden, HttpError } from './claims.errors.js';

const roles = ['driver', 'agent', 'admin'];

// À remplacer par le middleware du module 1. Accepte déjà un JWT signé avec
// JWT_SECRET ({ sub, role, name }). Hors production, les en-têtes x-user-*
// servent d'identité de développement.
export function identify({ token, userId, role, name }) {
  if (token) {
    try {
      const payload = jwt.verify(token, process.env.JWT_SECRET);
      return { id: payload.sub, role: payload.role, name: payload.name };
    } catch {
      throw new HttpError(401, 'Jeton invalide.');
    }
  }
  if (process.env.NODE_ENV !== 'production' && userId && roles.includes(role)) {
    return { id: userId, role, name: name ?? userId };
  }
  throw new HttpError(401, 'Authentification requise.');
}

export function requireUser(req, _res, next) {
  const header = req.get('authorization') ?? '';
  req.user = identify({
    token: header.startsWith('Bearer ') ? header.slice(7) : null,
    userId: req.get('x-user-id'),
    role: req.get('x-user-role'),
    name: decodeURIComponent(req.get('x-user-name') ?? '') || undefined,
  });
  next();
}

export function requireRole(...allowed) {
  return (req, _res, next) => {
    if (!allowed.includes(req.user.role)) throw forbidden();
    next();
  };
}
