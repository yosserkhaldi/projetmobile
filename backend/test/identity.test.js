import assert from 'node:assert/strict';
import { existsSync } from 'node:fs';
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

// Les alertes partent sans être attendues : on laisse la boucle d'événements tourner.
const settle = () => new Promise((resolve) => setTimeout(resolve, 50));

const photo = (tag, documentType) => {
  const data = new FormData();
  if (documentType) data.append('documentType', documentType);
  data.append('photo', new Blob([image(tag)], { type: 'image/png' }), 'piece.png');
  return data;
};

const selfieFile = (id) =>
  prisma.user
    .findUnique({ where: { id } })
    .then((u) => u.identitySelfieFile);

const identityPath = (name) =>
  join(process.env.UPLOAD_DIR, 'identity', name);

async function register(call, overrides) {
  const { body } = await call('POST', '/auth/register', {
    body: driver(overrides),
  });
  return { token: body.accessToken, id: body.user.id };
}

async function uploadDocument(
  call,
  token,
  { front = 'me', back = true, documentType } = {},
) {
  const res = await call('PUT', '/users/me/identity/front', {
    token,
    form: photo(front, documentType),
  });
  if (back) {
    await call('PUT', '/users/me/identity/back', { token, form: photo('blank') });
  }
  return res;
}

/** Défi demandé au serveur, puis une photo par consigne, dans son ordre. */
async function liveness(call, token, frames = {}) {
  const tags = { center: 'me', left: 'me-left', right: 'me-right', ...frames };
  const challenge = await call('POST', '/users/me/identity/liveness', { token, body: { consent: true } });
  const data = new FormData();
  data.append('token', frames.token ?? challenge.body.token);
  for (const step of challenge.body.steps) {
    data.append(
      'frames',
      new Blob([image(tags[step])], { type: 'image/png' }),
      `${step}.png`,
    );
  }
  return {
    steps: challenge.body.steps,
    res: await call('POST', '/users/me/identity/selfie', { token, form: data }),
  };
}

const submit = (call, token, body = { documentType: 'CIN', number: '12345678' }) =>
  call('POST', '/users/me/identity/submit', { token, body });

test('IA : pièce + visage reconnu, identité validée sans administrateur', async (t) => {
  const { call, sent } = await startApi(t);
  const sami = await register(call);

  const early = await submit(call, sami.token);
  assert.equal(early.status, 400);
  assert.equal(early.body.error.code, 'IDENTITY_PHOTOS_REQUIRED');

  assert.equal((await uploadDocument(call, sami.token)).status, 200);
  const noSelfie = await submit(call, sami.token);
  assert.equal(noSelfie.status, 400);
  assert.equal(noSelfie.body.error.code, 'SELFIE_REQUIRED');

  const { steps, res } = await liveness(call, sami.token);
  assert.equal(steps[0], 'center');
  assert.deepEqual([...steps.slice(1)].sort(), ['left', 'right']);
  assert.equal(res.status, 200);
  assert.ok(res.body.user.identity.selfieId);
  assert.ok(res.body.user.identity.livenessAt);
  const selfie = await selfieFile(sami.id);
  assert.ok(existsSync(identityPath(selfie)));

  const done = await submit(call, sami.token);
  assert.equal(done.status, 200);
  const identity = done.body.user.identity;
  assert.equal(identity.status, 'VERIFIED');
  assert.equal(identity.autoVerified, true);
  assert.equal(identity.faceMatch, 1);
  assert.equal(identity.documentType, 'CIN');
  // Minimisation : la photo du visage disparaît dès la décision.
  assert.equal(identity.selfieId, null);
  assert.equal(existsSync(identityPath(selfie)), false);
  await settle();
  assert.match(sent.sms.at(-1).text, /identité est vérifiée/);

  const locked = await call('PUT', '/users/me/identity/front', {
    token: sami.token,
    form: photo(),
  });
  assert.equal(locked.status, 409);
  assert.equal(locked.body.error.code, 'IDENTITY_LOCKED');
});

test('IA : une pièce sans visage est refusée dès l envoi', async (t) => {
  const { call } = await startApi(t);
  const { token } = await register(call);
  const res = await uploadDocument(call, token, { front: 'blank', back: false });
  assert.equal(res.status, 422);
  assert.equal(res.body.error.code, 'NO_FACE_ON_DOCUMENT');
  // Le verso n'a pas de visage : il n'est pas analysé.
  const back = await call('PUT', '/users/me/identity/back', {
    token,
    form: photo('blank'),
  });
  assert.equal(back.status, 200);
});

