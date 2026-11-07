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
    'TRUNCATE "User", "Company", "Agency", "RefreshToken", "VerificationCode", "DeviceKey", "Session", "LoginEvent" CASCADE',
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
    if (type.startsWith('image/')) {
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
