import assert from 'node:assert/strict';
import { test } from 'node:test';

import sharp from 'sharp';

import { faceEngine, similarity } from '../src/lib/face.js';

// Le vrai moteur (face-api, TensorFlow.js) : modèles chargés depuis le disque.
test('moteur : une image sans visage ne donne aucun visage', async () => {
  const blank = await sharp({
    create: { width: 640, height: 480, channels: 3, background: '#d9dee8' },
  })
    .jpeg()
    .toBuffer();
  assert.deepEqual(await faceEngine.analyze(blank), { faces: 0 });
});

test('moteur : une image en niveaux de gris est acceptée', async () => {
  const gray = await sharp({
    create: { width: 120, height: 120, channels: 3, background: '#777777' },
  })
    .grayscale()
    .png()
    .toBuffer();
  assert.equal((await faceEngine.analyze(gray)).faces, 0);
});

test('ressemblance : 1 pour la même empreinte, 0 pour deux personnes éloignées', () => {
  const a = Array(128).fill(0);
  assert.equal(similarity(a, a), 1);
  assert.equal(similarity(a, Array(128).fill(0.1)), 0);
  // Distance 0,55 : à mi-chemin.
  assert.equal(similarity(a, Array(128).fill(0.55 / Math.sqrt(128))), 0.5);
});
