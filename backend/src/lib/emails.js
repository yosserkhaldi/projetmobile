// Modèles d'e-mails, dans la langue du compte (FR, AR, EN).

const escape = (value) =>
  String(value).replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);

const TEXTS = {
  FR: {
    subject: 'Votre code de réinitialisation',
    hello: (name) => `Bonjour ${name},`,
    intro: 'Voici le code pour choisir un nouveau mot de passe :',
    validity: 'Il est valable 15 minutes et ne sert qu’une fois.',
    ignore:
      'Si vous n’avez rien demandé, ignorez cet e-mail : votre mot de passe ne change pas.',
    footer: 'Mon Constat Digital, le constat amiable sans papier.',
  },
  EN: {
    subject: 'Your password reset code',
    hello: (name) => `Hello ${name},`,
    intro: 'Here is the code to choose a new password:',
    validity: 'It is valid for 15 minutes and works only once.',
    ignore:
      'If you did not ask for this, ignore this email: your password stays the same.',
    footer: 'Mon Constat Digital, paper-free accident reports.',
  },
  AR: {
    subject: 'رمز إعادة تعيين كلمة المرور',
    hello: (name) => `مرحبًا ${name}،`,
    intro: 'إليك الرمز لاختيار كلمة مرور جديدة:',
    validity: 'الرمز صالح لمدة 15 دقيقة ولمرة واحدة فقط.',
    ignore:
      'إذا لم تطلب ذلك، تجاهل هذا البريد: كلمة المرور لن تتغيّر.',
    footer: 'Mon Constat Digital، المعاينة الودية بدون ورق.',
  },
};

