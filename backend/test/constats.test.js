import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { after, before, beforeEach, test } from 'node:test';

import { driver, migrate, prisma, resetDatabase, startApi } from './helpers.js';
import { verifyPdfBuffer } from '../src/lib/pdf-signature.js';

before(migrate);
beforeEach(resetDatabase);
after(() => prisma.$disconnect());

// Contenu PDF factice pour les tests (avec entête %PDF)
const dummyPdfBuffer = Buffer.from('%PDF-1.4 dummy test constat content %EOF');
const dummyPdfHash = createHash('sha256').update(dummyPdfBuffer).digest('hex');
const dummyPdfBase64 = dummyPdfBuffer.toString('base64');

async function register(call, overrides = {}) {
  const response = await call('POST', '/auth/register', {
    body: driver(overrides),
  });
  assert.equal(response.status, 201);
  return response.body;
}

const sampleConstatInput = (overrides = {}) => ({
  sha256Hash: dummyPdfHash,
  pdfBase64: dummyPdfBase64,
  driverAName: 'Sami Ben Ali',
  driverAPlate: '180 TN 4567',
  driverAInsurer: 'STAR Assurances',
  driverBName: 'Karim Trabelsi',
  driverBEmail: 'karim@example.com',
  driverBPlate: '210 TN 8901',
  driverBInsurer: 'GAT Assurances',
  place: 'Route de La Marsa, Tunis',
  occurredAt: '2026-11-08T14:30:00.000Z',
  circumstancesA: ['1 - En stationnement'],
  circumstancesB: ['2 - Quittait un stationnement'],
  impactZones: ['Arrière droit'],
  observations: 'Choc arrière lors d’une manœuvre.',
  ...overrides,
});

test('les routes constats protégées exigent une authentification', async (t) => {
  const { call } = await startApi(t);
  assert.equal((await call('GET', '/constats')).status, 401);
  assert.equal((await call('GET', '/constats/f0000000-0000-0000-0000-000000000001')).status, 401);
});

test('vérification publique d’un hash SHA-256', async (t) => {
  const { call } = await startApi(t);
  
  // Hash invalide (pas 64 car)
  const badHash = await call('GET', '/constats/verify/tropcourt');
  assert.equal(badHash.status, 400);

  // Hash introuvable
  const notFound = await call('GET', `/constats/verify/${'a'.repeat(64)}`);
  assert.equal(notFound.status, 404);
});

test('refuse un constat si le hash SHA-256 ne correspond pas au PDF', async (t) => {
  const { call } = await startApi(t);
  const auth = await register(call);

  const res = await call('POST', '/constats', {
    token: auth.accessToken,
    body: sampleConstatInput({
      sha256Hash: 'b'.repeat(64), // mauvais hash
    }),
  });
  assert.equal(res.status, 400);
  assert.equal(res.body.error.code, 'HASH_MISMATCH');
});

test('scelle un constat, le liste, le consulte et vérifie son authenticité publique', async (t) => {
  const { call, sent } = await startApi(t);
  const auth = await register(call);

  // 1. Création / scellement
  const created = await call('POST', '/constats', {
    token: auth.accessToken,
    body: sampleConstatInput(),
  });

  assert.equal(created.status, 201);
  assert.equal(created.body.constat.sha256Hash, dummyPdfHash);
  assert.equal(created.body.constat.driverAName, 'Sami Ben Ali');
  assert.equal(created.body.constat.driverBName, 'Karim Trabelsi');
  assert.equal(created.body.constat.status, 'SIGNED');

  const constatId = created.body.constat.id;

  // 2. Notification e-mail envoyée
  assert.ok(sent.mail.length >= 1);
  assert.ok(sent.mail.some((m) => m.to === auth.user.email));

  // 3. Liste des constats
  const list = await call('GET', '/constats', { token: auth.accessToken });
  assert.equal(list.status, 200);
  assert.equal(list.body.constats.length, 1);
  assert.equal(list.body.constats[0].id, constatId);

  // 4. Consultation unitaire
  const detail = await call('GET', `/constats/${constatId}`, { token: auth.accessToken });
  assert.equal(detail.status, 200);
  assert.equal(detail.body.constat.place, 'Route de La Marsa, Tunis');

  // 5. Téléchargement du PDF
  const pdfRes = await call('GET', `/constats/${constatId}/pdf`, { token: auth.accessToken });
  assert.equal(pdfRes.status, 200);

  // 6. Vérification publique par le hash SHA-256
  const verify = await call('GET', `/constats/verify/${dummyPdfHash}`);
  assert.equal(verify.status, 200);
  assert.equal(verify.body.valid, true);
  assert.equal(verify.body.constat.driverAPlate, '180 TN 4567');
});