test('vérification du visage : photo, écran ou autre personne refusés', async (t) => {
  const { call } = await startApi(t);
  const { token } = await register(call);
  const code = async (frames) => (await liveness(call, token, frames)).res.body.error?.code;

  // Une photo tenue devant la caméra ne tourne pas la tête.
  assert.equal(
    await code({ left: 'me-tilted', right: 'me-tilted' }),
    'LIVENESS_NO_TURN',
  );
  // Tournée deux fois du même côté.
  assert.equal(await code({ right: 'me-left' }), 'LIVENESS_NO_TURN');
  assert.equal(await code({ center: 'me-sideways' }), 'LIVENESS_NOT_CENTERED');
  assert.equal(await code({ center: 'blank' }), 'LIVENESS_NO_FACE');
  assert.equal(await code({ left: 'crowd' }), 'LIVENESS_MANY_FACES');
  // Quelqu'un d'autre prend la place pendant le défi.
  assert.equal(await code({ right: 'other' }), 'LIVENESS_DIFFERENT_FACES');
  assert.equal(await code({ token: 'faux' }), 'LIVENESS_EXPIRED');
  assert.equal(await selfieFile((await prisma.user.findFirst()).id), null);
});

test('vérification du visage : le défi appartient à un seul compte', async (t) => {
  const { call } = await startApi(t);
  const sami = await register(call);
  const other = await register(call, {
    email: 'autre@example.com',
    phone: '20777000',
  });
  const challenge = await call('POST', '/users/me/identity/liveness', {
    token: sami.token,
    body: { consent: true },
  });
  const { res } = await liveness(call, other.token, {
    token: challenge.body.token,
  });
  assert.equal(res.status, 403);

  const data = new FormData();
  data.append('token', challenge.body.token);
  data.append('frames', new Blob([image()], { type: 'image/png' }), 'a.png');
  const missing = await call('POST', '/users/me/identity/selfie', {
    token: sami.token,
    form: data,
  });
  assert.equal(missing.status, 400);
  assert.equal(missing.body.error.code, 'FRAMES_REQUIRED');
});

test('IA dans le doute : la demande va à l administrateur, avec le score', async (t) => {
  const { call, sent } = await startApi(t);
  const sami = await register(call);
  await uploadDocument(call, sami.token, { front: 'lookalike' });
  await liveness(call, sami.token);
  const res = await submit(call, sami.token);
  assert.equal(res.body.user.identity.status, 'PENDING');
  assert.equal(res.body.user.identity.faceMatch, 0.4);
  assert.equal(res.body.user.identity.autoVerified, false);

  const { token: admin } = await createAdmin(call);
  assert.equal(
    (await call('GET', '/users/identity/pending', { token: sami.token })).status,
    403,
  );
  const queue = await call('GET', '/users/identity/pending', { token: admin });
  assert.deepEqual(queue.body.items.map((u) => u.id), [sami.id]);
  assert.equal(queue.body.items[0].identity.faceMatch, 0.4);

  // L'administrateur compare la pièce et le visage.
  for (const side of ['front', 'selfie']) {
    const file = await call('GET', `/users/${sami.id}/identity/${side}`, {
      token: admin,
    });
    assert.equal(file.status, 200);
  }
  const selfie = await selfieFile(sami.id);
  const approved = await call('POST', `/users/${sami.id}/identity/approve`, {
    token: admin,
  });
  assert.equal(approved.body.user.identity.status, 'VERIFIED');
  assert.equal(approved.body.user.identity.autoVerified, false);
  assert.equal(approved.body.user.identity.selfieId, null);
  assert.equal(existsSync(identityPath(selfie)), false);
  await settle();
  assert.match(sent.sms.at(-1).text, /identité est vérifiée/);

  const twice = await call('POST', `/users/${sami.id}/identity/approve`, {
    token: admin,
  });
  assert.equal(twice.status, 409);
});

test('IA : un autre visage que celui de la pièce n est jamais validé seul', async (t) => {
  const { call } = await startApi(t);
  const { token } = await register(call);
  await uploadDocument(call, token, { front: 'other' });
  await liveness(call, token);
  const res = await submit(call, token);
  assert.equal(res.body.user.identity.status, 'PENDING');
  assert.equal(res.body.user.identity.faceMatch, 0);
});