/** E-mail du code de réinitialisation : `{ subject, text, html }`. */
export function passwordResetEmail({ firstName, language, code }) {
  const t = TEXTS[language] ?? TEXTS.FR;
  const dir = language === 'AR' ? 'rtl' : 'ltr';
  const name = escape(firstName);

  const text = [
    t.hello(firstName),
    '',
    t.intro,
    '',
    `    ${code}`,
    '',
    t.validity,
    t.ignore,
    '',
    t.footer,
  ].join('\n');

  // Mise en page en tableaux et styles en ligne : seule forme fiable dans
  // Gmail, Outlook et les applications mobiles.
  const html = `<!doctype html>
<html lang="${language.toLowerCase()}" dir="${dir}">
<body style="margin:0;padding:0;background:#F2F4F7;font-family:Arial,Helvetica,sans-serif;color:#0B1626">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#F2F4F7;padding:24px 12px">
    <tr><td align="center">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:480px;background:#FFFFFF;border:1px solid #E4E8EE;border-radius:20px;overflow:hidden">
        <tr><td style="background:#0B1626;padding:22px 24px">
          <span style="display:inline-block;background:#F5A524;color:#0B1626;font-weight:800;border-radius:10px;padding:6px 10px;font-size:14px">MC</span>
          <span style="color:#FFFFFF;font-weight:800;font-size:18px;padding:0 10px">Mon Constat</span>
        </td></tr>
        <tr><td dir="${dir}" style="padding:28px 24px 8px;font-size:15px;line-height:1.5">
          <p style="margin:0 0 12px">${t.hello(name)}</p>
          <p style="margin:0 0 18px">${t.intro}</p>
        </td></tr>
        <tr><td align="center" style="padding:0 24px">
          <div dir="ltr" style="display:inline-block;background:#E7ECFB;color:#1537A8;font-family:'Courier New',monospace;font-size:34px;font-weight:700;letter-spacing:10px;padding:14px 22px;border-radius:14px">${code}</div>
        </td></tr>
        <tr><td dir="${dir}" style="padding:18px 24px 26px;font-size:13px;line-height:1.5;color:#4A5568">
          <p style="margin:0 0 8px">${t.validity}</p>
          <p style="margin:0">${t.ignore}</p>
        </td></tr>
        <tr><td dir="${dir}" style="border-top:1px solid #EEF1F5;padding:14px 24px;font-size:12px;color:#4A5568">${t.footer}</td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;

  return { subject: t.subject, text, html };
}


const LOGIN_TEXTS = {
  FR: {
    subject: 'Nouvelle connexion à votre compte',
    body: (device, when) =>
      `Nouvelle connexion à votre compte Mon Constat depuis ${device}, le ${when}.`,
    notYou:
      "Ce n'était pas vous ? Changez votre mot de passe, puis déconnectez cet appareil dans Profil > Sécurité > Appareils connectés.",
    unknownDevice: 'un nouvel appareil',
    locale: 'fr-TN',
  },
  EN: {
    subject: 'New sign-in to your account',
    body: (device, when) =>
      `New sign-in to your Mon Constat account from ${device}, on ${when}.`,
    notYou:
      'Not you? Change your password, then sign this device out in Profile > Security > Connected devices.',
    unknownDevice: 'a new device',
    locale: 'en-GB',
  },
  AR: {
    subject: 'تسجيل دخول جديد إلى حسابك',
    body: (device, when) =>
      `تسجيل دخول جديد إلى حسابك في Mon Constat من ${device}، بتاريخ ${when}.`,
    notYou:
      'لست أنت؟ غيّر كلمة المرور، ثم أخرج هذا الجهاز من الملف > الأمان > الأجهزة المتصلة.',
    unknownDevice: 'جهاز جديد',
    locale: 'ar-TN',
  },
};

/** Alerte de connexion depuis un appareil inconnu : `{ subject, text, html }`. */
export function newLoginEmail({ firstName, language, deviceName, when }) {
  const t = LOGIN_TEXTS[language] ?? LOGIN_TEXTS.FR;
  const hello = (TEXTS[language] ?? TEXTS.FR).hello;
  const dir = language === 'AR' ? 'rtl' : 'ltr';
  const date = when.toLocaleString(t.locale, {
    dateStyle: 'long',
    timeStyle: 'short',
    timeZone: 'Africa/Tunis',
  });
  const device = deviceName || t.unknownDevice;
  const text = [hello(firstName), '', t.body(device, date), '', t.notYou].join(
    '\n',
  );
  const html = `<!doctype html>
<html lang="${language.toLowerCase()}" dir="${dir}">
<body style="margin:0;padding:0;background:#F2F4F7;font-family:Arial,Helvetica,sans-serif;color:#0B1626">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#F2F4F7;padding:24px 12px">
    <tr><td align="center">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:480px;background:#FFFFFF;border:1px solid #E4E8EE;border-radius:20px;overflow:hidden">
        <tr><td style="background:#0B1626;padding:22px 24px">
          <span style="display:inline-block;background:#F5A524;color:#0B1626;font-weight:800;border-radius:10px;padding:6px 10px;font-size:14px">MC</span>
          <span style="color:#FFFFFF;font-weight:800;font-size:18px;padding:0 10px">Mon Constat</span>
        </td></tr>
        <tr><td dir="${dir}" style="padding:26px 24px;font-size:15px;line-height:1.5">
          <p style="margin:0 0 12px">${hello(escape(firstName))}</p>
          <p style="margin:0 0 16px">${t.body(`<b>${escape(device)}</b>`, escape(date))}</p>
          <p style="margin:0;padding:12px 14px;background:#FFF1D6;color:#7A4300;border-radius:12px;font-size:13px">${t.notYou}</p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;
  return { subject: t.subject, text, html };
}


