import assert from 'node:assert/strict';
import { after, before, beforeEach, test } from 'node:test';

import {
  codeFrom,
  driver,
  migrate,
  prisma,
  resetDatabase,
  startApi,
} from './helpers.js';

before(migrate);
beforeEach(resetDatabase);
after(() => prisma.$disconnect());

test('inscription : crée un conducteur et ne renvoie aucun secret', async (t) => {
  const { call, sent } = await startApi(t);
  const { status, body } = await call('POST', '/auth/register', {
    body: driver({ email: ' Sami@Example.com ', role: 'ADMIN' }),
  });
  assert.equal(status, 201);
  assert.equal(body.user.email, 'sami@example.com');
  assert.equal(body.user.phone, '+21620123456');
  assert.equal(body.user.role, 'DRIVER', 'le rôle envoyé est ignoré');
  assert.equal(body.user.phoneVerified, false);
  assert.equal(body.user.passwordHash, undefined);
  assert.ok(body.accessToken && body.refreshToken);
  assert.equal(sent.sms.length, 1);

  const row = await prisma.user.findUnique({
    where: { email: 'sami@example.com' },
  });
  assert.ok(row.passwordHash.startsWith('$2'), 'mot de passe haché avec bcrypt');
});

test('inscription : refuse un doublon et les données invalides', async (t) => {
  const { call } = await startApi(t);
  await call('POST', '/auth/register', { body: driver() });

  const duplicate = await call('POST', '/auth/register', {
    body: driver({ phone: '20000111' }),
  });
  assert.equal(duplicate.status, 409);
  assert.equal(duplicate.body.error.code, 'ALREADY_EXISTS');

  const short = await call('POST', '/auth/register', {
    body: driver({ email: 'a@b.tn', phone: '20000222', password: 'court' }),
  });
  assert.equal(short.status, 400);
  assert.match(short.body.error.message, /8 caractères/);

  const badEmail = await call('POST', '/auth/register', {
    body: driver({ email: 'pas-un-email', phone: '20000333' }),
  });
  assert.equal(badEmail.status, 400);
});

test('connexion : mauvais mot de passe et e-mail inconnu répondent pareil', async (t) => {
  const { call } = await startApi(t);
  await call('POST', '/auth/register', { body: driver() });

  const wrong = await call('POST', '/auth/login', {
    body: { identifier: 'sami@example.com', password: 'mauvais-mot-de-passe' },
  });
  const unknown = await call('POST', '/auth/login', {
    body: { identifier: 'inconnu@example.com', password: 'mauvais-mot-de-passe' },
  });
  assert.equal(wrong.status, 401);
  assert.deepEqual(wrong.body, unknown.body);

  const ok = await call('POST', '/auth/login', {
    body: { identifier: 'SAMI@example.com', password: 'Password123!' },
  });
  assert.equal(ok.status, 200);
  const me = await call('GET', '/users/me', { token: ok.body.accessToken });
  assert.equal(me.body.user.email, 'sami@example.com');

  const byPhone = await call('POST', '/auth/login', {
    body: { identifier: '20 123 456', password: 'Password123!' },
  });
  assert.equal(byPhone.status, 200);
});

test('connexion : compte bloqué 15 min après 5 échecs, même avec le bon mot de passe', async (t) => {
  const { call } = await startApi(t);
  await call('POST', '/auth/register', { body: driver() });
  const attempt = (password) =>
    call('POST', '/auth/login', {
      body: { identifier: 'sami@example.com', password },
    });

  for (let i = 0; i < 5; i += 1) {
    assert.equal((await attempt('mauvais')).status, 401);
  }
  const locked = await attempt('Password123!');
  assert.equal(locked.status, 423);

  const row = await prisma.user.findUnique({
    where: { email: 'sami@example.com' },
  });
  const minutes = (row.lockedUntil - Date.now()) / 60_000;
  assert.ok(minutes > 14 && minutes <= 15);

  // Le blocage terminé, le compte fonctionne et le compteur repart de zéro.
  await prisma.user.update({
    where: { id: row.id },
    data: { lockedUntil: new Date(Date.now() - 1000) },
  });
  assert.equal((await attempt('Password123!')).status, 200);
});

