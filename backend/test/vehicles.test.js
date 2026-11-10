import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { after, before, beforeEach, test } from 'node:test';

import { driver, image, migrate, prisma, resetDatabase, startApi } from './helpers.js';

const PNG = image('doc');

const { sendExpiryReminders } = await import(
  '../src/modules/vehicles/vehicles.reminders.js'
);

before(migrate);
beforeEach(resetDatabase);
after(() => prisma.$disconnect());

const vehicleInput = (overrides = {}) => ({
  plate: '245 TU 8812',
  brand: 'Peugeot',
  model: '208',
  year: 2021,
  policy: 'POL-55821',
  insuranceExpiry: '2027-03-31',
  ...overrides,
});

async function signedDriver(call) {
  const { body } = await call('POST', '/auth/register', { body: driver() });
  return { token: body.accessToken, id: body.user.id };
}

test('véhicule : assureur choisi dans le référentiel des compagnies', async (t) => {
  const { call } = await startApi(t);
  const { token } = await signedDriver(call);
  const star = await prisma.company.create({ data: { name: 'STAR Assurances' } });

  const res = await call('POST', '/vehicles', {
    token,
    body: vehicleInput({ companyId: star.id }),
  });
  assert.equal(res.status, 201);
  assert.equal(res.body.companyId, star.id);
  // Nom repris de la compagnie, date gardée telle quelle.
  assert.equal(res.body.insurerName, 'STAR Assurances');
  assert.equal(res.body.insuranceExpiry, '2027-03-31');

  const unknown = await call('POST', '/vehicles', {
    token,
    body: vehicleInput({ plate: '1 TU 1', companyId: randomUUID() }),
  });
  assert.equal(unknown.status, 400);
  assert.equal(unknown.body.error.code, 'COMPANY_NOT_FOUND');

  const changed = await call('PATCH', `/vehicles/${res.body.id}`, {
    token,
    body: { companyId: null, insurerName: 'Autre', insuranceExpiry: '2028-01-15' },
  });
  assert.equal(changed.status, 200);
  assert.equal(changed.body.companyId, null);
  assert.equal(changed.body.insuranceExpiry, '2028-01-15');
});

test('véhicule : identifiant du téléphone gardé, renvoi sans doublon', async (t) => {
  const { call } = await startApi(t);
  const { token } = await signedDriver(call);
  const id = randomUUID();
  const first = await call('POST', '/vehicles', { token, body: vehicleInput({ id }) });
  assert.equal(first.status, 201);
  assert.equal(first.body.id, id);
  // Même envoi après une coupure réseau : même véhicule, pas d'erreur.
  const again = await call('POST', '/vehicles', { token, body: vehicleInput({ id }) });
  assert.equal(again.status, 201);
  assert.equal(again.body.id, id);
  assert.equal(await prisma.vehicle.count(), 1);
});

test('rappels d échéance : 30, 7 et 1 jours avant, une fois', async (t) => {
  const { call, sent } = await startApi(t);
  const { id } = await signedDriver(call);
  const today = new Date('2026-11-10T09:00:00Z');
  const inDays = (days) => new Date(Date.UTC(2026, 10, 10 + days));
  await prisma.vehicle.createMany({
    data: [
      { userId: id, plate: 'A', brand: 'Kia', model: 'Rio', year: 2020, policy: 'P1', insuranceExpiry: inDays(30) },
      { userId: id, plate: 'B', brand: 'Kia', model: 'Picanto', year: 2020, policy: 'P2', insuranceExpiry: inDays(90), technicalExpiry: inDays(7) },
      { userId: id, plate: 'C', brand: 'Fiat', model: 'Tipo', year: 2019, policy: 'P3', insuranceExpiry: inDays(1) },
      // Pas un jour de rappel, ou véhicule archivé : rien.
      { userId: id, plate: 'D', brand: 'Fiat', model: 'Uno', year: 2010, policy: 'P4', insuranceExpiry: inDays(12) },
      { userId: id, plate: 'E', brand: 'Fiat', model: 'Panda', year: 2012, policy: 'P5', insuranceExpiry: inDays(7), archived: true },
    ],
  });

  const count = await sendExpiryReminders(today);
  assert.equal(count, 3);
  const notes = await prisma.claimNotification.findMany({ where: { recipientId: id } });
  assert.equal(notes.length, 3);
  assert.ok(notes.some((n) => /assurance pour Kia Rio \(A\) expire dans 30 jours/.test(n.body)));
  assert.ok(notes.some((n) => /visite technique pour Kia Picanto \(B\) expire dans 7 jours/.test(n.body)));
  assert.ok(notes.some((n) => /Fiat Tipo \(C\) expire demain/.test(n.body)));
  // Aussi sur WhatsApp (SMS simulé dans les tests).
  assert.equal(sent.sms.filter((m) => /expire/.test(m.text)).length, 3);
});