const CONSTAT_TEXTS = {
  FR: {
    subject: 'Votre constat amiable numérique scellé',
    title: 'Constat amiable scellé',
    body: (place, date) =>
      `Le constat amiable pour l'accident survenu à ${place} le ${date} a été signé par les deux parties et scellé avec succès.`,
    hashLabel: 'Empreinte de sécurité (SHA-256) :',
    attachedInfo:
      'L’exemplaire officiel du constat au format PDF est joint à cet e-mail. Ce document est infalsifiable et a été transmis à votre assureur.',
    footer: 'Mon Constat Digital, le constat amiable sans papier.',
  },
  EN: {
    subject: 'Your sealed digital accident report',
    title: 'Sealed accident report',
    body: (place, date) =>
      `The accident report for the incident at ${place} on ${date} has been signed by both parties and successfully sealed.`,
    hashLabel: 'Security fingerprint (SHA-256):',
    attachedInfo:
      'The official PDF accident report is attached to this email. It is tamper-proof and has been transmitted to your insurer.',
    footer: 'Mon Constat Digital, paper-free accident reports.',
  },
  AR: {
    subject: 'المعاينة الودية الرقمية المعتمدة والمختومة',
    title: 'معاينة ودية معتمدة',
    body: (place, date) =>
      `تم إمضاء المعاينة الودية للحادث في ${place} بتاريخ ${date} من الطرفين وختمها بنجاح.`,
    hashLabel: 'البصمة الرقمية للأمان (SHA-256):',
    attachedInfo:
      'النسخة الرسمية من المعاينة الودية بصيغة PDF مرفقة مع هذه الرسالة. هذه الوثيقة غير قابلة للتعديل وتم إرسالها لشركة التأمين.',
    footer: 'Mon Constat Digital، المعاينة الودية بدون ورق.',
  },
};

export function constatSealedEmail({ name, place, date, sha256Hash, language = 'FR' }) {
  const t = CONSTAT_TEXTS[language] ?? CONSTAT_TEXTS.FR;
  const hello = (TEXTS[language] ?? TEXTS.FR).hello;
  const dir = language === 'AR' ? 'rtl' : 'ltr';

  const text = [
    hello(name),
    '',
    t.body(place, date),
    '',
    `${t.hashLabel} ${sha256Hash}`,
    '',
    t.attachedInfo,
    '',
    t.footer,
  ].join('\n');

  const html = `<!doctype html>
<html lang="${language.toLowerCase()}" dir="${dir}">
<body style="margin:0;padding:0;background:#F2F4F7;font-family:Arial,Helvetica,sans-serif;color:#0B1626">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#F2F4F7;padding:24px 12px">
    <tr><td align="center">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:520px;background:#FFFFFF;border:1px solid #E4E8EE;border-radius:20px;overflow:hidden">
        <tr><td style="background:#0B1626;padding:22px 24px">
          <span style="display:inline-block;background:#F5A524;color:#0B1626;font-weight:800;border-radius:10px;padding:6px 10px;font-size:14px">MC</span>
          <span style="color:#FFFFFF;font-weight:800;font-size:18px;padding:0 10px">Mon Constat</span>
        </td></tr>
        <tr><td dir="${dir}" style="padding:28px 24px 8px;font-size:15px;line-height:1.5">
          <h2 style="margin:0 0 14px;color:#1537A8;font-size:20px">${t.title}</h2>
          <p style="margin:0 0 12px">${hello(escape(name))}</p>
          <p style="margin:0 0 18px">${t.body(`<b>${escape(place)}</b>`, `<b>${escape(date)}</b>`)}</p>
        </td></tr>
        <tr><td align="center" style="padding:0 24px">
          <div style="background:#F2F4F7;border:1px solid #DCE1E8;border-radius:12px;padding:12px;text-align:left">
            <div style="font-size:11px;color:#4A5568;font-weight:700;margin-bottom:4px">${t.hashLabel}</div>
            <div dir="ltr" style="font-family:'Courier New',monospace;font-size:12px;word-break:break-all;color:#0B1626;font-weight:700">${sha256Hash}</div>
          </div>
        </td></tr>
        <tr><td dir="${dir}" style="padding:18px 24px 26px;font-size:13px;line-height:1.5;color:#4A5568">
          <p style="margin:0">${t.attachedInfo}</p>
        </td></tr>
        <tr><td dir="${dir}" style="border-top:1px solid #EEF1F5;padding:14px 24px;font-size:12px;color:#4A5568">${t.footer}</td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;

  return { subject: t.subject, text, html };
}