test('connexion : un succès remet le compteur d échecs à zéro', async (t) => {
  const { call } = await startApi(t);
  await call('POST', '/auth/register', { body: driver() });
  const attempt = (password) =>
    call('POST', '/auth/login', {
      body: { identifier: 'sami@example.com', password },
    });
  for (let i = 0; i < 4; i += 1) await attempt('mauvais');
  assert.equal((await attempt('Password123!')).status, 200);
  for (let i = 0; i < 4; i += 1) await attempt('mauvais');
  assert.equal((await attempt('Password123!')).status, 200);
});

test('routes protégées : refusent les jetons absents, faux ou expirés', async (t) => {
  const { call } = await startApi(t);
  assert.equal((await call('GET', '/users/me')).status, 401);
  assert.equal(
    (await call('GET', '/users/me', { token: 'faux' })).status,
    401,
  );

  const { default: jwt } = await import('jsonwebtoken');
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const expired = jwt.sign({ sub: body.user.id }, process.env.JWT_SECRET, {
    expiresIn: -1,
  });
  assert.equal((await call('GET', '/users/me', { token: expired })).status, 401);
  const forged = jwt.sign({ sub: body.user.id }, 'autre-secret');
  assert.equal((await call('GET', '/users/me', { token: forged })).status, 401);
  const unsigned = jwt.sign({ sub: body.user.id }, '', { algorithm: 'none' });
  assert.equal(
    (await call('GET', '/users/me', { token: unsigned })).status,
    401,
  );
});

test('rafraîchissement : rotation, puis réutilisation détectée', async (t) => {
  const { call } = await startApi(t);
  const { body: first } = await call('POST', '/auth/register', {
    body: driver(),
  });

  const second = await call('POST', '/auth/refresh', {
    body: { refreshToken: first.refreshToken },
  });
  assert.equal(second.status, 200);
  assert.notEqual(second.body.refreshToken, first.refreshToken);

  // L'ancien jeton revient : le nouveau tombe avec lui.
  const reuse = await call('POST', '/auth/refresh', {
    body: { refreshToken: first.refreshToken },
  });
  assert.equal(reuse.status, 401);
  const afterReuse = await call('POST', '/auth/refresh', {
    body: { refreshToken: second.body.refreshToken },
  });
  assert.equal(afterReuse.status, 401);
});

test('session : expire après 30 min d inactivité', async (t) => {
  const { call } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });

  const row = await prisma.refreshToken.findFirstOrThrow({
    where: { userId: body.user.id },
  });
  const minutes = (row.expiresAt - Date.now()) / 60_000;
  assert.ok(minutes > 29 && minutes <= 30);

  await prisma.refreshToken.update({
    where: { id: row.id },
    data: { expiresAt: new Date(Date.now() - 1000) },
  });
  const expired = await call('POST', '/auth/refresh', {
    body: { refreshToken: body.refreshToken },
  });
  assert.equal(expired.status, 401);
  assert.equal(expired.body.error.code, 'SESSION_EXPIRED');
});

test('déconnexion : le jeton de rafraîchissement ne marche plus', async (t) => {
  const { call } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const { refreshToken } = body;
  assert.equal(
    (await call('POST', '/auth/logout', { body: { refreshToken } })).status,
    204,
  );
  assert.equal(
    (await call('POST', '/auth/refresh', { body: { refreshToken } })).status,
    401,
  );
});

test('OTP : vérifie le téléphone, usage unique', async (t) => {
  const { call, sent } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const token = body.accessToken;
  const code = codeFrom(sent.sms[0]);
  const wrongCode = code === '000000' ? '000001' : '000000';

  const wrong = await call('POST', '/auth/phone/verify', {
    token,
    body: { code: wrongCode },
  });
  assert.equal(wrong.status, 400);

  const ok = await call('POST', '/auth/phone/verify', { token, body: { code } });
  assert.equal(ok.status, 200);
  assert.equal(ok.body.user.phoneVerified, true);

  const again = await call('POST', '/auth/phone/verify', {
    token,
    body: { code },
  });
  assert.equal(again.status, 400);
  assert.equal((await call('POST', '/auth/phone/send', { token })).status, 409);
});

test('OTP : 5 essais maximum, même le bon code est ensuite refusé', async (t) => {
  const { call, sent } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const token = body.accessToken;
  const code = codeFrom(sent.sms[0]);
  const wrongCode = code === '000000' ? '000001' : '000000';

  for (let i = 0; i < 5; i += 1) {
    await call('POST', '/auth/phone/verify', {
      token,
      body: { code: wrongCode },
    });
  }
  const blocked = await call('POST', '/auth/phone/verify', {
    token,
    body: { code },
  });
  assert.equal(blocked.status, 400);
});