// ── Lecture des documents du véhicule (données fictives) ─────────────────────
const docs = await import('../src/lib/vehicleDocs.js');

test('carte grise : plaque de la bande verticale, marque, modèle, année', () => {
  // Texte tel que l'OCR le rend, carte à l'endroit puis tournée d'un quart.
  const flat = [
    "CERTIFICAT D'IMMATRICULATION\n12345678 CIN (ou MF)\nKMHJ381ABCU123456\nRENAULT S7S111AB1\n2023/03/15 DPMC\nType commercial\nRENAULT CLIO",
  ];
  const turned = ['7781\n183\nN° d\'immatriculation', 'xx 18 ZZ'];
  const result = docs.parseRegistration({ flat, turned });
  assert.deepEqual(result, {
    plate: '183 TU 7781',
    brand: 'Renault',
    model: 'CLIO',
    year: 2023,
    firstRegistration: '2023-03-15',
  });
  // Les chiffres d'un long numéro (CIN) ne sont pas pris pour la plaque.
  assert.equal(docs.plateFromBand(['1234\n567'], ['12345678 CIN']), null);
});

test('carte grise : marque écrite avec des points, plaque à l horizontale', () => {
  assert.equal(docs.brandIn('Constructeur M.G.'), 'MG');
  assert.equal(docs.brandIn('PEUGEOT'), 'Peugeot');
  assert.equal(docs.plateIn('Immatriculation 4521TU198'), '198 TU 4521');
  assert.equal(docs.plateIn('198 TU 4521'), '198 TU 4521');
});

test('attestation : assureur, contrat, validité, plaque', () => {
  const flat = [
    "Attestation d'Assurance\nEntreprise d'Assurance\nCOMAR\nContrat N° 2025123456789\nValidité Du 01/09/2025 Au 31/08/2026\nImmatriculation 4521TU198\nMarque KIA\nFédération Tunisienne des Sociétés d'Assurances",
  ];
  assert.deepEqual(docs.parseInsurance({ flat }), {
    insurer: 'COMAR',
    policy: '2025123456789',
    startsAt: '2025-09-01',
    expiresAt: '2026-08-31',
    expiresAtEstimated: false,
    plate: '198 TU 4521',
    brand: 'Kia',
  });
});

test('attestation : dates mal lues et contrat retenu par vote seulement', () => {
  // Barres lues « 1 », fin seule lisible : la fin est la plus tardive.
  const result = docs.parseInsurance({
    flat: ['STAR\nDu: 0110912025\nfait le 20/08/2025\n31/08/2026'],
    policyVotes: [['2025111222333', 2]],
  });
  assert.equal(result.insurer, 'STAR Assurances');
  assert.equal(result.startsAt, '2025-09-01');
  assert.equal(result.expiresAt, '2026-08-31');
  assert.equal(result.policy, '2025111222333');
  // Une seule lecture du numéro : pas assez sûr, champ vide.
  assert.equal(
    docs.parseInsurance({ flat: ['GAT'], policyVotes: [['2025999', 1]] }).policy,
    null,
  );
  // Début seul : fin estimée à un an, signalée.
  const estimated = docs.parseInsurance({ flat: ['GAT\nValidité Du 10/02/2026'] });
  assert.equal(estimated.expiresAt, '2027-02-09');
  assert.equal(estimated.expiresAtEstimated, true);
});

test('lecture d un document : route, compagnie du référentiel, refus du type', async (t) => {
  const { call } = await startApi(t);
  const { token } = await signedDriver(call);
  const comar = await prisma.company.create({ data: { name: 'COMAR' } });
  t.mock.method(docs.vehicleDocReader, 'read', async (_buffer, kind) =>
    kind === 'INSURANCE'
      ? { insurer: 'COMAR', policy: 'P-1', expiresAt: '2026-08-31', plate: '198 TU 4521' }
      : { plate: '198 TU 4521', brand: 'Kia', model: 'Rio', year: 2022 },
  );
  const photo = (kind) => {
    const data = new FormData();
    data.append('kind', kind);
    data.append('photo', new Blob([PNG], { type: 'image/png' }), 'doc.png');
    return data;
  };
  const insurance = await call('POST', '/vehicles/scan', { token, form: photo('insurance') });
  assert.equal(insurance.status, 200);
  assert.equal(insurance.body.extracted.companyId, comar.id);
  const card = await call('POST', '/vehicles/scan', { token, form: photo('registration') });
  assert.equal(card.body.extracted.model, 'Rio');
  const wrong = await call('POST', '/vehicles/scan', { token, form: photo('passeport') });
  assert.equal(wrong.status, 400);
  // Rien n'est enregistré.
  assert.equal(await prisma.vehicle.count(), 0);
});
