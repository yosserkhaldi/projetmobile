import { randomUUID } from 'node:crypto';
import { mkdir, rm, writeFile } from 'node:fs/promises';
import { join, resolve } from 'node:path';

import multer from 'multer';

import { HttpError } from './errors.js';

const MAX_IMAGE_BYTES = 5 * 1024 * 1024;

/** Dossier des fichiers envoyés. Hors du dossier public, servi par des routes protégées. */
export const uploadDir = () => resolve(process.env.UPLOAD_DIR ?? 'uploads');

/** Garde l'image en mémoire, un seul fichier dans le champ `field`. */
export const singleImage = (field) =>
  multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: MAX_IMAGE_BYTES, files: 1 },
  }).single(field);

// Le type est lu dans les premiers octets : l'en-tête Content-Type du client ne suffit pas.
function imageExtension(buffer) {
  if (buffer.length < 12) return null;
  if (buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff) return 'jpg';
  if (buffer.subarray(0, 8).equals(Buffer.from('89504e470d0a1a0a', 'hex'))) {
    return 'png';
  }
  if (
    buffer.subarray(0, 4).toString('ascii') === 'RIFF' &&
    buffer.subarray(8, 12).toString('ascii') === 'WEBP'
  ) {
    return 'webp';
  }
  return null;
}

/** Enregistre l'image reçue et renvoie son nom de fichier. */
export async function saveImage(file, folder) {
  if (!file) {
    throw new HttpError(400, 'FILE_REQUIRED', 'Aucune image reçue.');
  }
  const extension = imageExtension(file.buffer);
  if (!extension) {
    throw new HttpError(
      415,
      'UNSUPPORTED_IMAGE',
      'Format accepté : JPEG, PNG ou WebP.',
    );
  }
  const dir = join(uploadDir(), folder);
  await mkdir(dir, { recursive: true });
  const name = `${randomUUID()}.${extension}`;
  await writeFile(join(dir, name), file.buffer);
  return name;
}

export async function deleteImage(name, folder) {
  if (name) await rm(join(uploadDir(), folder, name), { force: true });
}

export const imagePath = (name, folder) => join(uploadDir(), folder, name);
