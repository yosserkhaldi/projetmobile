import { Router } from 'express';

import { HttpError } from '../../lib/errors.js';
import { assertImage, singleImage } from '../../lib/uploads.js';
import { INSURERS, vehicleDocReader } from '../../lib/vehicleDocs.js';
import { prisma } from '../../lib/prisma.js';
import { requireAuth } from '../../middleware/auth.js';
import { aiQuota } from '../../middleware/quota.js';
import {
  createVehicleSchema,
  listVehiclesSchema,
  updateVehicleSchema,
} from './vehicles.schemas.js';
import * as vehicles from './vehicles.service.js';

// Module 2 : véhicules et contrats d'assurance.
const router = Router();

// Toutes les routes nécessitent une session valide.
router.use(requireAuth);

// ── Liste et création ─────────────────────────────────────────────────────────

/**
 * GET /api/vehicles
 * Liste les véhicules de l'utilisateur connecté.
 * ?archived=true pour voir les archives.
 * ?page=1&pageSize=20 pour la pagination.
 */
router.get('/', async (req, res) => {
  const params = listVehiclesSchema.parse(req.query);
  res.json(await vehicles.listVehicles(req.user.id, params));
});

/**
 * POST /api/vehicles
 * Crée un nouveau véhicule.
 */
router.post('/', async (req, res) => {
  const data = createVehicleSchema.parse(req.body);
  res.status(201).json(await vehicles.createVehicle(req.user.id, data));
});

/**
 * POST /api/vehicles/scan
 * Lit une carte grise (kind=REGISTRATION) ou une attestation d'assurance
 * (kind=INSURANCE) pour pré-remplir le formulaire. Rien n'est enregistré.
 * L'assureur lu est rapproché des compagnies du référentiel (module 1).
 */
router.post('/scan', aiQuota({ max: 30 }), singleImage('photo'), async (req, res) => {
  const kind = String(req.body.kind ?? '').toUpperCase();
  if (!['REGISTRATION', 'INSURANCE'].includes(kind)) {
    throw new HttpError(400, 'VALIDATION_ERROR', 'Type de document invalide.');
  }
  assertImage(req.file);
  const extracted = await vehicleDocReader.read(req.file.buffer, kind);
  if (kind === 'INSURANCE' && extracted.insurer) {
    const key = INSURERS.find(([, name]) => name === extracted.insurer)?.[0];
    const word = key && new RegExp(`(^|[^A-Z])${key.replace(/\s+/g, '\\s*')}($|[^A-Z])`);
    const companies = await prisma.company.findMany({ select: { id: true, name: true } });
    const company = word ? companies.find((c) => word.test(c.name.toUpperCase())) : null;
    extracted.companyId = company?.id ?? null;
    if (company) extracted.insurer = company.name;
  }
  res.json({ kind, extracted });
});

// ── Alertes d'échéance ────────────────────────────────────────────────────────

/**
 * GET /api/vehicles/alerts
 * Véhicules dont l'assurance ou la visite technique expire dans les 30 jours.
 * ?days=30 pour changer le seuil.
 */
router.get('/alerts', async (req, res) => {
  const days = Math.min(
    365,
    Math.max(1, parseInt(req.query.days ?? '30', 10) || 30),
  );
  res.json(await vehicles.getExpiringVehicles(req.user.id, days));
});

// ── Opérations sur un véhicule ────────────────────────────────────────────────

/**
 * GET /api/vehicles/:id
 * Récupère les détails d'un véhicule.
 */
router.get('/:id', async (req, res) => {
  res.json(await vehicles.getVehicle(req.params.id, req.user.id));
});

/**
 * PATCH /api/vehicles/:id
 * Met à jour un véhicule (modification partielle).
 */
router.patch('/:id', async (req, res) => {
  const data = updateVehicleSchema.parse(req.body);
  res.json(await vehicles.updateVehicle(req.params.id, req.user.id, data));
});

/**
 * PATCH /api/vehicles/:id/archive
 * Archive ou désarchive un véhicule.
 * Body : { archived: true/false }
 */
router.patch('/:id/archive', async (req, res) => {
  const { archived } = req.body;
  if (typeof archived !== 'boolean') {
    return res.status(400).json({ code: 'INVALID_BODY', message: 'archived doit être un booléen.' });
  }
  res.json(await vehicles.archiveVehicle(req.params.id, req.user.id, archived));
});

/**
 * DELETE /api/vehicles/:id
 * Supprime définitivement un véhicule.
 */
router.delete('/:id', async (req, res) => {
  await vehicles.deleteVehicle(req.params.id, req.user.id);
  res.status(204).end();
});

export default router;
