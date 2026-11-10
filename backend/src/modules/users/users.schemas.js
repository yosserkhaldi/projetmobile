import { z } from 'zod';

const name = (label) =>
  z
    .string({ error: `${label} obligatoire.` })
    .trim()
    .min(1, `${label} obligatoire.`)
    .max(80);

const email = z
  .string({ error: 'Adresse e-mail obligatoire.' })
  .trim()
  .toLowerCase()
  .max(254)
  .pipe(z.email('Adresse e-mail invalide.'));

// Un numéro à 8 chiffres est un numéro tunisien : il est stocké avec +216.
const normalizePhone = (v) => {
  const compact = v.replace(/[\s.-]/g, '');
  return /^\d{8}$/.test(compact) ? `+216${compact}` : compact;
};

const phone = z
  .string({ error: 'Numéro de téléphone obligatoire.' })
  .transform(normalizePhone)
  .refine((v) => /^\+?\d{8,15}$/.test(v), 'Numéro de téléphone invalide.');

// bcrypt ignore tout ce qui dépasse 72 octets.
const password = z
  .string({ error: 'Mot de passe obligatoire.' })
  .min(8, 'Le mot de passe doit contenir au moins 8 caractères.')
  .refine((v) => Buffer.byteLength(v) <= 72, 'Mot de passe trop long.');

const code = z
  .string({ error: 'Code obligatoire.' })
  .regex(/^\d{6}$/, 'Le code contient 6 chiffres.');

const language = z.enum(['FR', 'AR', 'EN'], { error: 'Langue invalide.' });

// Inscription en deux temps : e-mail et mot de passe ici, puis le nom et le
// téléphone dans l'accueil de l'application (PATCH /users/me). Encore
// acceptés ici, pour les clients qui les envoient d'un coup.
export const registerSchema = z.object({
  firstName: name('Prénom').optional(),
  lastName: name('Nom').optional(),
  email,
  phone: phone.optional(),
  password,
  // Langue choisie sur l'écran de connexion, avant l'inscription.
  language: language.optional(),
  // Loi n° 2004-63 : consentement explicite au traitement des données.
  consent: z.literal(true, {
    error: 'Vous devez accepter le traitement de vos données pour créer un compte.',
  }),
});

// La connexion accepte l'e-mail ou le téléphone, comme sur la maquette.
export const loginSchema = z.object({
  identifier: z
    .string({ error: 'E-mail ou téléphone obligatoire.' })
    .trim()
    .min(1, 'E-mail ou téléphone obligatoire.')
    .max(254)
    .transform((v) =>
      v.includes('@') ? { email: v.toLowerCase() } : { phone: normalizePhone(v) },
    ),
  password: z
    .string({ error: 'Mot de passe obligatoire.' })
    .min(1, 'Mot de passe obligatoire.'),
});

export const refreshSchema = z.object({
  refreshToken: z.string({ error: 'Jeton obligatoire.' }).min(1),
});

export const verifyPhoneSchema = z.object({ code });
export const forgotPasswordSchema = z.object({ email });
export const resetPasswordSchema = z.object({ email, code, password });

const emptyToNull = (v) => (v === '' ? null : v);

const licenseIssuedAt = z.preprocess(
  emptyToNull,
  z.iso
    .date('Date de délivrance invalide.')
    .refine(
      (v) => new Date(v) <= new Date(),
      'La date de délivrance est dans le futur.',
    )
    .nullable(),
);

export const updateProfileSchema = z
  .object({
    firstName: name('Prénom'),
    lastName: name('Nom'),
    phone,
    language,
    licenseNumber: z.preprocess(
      emptyToNull,
      z.string().trim().max(40).nullable(),
    ),
    licenseCategory: z.preprocess(
      emptyToNull,
      z.string().trim().max(20).nullable(),
    ),
    licenseIssuedAt,
  })
  .partial();

const id = z.uuid('Identifiant invalide.');
const role = z.enum(['DRIVER', 'AGENT', 'ADMIN'], { error: 'Rôle invalide.' });

export const idParams = z.object({ id });

export const listUsersQuery = z.object({
  q: z.string().trim().max(100).optional(),
  role: role.optional(),
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(50),
});

export const updateRoleSchema = z
  .object({ role, companyId: id.optional() })
  .refine((v) => v.role !== 'AGENT' || v.companyId, {
    path: ['companyId'],
    error: 'Un agent doit être rattaché à une compagnie.',
  });

export const updateStatusSchema = z.object({
  active: z.boolean({ error: 'Statut invalide.' }),
});

