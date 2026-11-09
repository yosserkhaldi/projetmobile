import { HttpError } from '../../lib/errors.js';

export const badRequest = (message) => new HttpError(400, 'BAD_REQUEST', message);
export const notFound = () =>
  new HttpError(404, 'NOT_FOUND', 'Dossier introuvable.');
export const conflict = (message) => new HttpError(409, 'CONFLICT', message);
