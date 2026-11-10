import assert from 'node:assert/strict';
import { existsSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { after, before, beforeEach, test } from 'node:test';

import {
  createAdmin,
  driver,
  image,
  migrate,
  prisma,
  resetDatabase,
  startApi,
} from './helpers.js';

before(migrate);
beforeEach(resetDatabase);
after(() => prisma.$disconnect());

// Plus petit PNG valide (1 × 1 pixel).
const PNG = Buffer.from(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  'base64',
);
const JPEG = Buffer.concat([
  Buffer.from([0xff, 0xd8, 0xff, 0xe0]),
  Buffer.alloc(60, 1),
]);

const form = (bytes, name = 'photo.png', type = 'image/png') => {
  const data = new FormData();
  data.append('photo', new Blob([bytes], { type }), name);
  return data;
};

const folder = () => join(process.env.UPLOAD_DIR, 'users');

test('photo de profil : envoi, lecture, remplacement, suppression', async (t) => {
  const { call } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const token = body.accessToken;
  const id = body.user.id;
  assert.equal(body.user.photoId, null);

  const sent = await call('PUT', '/users/me/photo', { token, form: form(PNG) });
  assert.equal(sent.status, 200);
  const first = sent.body.user.photoId;
  assert.match(first, /^[0-9a-f-]{36}\.png$/);

  const read = await call('GET', `/users/${id}/photo`, { token });
  assert.equal(read.status, 200);
  assert.equal(read.type, 'image/png');
  assert.deepEqual(read.bytes, PNG);

  // Un nouvel envoi remplace le fichier précédent.
  const replaced = await call('PUT', '/users/me/photo', {
    token,
    form: form(JPEG, 'photo.jpg', 'image/jpeg'),
  });
  const second = replaced.body.user.photoId;
  assert.match(second, /\.jpg$/);
  assert.equal(existsSync(join(folder(), first)), false);
  assert.equal(existsSync(join(folder(), second)), true);

  const removed = await call('DELETE', '/users/me/photo', { token });
  assert.equal(removed.body.user.photoId, null);
  assert.equal(existsSync(join(folder(), second)), false);
  assert.equal((await call('GET', `/users/${id}/photo`, { token })).status, 404);
});

test('photo du permis : champ séparé de la photo de profil', async (t) => {
  const { call } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const token = body.accessToken;
  const sent = await call('PUT', '/users/me/license-photo', {
    token,
    form: form(PNG),
  });
  assert.equal(sent.status, 200);
  assert.ok(sent.body.user.licensePhotoId);
  assert.equal(sent.body.user.photoId, null);
  const read = await call('GET', `/users/${body.user.id}/license-photo`, {
    token,
  });
  assert.deepEqual(read.bytes, PNG);
});

test('photos : refuse ce qui n est pas une image, quel que soit le type annoncé', async (t) => {
  const { call } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const token = body.accessToken;
  const before = existsSync(folder()) ? readdirSync(folder()).length : 0;

  const fake = await call('PUT', '/users/me/photo', {
    token,
    form: form(Buffer.from('<script>alert(1)</script>'), 'x.png', 'image/png'),
  });
  assert.equal(fake.status, 415);

  const missing = await call('PUT', '/users/me/photo', {
    token,
    form: new FormData(),
  });
  assert.equal(missing.status, 400);

  const huge = await call('PUT', '/users/me/photo', {
    token,
    form: form(Buffer.concat([PNG, Buffer.alloc(6 * 1024 * 1024)])),
  });
  assert.equal(huge.status, 413);

  const after = existsSync(folder()) ? readdirSync(folder()).length : 0;
  assert.equal(after, before, 'aucun fichier écrit');
});

test('photos : visibles par le titulaire et les administrateurs seulement', async (t) => {
  const { call } = await startApi(t);
  const { body: owner } = await call('POST', '/auth/register', {
    body: driver(),
  });
  await call('PUT', '/users/me/license-photo', {
    token: owner.accessToken,
    form: form(PNG),
  });
  const { body: other } = await call('POST', '/auth/register', {
    body: driver({ email: 'autre@example.com', phone: '20777000' }),
  });
  const { token: admin } = await createAdmin(call);
  const path = `/users/${owner.user.id}/license-photo`;

  assert.equal((await call('GET', path)).status, 401);
  assert.equal(
    (await call('GET', path, { token: other.accessToken })).status,
    403,
  );
  assert.equal((await call('GET', path, { token: admin })).status, 200);
});

test('photo du permis : l IA lit numéro, catégories et dates', async (t) => {
  const { call } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const data = new FormData();
  data.append('photo', new Blob([image('license')], { type: 'image/png' }), 'permis.png');
  const res = await call('PUT', '/users/me/license-photo', {
    token: body.accessToken,
    form: data,
  });
  assert.equal(res.status, 200);
  assert.ok(res.body.user.licensePhotoId);
  assert.deepEqual(res.body.extracted, {
    number: '12/345678',
    categories: ['B', 'B+E'],
    issuedAt: '2020-05-10',
    expiresAt: '2030-05-10',
    birthDate: '1999-03-12',
    lastName: 'BEN ALI',
    firstName: 'SAMI',
    cinNumber: '12345678',
    nameMatchesAccount: true,
    birthDateMatchesIdentity: null,
    cinMatchesIdentity: null,
  });
  // Rien n'est enregistré sans confirmation de l'utilisateur.
  assert.equal(res.body.user.licenseNumber, null);
});

test('photo du permis : un permis à un autre nom est signalé', async (t) => {
  const { call } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const data = new FormData();
  data.append(
    'photo',
    new Blob([image('license-other')], { type: 'image/png' }),
    'permis.png',
  );
  const res = await call('PUT', '/users/me/license-photo', {
    token: body.accessToken,
    form: data,
  });
  // Même nom de famille (un frère, une sœur), autre prénom.
  assert.equal(res.body.extracted.nameMatchesAccount, false);
});

test('photo du permis : un passeport est refusé, rien n est enregistré', async (t) => {
  const { call } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const data = new FormData();
  data.append('photo', new Blob([image('passport')], { type: 'image/png' }), 'p.png');
  const res = await call('PUT', '/users/me/license-photo', {
    token: body.accessToken,
    form: data,
  });
  assert.equal(res.status, 422);
  assert.equal(res.body.error.code, 'NOT_A_LICENSE');
  const me = await call('GET', '/users/me', { token: body.accessToken });
  assert.equal(me.body.user.licensePhotoId, null);
});
