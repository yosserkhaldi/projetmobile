import { ZodError } from 'zod';

/** Erreur renvoyée au client : `{ error: { code, message } }`. */
export class HttpError extends Error {
  constructor(status, code, message) {
    super(message);
    this.status = status;
    this.code = code;
  }
}

export const isUniqueViolation = (err) => err?.code === 'P2002';
export const isForeignKeyViolation = (err) => err?.code === 'P2003';
const isRecordNotFound = (err) => err?.code === 'P2025';

export function notFoundHandler(_req, _res, next) {
  next(new HttpError(404, 'NOT_FOUND', 'Ressource introuvable.'));
}

export function errorHandler(err, _req, res, _next) {
  const send = (status, code, message, extra) =>
    res.status(status).json({ error: { code, message, ...extra } });

  if (err instanceof ZodError) {
    return send(
      400,
      'VALIDATION_ERROR',
      err.issues[0]?.message ?? 'Données invalides.',
      {
        fields: err.issues.map((i) => ({
          field: i.path.join('.'),
          message: i.message,
        })),
      },
    );
  }
  if (err instanceof HttpError) return send(err.status, err.code, err.message);
  if (isRecordNotFound(err)) {
    return send(404, 'NOT_FOUND', 'Ressource introuvable.');
  }
  // Erreurs du corps de requête levées par express.json (JSON invalide, trop long).
  if (err?.status >= 400 && err?.status < 500) {
    return send(err.status, 'BAD_REQUEST', 'Requête invalide.');
  }
  console.error(err);
  return send(500, 'INTERNAL_ERROR', 'Erreur interne du serveur.');
}
