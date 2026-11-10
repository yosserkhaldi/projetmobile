import assert from 'node:assert/strict';
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

const licenseForm = (tag) => {
  const data = new FormData();
  data.append('photo', new Blob([image(tag)], { type: 'image/png' }), 'permis.png');
  return data;
};

/** Conducteur dont l'identité est déjà vérifiée par sa CIN. */
async function verifiedDriver(call) {
  const { body } = await call('POST', '/auth/register', { body: driver() });
  await prisma.user.update({
    where: { id: body.user.id },
    data: {
      identityStatus: 'VERIFIED',
      identityDocument: 'CIN',
      cinNumber: '12345678',
      cinFrontFile: 'front.png',
      identityAutoVerified: true,
      identityExtracted: { number: '12345678', birthDate: '1999-03-12' },
    },
  });
  return { token: body.accessToken, id: body.user.id };
}

test('permis : le sien est validé par l IA', async (t) => {
  const { call } = await startApi(t);
  const { token } = await verifiedDriver(call);
  const res = await call('PUT', '/users/me/license-photo', {
    token,
    form: licenseForm('license'),
  });
  assert.equal(res.status, 200);
  assert.equal(res.body.user.license.status, 'VERIFIED');
  assert.deepEqual(res.body.user.license.checks, {
    nameMatchesAccount: true,
    birthDateMatchesIdentity: true,
    cinMatchesIdentity: true,
  });
});

test('permis : celui d une autre personne est refusé, rien n est enregistré', async (t) => {
  const { call } = await startApi(t);
  const { token } = await verifiedDriver(call);
  const res = await call('PUT', '/users/me/license-photo', {
    token,
    form: licenseForm('license-stranger'),
  });
  assert.equal(res.status, 422);
  assert.equal(res.body.error.code, 'LICENSE_NOT_YOURS');
  const me = await call('GET', '/users/me', { token });
  assert.equal(me.body.user.licensePhotoId, null);
  assert.equal(me.body.user.license.status, null);
});

test('permis : un seul écart est enregistré mais signalé à l administrateur', async (t) => {
  const { call } = await startApi(t);
  const admin = await createAdmin(call);
  const { token, id } = await verifiedDriver(call);
  // Même famille : nom identique, autre prénom ; rien d'autre de lisible.
  const res = await call('PUT', '/users/me/license-photo', {
    token,
    form: licenseForm('license-other'),
  });
  assert.equal(res.status, 200);
  assert.equal(res.body.user.license.status, 'TO_REVIEW');

  const queue = await call('GET', '/users/licenses/review', { token: admin.token });
  assert.deepEqual(
    queue.body.items.map((user) => user.id),
    [id],
  );
  const stats = await call('GET', '/users/stats', { token: admin.token });
  assert.equal(stats.body.licensesToReview, 1);
  // Un conducteur n'a pas accès à la file.
  const denied = await call('GET', '/users/licenses/review', { token });
  assert.equal(denied.status, 403);
});

test('permis : numéro tapé à la main différent de celui lu, à vérifier', async (t) => {
  const { call } = await startApi(t);
  const { token } = await verifiedDriver(call);
  await call('PUT', '/users/me/license-photo', { token, form: licenseForm('license') });
  const same = await call('PATCH', '/users/me', {
    token,
    body: { licenseNumber: '12 / 345678' },
  });
  assert.equal(same.body.user.license.status, 'VERIFIED');
  const changed = await call('PATCH', '/users/me', {
    token,
    body: { licenseNumber: '99/111111' },
  });
  assert.equal(changed.body.user.license.status, 'TO_REVIEW');
  assert.equal(changed.body.user.license.checks.numberMatchesReading, false);
});