test('refuse de sceller deux fois le même constat (inviolabilité)', async (t) => {
  const { call } = await startApi(t);
  const auth = await register(call);

  const first = await call('POST', '/constats', {
    token: auth.accessToken,
    body: sampleConstatInput(),
  });
  assert.equal(first.status, 201);

  const duplicate = await call('POST', '/constats', {
    token: auth.accessToken,
    body: sampleConstatInput(),
  });
  assert.equal(duplicate.status, 409);
  assert.equal(duplicate.body.error.code, 'CONSTAT_ALREADY_SEALED');
});

test('un agent d’assurance ne peut voir que les constats de sa compagnie', async (t) => {
  const { call } = await startApi(t);
  const authDriver = await register(call);

  // Création des compagnies
  const companyStar = await prisma.company.create({ data: { name: 'STAR' } });
  const companyGat = await prisma.company.create({ data: { name: 'GAT' } });
  const companyComar = await prisma.company.create({ data: { name: 'COMAR' } });

  // Création du constat associant STAR (A) et GAT (B)
  const created = await call('POST', '/constats', {
    token: authDriver.accessToken,
    body: sampleConstatInput({
      companyAId: companyStar.id,
      companyBId: companyGat.id,
    }),
  });
  assert.equal(created.status, 201);
  const constatId = created.body.constat.id;

  // Création d'un agent STAR
  const agentStarAuth = await register(call, {
    email: 'agent.star@example.com',
    phone: '21111222',
  });
  await prisma.user.update({
    where: { id: agentStarAuth.user.id },
    data: { role: 'AGENT', companyId: companyStar.id },
  });

  // L'agent STAR peut voir le constat
  const starView = await call('GET', `/constats/${constatId}`, {
    token: agentStarAuth.accessToken,
  });
  assert.equal(starView.status, 200);

  // Création d'un agent COMAR (compagnie non impliquée)
  const agentComarAuth = await register(call, {
    email: 'agent.comar@example.com',
    phone: '22333444',
  });
  await prisma.user.update({
    where: { id: agentComarAuth.user.id },
    data: { role: 'AGENT', companyId: companyComar.id },
  });

  // L'agent COMAR se voit refuser l'accès
  const comarView = await call('GET', `/constats/${constatId}`, {
    token: agentComarAuth.accessToken,
  });
  assert.equal(comarView.status, 403);
});

