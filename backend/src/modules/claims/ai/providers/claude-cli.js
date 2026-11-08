import { spawn } from 'node:child_process';
import { accessSync, constants, readdirSync } from 'node:fs';
import { homedir, tmpdir } from 'node:os';
import path from 'node:path';

import { AiUnavailable, transcript } from './shared.js';

// La CLI Claude Code installée sur la machine de développement : elle répond
// avec le compte Claude de la personne connectée, sans clé d'API.
// Réservée au développement : en production, une clé (voir llm.js).

const timeoutMs = 90_000;
const maxRunning = 2;

const executable = process.platform === 'win32' ? 'claude.exe' : 'claude';

function isExecutable(file) {
  try {
    accessSync(file, constants.X_OK);
    return true;
  } catch {
    return false;
  }
}

// La CLI fournie avec l'extension VS Code, la plus récente d'abord.
function fromEditorExtensions() {
  const found = [];
  for (const editor of ['.vscode', '.vscode-insiders', '.cursor', '.windsurf']) {
    const folder = path.join(homedir(), editor, 'extensions');
    let names = [];
    try {
      names = readdirSync(folder);
    } catch {
      continue;
    }
    for (const name of names.filter((n) => n.startsWith('anthropic.claude-code-'))) {
      found.push(path.join(folder, name, 'resources', 'native-binary', executable));
    }
  }
  return found.sort().reverse();
}

function candidates() {
  const fromPath = (process.env.PATH ?? '')
    .split(path.delimiter)
    .filter(Boolean)
    .map((dir) => path.join(dir, executable));
  return [
    ...fromPath,
    path.join(homedir(), '.claude', 'local', executable),
    path.join(homedir(), '.local', 'bin', executable),
    ...fromEditorExtensions(),
  ];
}

let binary;

/** Chemin de la CLI, ou null. CLAUDE_CLI_PATH l'impose. */
export function findBinary() {
  if (binary === undefined) {
    const forced = process.env.CLAUDE_CLI_PATH?.trim();
    binary = forced
      ? isExecutable(forced)
        ? forced
        : null
      : (candidates().find(isExecutable) ?? null);
  }
  return binary;
}

export const forgetBinary = () => {
  binary = undefined;
};

// Environnement minimal : la CLI n'a besoin ni de la base, ni des secrets de
// l'API. Sans clé d'API transmise, elle utilise la connexion Claude du compte.
function childEnv() {
  const keep = ['HOME', 'USER', 'LOGNAME', 'PATH', 'SHELL', 'LANG', 'TMPDIR', 'TEMP', 'TMP',
    'USERPROFILE', 'APPDATA', 'LOCALAPPDATA', 'SystemRoot', 'CLAUDE_CONFIG_DIR'];
  return Object.fromEntries(
    keep.filter((name) => process.env[name] !== undefined).map((name) => [name, process.env[name]]),
  );
}

// Quelques réponses à la fois au plus : chaque appel lance un processus.
let running = 0;
const waiting = [];
async function slot() {
  if (running >= maxRunning) await new Promise((resolve) => waiting.push(resolve));
  running++;
  return () => {
    running--;
    waiting.shift()?.();
  };
}

function attachmentBlock({ mediaType, data }) {
  const source = { type: 'base64', media_type: mediaType, data };
  return { type: mediaType === 'application/pdf' ? 'document' : 'image', source };
}

export async function run({ binary: file, model, system, messages, tools, schema, attachment, effort }) {
  if (!file) throw new AiUnavailable('CLI Claude introuvable');
  const args = [
    '-p',
    '--input-format', 'stream-json',
    '--output-format', 'stream-json',
    '--verbose',
    // Aucun outil : la CLI ne lit, n'écrit et n'exécute rien sur la machine.
    '--tools', '',
    '--strict-mcp-config',
    '--setting-sources', '',
    '--disable-slash-commands',
    '--no-session-persistence',
    '--model', model,
    '--effort', effort,
    '--system-prompt', system,
    ...(schema ? ['--json-schema', JSON.stringify(schema)] : []),
  ];
  const content = [
    ...(attachment ? [attachmentBlock(attachment)] : []),
    { type: 'text', text: transcript(messages, tools) },
  ];
  const input = `${JSON.stringify({ type: 'user', message: { role: 'user', content } })}\n`;

  const release = await slot();
  try {
    const output = await new Promise((resolve, reject) => {
      const child = spawn(file, args, { cwd: tmpdir(), env: childEnv() });
      let stdout = '';
      let stderr = '';
      const timer = setTimeout(() => {
        child.kill('SIGKILL');
        reject(new AiUnavailable('délai dépassé'));
      }, timeoutMs);
      child.stdout.on('data', (chunk) => (stdout += chunk));
      child.stderr.on('data', (chunk) => (stderr += chunk));
      child.on('error', (error) => {
        clearTimeout(timer);
        reject(new AiUnavailable(`CLI Claude : ${error.code ?? error.message}`));
      });
      child.on('close', () => {
        clearTimeout(timer);
        resolve({ stdout, stderr });
      });
      child.stdin.on('error', () => {});
      child.stdin.end(input);
    });
    const result = output.stdout
      .split('\n')
      .map((line) => {
        try {
          return JSON.parse(line);
        } catch {
          return null;
        }
      })
      .findLast((event) => event?.type === 'result');
    if (!result) {
      const detail = output.stderr.trim().split('\n').at(-1) ?? '';
      throw new AiUnavailable(`CLI Claude sans réponse${detail ? ` : ${detail.slice(0, 160)}` : ''}`);
    }
    if (result.is_error || result.subtype !== 'success') {
      throw new AiUnavailable(`CLI Claude : ${String(result.result ?? result.subtype).slice(0, 160)}`);
    }
    const usage = result.usage ?? {};
    return {
      text: String(result.result ?? '').trim(),
      json: result.structured_output ?? undefined,
      inputTokens:
        (usage.input_tokens ?? 0) +
        (usage.cache_read_input_tokens ?? 0) +
        (usage.cache_creation_input_tokens ?? 0),
      outputTokens: usage.output_tokens,
    };
  } finally {
    release();
  }
}