// Le compte agent est créé par un administrateur : pas de case à cocher.
export const createAgentSchema = registerSchema
  .omit({ consent: true })
  .extend({
    firstName: name('Prénom'),
    lastName: name('Nom'),
    phone,
    companyId: id,
  });

export const agencyParams = z.object({ id, agencyId: id });

export const companySchema = z.object({ name: name('Nom de la compagnie') });

export const agencySchema = z.object({
  name: name("Nom de l'agence"),
  city: name('Ville'),
});

export const biometricLoginSchema = z.object({
  deviceToken: z.string({ error: 'Clé biométrique obligatoire.' }).min(1),
});

export const disableBiometricSchema = z.object({
  deviceToken: z.string().min(1).optional(),
});

export const sessionParams = z.object({ sessionId: id });

export const identitySideParams = z.object({
  side: z.enum(['front', 'back'], { error: 'Face de la pièce invalide.' }),
});

// Photos lisibles d'une demande : la pièce et la photo du visage.
export const identityFileParams = z.object({
  side: z.enum(['front', 'back', 'selfie'], { error: 'Photo inconnue.' }),
});

// Format du numéro selon la pièce tunisienne présentée.
const DOCUMENT_NUMBERS = {
  CIN: [/^\d{8}$/, 'Le numéro de CIN contient 8 chiffres.'],
  LICENSE: [/^\d{2}\/?\d{5,8}$/, 'Numéro de permis invalide (ex. 12/345678).'],
  PASSPORT: [/^[A-Z]\d{6,7}$/, 'Numéro de passeport invalide (ex. X1234567).'],
};

// Type de pièce envoyé avec la photo du recto, pour la lire correctement.
export const documentTypeSchema = z.object({
  documentType: z
    .enum(['CIN', 'LICENSE', 'PASSPORT'], { error: 'Pièce inconnue.' })
    .default('CIN'),
});

export const identitySubmitSchema = z
  .object({
    documentType: z
      .enum(['CIN', 'LICENSE', 'PASSPORT'], { error: 'Pièce inconnue.' })
      .default('CIN'),
    number: z
      .string({ error: 'Numéro de la pièce obligatoire.' })
      .trim()
      .toUpperCase()
      .transform((v) => v.replaceAll(' ', '')),
  })
  .superRefine(({ documentType, number }, ctx) => {
    const [pattern, message] = DOCUMENT_NUMBERS[documentType];
    if (!pattern.test(number)) ctx.addIssue({ code: 'custom', path: ['number'], message });
  });

// Loi n° 2004-63 : accord explicite avant l'analyse du visage.
export const biometricConsentSchema = z.object({
  consent: z.literal(true, {
    error: "Votre accord est nécessaire pour l'analyse de votre visage.",
  }),
});

export const livenessFramesSchema = z.object({
  token: z.string({ error: 'Défi manquant.' }).min(1),
});

export const rejectIdentitySchema = z.object({
  reason: z
    .string({ error: 'Motif obligatoire.' })
    .trim()
    .min(3, 'Indiquez un motif.')
    .max(300),
  // Refus grave (visage différent, pièce non valable) : plus de nouvelle demande.
  severe: z.boolean().default(false),
});

// Permis : correction par un administrateur, et motif de refus.
export const adminLicenseSchema = updateProfileSchema.pick({
  licenseNumber: true,
  licenseCategory: true,
  licenseIssuedAt: true,
});

export const rejectLicenseSchema = rejectIdentitySchema.pick({ reason: true });

// Correction par un administrateur de ce que l'IA a lu sur la pièce.
const readText = z.preprocess(
  emptyToNull,
  z.string().trim().max(120).nullable(),
);
const readDate = z.preprocess(
  emptyToNull,
  z.iso.date('Date invalide.').nullable(),
);
export const identityReadingSchema = z
  .object({
    number: z.preprocess(
      (v) => (typeof v === 'string' ? v.replace(/\s/g, '').toUpperCase() : v),
      z.string().min(6, 'Numéro invalide.').max(20),
    ),
    lastName: readText,
    firstName: readText,
    lastNameAr: readText,
    firstNameAr: readText,
    parentsAr: readText,
    birthPlaceAr: readText,
    birthDate: readDate,
    expiresAt: readDate,
  })
  .partial();

export const deleteAccountSchema = z.object({
  password: z
    .string({ error: 'Mot de passe obligatoire.' })
    .min(1, 'Mot de passe obligatoire.'),
});

export const statsQuery = z.object({
  days: z.coerce.number().int().min(7).max(90).default(30),
});
