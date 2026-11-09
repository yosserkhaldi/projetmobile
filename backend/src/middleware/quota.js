import { HttpError } from '../lib/errors.js';

/**
 * Quota par compte, en mémoire : `max` appels sur `windowMs`. Sert aux routes
 * où l'IA calcule (visage, lecture des pièces), une à trois secondes de
 * processeur chacune : un compte ne peut pas saturer le serveur.
 * À placer après `requireAuth`. Les compteurs se remettent à zéro au
 * redémarrage, ce qui suffit pour un seul serveur.
 */
export function aiQuota({ max = 30, windowMs = 60 * 60 * 1000 } = {}) {
  const calls = new Map();
  return (req, res, next) => {
    const now = Date.now();
    const recent = (calls.get(req.user.id) ?? []).filter(
      (at) => now - at < windowMs,
    );
    if (recent.length >= max) {
      const retryAfter = Math.ceil((recent[0] + windowMs - now) / 1000);
      res.set('Retry-After', String(retryAfter));
      throw new HttpError(
        429,
        'AI_QUOTA_EXCEEDED',
        'Trop d’analyses en peu de temps. Réessayez dans un moment.',
      );
    }
    recent.push(now);
    calls.set(req.user.id, recent);
    next();
  };
}
