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

const agent = (companyId, overrides = {}) =>
  driver({
    firstName: 'Leïla',
    lastName: 'Mansour',
    email: 'leila@assurance.tn',
    phone: '20555666',
    companyId,
    ...overrides,
  });

test('profil : modification, permis, et nouveau téléphone à revérifier', async (t) => {
  const { call } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const token = body.accessToken;
  await prisma.user.update({
    where: { id: body.user.id },
    data: { phoneVerifiedAt: new Date() },
  });

  const updated = await call('PATCH', '/users/me', {
    token,
    body: {
      firstName: 'Samir',
      language: 'EN',
      licenseNumber: '12/345678',
      licenseCategory: 'B',
      licenseIssuedAt: '2015-06-01',
      role: 'ADMIN',
      email: 'pirate@example.com',
    },
  });
  assert.equal(updated.status, 200);
  assert.equal(updated.body.user.firstName, 'Samir');
  assert.equal(updated.body.user.licenseIssuedAt, '2015-06-01');
  assert.equal(updated.body.user.language, 'EN');
  assert.equal(updated.body.user.role, 'DRIVER', 'rôle non modifiable');
  assert.equal(updated.body.user.email, 'sami@example.com');
  assert.equal(updated.body.user.phoneVerified, true);

  const newPhone = await call('PATCH', '/users/me', {
    token,
    body: { phone: '20777888' },
  });
  assert.equal(newPhone.body.user.phoneVerified, false);

  const cleared = await call('PATCH', '/users/me', {
    token,
    body: { licenseNumber: '', licenseIssuedAt: '' },
  });
  assert.equal(cleared.status, 200);
  assert.equal(cleared.body.user.licenseNumber, null);
  assert.equal(cleared.body.user.licenseIssuedAt, null);

  const future = await call('PATCH', '/users/me', {
    token,
    body: { licenseIssuedAt: '2999-01-01' },
  });
  assert.equal(future.status, 400);
});

test('rôles : un conducteur n accède à aucune route d administration', async (t) => {
  const { call } = await startApi(t);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const token = body.accessToken;
  const id = body.user.id;
  const denied = [
    ['POST', '/users/agents'],
    ['PATCH', `/users/${id}/role`],
    ['PATCH', `/users/${id}/status`],
    ['POST', '/companies'],
    ['PATCH', `/companies/${id}`],
    ['DELETE', `/companies/${id}`],
    ['POST', `/companies/${id}/agencies`],
  ];
  for (const [method, path] of denied) {
    const { status } = await call(method, path, { token, body: {} });
    assert.equal(status, 403, `${method} ${path}`);
  }
  assert.equal((await call('GET', '/users', { token })).status, 403);
  // Lecture des compagnies autorisée, utile au module 2.
  assert.equal((await call('GET', '/companies', { token })).status, 200);
  assert.equal((await call('GET', '/companies')).status, 401);
});

test('administration : liste paginée et recherche', async (t) => {
  const { call } = await startApi(t);
  const { token } = await createAdmin(call);
  await call('POST', '/auth/register', { body: driver() });
  await call('POST', '/auth/register', {
    body: driver({
      firstName: 'Mouna',
      lastName: 'Trabelsi',
      email: 'mouna@example.com',
      phone: '20444555',
    }),
  });

  const all = await call('GET', '/users', { token });
  assert.equal(all.body.total, 3);
  assert.equal(all.body.items[0].passwordHash, undefined);

  const search = await call('GET', '/users?q=trabel', { token });
  assert.equal(search.body.total, 1);
  assert.equal(search.body.items[0].email, 'mouna@example.com');

  const byRole = await call('GET', '/users?role=ADMIN', { token });
  assert.equal(byRole.body.total, 1);

  const page = await call('GET', '/users?pageSize=1&page=2', { token });
  assert.equal(page.body.items.length, 1);
  assert.equal(page.body.total, 3);
});

test('agents : créés et rattachés à une compagnie, qui ne peut plus être supprimée', async (t) => {
  const { call } = await startApi(t);
  const { token } = await createAdmin(call);
  const { body: created } = await call('POST', '/companies', {
    token,
    body: { name: 'STAR Assurances' },
  });
  const companyId = created.company.id;

  const missing = await call('POST', '/users/agents', {
    token,
    body: driver({ email: 'x@y.tn', phone: '20111222' }),
  });
  assert.equal(missing.status, 400);

  const unknown = await call('POST', '/users/agents', {
    token,
    body: agent('11111111-1111-4111-8111-111111111111'),
  });
  assert.equal(unknown.status, 400);
  assert.equal(unknown.body.error.code, 'COMPANY_NOT_FOUND');

  const ok = await call('POST', '/users/agents', {
    token,
    body: agent(companyId),
  });
  assert.equal(ok.status, 201);
  assert.equal(ok.body.user.role, 'AGENT');
  assert.equal(ok.body.user.company.name, 'STAR Assurances');

  const login = await call('POST', '/auth/login', {
    body: { identifier: 'leila@assurance.tn', password: 'Password123!' },
  });
  assert.equal(login.status, 200);

  const remove = await call('DELETE', `/companies/${companyId}`, { token });
  assert.equal(remove.status, 409);
  assert.equal(remove.body.error.code, 'COMPANY_IN_USE');
});

