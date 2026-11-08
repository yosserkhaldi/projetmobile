import assert from 'node:assert/strict';
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
  data.append('photo', new Blob([PNG], { type: 'image/png' }), 'cin.png');
  return data;
};

const credentials = { identifier: 'sami@example.com', password: 'Password123!' };

/** Appareil qui se connecte : envoie les en-têtes de l'application. */
async function loginFrom(base, deviceId, deviceName, password = 'Password123!') {
  const response = await fetch(`${base}/auth/login`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Device-Id': deviceId,
      'X-Device-Name': deviceName,
    },
    body: JSON.stringify({ ...credentials, password }),
  });
  return { status: response.status, body: await response.json() };
}

async function registerFrom(base, deviceId) {
  const response = await fetch(`${base}/auth/register`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Device-Id': deviceId,
      'X-Device-Name': 'HUAWEI JNY-LX1',
    },
    body: JSON.stringify(driver()),
  });
  return response.json();
}

// Les alertes partent sans être attendues : on laisse la boucle d'événements tourner.
const settle = () => new Promise((resolve) => setTimeout(resolve, 50));

test('appareils : chaque connexion est un appareil, la session courante est signalée', async (t) => {
  const { call, base } = await startApi(t);
  const phone = await registerFrom(base, 'device-huawei');
  const laptop = await loginFrom(base, 'device-pc', 'Chrome Windows');

  const list = await call('GET', '/users/me/sessions', {
    token: laptop.body.accessToken,
  });
  assert.equal(list.status, 200);
  assert.equal(list.body.items.length, 2);
  const current = list.body.items.find((s) => s.current);
  assert.equal(current.deviceName, 'Chrome Windows');
  assert.ok(list.body.items.some((s) => s.deviceName === 'HUAWEI JNY-LX1'));
  assert.ok(phone.accessToken);
});

test('déconnecter un appareil : son accès tombe tout de suite, les autres restent', async (t) => {
  const { call, base } = await startApi(t);
  const phone = await registerFrom(base, 'device-huawei');
  const laptop = await loginFrom(base, 'device-pc', 'Chrome Windows');

  const { body } = await call('GET', '/users/me/sessions', {
    token: laptop.body.accessToken,
  });
  const phoneSession = body.items.find((s) => !s.current);
  const revoke = await call('DELETE', `/users/me/sessions/${phoneSession.id}`, {
    token: laptop.body.accessToken,
  });
  assert.equal(revoke.status, 204);

  // Le jeton d'accès du téléphone est encore valable 15 min, mais refusé.
  assert.equal(
    (await call('GET', '/users/me', { token: phone.accessToken })).status,
    401,
  );
  const refreshed = await call('POST', '/auth/refresh', {
    body: { refreshToken: phone.refreshToken },
  });
  assert.equal(refreshed.status, 401);

  // L'appareil déconnecté à distance ne fait pas tomber les autres sessions.
  assert.equal(
    (await call('GET', '/users/me', { token: laptop.body.accessToken })).status,
    200,
  );
  const again = await call('POST', '/auth/refresh', {
    body: { refreshToken: laptop.body.refreshToken },
  });
  assert.equal(again.status, 200);
});

test('déconnecter les autres appareils : seul celui-ci reste', async (t) => {
  const { call, base } = await startApi(t);
  await registerFrom(base, 'device-huawei');
  await loginFrom(base, 'device-tablet', 'Galaxy Tab');
  const laptop = await loginFrom(base, 'device-pc', 'Chrome Windows');

  const result = await call('POST', '/users/me/sessions/revoke-others', {
    token: laptop.body.accessToken,
  });
  assert.equal(result.body.revoked, 2);
  const { body } = await call('GET', '/users/me/sessions', {
    token: laptop.body.accessToken,
  });
  assert.deepEqual(
    body.items.map((s) => s.deviceName),
    ['Chrome Windows'],
  );
});

