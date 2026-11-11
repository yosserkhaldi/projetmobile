import assert from 'node:assert/strict';
import { after, before, beforeEach, test } from 'node:test';

import { driver, migrate, prisma, resetDatabase, startApi } from './helpers.js';

before(migrate);
beforeEach(resetDatabase);
after(() => prisma.$disconnect());

async function register(call) {
  const response = await call('POST', '/auth/register', { body: driver() });
  assert.equal(response.status, 201);
  return response.body;
}

test('identité vérifiée : le nom ne se modifie plus depuis le profil', async (t) => {
  const { call } = await startApi(t);
  const auth = await register(call);
  const token = auth.accessToken;
  // Avant vérification : modifiable (onboarding).
  let res = await call('PATCH', '/users/me', { token, body: { firstName: 'Samy' } });
  assert.equal(res.status, 200);

  await prisma.user.update({
    where: { id: auth.user.id },
    data: { identityStatus: 'VERIFIED' },
  });
  res = await call('PATCH', '/users/me', { token, body: { lastName: 'Autre' } });
  assert.equal(res.status, 409);
  assert.equal(res.body.error.code, 'IDENTITY_NAME_LOCKED');
  // Le même nom renvoyé (formulaire complet) passe.
  res = await call('PATCH', '/users/me', {
    token,
    body: { firstName: 'samy', lastName: 'Ben Ali', language: 'FR' },
  });
  assert.equal(res.status, 200);
});

test('permis validé puis modifié : il repasse en revue', async (t) => {
  const { call } = await startApi(t);
  const auth = await register(call);
  await prisma.user.update({
    where: { id: auth.user.id },
    data: { licenseStatus: 'VERIFIED', licenseNumber: '12/345678', licenseCategory: 'B' },
  });
  let res = await call('PATCH', '/users/me', {
    token: auth.accessToken,
    body: { licenseNumber: '12/345678', licenseCategory: 'B' },
  });
  assert.equal(res.status, 200);
  assert.equal(
    (await prisma.user.findUnique({ where: { id: auth.user.id } })).licenseStatus,
    'VERIFIED',
  );
  res = await call('PATCH', '/users/me', {
    token: auth.accessToken,
    body: { licenseCategory: 'B, C, C+E, D, D1, D+E' },
  });
  assert.equal(res.status, 200);
  assert.equal(
    (await prisma.user.findUnique({ where: { id: auth.user.id } })).licenseStatus,
    'TO_REVIEW',
  );
});

test('identifiant mal formé : 404, pas une erreur serveur', async (t) => {
  const { call } = await startApi(t);
  const { accessToken: token } = await register(call);
  assert.equal((await call('GET', '/accidents/pas-un-uuid', { token })).status, 404);
  assert.equal((await call('GET', '/vehicles/pas-un-uuid', { token })).status, 404);
  assert.equal((await call('GET', '/vehicles?page=abc&pageSize=x', { token })).status, 200);
  assert.equal((await call('GET', '/vehicles/alerts?days=abc', { token })).status, 200);
});

test('déclaration avec un croquis détaillé : acceptée (plus de 100 Ko)', async (t) => {
  const { call } = await startApi(t);
  const { accessToken: token } = await register(call);
  const strokes = Array.from({ length: 40 }, () =>
    Array.from({ length: 200 }, (_, i) => ({ x: i * 1.123456789, y: i * 2.987654321 })),
  );
  const res = await call('POST', '/accidents', {
    token,
    body: {
      clientId: 'acc-croquis',
      currentStep: 6,
      place: 'Tunis',
      occurredAt: new Date().toISOString(),
      payload: { sketch_strokes_json: JSON.stringify(strokes) },
    },
  });
  assert.ok(JSON.stringify(strokes).length > 100_000);
  assert.equal(res.status, 201);
});

test('lecture de document sans photo : 400', async (t) => {
  const { call } = await startApi(t);
  const { accessToken: token } = await register(call);
  const form = new FormData();
  form.append('kind', 'INSURANCE');
  const res = await call('POST', '/vehicles/scan', { token, form });
  assert.equal(res.status, 400);
});