test('refus avec motif : nouvelle pièce et nouveau visage pour recommencer', async (t) => {
  const { call, sent } = await startApi(t);
  const sami = await register(call);
  await uploadDocument(call, sami.token, { front: 'lookalike' });
  await liveness(call, sami.token);
  await submit(call, sami.token);
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

  // Photos de la pièce et du visage effacées, 24 h d'attente.
  const identity = rejected.body.user.identity;
  assert.equal(identity.frontId, null);
  assert.equal(identity.backId, null);
  assert.equal(identity.refusals, 1);
  assert.equal(identity.blocked, false);
  assert.ok(new Date(identity.retryAt) > new Date(Date.now() + 23 * 3600e3));
  const early = await call('PUT', '/users/me/identity/front', {
    token: sami.token,
    form: photo('me'),
  });
  assert.equal(early.status, 429);
  assert.equal(early.body.error.code, 'IDENTITY_RETRY_LATER');

  // 24 h plus tard : nouvelles photos et nouveau visage obligatoires.
  await passDelay(sami.id);
  assert.equal(
    (await submit(call, sami.token)).body.error.code,
    'IDENTITY_PHOTOS_REQUIRED',
  );
  await uploadDocument(call, sami.token);
  assert.equal((await submit(call, sami.token)).body.error.code, 'SELFIE_REQUIRED');
  await liveness(call, sami.token);
  const again = await submit(call, sami.token);
  assert.equal(again.body.user.identity.status, 'VERIFIED');
  assert.equal(again.body.user.identity.rejectionReason, null);
});

/** Fait comme si les 24 h d'attente étaient passées. */
const passDelay = (id) =>
  prisma.user.update({ where: { id }, data: { identityRetryAt: new Date(0) } });

/** Demande envoyée, l'IA hésite : en attente de l'administrateur. */
async function pendingRequest(call, token) {
  await uploadDocument(call, token, { front: 'lookalike' });
  await liveness(call, token);
  return submit(call, token);
}

test('refus grave : plus aucune demande, jusqu au déblocage', async (t) => {
  const { call } = await startApi(t);
  const sami = await register(call);
  await pendingRequest(call, sami.token);
  const { token: admin } = await createAdmin(call);
  const res = await call('POST', `/users/${sami.id}/identity/reject`, {
    token: admin,
    body: { reason: 'Le visage ne correspond pas à la pièce', severe: true },
  });
  assert.equal(res.body.user.identity.blocked, true);
  assert.equal(res.body.user.identity.retryAt, null);

  const blocked = await call('POST', '/users/me/identity/liveness', {
    token: sami.token,
  });
  assert.equal(blocked.status, 403);
  assert.equal(blocked.body.error.code, 'IDENTITY_BLOCKED');

  // Seul un administrateur débloque.
  assert.equal(
    (await call('POST', `/users/${sami.id}/identity/unblock`, { token: sami.token }))
      .status,
    403,
  );
  const unblocked = await call('POST', `/users/${sami.id}/identity/unblock`, {
    token: admin,
  });
  assert.equal(unblocked.body.user.identity.blocked, false);
  assert.equal(unblocked.body.user.identity.refusals, 0);
  assert.equal((await uploadDocument(call, sami.token)).status, 200);
});

test('3e refus : vérification bloquée, historique complet', async (t) => {
  const { call } = await startApi(t);
  const sami = await register(call);
  const { token: admin } = await createAdmin(call);
  for (let i = 1; i <= 3; i++) {
    await passDelay(sami.id);
    await pendingRequest(call, sami.token);
    const res = await call('POST', `/users/${sami.id}/identity/reject`, {
      token: admin,
      body: { reason: 'Photo floue' },
    });
    assert.equal(res.body.user.identity.refusals, i);
    assert.equal(res.body.user.identity.blocked, i === 3);
  }
  const history = await call('GET', `/users/${sami.id}/identity/attempts`, {
    token: admin,
  });
  assert.equal(history.body.items.length, 3);
  assert.ok(history.body.items.every((a) => a.outcome === 'REJECTED'));
  assert.equal(history.body.items[0].reason, 'Photo floue');
  assert.equal(history.body.items[0].faceMatch, 0.4);
  // Réservé aux administrateurs.
  assert.equal(
    (await call('GET', `/users/${sami.id}/identity/attempts`, { token: sami.token }))
      .status,
    403,
  );
});