test('un appareil ne peut pas déconnecter la session d un autre compte', async (t) => {
  const { call, base } = await startApi(t);
  await registerFrom(base, 'device-huawei');
  const { token: admin } = await createAdmin(call);
  const sami = await loginFrom(base, 'device-pc', 'Chrome Windows');
  const { body } = await call('GET', '/users/me/sessions', {
    token: sami.body.accessToken,
  });
  const res = await call('DELETE', `/users/me/sessions/${body.items[0].id}`, {
    token: admin,
  });
  assert.equal(res.status, 404);
});

test('déconnexion : la session disparaît de la liste', async (t) => {
  const { call, base } = await startApi(t);
  const phone = await registerFrom(base, 'device-huawei');
  const laptop = await loginFrom(base, 'device-pc', 'Chrome Windows');
  await call('POST', '/auth/logout', {
    body: { refreshToken: phone.refreshToken },
  });
  const { body } = await call('GET', '/users/me/sessions', {
    token: laptop.body.accessToken,
  });
  assert.equal(body.items.length, 1);
});

test('historique : connexions réussies et échouées, avec le motif', async (t) => {
  const { call, base } = await startApi(t);
  await registerFrom(base, 'device-huawei');
  await loginFrom(base, 'device-pc', 'Chrome Windows', 'mauvais');
  const ok = await loginFrom(base, 'device-pc', 'Chrome Windows');

  const { body } = await call('GET', '/users/me/login-events', {
    token: ok.body.accessToken,
  });
  const [last, failed, signup] = body.items;
  assert.equal(last.success, true);
  assert.equal(last.method, 'password');
  assert.equal(failed.success, false);
  assert.equal(failed.reason, 'wrong_password');
  assert.equal(failed.deviceName, 'Chrome Windows');
  assert.equal(signup.method, 'register');
  assert.equal(last.userId, undefined);
});

test('alerte : nouvel appareil prévenu sur WhatsApp et par e-mail, appareil connu non', async (t) => {
  const { base, sent } = await startApi(t);
  await registerFrom(base, 'device-huawei');
  const smsAfterSignup = sent.sms.length;

  await loginFrom(base, 'device-huawei', 'HUAWEI JNY-LX1');
  await settle();
  assert.equal(sent.sms.length, smsAfterSignup, 'appareil connu : pas d alerte');
  assert.equal(sent.mail.length, 0);

  await loginFrom(base, 'device-pc', 'Chrome Windows');
  await settle();
  assert.equal(sent.sms.length, smsAfterSignup + 1);
  assert.match(sent.sms.at(-1).text, /Chrome Windows/);
  assert.equal(sent.mail.length, 1);
  assert.equal(sent.mail[0].subject, 'Nouvelle connexion à votre compte');
  assert.match(sent.mail[0].html, /Chrome Windows/);
});

test('identité : photos, envoi, puis verrouillée pendant la vérification', async (t) => {
  const { call } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const token = body.accessToken;
  assert.equal(body.user.identity.status, 'UNVERIFIED');

  const early = await call('POST', '/users/me/identity/submit', {
    token,
    body: { cinNumber: '12345678' },
  });
  assert.equal(early.status, 400);
  assert.equal(early.body.error.code, 'IDENTITY_PHOTOS_REQUIRED');

  for (const side of ['front', 'back']) {
    const res = await call('PUT', `/users/me/identity/${side}`, {
      token,
      form: form(),
    });
    assert.equal(res.status, 200);
  }
  const badCin = await call('POST', '/users/me/identity/submit', {
    token,
    body: { cinNumber: '1234' },
  });
  assert.equal(badCin.status, 400);

  const submitted = await call('POST', '/users/me/identity/submit', {
    token,
    body: { cinNumber: '12345678' },
  });
  assert.equal(submitted.body.user.identity.status, 'PENDING');
  assert.equal(submitted.body.user.identity.cinNumber, '12345678');

  const locked = await call('PUT', '/users/me/identity/front', {
    token,
    form: form(),
  });
  assert.equal(locked.status, 409);
  assert.equal(locked.body.error.code, 'IDENTITY_LOCKED');

  const own = await call('GET', `/users/${body.user.id}/identity/front`, {
    token,
  });
  assert.deepEqual(own.bytes, PNG);
});