test('scellement en 2 étapes : diffère l’e-mail, finalise le PDF avec signature ECDSA et verrouille une 2e finalisation', async (t) => {
  const { call, sent } = await startApi(t);
  const owner = await register(call);
  const stranger = await register(call, {
    email: 'stranger@example.com',
    phone: '29888777',
  });

  const signaturesHash = 'd'.repeat(64);
  const signedIso = '2026-11-10T15:00:00.000Z';

  // 1. Scellement initial avec deferEmail: true + signaturesHash + circonstances/croquis
  const created = await call('POST', '/constats', {
    token: owner.accessToken,
    body: sampleConstatInput({
      deferEmail: true,
      signaturesHash,
      sketchData: [[{ x: 0.2, y: 0.3 }, { x: 0.7, y: 0.8 }]],
      driverASignedAt: signedIso,
      driverBSignedAt: signedIso,
    }),
  });
  assert.equal(created.status, 201);
  const constatId = created.body.constat.id;

  // L'e-mail ne doit PAS encore être parti avant la finalisation du PDF estampillé
  assert.equal(sent.mail.length, 0);

  // Le JWS embarque le format compact (v: 2) avec codes circonstances, chocs, observations et empreintes
  const parts = created.body.jwsToken.split('.');
  const jwsPayload = JSON.parse(Buffer.from(parts[1], 'base64url').toString('utf8'));
  const b64 = (hex) => Buffer.from(hex, 'hex').toString('base64url');
  assert.deepEqual(jwsPayload.data.cA, [1]);
  assert.deepEqual(jwsPayload.data.cB, [2]);
  assert.deepEqual(jwsPayload.data.im, ['Arrière droit']);
  assert.equal(jwsPayload.data.ob, 'Choc arrière lors d’une manœuvre.');
  assert.equal(jwsPayload.data.sg, b64(signaturesHash));
  assert.match(jwsPayload.data.sk, /^[A-Za-z0-9_-]{43}$/);
  assert.match(jwsPayload.data.fh, /^[A-Za-z0-9_-]{43}$/);

  // 2. Un autre conducteur ne peut pas finaliser ce constat
  const stampedPdf = Buffer.from('%PDF-1.4 stamped-with-qr-code-content\n%%EOF\n', 'latin1');
  const forbiddenForm = new FormData();
  forbiddenForm.append('pdf', new Blob([stampedPdf], { type: 'application/pdf' }), 'stamped.pdf');
  const forbiddenRes = await call('POST', `/constats/${constatId}/finalize-pdf`, {
    token: stranger.accessToken,
    form: forbiddenForm,
  });
  assert.equal(forbiddenRes.status, 403);

  // 3. Refuse un fichier non-PDF
  const badFileForm = new FormData();
  badFileForm.append('pdf', new Blob([Buffer.from('NOT A PDF')], { type: 'application/pdf' }), 'bad.pdf');
  const badFileRes = await call('POST', `/constats/${constatId}/finalize-pdf`, {
    token: owner.accessToken,
    form: badFileForm,
  });
  assert.equal(badFileRes.status, 415);

  // 4. Finalisation légitime : retourne le PDF signé ECDSA P-256 (/ByteRange)
  const finalizeForm = new FormData();
  finalizeForm.append('pdf', new Blob([stampedPdf], { type: 'application/pdf' }), 'stamped.pdf');
  const finalized = await call('POST', `/constats/${constatId}/finalize-pdf`, {
    token: owner.accessToken,
    form: finalizeForm,
  });
  assert.equal(finalized.status, 200);
  assert.equal(finalized.type, 'application/pdf');

  const verifySigned = await verifyPdfBuffer(finalized.bytes);
  assert.equal(verifySigned.valid, true);
  assert.equal(verifySigned.metadata.constatId, constatId);
  assert.equal(verifySigned.metadata.contentSha256, dummyPdfHash);
  assert.equal(verifySigned.metadata.signaturesSha256, signaturesHash);

  // Toute modification d'1 octet du PDF téléchargé doit invalider la signature
  const tamperedPdf = Buffer.from(finalized.bytes);
  tamperedPdf[12] ^= 0xff;
  assert.equal((await verifyPdfBuffer(tamperedPdf)).valid, false);

  // Les e-mails scellés ont bien été envoyés après finalisation (Conducteur A + Conducteur B)
  assert.ok(sent.mail.length >= 2);

  // GET /constats/:id/pdf retourne exactement le PDF finalisé signé
  const fetchedPdf = await call('GET', `/constats/${constatId}/pdf`, {
    token: owner.accessToken,
  });
  assert.equal(fetchedPdf.status, 200);
  assert.equal(Buffer.compare(fetchedPdf.bytes, finalized.bytes), 0);

  // 5. Deuxième tentative de finalisation bloquée (verrou unique)
  const replayForm = new FormData();
  replayForm.append('pdf', new Blob([stampedPdf], { type: 'application/pdf' }), 'stamped.pdf');
  const replayRes = await call('POST', `/constats/${constatId}/finalize-pdf`, {
    token: owner.accessToken,
    form: replayForm,
  });
  assert.equal(replayRes.status, 409);
  assert.equal(replayRes.body.error.code, 'PDF_ALREADY_FINALIZED');
});