test('historique : une validation par l IA est enregistrée', async (t) => {
  const { call } = await startApi(t);
  const sami = await register(call);
  await uploadDocument(call, sami.token);
  await liveness(call, sami.token);
  await submit(call, sami.token);
  const { token: admin } = await createAdmin(call);
  const history = await call('GET', `/users/${sami.id}/identity/attempts`, {
    token: admin,
  });
  assert.equal(history.body.items[0].outcome, 'AUTO_VERIFIED');
  assert.equal(history.body.items[0].number, '12345678');
});

test('passeport : une seule page, numéro au format du passeport', async (t) => {
  const { call } = await startApi(t);
  const { token } = await register(call);
  await uploadDocument(call, token, {
    front: 'passport',
    back: false,
    documentType: 'PASSPORT',
  });
  await liveness(call, token);

  const cinWithoutBack = await submit(call, token);
  assert.equal(cinWithoutBack.body.error.code, 'IDENTITY_PHOTOS_REQUIRED');
  const badNumber = await submit(call, token, {
    documentType: 'PASSPORT',
    number: '12345678',
  });
  assert.equal(badNumber.status, 400);
  const res = await submit(call, token, {
    documentType: 'PASSPORT',
    number: 'x 1234567',
  });
  assert.equal(res.status, 200);
  assert.equal(res.body.user.identity.documentType, 'PASSPORT');
  assert.equal(res.body.user.identity.cinNumber, 'X1234567');
  assert.equal(res.body.user.identity.status, 'VERIFIED');
});

test('permis de conduire : numéro du permis accepté', async (t) => {
  const { call } = await startApi(t);
  const { token } = await register(call);
  await uploadDocument(call, token, { front: 'license', documentType: 'LICENSE' });
  await liveness(call, token);
  const res = await submit(call, token, {
    documentType: 'LICENSE',
    number: '12/345678',
  });
  assert.equal(res.status, 200);
  assert.equal(res.body.user.identity.documentType, 'LICENSE');
});

test('un numéro de pièce ne sert qu à un seul compte', async (t) => {
  const { call } = await startApi(t);
  for (const [index, overrides] of [
    {},
    { email: 'autre@example.com', phone: '20777000' },
  ].entries()) {
    const { token } = await register(call, overrides);
    await uploadDocument(call, token);
    await liveness(call, token);
    const res = await submit(call, token);
    if (index === 1) {
      assert.equal(res.status, 409);
      assert.equal(res.body.error.code, 'CIN_IN_USE');
    }
  }
});

test('statistiques : identités validées par l IA', async (t) => {
  const { call } = await startApi(t);
  const { token } = await register(call);
  await uploadDocument(call, token);
  await liveness(call, token);
  await submit(call, token);
  const { token: admin } = await createAdmin(call);
  const stats = await call('GET', '/users/stats', { token: admin });
  assert.equal(stats.body.identityAutoVerified, 1);
  assert.equal(stats.body.identity.VERIFIED, 1);
});

test('lecture de la pièce : numéro, nom et naissance pré-remplis', async (t) => {
  const { call } = await startApi(t);
  const { token } = await register(call);
  const res = await uploadDocument(call, token, { back: false, documentType: 'CIN' });
  const identity = res.body.user.identity;
  assert.equal(identity.documentType, 'CIN');
  assert.equal(identity.extracted.number, '12345678');
  assert.equal(identity.extracted.firstNameAr, 'سامي');
  assert.equal(identity.extracted.birthDate, '1999-03-12');
});

test('verso : une photo avec un visage (un recto) est refusée', async (t) => {
  const { call } = await startApi(t);
  const { token } = await register(call);
  const res = await call('PUT', '/users/me/identity/back', {
    token,
    form: photo('other'),
  });
  assert.equal(res.status, 422);
  assert.equal(res.body.error.code, 'BACK_HAS_FACE');
});

test('numéro différent de celui lu sur la carte : l administrateur décide', async (t) => {
  const { call } = await startApi(t);
  const { token } = await register(call);
  await uploadDocument(call, token, { front: 'other-number' });
  await liveness(call, token);
  const res = await submit(call, token);
  const identity = res.body.user.identity;
  assert.equal(identity.status, 'PENDING');
  assert.equal(identity.faceMatch, 1);
  assert.deepEqual(identity.checks, {
    numberRead: '87654321',
    numberMatches: false,
    nameMatches: null,
    notExpired: null,
    backRecognized: true,
  });
});

test('carte illisible : jamais validée seule', async (t) => {
  const { call } = await startApi(t);
  const { token } = await register(call);
  await uploadDocument(call, token, { front: 'unreadable' });
  await liveness(call, token);
  const res = await submit(call, token);
  assert.equal(res.body.user.identity.status, 'PENDING');
  assert.equal(res.body.user.identity.checks.numberMatches, null);
});

