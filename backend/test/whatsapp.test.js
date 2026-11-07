import assert from 'node:assert/strict';
import { afterEach, beforeEach, test } from 'node:test';

import { notifier } from '../src/lib/notifier.js';
import { chatId } from '../src/lib/whatsapp.js';

const ENV = ['WHATSAPP_API_URL', 'WHATSAPP_API_KEY', 'WHATSAPP_SESSION'];
let saved;

beforeEach(() => {
  saved = Object.fromEntries(ENV.map((k) => [k, process.env[k]]));
  process.env.WHATSAPP_API_URL = 'http://openwa.test/api';
  process.env.WHATSAPP_API_KEY = 'cle-de-test';
  process.env.WHATSAPP_SESSION = 'monconstat';
});

afterEach(() => {
  for (const [k, v] of Object.entries(saved)) {
    if (v === undefined) delete process.env[k];
    else process.env[k] = v;
  }
});

/** Faux OpenWA : enregistre les requêtes, session dans l'état donné. */
function fakeOpenWa(t, status = 'ready') {
  const requests = [];
  t.mock.method(globalThis, 'fetch', async (url, options = {}) => {
    requests.push({
      url,
      method: options.method ?? 'GET',
      key: options.headers['x-api-key'],
      body: options.body && JSON.parse(options.body),
    });
    if (url.endsWith('/sessions')) {
      return Response.json([
        { id: 'autre', name: 'autre', status: 'ready' },
        { id: 's1', name: 'monconstat', status },
      ]);
    }
    return Response.json({ ok: true });
  });
  return requests;
}

test('numéro au format WhatsApp', () => {
  assert.equal(chatId('+21620123456'), '21620123456@c.us');
});

test('envoie le code sur la session liée, avec la clé', async (t) => {
  const requests = fakeOpenWa(t);
  await notifier.sendToPhone('+21620123456', 'Votre code est 123456.');
  const send = requests.at(-1);
  assert.equal(send.url, 'http://openwa.test/api/sessions/s1/messages/send-text');
  assert.equal(send.method, 'POST');
  assert.equal(send.key, 'cle-de-test');
  assert.deepEqual(send.body, {
    chatId: '21620123456@c.us',
    text: 'Votre code est 123456.',
  });
});

test('session non liée : rien n est envoyé, le code reste dans les logs', async (t) => {
  const requests = fakeOpenWa(t, 'qr_ready');
  const logs = [];
  t.mock.method(console, 'log', (line) => logs.push(line));
  t.mock.method(console, 'error', () => {});
  await notifier.sendToPhone('+21620123456', 'Votre code est 123456.');
  assert.equal(requests.length, 1);
  assert.match(logs.join('\n'), /123456/);
});

test('OpenWA injoignable : l inscription n échoue pas', async (t) => {
  t.mock.method(globalThis, 'fetch', async () => {
    throw new TypeError('fetch failed');
  });
  t.mock.method(console, 'log', () => {});
  t.mock.method(console, 'error', () => {});
  await assert.doesNotReject(notifier.sendToPhone('+21620123456', 'code'));
});
