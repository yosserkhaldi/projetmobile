import nodemailer from 'nodemailer';

// Sans fournisseur configuré, les messages s'affichent dans les logs en développement.
// En production, le contenu (donc le code) n'est jamais écrit dans les logs.
function logForDevelopment(channel, to, text) {
  if (process.env.NODE_ENV === 'production') {
    console.error(`Aucun fournisseur ${channel} configuré : message non envoyé.`);
    return;
  }
  console.log(`[${channel}] ${to} : ${text}`);
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
  async sendSms(to, text) {
    logForDevelopment('SMS', to, text);
  },

  async sendMail(to, subject, text) {
    if (!process.env.SMTP_HOST) {
      logForDevelopment('E-MAIL', to, text);
      return;
    }
    await mailTransport().sendMail({
      from: process.env.SMTP_FROM ?? 'no-reply@monconstat.tn',
      to,
      subject,
      text,
    });
  },
};