test('passeport : nom de la MRZ et date de validité contrôlés', async (t) => {
  const { call } = await startApi(t);
  for (const [index, [front, check]] of [
    ['passport-other', 'nameMatches'],
    ['passport-expired', 'notExpired'],
  ].entries()) {
    const { token } = await register(call, {
      email: `p${index}@example.com`,
      phone: `2088800${index}`,
    });
    await uploadDocument(call, token, { front, back: false, documentType: 'PASSPORT' });
    await liveness(call, token);
    const res = await submit(call, token, {
      documentType: 'PASSPORT',
      number: `X123456${index}`,
    });
    assert.equal(res.body.user.identity.status, 'PENDING');
    assert.equal(res.body.user.identity.checks[check], false);
  }
});

test('permis du profil réutilisé comme pièce, sans nouvelle photo', async (t) => {
  const { call } = await startApi(t);
  const { token } = await register(call);
  const missing = await call('POST', '/users/me/identity/front/from-license', { token });
  assert.equal(missing.body.error.code, 'LICENSE_PHOTO_MISSING');

  await call('PUT', '/users/me/license-photo', { token, form: photo('license') });
  const res = await call('POST', '/users/me/identity/front/from-license', { token });
  assert.equal(res.status, 200);
  const identity = res.body.user.identity;
  assert.equal(identity.documentType, 'LICENSE');
  assert.ok(identity.frontId);
  assert.equal(identity.extracted.number, '12/345678');
  // Le permis du profil reste en place.
  assert.ok(res.body.user.licensePhotoId);
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

test('verso non reconnu : accepté, mais l IA ne valide pas seule', async (t) => {
  const { call } = await startApi(t);
  const { token } = await register(call);
  await uploadDocument(call, token, { back: false });
  // Pas de code-barres ni de date lus : la photo est gardée (photo de
  // téléphone difficile), un administrateur tranchera.
  const back = await call('PUT', '/users/me/identity/back', {
    token,
    form: photo('random'),
  });
  assert.equal(back.status, 200);
  await liveness(call, token);
  const res = await submit(call, token);
  assert.equal(res.body.user.identity.status, 'PENDING');
  assert.equal(res.body.user.identity.checks.backRecognized, false);
  assert.equal(res.body.user.identity.faceMatch, 1);
});

test('verso revérifié à l envoi : une ancienne photo ne passe plus', async (t) => {
  const { call } = await startApi(t);
  const sami = await register(call);
  await uploadDocument(call, sami.token);
  await liveness(call, sami.token);
  // Verso enregistré avant le contrôle : on remplace le fichier sur le disque.
  const row = await prisma.user.findUnique({ where: { id: sami.id } });
  const { writeFile } = await import('node:fs/promises');
  await writeFile(identityPath(row.cinBackFile), image('other'));
  const res = await submit(call, sami.token);
  assert.equal(res.status, 422);
  assert.equal(res.body.error.code, 'BACK_HAS_FACE');
});

test('visage : accord explicite exigé et daté (loi 2004-63)', async (t) => {
  const { call } = await startApi(t);
  const { token, id } = await register(call);
  const refused = await call('POST', '/users/me/identity/liveness', { token });
  assert.equal(refused.status, 400);
  assert.equal(refused.body.error.code, 'VALIDATION_ERROR');
  const ok = await call('POST', '/users/me/identity/liveness', {
    token,
    body: { consent: true },
  });
  assert.equal(ok.status, 200);
  const row = await prisma.user.findUnique({ where: { id } });
  assert.ok(row.identityBiometricConsentAt);
});

test('quota : 30 analyses par heure et par compte', async (t) => {
  const { call } = await startApi(t);
  const { token } = await register(call);
  const challenge = () =>
    call('POST', '/users/me/identity/liveness', {
      token,
      body: { consent: true },
    });
  for (let i = 0; i < 30; i++) assert.equal((await challenge()).status, 200);
  const over = await challenge();
  assert.equal(over.status, 429);
  assert.equal(over.body.error.code, 'AI_QUOTA_EXCEEDED');
  // Un autre compte n'est pas touché.
  const other = await register(call, { email: 'b@example.com', phone: '20555111' });
  const res = await call('POST', '/users/me/identity/liveness', {
    token: other.token,
    body: { consent: true },
  });
  assert.equal(res.status, 200);
});
