import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { after, before, beforeEach, test } from 'node:test';

import { driver, migrate, prisma, resetDatabase, startApi } from './helpers.js';

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
