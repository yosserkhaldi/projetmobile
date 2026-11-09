export class AiUnavailable extends Error {}

const roleNames = { user: 'Utilisateur', assistant: 'Assistant' };

/**
 * Données des outils, pour les fournisseurs qui ne les appellent pas :
 * elles sont lues d'avance et placées dans le message de l'utilisateur,
 * jamais dans la consigne, car elles viennent en partie des utilisateurs.
 */
export function inlineData(tools) {
  const entries = Object.entries(tools);
  if (entries.length === 0) return '';
  const blocks = entries.map(
    ([name, { description, run }]) =>
      `<${name} description="${description}">\n${JSON.stringify(run())}\n</${name}>`,
  );
  return `<donnees>\n${blocks.join('\n')}\n</donnees>\n\n`;
}

/** Ajoute les données au premier message de l'utilisateur. */
export function withData(messages, tools) {
  const data = inlineData(tools);
  if (!data) return messages;
  const first = messages.findIndex((message) => message.role === 'user');
  return messages.map((message, index) =>
    index === first ? { ...message, content: data + message.content } : message,
  );
}

/** Une conversation entière en un seul message, pour la CLI. */
export function transcript(messages, tools) {
  const data = inlineData(tools);
  if (messages.length === 1) return data + messages[0].content;
  const earlier = messages
    .slice(0, -1)
    .map((message) => `${roleNames[message.role]} : ${message.content}`)
    .join('\n');
  return `${data}Conversation jusqu’ici :\n${earlier}\n\nDernier message de l’utilisateur, auquel tu réponds :\n${messages.at(-1).content}`;
}