test('permis : l administrateur valide, corrige, refuse et supprime', async (t) => {
  const { call } = await startApi(t);
  const admin = await createAdmin(call);
  const { token, id } = await verifiedDriver(call);
  await call('PUT', '/users/me/license-photo', { token, form: licenseForm('license-other') });

  const approved = await call('POST', `/users/${id}/license/approve`, { token: admin.token });
  assert.equal(approved.body.user.license.status, 'VERIFIED');

  const edited = await call('PATCH', `/users/${id}/license`, {
    token: admin.token,
    body: { licenseNumber: '12/345678', licenseCategory: 'B', licenseIssuedAt: '2020-05-10' },
  });
  assert.equal(edited.body.user.licenseNumber, '12/345678');
  assert.equal(edited.body.user.licenseIssuedAt, '2020-05-10');

  const rejected = await call('POST', `/users/${id}/license/reject`, {
    token: admin.token,
    body: { reason: 'Permis d’un proche' },
  });
  assert.equal(rejected.body.user.license.status, 'REJECTED');
  assert.equal(rejected.body.user.license.rejectionReason, 'Permis d’un proche');
  assert.equal(rejected.body.user.licensePhotoId, null);
  assert.equal(rejected.body.user.licenseNumber, null);
  // Le conducteur voit le motif.
  const me = await call('GET', '/users/me', { token });
  assert.equal(me.body.user.license.rejectionReason, 'Permis d’un proche');

  await call('PUT', '/users/me/license-photo', { token, form: licenseForm('license') });
  const removed = await call('DELETE', `/users/${id}/license`, { token: admin.token });
  assert.equal(removed.status, 200);
  assert.equal(removed.body.user.licensePhotoId, null);
  assert.equal(removed.body.user.license.status, null);

  // Réservé aux administrateurs.
  const denied = await call('POST', `/users/${id}/license/approve`, { token });
  assert.equal(denied.status, 403);
});

test('dossier d un compte : l administrateur voit l identité validée par l IA', async (t) => {
  const { call } = await startApi(t);
  const admin = await createAdmin(call);
  const { id } = await verifiedDriver(call);
  const res = await call('GET', `/users/${id}`, { token: admin.token });
  assert.equal(res.status, 200);
  assert.equal(res.body.user.identity.status, 'VERIFIED');
  assert.equal(res.body.user.identity.autoVerified, true);
  assert.equal(res.body.user.identity.frontId, 'front.png');
  const missing = await call('GET', '/users/00000000-0000-4000-8000-000000000000', {
    token: admin.token,
  });
  assert.equal(missing.status, 404);
});

test('identité : l administrateur annule une vérification faite par l IA', async (t) => {
  const { call } = await startApi(t);
  const admin = await createAdmin(call);
  const { token, id } = await verifiedDriver(call);
  const res = await call('POST', `/users/${id}/identity/revoke`, {
    token: admin.token,
    body: { reason: 'Photo de la pièce floue' },
  });
  assert.equal(res.status, 200);
  const identity = res.body.user.identity;
  assert.equal(identity.status, 'REJECTED');
  assert.equal(identity.rejectionReason, 'Photo de la pièce floue');
  assert.equal(identity.frontId, null);
  assert.equal(identity.cinNumber, null);
  // Pas un refus compté : nouvelle demande possible tout de suite.
  assert.equal(identity.refusals, 0);
  assert.equal(identity.retryAt, null);
  assert.equal(identity.blocked, false);

  const again = await call('POST', `/users/${id}/identity/revoke`, {
    token: admin.token,
    body: { reason: 'Encore' },
  });
  assert.equal(again.status, 409);
  const denied = await call('POST', `/users/${id}/identity/revoke`, {
    token,
    body: { reason: 'Moi-même' },
  });
  assert.equal(denied.status, 403);
});

test('permis : une photo où rien ne ressemble à un permis est refusée', async (t) => {
  const { call } = await startApi(t);
  const { token } = await verifiedDriver(call);
  // L'IA simulée ne reconnaît aucune pièce et ne lit qu'un numéro de CIN.
  const res = await call('PUT', '/users/me/license-photo', {
    token,
    form: licenseForm('me'),
  });
  assert.equal(res.status, 422);
  assert.equal(res.body.error.code, 'NOT_A_LICENSE');
  const me = await call('GET', '/users/me', { token });
  assert.equal(me.body.user.licensePhotoId, null);
});

test('identité : l administrateur corrige ce que l IA a lu', async (t) => {
  const { call } = await startApi(t);
  const admin = await createAdmin(call);
  const { token, id } = await verifiedDriver(call);
  const res = await call('PATCH', `/users/${id}/identity/reading`, {
    token: admin.token,
    body: { birthPlaceAr: 'قابس', number: '87654321' },
  });
  assert.equal(res.status, 200);
  const identity = res.body.user.identity;
  assert.equal(identity.extracted.birthPlaceAr, 'قابس');
  // Les autres champs lus restent.
  assert.equal(identity.extracted.birthDate, '1999-03-12');
  assert.equal(identity.cinNumber, '87654321');

  const invalid = await call('PATCH', `/users/${id}/identity/reading`, {
    token: admin.token,
    body: { birthDate: '12/03/1999' },
  });
  assert.equal(invalid.status, 400);
  const denied = await call('PATCH', `/users/${id}/identity/reading`, {
    token,
    body: { birthPlaceAr: 'تونس' },
  });
  assert.equal(denied.status, 403);
});
