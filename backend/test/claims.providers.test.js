import assert from 'node:assert/strict';
import { chmodSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { createServer } from 'node:http';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { after, before, beforeEach, describe, test } from 'node:test';

import { migrate, prisma } from './helpers.js';

const { activeProvider, aiStatus, resetAi } = await import(
  '../src/modules/claims/ai/llm.js'
);

// Variables lues par llm.js : chaque test part d'un environnement connu, et
// la vraie CLI de la machine n'est jamais appelée.
const aiVariables = [
  'AI_PROVIDER',
  'NODE_ENV',
  'CLAUDE_CLI_PATH',
  'CLAUDE_MODEL',
  'ANTHROPIC_API_KEY',
  'OPENAI_API_KEY',
  'OPENAI_BASE_URL',
  'OPENAI_MODEL',
  'OPENAI_LABEL',
  'PERPLEXITY_API_KEY',
  'PERPLEXITY_BASE_URL',
  'PERPLEXITY_MODEL',
];
const saved = Object.fromEntries(aiVariables.map((name) => [name, process.env[name]]));
const folder = mkdtempSync(path.join(tmpdir(), 'claims-ai-'));
const missingCli = path.join(folder, 'absente');

function useEnvironment(values) {
  for (const name of aiVariables) delete process.env[name];
  process.env.CLAUDE_CLI_PATH = missingCli;
  Object.assign(process.env, values);
  resetAi();
}

// Fausse CLI : note ses arguments, son environnement et son entrée, puis
// répond comme `claude -p --output-format stream-json`.
function fakeCli(name, result) {
  const file = path.join(folder, name);
  const log = `${file}.log`;
  writeFileSync(
    file,
    `#!/usr/bin/env node
const fs = require('node:fs');
let input = '';
process.stdin.on('data', (c) => (input += c));
process.stdin.on('end', () => {
  fs.writeFileSync(${JSON.stringify(log)}, JSON.stringify({
    args: process.argv.slice(2), env: Object.keys(process.env), input, cwd: process.cwd(),
  }));
  console.log(JSON.stringify({ type: 'system', subtype: 'init' }));
  console.log(JSON.stringify(${JSON.stringify(result)}));
});
`,
  );
  chmodSync(file, 0o755);
  return { file, seen: () => JSON.parse(readFileSync(log, 'utf8')) };
}

describe('Fournisseurs d’IA', () => {
  test('auto : la CLI en développement, une clé en production', () => {
    const cli = fakeCli('claude-auto', {});
    useEnvironment({ NODE_ENV: 'development', CLAUDE_CLI_PATH: cli.file });
    assert.equal(activeProvider().id, 'claude-cli');

    useEnvironment({
      NODE_ENV: 'development',
      CLAUDE_CLI_PATH: cli.file,
      ANTHROPIC_API_KEY: 'k',
    });
    assert.equal(activeProvider().id, 'claude-cli');

    useEnvironment({ NODE_ENV: 'production', CLAUDE_CLI_PATH: cli.file });
    assert.equal(activeProvider(), null);

    useEnvironment({ NODE_ENV: 'production', ANTHROPIC_API_KEY: 'k', OPENAI_API_KEY: 'o' });
    assert.equal(activeProvider().id, 'anthropic');

    useEnvironment({ NODE_ENV: 'development', PERPLEXITY_API_KEY: 'p' });
    assert.equal(activeProvider().id, 'perplexity');

    // Ollama local : une adresse suffit, sans clé.
    useEnvironment({ NODE_ENV: 'development', OPENAI_BASE_URL: 'http://localhost:11434/v1' });
    assert.equal(activeProvider().id, 'openai');
  });

  test('AI_PROVIDER impose un fournisseur, ou aucun', () => {
    const cli = fakeCli('claude-forced', {});
    useEnvironment({ AI_PROVIDER: 'openai', OPENAI_API_KEY: 'o', CLAUDE_CLI_PATH: cli.file });
    assert.equal(activeProvider().id, 'openai');

    useEnvironment({ AI_PROVIDER: 'none', ANTHROPIC_API_KEY: 'k' });
    assert.equal(activeProvider(), null);

    // Imposé mais non configuré : les règles, pas un autre fournisseur.
    useEnvironment({ AI_PROVIDER: 'anthropic', OPENAI_API_KEY: 'o' });
    assert.equal(activeProvider(), null);
    assert.deepEqual(aiStatus().configured, ['openai']);
  });
});

describe('API sinistres avec chaque fournisseur', () => {
  let server;
  let fake;
  let fakeUrl;
  let base;
  let driver;
  let agent;
  let seq = 0;
  let requests = [];
  let replies = [];

  let testCompany;
  async function account(number, role, firstName, language = 'FR') {
    const { signAccessToken } = await import('../src/lib/tokens.js');
    // Un agent doit appartenir à une compagnie (companyScope, module 1).
    // Créée une seule fois : deux upserts simultanés se gênent.
    testCompany ??= prisma.company.upsert({
      where: { name: 'Compagnie prov' },
      update: {},
      create: { name: 'Compagnie prov' },
    });
    const companyId = role === 'AGENT' ? (await testCompany).id : null;
    const user = await prisma.user.upsert({
      where: { email: `prov${number}@test.tn` },
      update: { companyId, language },
      create: {
        firstName,
        lastName: 'Secret',
        email: `prov${number}@test.tn`,
        phone: `+21652${number}`,
        passwordHash: 'x',
        role,
        companyId,
        language,
      },
    });
    const session = await prisma.session.create({ data: { userId: user.id } });
    return { authorization: `Bearer ${signAccessToken(user, session.id)}`, id: user.id };
  }

  async function call(headers, method, route, body) {
    const response = await fetch(`${base}/api/claims${route}`, {
      method,
      headers: { ...headers, ...(body ? { 'content-type': 'application/json' } : {}) },
      body: body && JSON.stringify(body),
    });
    return { status: response.status, body: await response.json() };
  }

  async function newClaim() {
    const id = `SIN-PRV${++seq}`;
    await call(driver, 'POST', '/', {
      id,
      type: 'Collision',
      place: 'Sousse',
      date: '2026-11-07 10:00',
      severity: 'Grave',
      circumstances: ['Reculait'],
      impactZones: ['Avant'],
      observations: 'Pare-choc arrière abîmé.',
    });
    return id;
  }

  const ask = (headers, id, messages) =>
    call(headers, 'POST', `/${id}/ai/assistant`, { messages });

  const completion = (content, extra = {}) => ({
    choices: [{ message: { role: 'assistant', content }, finish_reason: 'stop' }],
    usage: { prompt_tokens: 30, completion_tokens: 7 },
    ...extra,
  });

  before(async () => {
    // Faux serveur au format OpenAI : note chaque requête, répond dans l'ordre.
    fake = createServer((req, res) => {
      let raw = '';
      req.on('data', (chunk) => (raw += chunk));
      req.on('end', () => {
        requests.push({ url: req.url, headers: req.headers, body: JSON.parse(raw) });
        const next = replies.shift() ?? completion('Réponse.');
        const status = typeof next === 'number' ? next : 200;
        res.writeHead(status, { 'content-type': 'application/json' });
        res.end(JSON.stringify(typeof next === 'number' ? { error: { message: 'x' } } : next));
      });
    });
    await new Promise((done) => fake.listen(0, done));
    fakeUrl = `http://127.0.0.1:${fake.address().port}`;

    migrate();
    [driver, agent] = await Promise.all([
      account('000001', 'DRIVER', 'Sami', 'AR'),
      account('000002', 'AGENT', 'Leïla', 'EN'),
    ]);
    const { createApp } = await import('../src/app.js');
    server = createApp().listen(0);
    await new Promise((done) => server.once('listening', done));
    base = `http://127.0.0.1:${server.address().port}`;
  });

  beforeEach(async () => {
    requests = [];
    replies = [];
    useEnvironment({ AI_PROVIDER: 'none' });
    await prisma.claim.deleteMany({ where: { driverId: driver.id } });
    await prisma.aiCall.deleteMany();
    await prisma.claimAiNote.deleteMany();
  });

  after(async () => {
    for (const [name, value] of Object.entries(saved)) {
      if (value === undefined) delete process.env[name];
      else process.env[name] = value;
    }
    resetAi();
    await prisma.claim.deleteMany({ where: { driverId: driver.id } });
    await prisma.user.deleteMany({ where: { email: { endsWith: '@test.tn' } } });
    server?.close();
    fake?.close();
    rmSync(folder, { recursive: true, force: true });
  });

  test('OpenAI compatible : données jointes, langue du profil, journal', async () => {
    const id = await newClaim();
    useEnvironment({
      AI_PROVIDER: 'openai',
      OPENAI_BASE_URL: `${fakeUrl}/v1/`,
      OPENAI_API_KEY: 'sk-test',
      OPENAI_MODEL: 'test-model',
      OPENAI_LABEL: 'Mistral',
    });
    replies = [completion('<think>brouillon</think>Proposal: A 100 %.')];
    const { body } = await ask(agent, id, [{ role: 'user', content: 'Responsibility?' }]);
    assert.deepEqual(body, {
      answer: 'Proposal: A 100 %.',
      source: 'ai',
      by: 'Mistral · test-model',
    });

    const [request] = requests;
    assert.equal(request.url, '/v1/chat/completions');
    assert.equal(request.headers.authorization, 'Bearer sk-test');
    assert.equal(request.body.model, 'test-model');
    const [system, user] = request.body.messages;
    assert.equal(system.role, 'system');
    assert.match(system.content, /Réponds en anglais/);
    // Les données du dossier sont dans le message de l'utilisateur, pas la consigne.
    assert.ok(!system.content.includes('<donnees>\n'));
    assert.ok(!system.content.includes('Pare-choc'));
    assert.match(user.content, /^<donnees>/);
    assert.match(user.content, /<analyse /);
    assert.match(user.content, /Responsibility\?$/);
    assert.ok(!user.content.includes('Sami'));

    const [logged] = await prisma.aiCall.findMany({ where: { claimId: id } });
    assert.equal(logged.source, 'openai');
    assert.equal(logged.model, 'test-model');
    assert.equal(logged.inputTokens, 30);
  });

  test('OpenAI compatible : le conducteur ne reçoit que ses données', async () => {
    const id = await newClaim();
    useEnvironment({ AI_PROVIDER: 'openai', OPENAI_BASE_URL: fakeUrl });
    replies = [completion('مرحبا')];
    const { body } = await ask(driver, id, [
      { role: 'user', content: 'Où en est mon dossier ?' },
      { role: 'assistant', content: 'Il est transmis.' },
      { role: 'user', content: 'Et ensuite ?' },
    ]);
    assert.equal(body.source, 'ai');
    const { messages } = requests[0].body;
    assert.match(messages[0].content, /Réponds en arabe/);
    // Sans clé (Ollama local), aucun en-tête d'autorisation.
    assert.equal(requests[0].headers.authorization, undefined);
    const sent = JSON.stringify(messages);
    assert.ok(sent.includes('<suivi '));
    assert.ok(!sent.includes('<analyse '));
    assert.ok(!sent.includes('estimate'));
    assert.deepEqual(
      messages.map((m) => m.role),
      ['system', 'user', 'assistant', 'user'],
    );
  });

  test('OpenAI compatible : réponses structurées, même entourées de texte', async () => {
    const id = await newClaim();
    await call(driver, 'POST', `/${id}/messages`, { body: 'Bonjour ?' });
    useEnvironment({ AI_PROVIDER: 'openai', OPENAI_BASE_URL: fakeUrl });
    replies = [completion('```json\n{"replies":["Bonjour.","Merci.","","Je regarde."]}\n```')];
    const { body } = await call(agent, 'POST', `/${id}/ai/replies`);
    assert.deepEqual(body.replies, ['Bonjour.', 'Merci.', 'Je regarde.']);
    assert.equal(body.source, 'ai');
    const format = requests[0].body.response_format;
    assert.equal(format.type, 'json_schema');
    assert.deepEqual(format.json_schema.schema.required, ['replies']);
  });

  test('une clé refusée renvoie aux règles et reste journalisée', async () => {
    const id = await newClaim();
    useEnvironment({ AI_PROVIDER: 'openai', OPENAI_BASE_URL: fakeUrl, OPENAI_API_KEY: 'bad' });
    replies = [401];
    const { body } = await ask(agent, id, [{ role: 'user', content: 'Responsabilité ?' }]);
    assert.equal(body.source, 'rules');
    assert.equal(body.by, null);
    const [logged] = await prisma.aiCall.findMany({ where: { claimId: id } });
    assert.equal(logged.ok, false);
    assert.equal(logged.error, 'clé refusée');
  });

  test('Perplexity : passerelle au format OpenAI, sans recherche web', async () => {
    const id = await newClaim();
    useEnvironment({
      AI_PROVIDER: 'perplexity',
      PERPLEXITY_API_KEY: 'pplx-test',
      PERPLEXITY_BASE_URL: fakeUrl,
    });
    replies = [completion('Résumé du dossier.')];
    const { body } = await call(agent, 'POST', `/${id}/ai/summary`);
    assert.deepEqual(body, {
      summary: 'Résumé du dossier.',
      source: 'ai',
      by: 'Perplexity · sonar',
    });
    assert.equal(requests[0].url, '/chat/completions');
    assert.equal(requests[0].body.model, 'sonar');
    assert.equal(requests[0].body.disable_search, true);

    // Synthèse inchangée : relue sans nouvel appel, avec son auteur.
    const again = await call(agent, 'POST', `/${id}/ai/summary`);
    assert.equal(again.body.by, 'Perplexity · sonar');
    assert.equal(requests.length, 1);
  });

  test('CLI Claude : sans outils ni secrets, conversation en un message', async () => {
    const id = await newClaim();
    const cli = fakeCli('claude-ok', {
      type: 'result',
      subtype: 'success',
      is_error: false,
      result: 'Prochaine action : désigner un expert.',
      usage: { input_tokens: 3, cache_read_input_tokens: 40, output_tokens: 9 },
    });
    useEnvironment({
      AI_PROVIDER: 'claude-cli',
      CLAUDE_CLI_PATH: cli.file,
      ANTHROPIC_API_KEY: 'ne-doit-pas-passer',
    });
    const { body } = await ask(agent, id, [
      { role: 'user', content: 'Statut ?' },
      { role: 'assistant', content: 'Transmis.' },
      { role: 'user', content: 'Et maintenant ?' },
    ]);
    assert.deepEqual(body, {
      answer: 'Prochaine action : désigner un expert.',
      source: 'ai',
      by: 'Claude (CLI) · claude-sonnet-5-5',
    });

    const { args, env, input, cwd } = cli.seen();
    const flag = (name) => args[args.indexOf(name) + 1];
    assert.ok(args.includes('-p'));
    assert.equal(flag('--tools'), '');
    assert.equal(flag('--model'), 'claude-sonnet-5-5');
    assert.equal(flag('--input-format'), 'stream-json');
    assert.ok(args.includes('--no-session-persistence'));
    assert.match(flag('--system-prompt'), /Réponds en anglais/);
    assert.ok(!args.includes('--json-schema'));
    // Ni clé, ni base, ni secret JWT dans l'environnement de la CLI.
    for (const secret of ['ANTHROPIC_API_KEY', 'DATABASE_URL', 'JWT_SECRET']) {
      assert.ok(!env.includes(secret), secret);
    }
    assert.notEqual(path.resolve(cwd), path.resolve(process.cwd()));

    const message = JSON.parse(input).message;
    const [{ text }] = message.content;
    assert.match(text, /^<donnees>/);
    assert.match(text, /Utilisateur : Statut \?\nAssistant : Transmis\./);
    assert.match(text, /Et maintenant \?$/);

    const [logged] = await prisma.aiCall.findMany({ where: { claimId: id } });
    assert.equal(logged.source, 'claude-cli');
    assert.equal(logged.inputTokens, 43);
  });

  test('CLI Claude : sortie structurée et erreur de connexion', async () => {
    const id = await newClaim();
    await call(driver, 'POST', `/${id}/messages`, { body: 'Bonjour ?' });
    const structured = fakeCli('claude-json', {
      type: 'result',
      subtype: 'success',
      is_error: false,
      result: '',
      structured_output: { replies: ['Bien reçu.'] },
      usage: {},
    });
    useEnvironment({ AI_PROVIDER: 'claude-cli', CLAUDE_CLI_PATH: structured.file });
    const { body } = await call(agent, 'POST', `/${id}/ai/replies`);
    assert.deepEqual(body.replies, ['Bien reçu.']);
    const { args } = structured.seen();
    assert.deepEqual(JSON.parse(args[args.indexOf('--json-schema') + 1]).required, ['replies']);

    const loggedOut = fakeCli('claude-logged-out', {
      type: 'result',
      subtype: 'success',
      is_error: true,
      result: 'Not logged in · Please run /login',
    });
    useEnvironment({ AI_PROVIDER: 'claude-cli', CLAUDE_CLI_PATH: loggedOut.file });
    const fallback = await ask(agent, id, [{ role: 'user', content: 'Responsabilité ?' }]);
    assert.equal(fallback.body.source, 'rules');
    const failed = await prisma.aiCall.findFirst({ where: { ok: false } });
    assert.match(failed.error, /Not logged in/);
  });

  test('sans modèle, les règles répondent dans la langue du profil', async () => {
    const id = await newClaim();
    // Leïla est en anglais, Sami en arabe.
    const english = await ask(agent, id, [{ role: 'user', content: 'Responsibility?' }]);
    assert.equal(english.body.source, 'rules');
    assert.match(english.body.answer, /^Proposal: A 100 %\. Reversing: risky manoeuvre by A\./);

    const arabic = await ask(driver, id, [{ role: 'user', content: 'متى ينتهي ملفي؟' }]);
    assert.match(arabic.body.answer, /^بقي حوالي \d+ أيام/);
    const money = await ask(driver, id, [{ role: 'user', content: 'كم مبلغ التعويض؟' }]);
    assert.match(money.body.answer, /العون/);

    const summary = await call(agent, 'POST', `/${id}/ai/summary`);
    assert.match(summary.body.summary, /^Collision \(Serious\) in Sousse, status Submitted\./);
    assert.match(summary.body.summary, /Next action: Take on the claim\./);

    await call(driver, 'POST', `/${id}/messages`, { body: 'Bonjour ?' });
    const replies = await call(agent, 'POST', `/${id}/ai/replies`);
    assert.match(replies.body.replies[0], /^Hello, your claim has been received/);
  });

  test('l’analyse envoyée à chacun est rédigée dans sa langue', async () => {
    const id = await newClaim();
    const forAgent = (await call(agent, 'GET', '/sync')).body.insights[id];
    assert.equal(forAgent.nextAction.label, 'Take on the claim.');
    // Le niveau reste un code ; seul le libellé est traduit.
    assert.ok(['faible', 'moyen', 'élevé'].includes(forAgent.risk.level));
    assert.ok(['low', 'medium', 'high'].includes(forAgent.risk.label));
    assert.deepEqual(forAgent.missingDocuments.map((d) => d.label), ['Devis', 'PV de police']);
    assert.equal(forAgent.missingDocuments[1].reason, 'Required for a serious claim.');

    const forDriver = (await call(driver, 'GET', '/sync')).body.insights[id];
    assert.equal(forDriver.driver.headline, 'تم استلام ملفك. سيتكفّل به أحد الأعوان.');
  });

  test('l’état dit quel modèle répond', async () => {
    useEnvironment({ AI_PROVIDER: 'perplexity', PERPLEXITY_API_KEY: 'p' });
    const { body } = await call(agent, 'GET', '/ai/status');
    assert.deepEqual(body.active, { provider: 'perplexity', label: 'Perplexity', model: 'sonar' });
    assert.deepEqual(body.configured, ['perplexity']);
  });
});
