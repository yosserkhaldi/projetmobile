import { createHash, createHmac, randomBytes, randomInt } from 'node:crypto';

import jwt from 'jsonwebtoken';

const ALGORITHM = 'HS256';
const ACCESS_TOKEN_TTL = '15m';

function jwtSecret() {
  const secret = process.env.JWT_SECRET;
  if (!secret) throw new Error('JWT_SECRET est obligatoire.');
  return secret;
}

/** Appelé au démarrage : le serveur refuse de démarrer sans secret. */
export function assertAuthConfig() {
  jwtSecret();
}

export const signAccessToken = (user, sessionId) =>
  jwt.sign({ sub: user.id, sid: sessionId, role: user.role }, jwtSecret(), {
    algorithm: ALGORITHM,
    expiresIn: ACCESS_TOKEN_TTL,
  });

export const verifyAccessToken = (token) =>
  jwt.verify(token, jwtSecret(), { algorithms: [ALGORITHM] });

export const newRefreshToken = () => randomBytes(32).toString('base64url');

export const hashToken = (token) =>
  createHash('sha256').update(token).digest('hex');

export const newCode = () => String(randomInt(0, 1_000_000)).padStart(6, '0');

export const hashCode = (userId, purpose, code) =>
  createHmac('sha256', jwtSecret())
    .update(`${userId}:${purpose}:${code}`)
    .digest('hex');
