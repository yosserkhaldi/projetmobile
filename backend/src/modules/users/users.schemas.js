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

export const registerSchema = z.object({
  firstName: name('Prénom'),
  lastName: name('Nom'),
  email,
  phone,
  password,
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
    language: z.enum(['FR', 'AR', 'EN'], { error: 'Langue invalide.' }),
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

export const createAgentSchema = registerSchema.extend({ companyId: id });

export const agencyParams = z.object({ id, agencyId: id });

export const companySchema = z.object({ name: name('Nom de la compagnie') });

export const agencySchema = z.object({
  name: name("Nom de l'agence"),
  city: name('Ville'),
});
