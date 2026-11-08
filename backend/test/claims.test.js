import assert from 'node:assert/strict';
import { after, before, beforeEach, describe, test } from 'node:test';
import path from 'node:path';

import { io } from 'socket.io-client';

import { migrate, prisma } from './helpers.js';

// Ces tests ne parlent à aucun modèle, même si une CLI Claude est installée.
process.env.AI_PROVIDER = 'none';

const { createApp } = await import('../src/app.js');
const { signAccessToken } = await import('../src/lib/tokens.js');
const { attachClaimsSocket } = await import(
  '../src/modules/claims/claims.socket.js'
);

describe('API sinistres', () => {
  let server;
  let base;
  let seq = 0;
  let driver;
  let other;
  let agent;

  // Vrais comptes et vrais jetons : le module 1 relit l'utilisateur en base.
  async function account(id, role, firstName) {
    const user = await prisma.user.upsert({
      where: { email: `${id}@test.tn` },
      update: {},
      create: {
        firstName,
        lastName: 'Test',
        email: `${id}@test.tn`,
        phone: `+216${id}`,
        passwordHash: 'x',
        role,
      },
    });
    // Le module 1 lie chaque jeton à une session d'appareil.
    const session = await prisma.session.create({ data: { userId: user.id } });
    return {
      user,
      authorization: `Bearer ${signAccessToken(user, session.id)}`,
    };
  }

  async function call(headers, method, route, body) {
    const form = body instanceof FormData;
    const response = await fetch(`${base}/api/claims${route}`, {
      method,
      headers: {
        ...headers,
        ...(body && !form ? { 'content-type': 'application/json' } : {}),
      },
      body: form ? body : body && JSON.stringify(body),
    });
    const text = await response.text();
    let json;
    try {
      json = JSON.parse(text);
    } catch {
      json = text;
    }
    return { status: response.status, body: json };
  }

  async function createClaim(extra = {}) {
    const id = `SIN-T${++seq}`;
    const created = await call(driver, 'POST', '/', {
      id,
      type: 'Collision',
      place: 'Tunis',
      date: '2026-11-07 10:00',
      severity: 'Grave',
      circumstances: ['Reculait'],
      ...extra,
    });
    assert.equal(created.status, 201);
    return id;
  }

  async function inReview() {
    const id = await createClaim();
    await call(agent, 'POST', `/${id}/take-charge`);
    return id;
  }

  before(async () => {
    migrate();
    const accounts = await Promise.all([
      account('50000001', 'DRIVER', 'Sami'),
      account('50000002', 'DRIVER', 'Hedi'),
      account('50000003', 'AGENT', 'Leïla'),
    ]);
    [driver, other, agent] = accounts.map(({ authorization, user }) => ({
      authorization,
      id: user.id,
    }));
    server = createApp().listen(0);
    await new Promise((resolve) => server.once('listening', resolve));
    attachClaimsSocket(server);
    base = `http://127.0.0.1:${server.address().port}`;
  });

  beforeEach(async () => {
    await prisma.processedRequest.deleteMany();
    await prisma.claimNotification.deleteMany();
    await prisma.claim.deleteMany();
  });

  after(async () => {
    await prisma.claim.deleteMany();
    await prisma.user.deleteMany({ where: { email: { endsWith: '@test.tn' } } });
    await new Promise((resolve) => server.close(resolve));
  });

  test('refuse une requête sans identité', async () => {
    assert.equal((await call({}, 'GET', '/')).status, 401);
  });

  test('accepte un jeton du module 1 et refuse un faux', async () => {
    assert.equal((await call(driver, 'GET', '/')).status, 200);
    const bad = await call({ authorization: 'Bearer faux' }, 'GET', '/');
    assert.equal(bad.status, 401);
  });

  test('un en-tête d’identité seul ne donne aucun accès', async () => {
    const forged = { 'x-user-id': driver.id, 'x-user-role': 'agent' };
    assert.equal((await call(forged, 'GET', '/')).status, 401);
  });

  test('un dossier suit tout le parcours jusqu’à la clôture', async () => {
    const id = await createClaim();
    let claim = (await call(agent, 'POST', `/${id}/take-charge`)).body;
    assert.equal(claim.status, 'En instruction');
    assert.equal(claim.agentName, 'Leïla Test');

    claim = (
      await call(agent, 'POST', `/${id}/document-requests`, {
        id: 'r1',
        label: 'Devis',
      })
    ).body;
    assert.equal(claim.status, 'Pièce demandée');

    const form = new FormData();
    form.set('id', 'doc1');
    form.set('requestId', 'r1');
    form.set('file', new Blob(['contenu']), 'devis.pdf');
    claim = (await call(driver, 'POST', `/${id}/documents`, form)).body;
    assert.equal(claim.status, 'En instruction');
    assert.equal(claim.requests[0].documentId, 'doc1');

    const file = await call(driver, 'GET', '/files/document/doc1');
    assert.equal(file.status, 200);
    assert.equal(file.body, 'contenu');
    assert.equal((await call(other, 'GET', '/files/document/doc1')).status, 404);

    claim = (
      await call(agent, 'POST', `/${id}/expertise`, {
        expertName: 'M. Trabelsi',
        appointment: '2026-12-01T09:00:00.000Z',
      })
    ).body;
    assert.equal(claim.status, 'Expertise');

    const report = new FormData();
    report.set('file', new Blob(['rapport']), 'rapport.pdf');
    await call(agent, 'POST', `/${id}/expert-report`, report);

    claim = (
      await call(agent, 'POST', `/${id}/close`, {
        responsibility: 100,
        indemnity: 1250.5,
      })
    ).body;
    assert.equal(claim.status, 'Clôturé');
    assert.equal(claim.indemnity, 1250.5);
    assert.deepEqual(
      claim.documents.map((d) => d.kind),
      ['Pièce', "Rapport d'expertise"],
    );
    assert.equal(claim.events.at(-1).label, 'Clôturé');

    const notifications = (await call(driver, 'GET', '/notifications')).body;
    assert.equal(notifications.length, 5);
    assert.equal((await call(other, 'GET', '/notifications')).body.length, 0);
  });

  test('refuse un passage hors du cycle de vie', async () => {
    const id = await createClaim();
    const response = await call(agent, 'POST', `/${id}/close`, {
      responsibility: 50,
      indemnity: 10,
    });
    assert.equal(response.status, 409);
    const claim = (await call(agent, 'GET', `/${id}`)).body;
    assert.equal(claim.status, 'Transmis');
    assert.equal(claim.indemnity, null);
  });

  test('valide la décision', async () => {
    const id = await inReview();
    const close = (body) => call(agent, 'POST', `/${id}/close`, body);
    assert.equal((await close({ responsibility: 30, indemnity: 1 })).status, 400);
    assert.equal((await close({ responsibility: 50, indemnity: -1 })).status, 400);
    assert.equal((await close({ responsibility: 50 })).status, 400);
    const reject = await call(agent, 'POST', `/${id}/reject`, { reason: '  ' });
    assert.equal(reject.status, 400);
    const ok = await call(agent, 'POST', `/${id}/reject`, { reason: 'Hors garantie' });
    assert.equal(ok.body.status, 'Rejeté');
    assert.equal(ok.body.decisionReason, 'Hors garantie');
  });

  test('rendez-vous d’expertise : proposé, contre-proposé, confirmé', async () => {
    const id = await inReview();
    const soon = (days) => new Date(Date.now() + days * 86_400_000).toISOString();
    const slot = (who, body) => call(who, 'POST', `/${id}/appointment`, body);

    let claim = (
      await call(agent, 'POST', `/${id}/expertise`, {
        expertName: 'M. Trabelsi',
        expertPhone: '+216 71 000 000',
        expertPlace: 'Garage Ennour, Ariana',
        appointment: soon(2),
      })
    ).body;
    assert.equal(claim.status, 'Expertise');
    assert.equal(claim.expertKind, 'Véhicule');
    assert.equal(claim.appointmentState, 'proposed');
    assert.equal(claim.appointmentBy, 'agent');

    // On ne confirme pas son propre créneau.
    assert.equal((await slot(agent, { action: 'accept' })).status, 409);
    assert.equal((await slot(other, { action: 'accept' })).status, 404);
    assert.equal(
      (await slot(driver, { action: 'propose', appointment: '2020-01-01T09:00:00Z' })).status,
      400,
    );

    claim = (
      await slot(driver, { action: 'propose', appointment: soon(4), note: 'Je travaille le matin.' })
    ).body;
    assert.equal(claim.appointmentBy, 'driver');
    assert.equal(claim.appointmentNote, 'Je travaille le matin.');
    let agentNotes = (await call(agent, 'GET', '/notifications')).body;
    assert.match(agentNotes[0].body, /autre créneau proposé/);
    const insights = (await call(agent, 'GET', `/${id}/insights`)).body;
    assert.equal(insights.nextAction.code, 'answer-slot');

    claim = (await slot(agent, { action: 'accept' })).body;
    assert.equal(claim.appointmentState, 'accepted');
    assert.equal(claim.events.at(-1).label, 'Rendez-vous confirmé');
    const driverNotes = (await call(driver, 'GET', '/notifications')).body;
    assert.match(driverNotes[0].body, /rendez-vous d’expertise confirmé/);
    agentNotes = (await call(agent, 'GET', '/notifications')).body;
    assert.equal(agentNotes.filter((n) => /confirmé/.test(n.body)).length, 0);
  });

  test('un piéton a une expertise médicale', async () => {
    const id = await createClaim({ type: 'Piéton' });
    await call(agent, 'POST', `/${id}/take-charge`);
    const claim = (
      await call(agent, 'POST', `/${id}/expertise`, {
        expertName: 'Dr Gharbi',
        appointment: new Date(Date.now() + 86_400_000).toISOString(),
      })
    ).body;
    assert.equal(claim.expertKind, 'Corporelle');
    const view = (await call(driver, 'GET', `/${id}/insights`)).body.driver;
    assert.ok(view.todo.some((task) => /examen médical/.test(task)));
  });

  test('l’agent rouvre un dossier clôturé par erreur', async () => {
    const id = await inReview();
    await call(agent, 'POST', `/${id}/close`, { responsibility: 100, indemnity: 900 });
    assert.equal((await call(driver, 'POST', `/${id}/reopen`, { reason: 'x' })).status, 403);
    assert.equal((await call(agent, 'POST', `/${id}/reopen`, { reason: ' ' })).status, 400);
    const claim = (
      await call(agent, 'POST', `/${id}/reopen`, { reason: 'Montant erroné' })
    ).body;
    assert.equal(claim.status, 'En instruction');
    assert.equal(claim.indemnity, null);
    assert.equal(claim.responsibility, null);
    assert.equal(claim.events.at(-1).label, 'Rouvert : Montant erroné');
    // Un dossier en cours ne se rouvre pas.
    assert.equal((await call(agent, 'POST', `/${id}/reopen`, { reason: 'x' })).status, 409);
  });

  test('applique les rôles et isole les conducteurs', async () => {
    const id = await createClaim();
    assert.equal((await call(driver, 'POST', `/${id}/take-charge`)).status, 403);
    assert.equal((await call(other, 'GET', `/${id}`)).status, 404);
    assert.equal((await call(other, 'GET', '/')).body.length, 0);
    assert.equal((await call(agent, 'GET', '/')).body.length, 1);
    assert.equal((await call(other, 'GET', `/${id}/messages`)).status, 404);
  });

  test('filtre par statut, gravité et texte', async () => {
    const id = await createClaim();
    await createClaim({ severity: 'Léger', place: 'Sfax' });
    await call(agent, 'POST', `/${id}/take-charge`);
    const list = async (query) =>
      (await call(agent, 'GET', `/?${query}`)).body.length;
    assert.equal(await list('severity=Grave'), 1);
    assert.equal(await list(`status=${encodeURIComponent('En instruction')}`), 1);
    assert.equal(await list('q=sfax'), 1);
    assert.equal(await list('from=2100-01-01'), 0);
  });

  test('un renvoi avec la même clé ne s’applique pas deux fois', async () => {
    const id = await inReview();
    const headers = { ...driver, 'idempotency-key': 'k1' };
    const first = await call(headers, 'POST', `/${id}/messages`, messageForm());
    const second = await call(headers, 'POST', `/${id}/messages`, messageForm());
    assert.equal(first.status, 201);
    assert.equal(second.status, 201);
    assert.equal(second.body.id, first.body.id);
    assert.equal((await call(driver, 'GET', `/${id}/messages`)).body.length, 1);

    const keyed = { ...agent, 'idempotency-key': 'k2' };
    const request = { id: 'r9', label: 'Facture' };
    await call(keyed, 'POST', `/${id}/document-requests`, request);
    await call(keyed, 'POST', `/${id}/document-requests`, request);
    const claim = (await call(agent, 'GET', `/${id}`)).body;
    assert.equal(claim.requests.length, 1);
  });

  function messageForm() {
    const form = new FormData();
    form.set('id', 'm1');
    form.set('body', 'Bonjour');
    return form;
  }

  test('les médias de la déclaration rejoignent le dossier sans alerte par fichier', async () => {
    const id = await createClaim();
    const before = (await call(agent, 'GET', '/notifications')).body.length;
    for (const [kind, name] of [
      ['Photo', 'Vue d’ensemble.jpg'],
      ['Vidéo', 'Vidéo de la scène.mp4'],
      ['Constat amiable', `Constat ${id}.pdf`],
    ]) {
      const form = new FormData();
      form.set('name', name);
      form.set('kind', kind);
      form.set('file', new Blob([Buffer.from('x')]), name);
      assert.equal((await call(driver, 'POST', `/${id}/documents`, form)).status, 201);
    }
    const claim = (await call(agent, 'GET', `/${id}`)).body;
    assert.deepEqual(
      claim.documents.map((d) => d.kind).sort(),
      ['Constat amiable', 'Photo', 'Vidéo'],
    );
    assert.equal((await call(agent, 'GET', '/notifications')).body.length, before);

    // Une autre nature reste une pièce ordinaire, et l'agent est prévenu.
    const form = new FormData();
    form.set('name', 'rapport.pdf');
    form.set('kind', "Rapport d'expertise");
    await call(driver, 'POST', `/${id}/documents`, form);
    const again = (await call(agent, 'GET', `/${id}`)).body;
    assert.equal(again.documents.find((d) => d.name === 'rapport.pdf').kind, 'Pièce');
    assert.equal((await call(agent, 'GET', '/notifications')).body.length, before + 1);
  });

  test('une erreur annule toute la transaction', async () => {
    const id = await inReview();
    const form = new FormData();
    form.set('requestId', 'inconnue');
    form.set('name', 'x.pdf');
    const response = await call(driver, 'POST', `/${id}/documents`, form);
    assert.equal(response.status, 400);
    const claim = (await call(agent, 'GET', `/${id}`)).body;
    assert.equal(claim.documents.length, 0);
  });

  test('messagerie : pièce jointe et accusé de lecture', async () => {
    const id = await createClaim();
    const form = messageForm();
    form.set('file', new Blob(['photo']), 'photo.jpg');
    await call(driver, 'POST', `/${id}/messages`, form);

    const empty = new FormData();
    empty.set('body', '   ');
    assert.equal((await call(driver, 'POST', `/${id}/messages`, empty)).status, 400);

    await call(driver, 'POST', `/${id}/messages/read`);
    let [message] = (await call(driver, 'GET', `/${id}/messages`)).body;
    assert.equal(message.read, false, 'on ne lit pas ses propres messages');

    await call(agent, 'POST', `/${id}/messages/read`);
    [message] = (await call(driver, 'GET', `/${id}/messages`)).body;
    assert.equal(message.read, true);
    assert.equal(message.attachmentName, 'photo.jpg');
    assert.equal((await call(agent, 'GET', '/files/message/m1')).body, 'photo');
  });

  test('sync renvoie dossiers, notifications et messages', async () => {
    const id = await createClaim();
    await createClaim();
    await call(agent, 'POST', `/${id}/take-charge`);
    const { body } = await call(driver, 'GET', '/sync');
    assert.equal(body.claims.length, 2);
    assert.equal(body.notifications.length, 1);
    assert.deepEqual(body.messages, []);
  });

  test('marque lues seulement ses notifications', async () => {
    const id = await inReview();
    const [notification] = (await call(driver, 'GET', '/notifications')).body;
    await call(other, 'POST', '/notifications/read', { ids: [notification.id] });
    assert.equal((await call(driver, 'GET', '/notifications')).body[0].read, false);
    await call(driver, 'POST', '/notifications/read', { ids: [notification.id] });
    assert.equal((await call(driver, 'GET', '/notifications')).body[0].read, true);
    assert.ok(id);
  });

  test('prévient en direct le conducteur du dossier, pas les autres', async () => {
    const id = await createClaim();
    const connect = (auth) =>
      new Promise((resolve, reject) => {
        const socket = io(base, { path: '/api/claims/socket', auth });
        socket.once('connect', () => resolve(socket));
        socket.once('connect_error', reject);
      });
    const token = ({ authorization }) => authorization.slice('Bearer '.length);
    const mine = await connect({ token: token(driver) });
    const theirs = await connect({ token: token(other) });
    let leaked = false;
    theirs.on('claims:changed', () => {
      leaked = true;
    });
    const event = new Promise((resolve) => mine.once('claims:changed', resolve));
    await call(agent, 'POST', `/${id}/take-charge`);
    assert.deepEqual(await event, { claimId: id });
    await new Promise((resolve) => setTimeout(resolve, 100));
    assert.equal(leaked, false);
    mine.close();
    theirs.close();

    await assert.rejects(connect({}));
  });

  test('la documentation répond', async () => {
    const response = await fetch(`${base}/api/claims/openapi.json`);
    assert.equal(response.status, 200);
    assert.ok((await response.json()).paths['/{id}/close']);
  });
});