test('OTP : délai entre deux envois, puis le nouveau code remplace l ancien', async (t) => {
  const { call, sent } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const token = body.accessToken;

  assert.equal((await call('POST', '/auth/phone/send', { token })).status, 429);
  assert.equal(sent.sms.length, 1);

  await prisma.verificationCode.updateMany({
    where: { userId: body.user.id },
    data: { createdAt: new Date(Date.now() - 61_000) },
  });
  assert.equal((await call('POST', '/auth/phone/send', { token })).status, 204);
  assert.equal(sent.sms.length, 2);

  const [oldCode, newCode] = sent.sms.map(codeFrom);
  if (oldCode !== newCode) {
    const old = await call('POST', '/auth/phone/verify', {
      token,
      body: { code: oldCode },
    });
    assert.equal(old.status, 400);
  }
  const fresh = await call('POST', '/auth/phone/verify', {
    token,
    body: { code: newCode },
  });
  assert.equal(fresh.status, 200);
});

test('OTP : un code expiré est refusé', async (t) => {
  const { call, sent } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  await prisma.verificationCode.updateMany({
    where: { userId: body.user.id },
    data: { expiresAt: new Date(Date.now() - 1000) },
  });
  const expired = await call('POST', '/auth/phone/verify', {
    token: body.accessToken,
    body: { code: codeFrom(sent.sms[0]) },
  });
  assert.equal(expired.status, 400);
});

test('mot de passe oublié : même réponse si l e-mail est inconnu', async (t) => {
  const { call, sent } = await startApi(t);
  const unknown = await call('POST', '/auth/password/forgot', {
    body: { email: 'inconnu@example.com' },
  });
  assert.equal(unknown.status, 204);
  assert.equal(sent.mail.length, 0);
});

test('mot de passe oublié : change le mot de passe, ferme les sessions, lève le blocage', async (t) => {
  const { call, sent } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const email = 'sami@example.com';
  await prisma.user.update({
    where: { email },
    data: { lockedUntil: new Date(Date.now() + 600_000) },
  });

  assert.equal(
    (await call('POST', '/auth/password/forgot', { body: { email } })).status,
    204,
  );
  const code = codeFrom(sent.mail[0]);
  const password = 'NouveauPass456!';

  const reset = await call('POST', '/auth/password/reset', {
    body: { email, code, password },
  });
  assert.equal(reset.status, 204);

  const reused = await call('POST', '/auth/password/reset', {
    body: { email, code, password: 'EncoreUnAutre789!' },
  });
  assert.equal(reused.status, 400);

  assert.equal(
    (
      await call('POST', '/auth/refresh', {
        body: { refreshToken: body.refreshToken },
      })
    ).status,
    401,
  );
  assert.equal(
    (
      await call('POST', '/auth/login', {
        body: { identifier: email, password: 'Password123!' },
      })
    ).status,
    401,
  );
  assert.equal(
    (await call('POST', '/auth/login', { body: { identifier: email, password } })).status,
    200,
  );
});

test('un code OTP de téléphone ne réinitialise pas le mot de passe', async (t) => {
  const { call, sent } = await startApi(t);
  await call('POST', '/auth/register', { body: driver() });
  const email = 'sami@example.com';
  await call('POST', '/auth/password/forgot', { body: { email } });
  const phoneCode = codeFrom(sent.sms[0]);
  const mailCode = codeFrom(sent.mail[0]);
  if (phoneCode === mailCode) return;

  const reset = await call('POST', '/auth/password/reset', {
    body: { email, code: phoneCode, password: 'NouveauPass456!' },
  });
  assert.equal(reset.status, 400);
});

test('corps vide ou JSON invalide : erreur 400 propre', async (t) => {
  const { call, base } = await startApi(t);
  const empty = await call('POST', '/auth/login', { body: {} });
  assert.equal(empty.status, 400);
  assert.equal(empty.body.error.code, 'VALIDATION_ERROR');

  const malformed = await fetch(`${base}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: '{pas du json',
  });
  assert.equal(malformed.status, 400);
  assert.equal((await malformed.json()).error.code, 'BAD_REQUEST');
});
