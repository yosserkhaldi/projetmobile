import nodemailer from 'nodemailer';

import { sendWhatsApp, whatsappConfigured } from './whatsapp.js';

// Sans fournisseur configuré, les messages s'affichent dans les logs en développement.
// En production, le contenu (donc le code) n'est jamais écrit dans les logs.
// Retours à la ligne et caractères de contrôle retirés : une valeur saisie
// par un utilisateur ne peut pas fabriquer de fausses lignes dans les logs.
const oneLine = (value) =>
  String(value)
    .replace(/[\u0000-\u001f\u007f]+/g, ' ')
    .slice(0, 500);

function logForDevelopment(channel, to, text) {
  if (process.env.NODE_ENV === 'production') {
    console.error(`Aucun fournisseur ${channel} configuré : message non envoyé.`);
    return;
  }
  console.log(`[${channel}] ${oneLine(to)} : ${oneLine(text)}`);
}

let transporter;
function mailTransport() {
  transporter ??= nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT ?? 587),
    auth: process.env.SMTP_USER
      ? { user: process.env.SMTP_USER, pass: process.env.SMTP_PASSWORD }
      : undefined,
  });
  return transporter;
}

export const notifier = {
  /**
   * Message vers un téléphone : par WhatsApp si OpenWA est configuré.
   * Si WhatsApp n'est pas lié ou ne répond pas, le code reste visible dans
   * les logs en développement, pour ne jamais bloquer une inscription.
   */
  async sendToPhone(to, text) {
    if (!whatsappConfigured()) {
      logForDevelopment('SMS', to, text);
      return;
    }
    try {
      await sendWhatsApp(to, text);
    } catch (err) {
      console.error(`WhatsApp indisponible : ${oneLine(err.message)}`);
      logForDevelopment('SMS', to, text);
    }
  },

  async sendMail(to, subject, text, html) {
    if (!process.env.SMTP_HOST) {
      logForDevelopment('E-MAIL', to, text);
      return;
    }
    await mailTransport().sendMail({
      from: process.env.SMTP_FROM ?? 'no-reply@monconstat.tn',
      to,
      subject,
      text,
      html,
    });
  },
};
