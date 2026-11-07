import Anthropic from '@anthropic-ai/sdk';

import { db } from '../claims.db.js';

const defaultModel = 'claude-opus-5-5';

// Modèles qui acceptent le repli côté serveur en cas de refus.
const withFallback = ['claude-opus-5-5', 'claude-fable-5-1', 'claude-sonnet-5-5'];

export const claudeModel = () => process.env.CLAUDE_MODEL || defaultModel;
export const claudeEnabled = () => Boolean(process.env.ANTHROPIC_API_KEY);

export class ClaudeUnavailable extends Error {}

let client;
const anthropic = () => {
  client ??= new Anthropic({ maxRetries: 1, timeout: 60_000 });
  return client;
};

// Pour les tests : repart d'un client neuf après un changement d'environnement.
export const resetClaude = () => {
  client = undefined;
};

// Le journal ne doit jamais faire échouer une réponse.
export function audit(entry) {
  return db()
    .aiCall.create({ data: entry })
    .catch((error) => console.warn(`Journal IA : ${error.message}`));
}

function explain(error) {
  if (error instanceof Anthropic.RateLimitError) return 'quota atteint';
  if (error instanceof Anthropic.AuthenticationError) return 'clé refusée';
  if (error instanceof Anthropic.APIConnectionError) return 'réseau';
  if (error instanceof Anthropic.APIError) return `API ${error.status}`;
  return error.message;
}

// Un appel à Claude, journalisé. Lève ClaudeUnavailable pour tout échec :
// l'appelant répond alors avec les règles.
export async function callClaude({
  feature,
  actorRole,
  claimId,
  system,
  messages,
  tools,
  format,
  effort = 'low',
}) {
  if (!claudeEnabled()) throw new ClaudeUnavailable('clé absente');
  const model = claudeModel();
  const started = Date.now();
  const entry = { feature, actorRole, claimId, model, source: 'claude' };
  try {
    const response = await anthropic().beta.messages.create({
      model,
      max_tokens: 16000,
      // Consigne fixe en tête : c'est la partie que le cache peut réutiliser.
      system: [{ type: 'text', text: system, cache_control: { type: 'ephemeral' } }],
      messages,
      output_config: { effort, ...(format ? { format } : {}) },
      ...(tools ? { tools } : {}),
      ...(withFallback.includes(model)
        ? { betas: ['server-side-fallback-2026-07-01'], fallbacks: 'default' }
        : {}),
    });
    if (response.stop_reason === 'refusal') {
      throw new ClaudeUnavailable('refus');
    }
    if (response.stop_reason === 'max_tokens') {
      throw new ClaudeUnavailable('réponse tronquée');
    }
    await audit({
      ...entry,
      ok: true,
      inputTokens: response.usage.input_tokens,
      outputTokens: response.usage.output_tokens,
      ms: Date.now() - started,
    });
    return response;
  } catch (error) {
    const reason = explain(error);
    await audit({ ...entry, ok: false, error: reason, ms: Date.now() - started });
    console.warn(`Claude indisponible (${feature}) : ${reason}`);
    throw new ClaudeUnavailable(reason);
  }
}

export const textOf = (response) =>
  response.content
    .filter((block) => block.type === 'text')
    .map((block) => block.text)
    .join('\n')
    .trim();
