import { db } from '../claims.db.js';
import * as anthropic from './providers/anthropic.js';
import * as claudeCli from './providers/claude-cli.js';
import * as openai from './providers/openai.js';
import { AiUnavailable } from './providers/shared.js';

export { AiUnavailable };

// Fournisseurs de modèle de langage. Le module ne dépend d'aucun : sans
// fournisseur, ou s'il échoue, chaque fonction répond avec les règles.
//
// AI_PROVIDER choisit le fournisseur : auto (défaut), claude-cli, anthropic,
// openai, perplexity ou none. En auto, le développement passe d'abord par la
// CLI Claude installée sur la machine (le compte Claude de la personne, sans
// clé), puis par la première clé configurée. En production, jamais la CLI.

const env = (name) => process.env[name]?.trim() || undefined;

const providers = {
  'claude-cli': {
    label: 'Claude (CLI)',
    configured: () => Boolean(claudeCli.findBinary()),
    model: () => env('CLAUDE_MODEL') ?? 'claude-sonnet-5-5',
    accepts: (mediaType) => anthropic.mediaTypes.includes(mediaType),
    run: (request) => claudeCli.run({ ...request, binary: claudeCli.findBinary() }),
  },
  anthropic: {
    label: 'Claude',
    configured: () => Boolean(env('ANTHROPIC_API_KEY')),
    model: () => env('CLAUDE_MODEL') ?? 'claude-opus-5-5',
    accepts: (mediaType) => anthropic.mediaTypes.includes(mediaType),
    run: anthropic.run,
  },
  openai: {
    // Tout serveur au format OpenAI : OpenAI, Mistral, Groq, OpenRouter,
    // Ollama, LM Studio… Ollama local n'a pas besoin de clé.
    // Nom affiché dans l'application, par exemple OPENAI_LABEL=Mistral.
    get label() {
      if (env('OPENAI_LABEL')) return env('OPENAI_LABEL');
      return !env('OPENAI_BASE_URL') || env('OPENAI_BASE_URL').includes('api.openai.com')
        ? 'OpenAI'
        : 'IA';
    },
    configured: () => Boolean(env('OPENAI_API_KEY') || env('OPENAI_BASE_URL')),
    model: () => env('OPENAI_MODEL') ?? 'gpt-4o-mini',
    accepts: (mediaType) => openai.mediaTypes.includes(mediaType),
    run: (request) =>
      openai.run({
        ...request,
        baseUrl: env('OPENAI_BASE_URL') ?? 'https://api.openai.com/v1',
        apiKey: env('OPENAI_API_KEY'),
      }),
  },
  perplexity: {
    label: 'Perplexity',
    configured: () => Boolean(env('PERPLEXITY_API_KEY')),
    model: () => env('PERPLEXITY_MODEL') ?? 'sonar',
    accepts: (mediaType) => openai.mediaTypes.includes(mediaType),
    run: (request) =>
      openai.run({
        ...request,
        baseUrl: env('PERPLEXITY_BASE_URL') ?? 'https://api.perplexity.ai',
        apiKey: env('PERPLEXITY_API_KEY'),
        // Les faits du dossier ne doivent pas partir en requête de recherche web.
        extra: { disable_search: true },
      }),
  },
};

export const providerIds = Object.keys(providers);

const development = () =>
  !['production', 'test'].includes(process.env.NODE_ENV ?? 'development');

let warned;

/** Fournisseur utilisé maintenant, ou null : le module répond avec les règles. */
export function activeProvider() {
  const wanted = (env('AI_PROVIDER') ?? 'auto').toLowerCase();
  if (wanted === 'none') return null;
  if (wanted !== 'auto') {
    const provider = providers[wanted];
    if (!provider && warned !== wanted) {
      warned = wanted;
      console.warn(`AI_PROVIDER inconnu : ${wanted}. Valeurs : auto, none, ${providerIds.join(', ')}.`);
    }
    return provider?.configured() ? { id: wanted, ...provider } : null;
  }
  const order = development()
    ? providerIds
    : providerIds.filter((id) => id !== 'claude-cli');
  const id = order.find((candidate) => providers[candidate].configured());
  return id ? { id, ...providers[id] } : null;
}

/** Pour /ai/status : ce qui répond, et ce qui pourrait répondre. */
export function aiStatus() {
  const active = activeProvider();
  return {
    active: active
      ? { provider: active.id, label: active.label, model: active.model() }
      : null,
    configured: providerIds.filter((id) => providers[id].configured()),
  };
}

// Pour les tests : relit l'environnement (chemin de la CLI).
export const resetAi = () => claudeCli.forgetBinary();

// Le journal ne doit jamais faire échouer une réponse.
export function audit(entry) {
  return db()
    .aiCall.create({ data: entry })
    .catch((error) => console.warn(`Journal IA : ${error.message}`));
}

// Extrait l'objet JSON d'une réponse, même entourée de texte ou de balises.
function parseJson(text) {
  const cleaned = text.replace(/<think>[\s\S]*?<\/think>/g, '');
  const start = cleaned.indexOf('{');
  const end = cleaned.lastIndexOf('}');
  if (start < 0 || end < start) throw new AiUnavailable('réponse non JSON');
  try {
    return JSON.parse(cleaned.slice(start, end + 1));
  } catch {
    throw new AiUnavailable('réponse non JSON');
  }
}

/**
 * Un appel au modèle, journalisé. Lève AiUnavailable pour tout échec :
 * l'appelant répond alors avec les règles.
 *
 * - messages : [{ role: 'user' | 'assistant', content: string }]
 * - tools : { nom: { description, run } }, en lecture seule et sans paramètre.
 *   Claude par clé les appelle à la demande ; les autres fournisseurs reçoivent
 *   leurs données d'emblée.
 * - schema : schéma JSON de la réponse attendue ; le résultat est dans `json`.
 * - attachment : { mediaType, data (base64) }, joint au dernier message.
 *
 * Renvoie { text, json, by } où `by` nomme le modèle qui a répondu.
 */
export async function generate({
  feature,
  actorRole,
  claimId,
  system,
  messages,
  tools = {},
  schema,
  attachment,
  effort = 'low',
}) {
  const provider = activeProvider();
  if (!provider) throw new AiUnavailable('aucun fournisseur');
  if (attachment && !provider.accepts(attachment.mediaType)) {
    throw new AiUnavailable('format non pris en charge');
  }
  const model = provider.model();
  const started = Date.now();
  const entry = { feature, actorRole, claimId, model, source: provider.id };
  try {
    const result = await provider.run({
      model,
      system,
      messages,
      tools,
      schema,
      attachment,
      effort,
    });
    const json = schema ? (result.json ?? parseJson(result.text)) : undefined;
    if (!schema && !result.text) throw new AiUnavailable('réponse vide');
    await audit({
      ...entry,
      ok: true,
      inputTokens: result.inputTokens ?? null,
      outputTokens: result.outputTokens ?? null,
      ms: Date.now() - started,
    });
    return { text: result.text, json, by: `${provider.label} · ${model}` };
  } catch (error) {
    const reason =
      error instanceof AiUnavailable ? error.message : String(error.message).slice(0, 200);
    await audit({ ...entry, ok: false, error: reason, ms: Date.now() - started });
    console.warn(`IA indisponible (${provider.id}, ${feature}) : ${reason}`);
    throw new AiUnavailable(reason);
  }
}
