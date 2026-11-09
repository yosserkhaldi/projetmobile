// À importer avant `src/` : fixe l'environnement de test.
import { execFileSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const backendDir = join(dirname(fileURLToPath(import.meta.url)), '..');

// Base dédiée, créée par Prisma : les tests ne touchent jamais aux données de développement.
process.env.DATABASE_URL =
  process.env.TEST_DATABASE_URL ??
  'postgresql://monconstat:monconstat@localhost:5434/monconstat_test';
process.env.JWT_SECRET = 'secret-de-test';
process.env.UPLOAD_DIR = join(tmpdir(), `monconstat-test-${process.pid}`);

const { createApp } = await import('../src/app.js');
const { prisma } = await import('../src/lib/prisma.js');
const { notifier } = await import('../src/lib/notifier.js');
const { faceEngine } = await import('../src/lib/face.js');
const { documentReader } = await import('../src/lib/ocr.js');

export { prisma };

export function migrate() {
  execFileSync(
    process.execPath,
    [join(backendDir, 'node_modules/prisma/build/index.js'), 'migrate', 'deploy'],
    { cwd: backendDir, env: process.env, stdio: 'pipe' },
  );
}

export const resetDatabase = () =>
  prisma.$executeRawUnsafe(
    'TRUNCATE "User", "Company", "Agency", "RefreshToken", "VerificationCode", "DeviceKey", "Session", "LoginEvent", "Accident", "Vehicle", "Constat" CASCADE',
  );

/** Démarre l'API sur un port libre et capture les SMS et e-mails envoyés. */
export async function startApi(t) {
  const sent = { sms: [], mail: [] };
  t.mock.method(notifier, 'sendToPhone', async (to, text) => {
    sent.sms.push({ to, text });
  });
  t.mock.method(notifier, 'sendMail', async (to, subject, text, html) => {
    sent.mail.push({ to, subject, text, html });
  });
  t.mock.method(faceEngine, 'analyze', async (buffer) => fakeFaces(buffer));
  t.mock.method(documentReader, 'read', async (buffer, type) => ({
    type,
    ...fakeReading(buffer),
  }));
  // Verso : reconnu, sauf une photo quelconque (étiquette « random »).
  t.mock.method(documentReader, 'readBack', async (buffer) => ({
    recognized: tagOf(buffer) !== 'random',
  }));
  const server = createApp().listen(0);
  await new Promise((resolve) => server.once('listening', resolve));
  t.after(() => server.close());
  const base = `http://127.0.0.1:${server.address().port}/api`;

  const call = async (method, path, { body, token, form } = {}) => {
    const response = await fetch(base + path, {
      method,
      headers: {
        ...(body !== undefined && { 'Content-Type': 'application/json' }),
        ...(token && { Authorization: `Bearer ${token}` }),
      },
      body: form ?? (body === undefined ? undefined : JSON.stringify(body)),
    });
    const type = response.headers.get('content-type') ?? '';
    if (type.startsWith('image/') || type === 'application/pdf') {
      return {
        status: response.status,
        type,
        bytes: Buffer.from(await response.arrayBuffer()),
      };
    }
    const text = await response.text();
    return { status: response.status, body: text ? JSON.parse(text) : null };
  };
  return { call, sent, base };
}

export const codeFrom = (message) => message.text.match(/\d{6}/)[0];

export const driver = (overrides = {}) => ({
  firstName: 'Sami',
  lastName: 'Ben Ali',
  email: 'sami@example.com',
  phone: '20 123 456',
  password: 'Password123!',
  consent: true,
  ...overrides,
});

/** Crée un administrateur directement en base : aucune route ne le permet. */
export async function createAdmin(call) {
  const email = 'admin@example.com';
  const { status, body } = await call('POST', '/auth/register', {
    body: driver({ email, phone: '20999999' }),
  });
  if (status !== 201) throw new Error(`Inscription impossible : ${status}`);
  await prisma.user.update({ where: { email }, data: { role: 'ADMIN' } });
  return { token: body.accessToken, id: body.user.id };
}

// ---------------------------------------------------------------------------
// Reconnaissance faciale simulée : le vrai moteur est testé à part
// (face.test.js). Une image de test porte une étiquette après ses octets PNG,
// qui dit ce que l'IA « voit ».

const PNG = Buffer.from(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  'base64',
);
const TAG = '#face:';
const vector = (value) => Array(128).fill(value);

/** Empreintes : « me » et ses variantes sont la même personne, « other » non,
 * « lookalike » ressemble à moitié (ressemblance 0,4). */
export const FACES = {
  me: { faces: 1, descriptor: vector(0), yaw: 0.02 },
  'me-left': { faces: 1, descriptor: vector(0.01), yaw: 0.35 },
  'me-right': { faces: 1, descriptor: vector(0.01), yaw: -0.35 },
  'me-tilted': { faces: 1, descriptor: vector(0.01), yaw: 0.05 },
  'me-sideways': { faces: 1, descriptor: vector(0), yaw: 0.3 },
  other: { faces: 1, descriptor: vector(0.1), yaw: -0.35 },
  lookalike: { faces: 1, descriptor: vector(0.6 / Math.sqrt(128)), yaw: 0 },
  blank: { faces: 0 },
  random: { faces: 0 },
  unreadable: { faces: 1, descriptor: vector(0), yaw: 0 },
  'other-number': { faces: 1, descriptor: vector(0), yaw: 0 },
  'other-name': { faces: 1, descriptor: vector(0), yaw: 0 },
  passport: { faces: 1, descriptor: vector(0), yaw: 0 },
  'passport-expired': { faces: 1, descriptor: vector(0), yaw: 0 },
  'passport-other': { faces: 1, descriptor: vector(0), yaw: 0 },
  license: { faces: 1, descriptor: vector(0), yaw: 0 },
  crowd: { faces: 2, descriptor: vector(0), yaw: 0 },
};

/** Image PNG valide portant l'étiquette `tag`. */
export const image = (tag = 'me') =>
  Buffer.concat([PNG, Buffer.from(TAG + tag)]);

function tagOf(buffer) {
  const text = buffer.toString('latin1');
  const at = text.lastIndexOf(TAG);
  return at === -1 ? 'me' : text.slice(at + TAG.length);
}

const fakeFaces = (buffer) => FACES[tagOf(buffer)] ?? FACES.me;

/** Ce que l'OCR « lit » sur une pièce, selon son étiquette. */
export const READINGS = {
  me: { number: '12345678', lastNameAr: 'بن علي', firstNameAr: 'سامي', birthDate: '1999-03-12' },
  unreadable: { number: null },
  'other-number': { number: '87654321' },
  // Nom arabe d'une autre personne que « Sami Ben Ali ».
  'other-name': { number: '12345678', lastNameAr: 'الطرابلسي', firstNameAr: 'منى', birthDate: '1999-03-12' },
  passport: { number: 'X1234567', lastName: 'BEN ALI', firstName: 'SAMI', expiresAt: '2030-01-01' },
  'passport-expired': { number: 'X1234567', lastName: 'BEN ALI', firstName: 'SAMI', expiresAt: '2020-01-01' },
  'passport-other': { number: 'X1234567', lastName: 'TRABELSI', firstName: 'MOUNA', expiresAt: '2030-01-01' },
  license: {
    number: '12/345678',
    birthDate: '1999-03-12',
    categories: ['B', 'B+E'],
    issuedAt: '2020-05-10',
    expiresAt: '2030-05-10',
  },
};

const fakeReading = (buffer) => READINGS[tagOf(buffer)] ?? READINGS.me;
