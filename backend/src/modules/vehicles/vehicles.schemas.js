import { z } from 'zod';

// ── Énumérations ──────────────────────────────────────────────────────────────

const vehicleTypes = ['CAR', 'MOTO', 'TRUCK', 'VAN', 'OTHER'];
const fuelTypes = ['PETROL', 'DIESEL', 'ELECTRIC', 'HYBRID', 'OTHER'];

// ── Schémas communs ────────────────────────────────────────────────────────────

const plate = z
  .string({ error: 'Immatriculation obligatoire.' })
  .trim()
  .min(1, 'Immatriculation obligatoire.')
  .max(20, 'Immatriculation trop longue.');

const isoDate = z
  .string()
  .regex(/^\d{4}-\d{2}-\d{2}$/, 'Format de date invalide (AAAA-MM-JJ).');

// ── Schéma de création ─────────────────────────────────────────────────────────

export const createVehicleSchema = z.object({
  plate,
  brand: z.string().trim().min(1).max(50),
  model: z.string().trim().min(1).max(50),
  year: z.number().int().min(1950).max(new Date().getFullYear() + 1),
  policy: z.string().trim().min(1).max(50),
  insurerName: z.string().trim().max(100).default(''),
  insuranceExpiry: isoDate,
  technicalExpiry: isoDate.nullable().optional(),
  color: z.string().trim().max(30).nullable().optional(),
  mileage: z.number().int().min(0).max(2_000_000).nullable().optional(),
  type: z.enum(vehicleTypes).default('CAR'),
  fuel: z.enum(fuelTypes).default('PETROL'),
});

// ── Schéma de modification (tous les champs optionnels) ────────────────────────

export const updateVehicleSchema = createVehicleSchema.partial().extend({
  archived: z.boolean().optional(),
  mileage: z.number().int().min(0).max(2_000_000).nullable().optional(),
});

// ── Pagination et filtres ─────────────────────────────────────────────────────

export const listVehiclesSchema = z.object({
  archived: z
    .string()
    .optional()
    .transform((v) => v === 'true'),
  page: z
    .string()
    .optional()
    .transform((v) => (v ? Math.max(1, parseInt(v, 10)) : 1)),
  pageSize: z
    .string()
    .optional()
    .transform((v) => Math.min(50, Math.max(1, parseInt(v ?? '20', 10)))),
});
