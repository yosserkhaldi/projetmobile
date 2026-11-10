import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';

import sharp from 'sharp';

// Reconnaissance faciale exécutée sur le serveur (face-api, TensorFlow.js en
// WebAssembly). Aucune photo ni empreinte faciale n'est envoyée à un service
// tiers : tout reste sur la machine de l'API.

/** Ressemblance minimale pour valider une identité sans administrateur. */
export const AUTO_APPROVE_MATCH = 0.6;
/** Entre deux images de la vérification du visage (tête tournée comprise). */
export const SAME_PERSON_MATCH = 0.4;
/** Tête de face : le nez reste près du milieu des yeux. */
export const CENTER_MAX_YAW = 0.15;
/** Tête tournée : le nez s'écarte nettement du milieu des yeux. */
export const TURN_MIN_YAW = 0.18;

const MAX_SIDE = 1024;

let models = null;

async function loadModels() {
  const faceapi = await import('@vladmandic/face-api/dist/face-api.node-wasm.js');
  await faceapi.tf.setBackend('wasm');
  await faceapi.tf.ready();
  const require = createRequire(import.meta.url);
  const dir = join(
    dirname(require.resolve('@vladmandic/face-api/package.json')),
    'model',
  );
  await Promise.all([
    faceapi.nets.ssdMobilenetv1.loadFromDisk(dir),
    faceapi.nets.faceLandmark68Net.loadFromDisk(dir),
    faceapi.nets.faceRecognitionNet.loadFromDisk(dir),
  ]);
  return faceapi;
}

/** Image décodée en RGB. Une petite image reçoit une marge : le détecteur
 * repère mal un visage qui touche les bords. */
async function toTensor(faceapi, buffer, angle = 0) {
  // Orientation EXIF appliquée d'abord, puis l'angle essayé : les dimensions
  // sont celles de l'image tournée.
  const exif = await sharp(buffer).rotate().toBuffer();
  const upright = angle ? await sharp(exif).rotate(angle).toBuffer() : exif;
  const { width = 0, height = 0 } = await sharp(upright).metadata();
  const longest = Math.max(width, height);
  const pad = longest < 400 ? Math.round(longest / 2) : 0;
  const { data, info } = await sharp(upright)
    .extend({ top: pad, bottom: pad, left: pad, right: pad, background: '#808080' })
    .resize({ width: MAX_SIDE, height: MAX_SIDE, fit: 'inside', withoutEnlargement: true })
    .removeAlpha()
    .toColourspace('srgb')
    .raw()
    .toBuffer({ resolveWithObject: true });
  const tensor = faceapi.tf.tensor3d(new Uint8Array(data), [
    info.height,
    info.width,
    info.channels,
  ]);
  const scale = info.width / (width + 2 * pad);
  /** Cadre du visage ramené à l'image d'origine, en fractions (0 à 1). */
  const frame = ({ x, y, width: w, height: h }) => ({
    x: (x / scale - pad) / width,
    y: (y / scale - pad) / height,
    width: w / scale / width,
    height: h / scale / height,
  });
  return { tensor, frame };
}

/**
 * Rotation de la tête, d'après les 68 points du visage : écart du bout du nez
 * (30) au milieu des coins externes des yeux (36, 45), rapporté à l'écart des
 * yeux. 0 de face, environ ±0,3 à ±0,5 tête tournée. Le signe dépend du sens
 * de rotation et du miroir éventuel de la caméra.
 */
function yawOf(landmarks) {
  const p = landmarks.positions;
  const middle = (p[36].x + p[45].x) / 2;
  return (p[30].x - middle) / (p[45].x - p[36].x);
}

const area = (d) => d.detection.box.width * d.detection.box.height;

/** Sens essayés : à l'endroit d'abord, puis couché d'un côté et de l'autre. */
const ROTATIONS = [0, 90, 270, 180];

/** Confiance à partir de laquelle on ne cherche pas plus loin. Mesuré : un
 * vrai visage 0,99 à 1, un motif pris pour un visage sur une page tournée
 * 0,92 à 0,93. */
const CLEAR_FACE = 0.97;

async function detect(faceapi, buffer, rotation) {
  const { tensor, frame } = await toTensor(faceapi, buffer, rotation);
  try {
    const found = await faceapi
      .detectAllFaces(tensor, new faceapi.SsdMobilenetv1Options({ minConfidence: 0.5 }))
      .withFaceLandmarks()
      .withFaceDescriptors();
    if (found.length === 0) return null;
    const main = found.reduce((a, b) => (area(b) > area(a) ? b : a));
    // Inclinaison de la ligne des yeux, en degrés : 0 à l'endroit, ±90 couché.
    const p = main.landmarks.positions;
    const roll =
      (Math.atan2(p[45].y - p[36].y, p[45].x - p[36].x) * 180) / Math.PI;
    return {
      faces: found.length,
      descriptor: Array.from(main.descriptor),
      yaw: yawOf(main.landmarks),
      roll,
      confidence: main.detection.score,
      box: frame(main.detection.box),
    };
  } finally {
    tensor.dispose();
  }
}

export const faceEngine = {
  /**
   * Analyse une image. Renvoie le nombre de visages et, pour le plus grand,
   * son empreinte (128 nombres), la rotation de la tête, son cadre dans
   * l'image tournée (fractions de la largeur et de la hauteur) et `rotation`,
   * l'angle qui met le visage à l'endroit.
   *
   * Une pièce photographiée de travers (téléphone en portrait) montre un
   * visage couché : sans visage à l'endroit, on essaie les trois autres sens.
   */
  async analyze(buffer) {
    models ??= loadModels().catch((err) => {
      models = null;
      throw err;
    });
    const faceapi = await models;
    // Sur une page tournée, un motif peut passer pour un visage peu sûr : on
    // garde le sens où le visage, yeux à l'horizontale, est le plus net. Un
    // visage très net à l'endroit suffit (cas courant, une seule analyse).
    let best = null;
    for (const rotation of ROTATIONS) {
      const found = await detect(faceapi, buffer, rotation);
      if (!found) continue;
      const upright = Math.abs(found.roll) <= 30;
      const candidate = { ...found, rotation, upright };
      if (upright && found.confidence >= CLEAR_FACE) return candidate;
      if (
        !best ||
        (upright && !best.upright) ||
        (upright === best.upright && found.confidence > best.confidence)
      ) {
        best = candidate;
      }
    }
    return best ?? { faces: 0 };
  },
};

/**
 * Ressemblance entre deux empreintes, de 0 à 1. La distance euclidienne vaut
 * environ 0,3 à 0,5 pour une même personne et plus de 0,7 pour deux personnes
 * différentes : 0,3 donne 1, 0,8 donne 0.
 */
export function similarity(a, b) {
  let sum = 0;
  for (let i = 0; i < a.length; i++) sum += (a[i] - b[i]) ** 2;
  const distance = Math.sqrt(sum);
  const score = Math.min(1, Math.max(0, (0.8 - distance) / 0.5));
  return Math.round(score * 100) / 100;
}
