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

async function enabled(call) {
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const key = await call('POST', '/auth/biometric', {
    token: body.accessToken,
  });
  return { session: body, key: key.body, status: key.status };
}

test('activation : réservée à un compte connecté, clé valable 30 jours', async (t) => {
  const { call } = await startApi(t);
  assert.equal((await call('POST', '/auth/biometric')).status, 401);

  const { key, status } = await enabled(call);
  assert.equal(status, 201);
  assert.ok(key.deviceToken.length >= 40);
  const days = (new Date(key.expiresAt) - Date.now()) / 86_400_000;
  assert.ok(days > 29.9 && days <= 30);
});

test('connexion biométrique : ouvre une session et remplace la clé', async (t) => {
  const { call } = await startApi(t);
  const { key, session } = await enabled(call);
  await call('POST', '/auth/logout', {
    body: { refreshToken: session.refreshToken },
  });

  const login = await call('POST', '/auth/biometric/login', {
    body: { deviceToken: key.deviceToken },
  });
  assert.equal(login.status, 200);
  assert.equal(login.body.user.email, 'sami@example.com');
  assert.ok(login.body.accessToken && login.body.refreshToken);
  assert.notEqual(login.body.deviceToken, key.deviceToken);

  const again = await call('POST', '/auth/biometric/login', {
    body: { deviceToken: login.body.deviceToken },
  });
  assert.equal(again.status, 200);
});

test('clé réutilisée : toutes les sessions et clés tombent', async (t) => {
  const { call } = await startApi(t);
  const { key } = await enabled(call);
  const first = await call('POST', '/auth/biometric/login', {
    body: { deviceToken: key.deviceToken },
  });

  const replay = await call('POST', '/auth/biometric/login', {
    body: { deviceToken: key.deviceToken },
  });
  assert.equal(replay.status, 401);
  assert.equal(replay.body.error.code, 'BIOMETRIC_INVALID');

  assert.equal(
    (
      await call('POST', '/auth/biometric/login', {
        body: { deviceToken: first.body.deviceToken },
      })
    ).status,
    401,
  );
  assert.equal(
    (
      await call('POST', '/auth/refresh', {
        body: { refreshToken: first.body.refreshToken },
      })
    ).status,
    401,
  );
});

test('clé expirée ou inconnue : refusée', async (t) => {
  const { call } = await startApi(t);
  const { key } = await enabled(call);
  assert.equal(
    (
      await call('POST', '/auth/biometric/login', {
        body: { deviceToken: 'inconnue' },
      })
    ).status,
    401,
  );
  await prisma.deviceKey.updateMany({
    data: { expiresAt: new Date(Date.now() - 1000) },
  });
  assert.equal(
    (
      await call('POST', '/auth/biometric/login', {
        body: { deviceToken: key.deviceToken },
      })
    ).status,
    401,
  );
});

test('désactivation : sur cet appareil seulement, ou partout', async (t) => {
  const { call } = await startApi(t);
  const { key, session } = await enabled(call);
  const token = session.accessToken;
  const { body: second } = await call('POST', '/auth/biometric', { token });

  await call('DELETE', '/auth/biometric', {
    token,
    body: { deviceToken: key.deviceToken },
  });
  const login = (deviceToken) =>
    call('POST', '/auth/biometric/login', { body: { deviceToken } });
  assert.equal((await login(key.deviceToken)).status, 401);
  const stillWorks = await login(second.deviceToken);
  assert.equal(stillWorks.status, 200);

  await call('DELETE', '/auth/biometric', { token });
  assert.equal((await login(stillWorks.body.deviceToken)).status, 401);
});

test('suspension et mot de passe réinitialisé : la clé ne marche plus', async (t) => {
  const { call, sent } = await startApi(t);
  const { key, session } = await enabled(call);
  const { token: admin } = await createAdmin(call);

  await call('PATCH', `/users/${session.user.id}/status`, {
    token: admin,
    body: { active: false },
  });
  assert.equal(
    (
      await call('POST', '/auth/biometric/login', {
        body: { deviceToken: key.deviceToken },
      })
    ).status,
    401,
  );

  await call('PATCH', `/users/${session.user.id}/status`, {
    token: admin,
    body: { active: true },
  });
  const login = await call('POST', '/auth/login', {
    body: { identifier: 'sami@example.com', password: 'Password123!' },
  });
  const { body: fresh } = await call('POST', '/auth/biometric', {
    token: login.body.accessToken,
  });
  await call('POST', '/auth/password/forgot', {
    body: { email: 'sami@example.com' },
  });
  const code = sent.mail.at(-1).text.match(/\d{6}/)[0];
  await call('POST', '/auth/password/reset', {
    body: { email: 'sami@example.com', code, password: 'NouveauPass456!' },
  });
  assert.equal(
    (
      await call('POST', '/auth/biometric/login', {
        body: { deviceToken: fresh.deviceToken },
      })
    ).status,
    401,
  );
});

test('la déconnexion simple garde la connexion biométrique', async (t) => {
  const { call } = await startApi(t);
  const { key, session } = await enabled(call);
  await call('POST', '/auth/logout', {
    body: { refreshToken: session.refreshToken },
  });
  assert.equal(
    (
      await call('POST', '/auth/biometric/login', {
        body: { deviceToken: key.deviceToken },
      })
    ).status,
    200,
  );
});
