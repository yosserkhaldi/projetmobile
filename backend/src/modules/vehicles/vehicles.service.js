import { HttpError } from '../../lib/errors.js';
import { prisma } from '../../lib/prisma.js';
import { assertCompanyExists } from '../../middleware/auth.js';

/**
 * Données prêtes pour la base : dates « AAAA-MM-JJ » en Date, compagnie
 * vérifiée, et nom de l'assureur repris de la compagnie s'il manque.
 */
async function toRecord(data) {
  const record = { ...data };
  for (const field of ['insuranceExpiry', 'technicalExpiry']) {
    if (typeof record[field] === 'string') record[field] = new Date(record[field]);
  }
  if (record.companyId) {
    const company = await assertCompanyExists(record.companyId);
    if (!record.insurerName) record.insurerName = company.name;
  }
  return record;
}

const withCompany = { company: { select: { id: true, name: true } } };

// ── Sélection publique d'un véhicule ──────────────────────────────────────────

/** Ce que l'API expose d'un véhicule. Ne jamais renvoyer l'objet Prisma brut. */
export function publicVehicle(v) {
  return {
    id: v.id,
    userId: v.userId,
    plate: v.plate,
    brand: v.brand,
    model: v.model,
    year: v.year,
    policy: v.policy,
    insurerName: v.company?.name ?? v.insurerName,
    companyId: v.companyId ?? null,
    insuranceExpiry: v.insuranceExpiry?.toISOString().slice(0, 10) ?? null,
    technicalExpiry: v.technicalExpiry?.toISOString().slice(0, 10) ?? null,
    color: v.color ?? null,
    mileage: v.mileage ?? null,
    type: v.type,
    fuel: v.fuel,
    claimCount: v.claimCount,
    archived: v.archived,
    createdAt: v.createdAt.toISOString(),
    updatedAt: v.updatedAt.toISOString(),
    // Alerte calculée : jours restants avant expiration de l'assurance
    daysUntilInsuranceExpiry: _daysUntil(v.insuranceExpiry),
    daysUntilTechnicalExpiry: v.technicalExpiry
      ? _daysUntil(v.technicalExpiry)
      : null,
  };
}

function _daysUntil(date) {
  if (!date) return null;
  const now = new Date();
  now.setHours(0, 0, 0, 0);
  const target = new Date(date);
  target.setHours(0, 0, 0, 0);
  return Math.round((target - now) / 86_400_000);
}

// ── CRUD ───────────────────────────────────────────────────────────────────────

/** Liste les véhicules d'un utilisateur. */
export async function listVehicles(userId, { archived = false, page = 1, pageSize = 20 } = {}) {
  const skip = (page - 1) * pageSize;
  const where = { userId, archived };

  const [total, rows] = await prisma.$transaction([
    prisma.vehicle.count({ where }),
    prisma.vehicle.findMany({
      where,
      include: withCompany,
      orderBy: { createdAt: 'desc' },
      skip,
      take: pageSize,
    }),
  ]);

  return {
    vehicles: rows.map(publicVehicle),
    total,
    page,
    pageSize,
    totalPages: Math.ceil(total / pageSize),
  };
}

/** Crée un nouveau véhicule pour l'utilisateur. */
export async function createVehicle(userId, input) {
  const data = await toRecord(input);
  // Déjà créé (renvoi après une coupure réseau) : rien à refaire.
  if (data.id) {
    const same = await prisma.vehicle.findUnique({
      where: { id: data.id },
      include: withCompany,
    });
    if (same?.userId === userId) return publicVehicle(same);
    if (same) throw new HttpError(409, 'VEHICLE_ID_TAKEN', 'Identifiant déjà utilisé.');
  }
  // Vérifier si la plaque est déjà enregistrée pour cet utilisateur.
  const existing = await prisma.vehicle.findUnique({
    where: { userId_plate: { userId, plate: data.plate } },
  });
  if (existing) {
    if (existing.archived) {
      // Si archivé, on le désarchive et on met à jour.
      const { id: _id, ...fields } = data;
      const updated = await prisma.vehicle.update({
        where: { id: existing.id },
        data: { ...fields, archived: false },
        include: withCompany,
      });
      return publicVehicle(updated);
    }
    throw new HttpError(
      409,
      'VEHICLE_PLATE_EXISTS',
      'Ce véhicule est déjà enregistré.',
    );
  }

  const vehicle = await prisma.vehicle.create({
    data: { ...data, userId },
    include: withCompany,
  });
  return publicVehicle(vehicle);
}

/** Récupère un véhicule. Vérifie que l'utilisateur en est propriétaire. */
export async function getVehicle(id, userId) {
  const vehicle = await prisma.vehicle.findUnique({ where: { id } });
  if (!vehicle || vehicle.userId !== userId) {
    throw new HttpError(404, 'VEHICLE_NOT_FOUND', 'Véhicule introuvable.');
  }
  return publicVehicle(vehicle);
}

/** Met à jour un véhicule existant. */
export async function updateVehicle(id, userId, input) {
  const data = await toRecord(input);
  const vehicle = await prisma.vehicle.findUnique({ where: { id } });
  if (!vehicle || vehicle.userId !== userId) {
    throw new HttpError(404, 'VEHICLE_NOT_FOUND', 'Véhicule introuvable.');
  }

  // Si la plaque change, vérifier qu'elle n'existe pas déjà.
  if (data.plate && data.plate !== vehicle.plate) {
    const clash = await prisma.vehicle.findUnique({
      where: { userId_plate: { userId, plate: data.plate } },
    });
    if (clash && clash.id !== id) {
      throw new HttpError(
        409,
        'VEHICLE_PLATE_EXISTS',
        'Cette immatriculation est déjà enregistrée.',
      );
    }
  }

  const updated = await prisma.vehicle.update({
    where: { id },
    data,
    include: withCompany,
  });
  return publicVehicle(updated);
}

/** Archive ou désarchive un véhicule (soft delete). */
export async function archiveVehicle(id, userId, archived) {
  return updateVehicle(id, userId, { archived });
}

/** Supprime définitivement un véhicule. */
export async function deleteVehicle(id, userId) {
  const vehicle = await prisma.vehicle.findUnique({ where: { id } });
  if (!vehicle || vehicle.userId !== userId) {
    throw new HttpError(404, 'VEHICLE_NOT_FOUND', 'Véhicule introuvable.');
  }
  await prisma.vehicle.delete({ where: { id } });
}

/**
 * Incrémente le compteur de sinistres d'un véhicule.
 * Appelé par le module accidents lors d'un nouveau constat.
 */
export async function incrementClaimCount(vehicleId, userId) {
  const vehicle = await prisma.vehicle.findUnique({ where: { id: vehicleId } });
  if (!vehicle || vehicle.userId !== userId) return;
  await prisma.vehicle.update({
    where: { id: vehicleId },
    data: { claimCount: { increment: 1 } },
  });
}

/**
 * Alertes d'échéance : véhicules dont l'assurance ou la visite expire
 * dans les [thresholdDays] jours. Utilisé pour les notifications push.
 */
export async function getExpiringVehicles(userId, thresholdDays = 30) {
  const threshold = new Date();
  threshold.setDate(threshold.getDate() + thresholdDays);

  const vehicles = await prisma.vehicle.findMany({
    where: {
      userId,
      archived: false,
      OR: [
        { insuranceExpiry: { lte: threshold } },
        { technicalExpiry: { lte: threshold } },
      ],
    },
    orderBy: { insuranceExpiry: 'asc' },
  });

  return vehicles.map(publicVehicle);
}