test('rôles : attribution, compagnie obligatoire pour un agent', async (t) => {
  const { call } = await startApi(t);
  const { token } = await createAdmin(call);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const { id } = body.user;
  const { body: created } = await call('POST', '/companies', {
    token,
    body: { name: 'COMAR' },
  });

  const noCompany = await call('PATCH', `/users/${id}/role`, {
    token,
    body: { role: 'AGENT' },
  });
  assert.equal(noCompany.status, 400);

  const toAgent = await call('PATCH', `/users/${id}/role`, {
    token,
    body: { role: 'AGENT', companyId: created.company.id },
  });
  assert.equal(toAgent.body.user.role, 'AGENT');
  assert.equal(toAgent.body.user.company.name, 'COMAR');

  // Le changement vaut immédiatement, même avec un ancien jeton.
  const me = await call('GET', '/users/me', { token: body.accessToken });
  assert.equal(me.body.user.role, 'AGENT');

  const toDriver = await call('PATCH', `/users/${id}/role`, {
    token,
    body: { role: 'DRIVER' },
  });
  assert.equal(toDriver.body.user.company, null);

  assert.equal(
    (
      await call('PATCH', '/users/not-a-uuid/role', {
        token,
        body: { role: 'DRIVER' },
      })
    ).status,
    400,
  );
  assert.equal(
    (
      await call('PATCH', '/users/11111111-1111-4111-8111-111111111111/role', {
        token,
        body: { role: 'DRIVER' },
      })
    ).status,
    404,
  );
});

test('suspension : coupe l accès tout de suite, réactivation possible', async (t) => {
  const { call } = await startApi(t);
  const { token } = await createAdmin(call);
  const { body } = await call('POST', '/auth/register', { body: driver() });
  const { id } = body.user;
  const credentials = {
    identifier: 'sami@example.com',
    password: 'Password123!',
  };

  const suspended = await call('PATCH', `/users/${id}/status`, {
    token,
    body: { active: false },
  });
  assert.equal(suspended.body.user.active, false);

  assert.equal(
    (await call('GET', '/users/me', { token: body.accessToken })).status,
    401,
  );
  assert.equal(
    (
      await call('POST', '/auth/refresh', {
        body: { refreshToken: body.refreshToken },
      })
    ).status,
    401,
  );
  const login = await call('POST', '/auth/login', { body: credentials });
  assert.equal(login.status, 403);
  assert.equal(login.body.error.code, 'ACCOUNT_SUSPENDED');

  await call('PATCH', `/users/${id}/status`, { token, body: { active: true } });
  assert.equal(
    (await call('POST', '/auth/login', { body: credentials })).status,
    200,
  );
});

test('un administrateur ne peut ni se suspendre ni changer son propre rôle', async (t) => {
  const { call } = await startApi(t);
  const { token, id } = await createAdmin(call);
  const status = await call('PATCH', `/users/${id}/status`, {
    token,
    body: { active: false },
  });
  assert.equal(status.status, 409);
  const role = await call('PATCH', `/users/${id}/role`, {
    token,
    body: { role: 'DRIVER' },
  });
  assert.equal(role.status, 409);
});

test('compagnies et agences : création, modification, suppression, doublons', async (t) => {
  const { call } = await startApi(t);
  const { token } = await createAdmin(call);

  const { status, body } = await call('POST', '/companies', {
    token,
    body: { name: 'GAT Assurances' },
  });
  assert.equal(status, 201);
  const { id } = body.company;

  const duplicate = await call('POST', '/companies', {
    token,
    body: { name: 'GAT Assurances' },
  });
  assert.equal(duplicate.status, 409);

  const agency = await call('POST', `/companies/${id}/agencies`, {
    token,
    body: { name: 'Agence Lac', city: 'Tunis' },
  });
  assert.equal(agency.status, 201);
  const agencyId = agency.body.agency.id;

  const dupAgency = await call('POST', `/companies/${id}/agencies`, {
    token,
    body: { name: 'Agence Lac', city: 'Tunis' },
  });
  assert.equal(dupAgency.status, 409);

  const noCompany = await call(
    'POST',
    '/companies/11111111-1111-4111-8111-111111111111/agencies',
    { token, body: { name: 'Agence', city: 'Tunis' } },
  );
  assert.equal(noCompany.status, 404);

  const renamed = await call('PATCH', `/companies/${id}/agencies/${agencyId}`, {
    token,
    body: { name: 'Agence du Lac', city: 'Tunis' },
  });
  assert.equal(renamed.body.agency.name, 'Agence du Lac');

  const list = await call('GET', '/companies', { token });
  assert.equal(list.body.items[0].agencies[0].name, 'Agence du Lac');

  assert.equal(
    (await call('DELETE', `/companies/${id}/agencies/${agencyId}`, { token }))
      .status,
    204,
  );
  assert.equal(
    (await call('DELETE', `/companies/${id}/agencies/${agencyId}`, { token }))
      .status,
    404,
  );
  assert.equal(
    (await call('PATCH', `/companies/${id}`, { token, body: { name: 'GAT' } }))
      .body.company.name,
    'GAT',
  );
  assert.equal((await call('DELETE', `/companies/${id}`, { token })).status, 204);
});
