import Anthropic from '@anthropic-ai/sdk';

import { AiUnavailable } from './shared.js';

// API Claude avec une clé (ANTHROPIC_API_KEY). C'est le seul fournisseur qui
// orchestre ses outils : Claude choisit quoi lire, le code exécute.

export const mediaTypes = ['application/pdf', 'image/png', 'image/jpeg', 'image/webp'];

const maxToolRounds = 5;

// Modèles qui acceptent le repli côté serveur en cas de refus.
const withFallback = ['claude-opus-5-5', 'claude-fable-5-1', 'claude-sonnet-5-5'];

const noInput = { type: 'object', properties: {}, additionalProperties: false };

let client;
let clientKey;
const anthropic = () => {
  // Nouveau client si la clé ou l'adresse a changé (tests, rechargement).
  const key = `${process.env.ANTHROPIC_API_KEY}|${process.env.ANTHROPIC_BASE_URL}`;
  if (clientKey !== key) {
    client = new Anthropic({ maxRetries: 1, timeout: 60_000 });
    clientKey = key;
  }
  return client;
};

function explain(error) {
  if (error instanceof AiUnavailable) return error;
  if (error instanceof Anthropic.RateLimitError) return new AiUnavailable('quota atteint');
  if (error instanceof Anthropic.AuthenticationError) return new AiUnavailable('clé refusée');
  if (error instanceof Anthropic.APIConnectionError) return new AiUnavailable('réseau');
  if (error instanceof Anthropic.APIError) return new AiUnavailable(`API ${error.status}`);
  return error;
}

const textOf = (response) =>
  response.content
    .filter((block) => block.type === 'text')
    .map((block) => block.text)
    .join('\n')
    .trim();

function withAttachment(messages, attachment) {
  if (!attachment) return messages;
  const last = messages.at(-1);
  const source = { type: 'base64', media_type: attachment.mediaType, data: attachment.data };
  const kind = attachment.mediaType === 'application/pdf' ? 'document' : 'image';
  return [
    ...messages.slice(0, -1),
    { role: last.role, content: [{ type: kind, source }, { type: 'text', text: last.content }] },
  ];
}

export async function run({ model, system, messages, tools, schema, attachment, effort }) {
  const definitions = Object.entries(tools).map(([name, { description }]) => ({
    name,
    description,
    strict: true,
    input_schema: noInput,
  }));
  const conversation = withAttachment(
    messages.map(({ role, content }) => ({ role, content })),
    attachment,
  );
  let inputTokens = 0;
  let outputTokens = 0;
  try {
    for (let round = 0; round < maxToolRounds; round++) {
      const response = await anthropic().beta.messages.create({
        model,
        max_tokens: 16000,
        // Consigne fixe en tête : c'est la partie que le cache peut réutiliser.
        system: [{ type: 'text', text: system, cache_control: { type: 'ephemeral' } }],
        messages: conversation,
        output_config: {
          effort,
          ...(schema ? { format: { type: 'json_schema', schema } } : {}),
        },
        ...(definitions.length > 0 ? { tools: definitions } : {}),
        ...(withFallback.includes(model)
          ? { betas: ['server-side-fallback-2026-07-01'], fallbacks: 'default' }
          : {}),
      });
      inputTokens += response.usage.input_tokens;
      outputTokens += response.usage.output_tokens;
      if (response.stop_reason === 'refusal') throw new AiUnavailable('refus');
      if (response.stop_reason === 'max_tokens') throw new AiUnavailable('réponse tronquée');
      if (response.stop_reason !== 'tool_use') {
        return { text: textOf(response), inputTokens, outputTokens };
      }
      conversation.push({ role: 'assistant', content: response.content });
      conversation.push({
        role: 'user',
        content: response.content
          .filter((block) => block.type === 'tool_use')
          .map((block) => {
            const known = tools[block.name];
            return {
              type: 'tool_result',
              tool_use_id: block.id,
              content: known ? JSON.stringify(known.run()) : 'Outil inconnu.',
              ...(known ? {} : { is_error: true }),
            };
          }),
      });
    }
    throw new AiUnavailable('trop d’appels d’outils');
  } catch (error) {
    throw explain(error);
  }
}
