import { AiUnavailable, withData } from './shared.js';

// Tout serveur qui parle le format « chat completions » d'OpenAI : OpenAI,
// Perplexity, Mistral, Groq, OpenRouter, Ollama, LM Studio…
// Les outils ne sont pas appelés à la demande : leurs données sont jointes
// d'emblée, car beaucoup de ces serveurs ne gèrent pas l'appel d'outils.

export const mediaTypes = ['image/png', 'image/jpeg', 'image/webp'];

const statusReasons = { 401: 'clé refusée', 403: 'clé refusée', 429: 'quota atteint' };

// Certains serveurs exigent une alternance stricte utilisateur / assistant.
function alternating(messages) {
  const merged = [];
  for (const message of messages) {
    const last = merged.at(-1);
    if (last?.role === message.role) last.content += `\n\n${message.content}`;
    else merged.push({ ...message });
  }
  return merged;
}

function withAttachment(messages, attachment) {
  if (!attachment) return messages;
  const last = messages.at(-1);
  return [
    ...messages.slice(0, -1),
    {
      role: last.role,
      content: [
        { type: 'text', text: last.content },
        {
          type: 'image_url',
          image_url: { url: `data:${attachment.mediaType};base64,${attachment.data}` },
        },
      ],
    },
  ];
}

export async function run({
  baseUrl,
  apiKey,
  model,
  system,
  messages,
  tools,
  schema,
  attachment,
  extra = {},
}) {
  const conversation = withAttachment(alternating(withData(messages, tools)), attachment);
  const body = {
    model,
    messages: [{ role: 'system', content: system }, ...conversation],
    ...(schema
      ? {
          response_format: {
            type: 'json_schema',
            json_schema: { name: 'reponse', schema, strict: true },
          },
        }
      : {}),
    ...extra,
  };
  let response;
  try {
    response = await fetch(`${baseUrl.replace(/\/+$/, '')}/chat/completions`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        ...(apiKey ? { authorization: `Bearer ${apiKey}` } : {}),
      },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(60_000),
    });
  } catch (error) {
    throw new AiUnavailable(error.name === 'TimeoutError' ? 'délai dépassé' : 'réseau');
  }
  if (!response.ok) {
    throw new AiUnavailable(statusReasons[response.status] ?? `API ${response.status}`);
  }
  const data = await response.json().catch(() => null);
  const choice = data?.choices?.[0];
  if (!choice) throw new AiUnavailable('réponse illisible');
  if (choice.message?.refusal) throw new AiUnavailable('refus');
  if (choice.finish_reason === 'length') throw new AiUnavailable('réponse tronquée');
  const text = String(choice.message?.content ?? '')
    // Modèles « raisonnants » : seule la réponse finale compte.
    .replace(/<think>[\s\S]*?<\/think>/g, '')
    .trim();
  return {
    text,
    inputTokens: data.usage?.prompt_tokens,
    outputTokens: data.usage?.completion_tokens,
  };
}
