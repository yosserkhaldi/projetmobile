// Envoi de messages WhatsApp via OpenWA (github.com/rmyndharis/OpenWA, MIT).
// Facultatif : sans WHATSAPP_API_URL, rien n'est envoyé.

const TIMEOUT_MS = 15_000;

export const whatsappConfigured = () =>
  Boolean(process.env.WHATSAPP_API_URL && process.env.WHATSAPP_API_KEY);

async function call(path, options = {}) {
  const response = await fetch(`${process.env.WHATSAPP_API_URL}${path}`, {
    ...options,
    headers: {
      'content-type': 'application/json',
      'x-api-key': process.env.WHATSAPP_API_KEY,
    },
    signal: AbortSignal.timeout(TIMEOUT_MS),
  });
  if (!response.ok) {
    throw new Error(`OpenWA a répondu ${response.status}`);
  }
  return response.json();
}

// La session est retrouvée par son nom : son identifiant change si on la recrée.
async function findLinkedSession() {
  const name = process.env.WHATSAPP_SESSION ?? 'monconstat';
  const body = await call('/sessions');
  const sessions = Array.isArray(body) ? body : (body.data ?? []);
  const session = sessions.find((s) => s.name === name);
  if (!session) throw new Error(`Session WhatsApp « ${name} » introuvable`);
  if (String(session.status).toLowerCase() !== 'ready') {
    throw new Error(`Session WhatsApp non liée (${session.status})`);
  }
  return session;
}

/** `+21620123456` devient l'identifiant WhatsApp `21620123456@c.us`. */
export const chatId = (phone) => `${phone.replace(/\D/g, '')}@c.us`;

export async function sendWhatsApp(phone, text) {
  const session = await findLinkedSession();
  await call(`/sessions/${session.id}/messages/send-text`, {
    method: 'POST',
    body: JSON.stringify({ chatId: chatId(phone), text }),
  });
}
