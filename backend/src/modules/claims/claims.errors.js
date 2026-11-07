export class HttpError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

export const badRequest = (message) => new HttpError(400, message);
export const forbidden = (message = 'Action non autorisée.') =>
  new HttpError(403, message);
export const notFound = () => new HttpError(404, 'Dossier introuvable.');
export const conflict = (message) => new HttpError(409, message);