async function pendingDriver(call) {
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const token = body.accessToken;
  for (const side of ['front', 'back']) {
    await call('PUT', `/users/me/identity/${side}`, { token, form: form() });
  }
  await call('POST', '/users/me/identity/submit', {
    token,
    body: { cinNumber: '12345678' },
  });
  return { token, id: body.user.id };
}

test('identité : file d administration, validation et notification', async (t) => {
  const { call, sent } = await startApi(t);
  const sami = await pendingDriver(call);
  const { token: admin } = await createAdmin(call);

  // Réservé aux administrateurs.
  assert.equal(
    (await call('GET', '/users/identity/pending', { token: sami.token }))
      .status,
    403,
  );
  const queue = await call('GET', '/users/identity/pending', { token: admin });
  assert.deepEqual(
    queue.body.items.map((u) => u.id),
    [sami.id],
  );
  const photo = await call('GET', `/users/${sami.id}/identity/back`, {
    token: admin,
  });
  assert.equal(photo.status, 200);

  const approved = await call('POST', `/users/${sami.id}/identity/approve`, {
    token: admin,
  });
  assert.equal(approved.body.user.identity.status, 'VERIFIED');
  await settle();
  assert.match(sent.sms.at(-1).text, /identité est vérifiée/);

  const twice = await call('POST', `/users/${sami.id}/identity/approve`, {
    token: admin,
  });
  assert.equal(twice.status, 409);
  const row = await prisma.user.findUnique({ where: { id: sami.id } });
  assert.ok(row.identityReviewedAt);
});

test('identité : refus avec motif, puis nouvel envoi possible', async (t) => {
  const { call, sent } = await startApi(t);
  const sami = await pendingDriver(call);
  const { token: admin } = await createAdmin(call);

  const noReason = await call('POST', `/users/${sami.id}/identity/reject`, {
    token: admin,
    body: {},
  });
  assert.equal(noReason.status, 400);

  const rejected = await call('POST', `/users/${sami.id}/identity/reject`, {
    token: admin,
    body: { reason: 'Photo floue' },
  });
  assert.equal(rejected.body.user.identity.status, 'REJECTED');
  assert.equal(rejected.body.user.identity.rejectionReason, 'Photo floue');
  await settle();
  assert.match(sent.sms.at(-1).text, /Photo floue/);

  const retry = await call('PUT', '/users/me/identity/front', {
    token: sami.token,
    form: form(),
  });
  assert.equal(retry.status, 200);
  const resubmitted = await call('POST', '/users/me/identity/submit', {
    token: sami.token,
    body: { cinNumber: '12345678' },
  });
  assert.equal(resubmitted.body.user.identity.status, 'PENDING');
  assert.equal(resubmitted.body.user.identity.rejectionReason, null);
});

test('identité : un numéro de CIN ne sert qu à un seul compte', async (t) => {
  const { call } = await startApi(t);
  await pendingDriver(call);
  const { body } = await call('POST', '/auth/register', {
    body: driver({ email: 'autre@example.com', phone: '20777000' }),
  });
  for (const side of ['front', 'back']) {
    await call('PUT', `/users/me/identity/${side}`, {
      token: body.accessToken,
      form: form(),
    });
  }
  const dup = await call('POST', '/users/me/identity/submit', {
    token: body.accessToken,
    body: { cinNumber: '12345678' },
  });
  assert.equal(dup.status, 409);
  assert.equal(dup.body.error.code, 'CIN_IN_USE');
});

test('requireVerifiedIdentity : réservé aux identités vérifiées', async () => {
  const { requireVerifiedIdentity } = await import('../src/middleware/auth.js');
  assert.throws(
    () => requireVerifiedIdentity({ user: { identityStatus: 'PENDING' } }, {}, () => {}),
    /identité doit être vérifiée/,
  );
  let passed = false;
  requireVerifiedIdentity({ user: { identityStatus: 'VERIFIED' } }, {}, () => {
    passed = true;
  });
  assert.ok(passed);
});
