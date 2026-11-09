import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { after, before, beforeEach, test } from 'node:test';

import { driver, migrate, prisma, resetDatabase, startApi } from './helpers.js';

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

