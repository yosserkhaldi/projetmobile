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
