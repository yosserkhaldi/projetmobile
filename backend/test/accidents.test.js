import assert from 'node:assert/strict';
import { after, before, beforeEach, test } from 'node:test';

import { driver, migrate, prisma, resetDatabase, startApi } from './helpers.js';

before(migrate);
beforeEach(resetDatabase);
after(() => prisma.$disconnect());

const draft = (overrides = {}) => ({
  clientId: 'local-accident-001',
  currentStep: 2,
  place: 'Avenue Habib Bourguiba, Tunis',
  occurredAt: '2026-11-08T09:30:00.000Z',
  payload: { weather: 'Ensoleillé', road: 'Sèche', evidencePaths: {} },
  ...overrides,
});

async function register(call, overrides = {}) {
  const response = await call('POST', '/auth/register', {
    body: driver(overrides),
  });
  assert.equal(response.status, 201);
  return response.body;
}

test('les routes accidents exigent un conducteur authentifié', async (t) => {
  const { call } = await startApi(t);
  assert.equal((await call('GET', '/accidents')).status, 401);
  const admin = await register(call, {
    email: 'admin-accidents@example.com',
    phone: '20111222',
  });
  await prisma.user.update({
    where: { id: admin.user.id },
    data: { role: 'ADMIN' },
  });
  assert.equal(
    (await call('GET', '/accidents', { token: admin.accessToken })).status,
    403,
  );
});

test('crée, liste et recharge un brouillon complet', async (t) => {
  const { call } = await startApi(t);
  const auth = await register(call);
  const created = await call('POST', '/accidents', {
    token: auth.accessToken,
    body: draft(),
  });
  assert.equal(created.status, 201);
  assert.equal(created.body.accident.status, 'DRAFT');
  assert.equal(created.body.accident.revision, 1);
  assert.equal(created.body.accident.payload.weather, 'Ensoleillé');
  const list = await call('GET', '/accidents?status=DRAFT', {
    token: auth.accessToken,
  });
  assert.equal(list.body.accidents.length, 1);
  const loaded = await call(
    'GET',
    `/accidents/${created.body.accident.id}`,
    { token: auth.accessToken },
  );
  assert.equal(loaded.body.accident.place, draft().place);
});

test('le même clientId met à jour sans créer de doublon', async (t) => {
  const { call } = await startApi(t);
  const auth = await register(call);
  const first = await call('POST', '/accidents', {
    token: auth.accessToken,
    body: draft(),
  });
  const retry = await call('POST', '/accidents', {
    token: auth.accessToken,
    body: draft({ currentStep: 3, place: 'La Marsa' }),
  });
  assert.equal(retry.status, 200);
  assert.equal(retry.body.accident.id, first.body.accident.id);
  assert.equal(retry.body.accident.revision, 2);
  assert.equal(await prisma.accident.count(), 1);
});

test('la révision empêche d’écraser une version plus récente', async (t) => {
  const { call } = await startApi(t);
  const auth = await register(call);
  const { body } = await call('POST', '/accidents', {
    token: auth.accessToken,
    body: draft(),
  });
  const id = body.accident.id;
  const updated = await call('PATCH', `/accidents/${id}`, {
    token: auth.accessToken,
    body: { revision: 1, place: 'Sidi Bou Saïd' },
  });
  assert.equal(updated.body.accident.revision, 2);
  const stale = await call('PATCH', `/accidents/${id}`, {
    token: auth.accessToken,
    body: { revision: 1, place: 'Ancienne valeur' },
  });
  assert.equal(stale.status, 409);
  assert.equal(stale.body.error.code, 'SYNC_CONFLICT');
});

test('un conducteur ne voit pas le brouillon d’un autre', async (t) => {
  const { call } = await startApi(t);
  const first = await register(call);
  const second = await register(call, {
    email: 'autre@example.com',
    phone: '20222333',
  });
  const created = await call('POST', '/accidents', {
    token: first.accessToken,
    body: draft(),
  });
  const hidden = await call(
    'GET',
    `/accidents/${created.body.accident.id}`,
    { token: second.accessToken },
  );
  assert.equal(hidden.status, 404);
});

test('la transmission verrouille définitivement la déclaration', async (t) => {
  const { call } = await startApi(t);
  const auth = await register(call);
  const created = await call('POST', '/accidents', {
    token: auth.accessToken,
    body: draft(),
  });
  const id = created.body.accident.id;
  const submitted = await call('POST', `/accidents/${id}/submit`, {
    token: auth.accessToken,
  });
  assert.equal(submitted.body.accident.status, 'SUBMITTED');
  assert.ok(submitted.body.accident.submittedAt);
  const update = await call('PATCH', `/accidents/${id}`, {
    token: auth.accessToken,
    body: { revision: 2, place: 'Modification interdite' },
  });
  assert.equal(update.status, 409);
  assert.equal(
    (await call('DELETE', `/accidents/${id}`, { token: auth.accessToken }))
      .status,
    409,
  );
});

test('un brouillon non transmis peut être supprimé', async (t) => {
  const { call } = await startApi(t);
  const auth = await register(call);
  const created = await call('POST', '/accidents', {
    token: auth.accessToken,
    body: draft(),
  });
  const removed = await call(
    'DELETE',
    `/accidents/${created.body.accident.id}`,
    { token: auth.accessToken },
  );
  assert.equal(removed.status, 204);
  assert.equal(await prisma.accident.count(), 0);
});
