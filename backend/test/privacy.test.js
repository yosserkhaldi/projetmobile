import assert from 'node:assert/strict';
import { existsSync } from 'node:fs';
import { join } from 'node:path';
import { after, before, beforeEach, test } from 'node:test';

import {
  createAdmin,
  driver,
  migrate,
  prisma,
  resetDatabase,
  startApi,
} from './helpers.js';

before(migrate);
beforeEach(resetDatabase);
after(() => prisma.$disconnect());

const PNG = Buffer.from(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  'base64',
);
const form = () => {
  const data = new FormData();
  data.append('photo', new Blob([PNG], { type: 'image/png' }), 'p.png');
  return data;
};

test('inscription : sans consentement, pas de compte', async (t) => {
  const { call } = await startApi(t);
  const refused = await call('POST', '/auth/register', {
    body: driver({ consent: false }),
  });
  assert.equal(refused.status, 400);
  assert.match(refused.body.error.message, /traitement de vos données/);
  assert.equal(await prisma.user.count(), 0);

  const ok = await call('POST', '/auth/register', { body: driver() });
  assert.equal(ok.status, 201);
  const row = await prisma.user.findFirst();
  assert.ok(row.consentAt, 'date du consentement enregistrée');
});

test('export : toutes les données du compte, sans secret', async (t) => {
  const { call } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const res = await call('GET', '/users/me/export', {
    token: body.accessToken,
  });
  assert.equal(res.status, 200);
  assert.equal(res.body.account.email, 'sami@example.com');
  assert.ok(res.body.account.consentAt);
  assert.equal(res.body.devices.length, 1);
  assert.equal(res.body.signIns[0].method, 'register');
  assert.match(res.body.legalBasis, /2004-63/);
  const text = JSON.stringify(res.body);
  assert.doesNotMatch(text, /passwordHash|tokenHash|\$2[aby]\$/);
});

test('suppression : mot de passe exigé, compte anonymisé, photos effacées', async (t) => {
  const { call } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const token = body.accessToken;
  const sent = await call('PUT', '/users/me/photo', { token, form: form() });
  const photo = join(process.env.UPLOAD_DIR, 'users', sent.body.user.photoId);
  assert.ok(existsSync(photo));

  const wrong = await call('DELETE', '/users/me', {
    token,
    body: { password: 'mauvais' },
  });
  assert.equal(wrong.status, 401);

  const deleted = await call('DELETE', '/users/me', {
    token,
    body: { password: 'Password123!' },
  });
  assert.equal(deleted.status, 204);

  const row = await prisma.user.findUnique({ where: { id: body.user.id } });
  assert.equal(row.firstName, 'Compte');
  assert.notEqual(row.email, 'sami@example.com');
  assert.equal(row.photoFile, null);
  assert.ok(row.deletedAt);
  assert.equal(existsSync(photo), false);
  assert.equal(await prisma.loginEvent.count(), 0);

  // Plus d'accès, plus de connexion possible, e-mail et téléphone libérés.
  assert.equal((await call('GET', '/users/me', { token })).status, 401);
  const login = await call('POST', '/auth/login', {
    body: { identifier: 'sami@example.com', password: 'Password123!' },
  });
  assert.equal(login.status, 401);
  const again = await call('POST', '/auth/register', { body: driver() });
  assert.equal(again.status, 201);
});

test('suppression : refusée pour un administrateur, absente de la liste des comptes', async (t) => {
  const { call } = await startApi(t);
  const { token } = await createAdmin(call);
  const refused = await call('DELETE', '/users/me', {
    token,
    body: { password: 'Password123!' },
  });
  assert.equal(refused.status, 409);

  const { body } = await call('POST', '/auth/register', { body: driver() });
  await call('DELETE', '/users/me', {
    token: body.accessToken,
    body: { password: 'Password123!' },
  });
  const list = await call('GET', '/users', { token });
  assert.equal(list.body.total, 1, 'seul l administrateur reste');
});

test('statistiques : réservées aux administrateurs, comptes et inscriptions par jour', async (t) => {
  const { call } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  await call('POST', '/auth/register', {
    body: driver({ email: 'b@example.com', phone: '20777000' }),
  });
  const { token } = await createAdmin(call);
  await call('POST', '/companies', { token, body: { name: 'COMAR' } });
  await call('POST', '/auth/login', {
    body: { identifier: 'sami@example.com', password: 'mauvais' },
  });

  assert.equal(
    (await call('GET', '/users/stats', { token: body.accessToken })).status,
    403,
  );
  const stats = await call('GET', '/users/stats?days=7', { token });
  assert.equal(stats.status, 200);
  assert.equal(stats.body.users.total, 3);
  assert.deepEqual(stats.body.users.byRole, { DRIVER: 2, AGENT: 0, ADMIN: 1 });
  assert.equal(stats.body.identity.UNVERIFIED, 2);
  assert.equal(stats.body.companies, 1);
  assert.equal(stats.body.signIns7Days.failed, 1);
  assert.equal(stats.body.signups.length, 7);
  assert.equal(stats.body.signups.at(-1).count, 3);
});
