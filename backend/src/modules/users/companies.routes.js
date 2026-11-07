import { Router } from 'express';

import {
  HttpError,
  isForeignKeyViolation,
  isUniqueViolation,
} from '../../lib/errors.js';
import { prisma } from '../../lib/prisma.js';
import { requireAuth, requireRole } from '../../middleware/auth.js';
import {
  agencyParams,
  agencySchema,
  companySchema,
  idParams,
} from './users.schemas.js';

// Module 1 : compagnies d'assurance et agences.
const router = Router();
const withAgencies = { agencies: { orderBy: { name: 'asc' } } };

const rethrowDuplicate = (message) => (err) => {
  throw isUniqueViolation(err)
    ? new HttpError(409, 'ALREADY_EXISTS', message)
    : err;
};
const duplicateCompany = rethrowDuplicate('Cette compagnie existe déjà.');
const duplicateAgency = rethrowDuplicate(
  'Cette agence existe déjà dans la compagnie.',
);

router.use(requireAuth);

// Lecture ouverte aux comptes connectés : le module 2 en a besoin pour les contrats.
router.get('/', async (_req, res) => {
  const items = await prisma.company.findMany({
    include: withAgencies,
    orderBy: { name: 'asc' },
  });
  res.json({ items });
});

router.use(requireRole('ADMIN'));

router.post('/', async (req, res) => {
  const data = companySchema.parse(req.body);
  const company = await prisma.company
    .create({ data, include: withAgencies })
    .catch(duplicateCompany);
  res.status(201).json({ company });
});

router.patch('/:id', async (req, res) => {
  const { id } = idParams.parse(req.params);
  const data = companySchema.parse(req.body);
  const company = await prisma.company
    .update({ where: { id }, data, include: withAgencies })
    .catch(duplicateCompany);
  res.json({ company });
});

router.delete('/:id', async (req, res) => {
  const { id } = idParams.parse(req.params);
  await prisma.company.delete({ where: { id } }).catch((err) => {
    throw isForeignKeyViolation(err)
      ? new HttpError(
          409,
          'COMPANY_IN_USE',
          'Cette compagnie a encore des agents rattachés.',
        )
      : err;
  });
  res.status(204).end();
});

router.post('/:id/agencies', async (req, res) => {
  const { id } = idParams.parse(req.params);
  const data = agencySchema.parse(req.body);
  const agency = await prisma.agency
    .create({ data: { ...data, companyId: id } })
    .catch((err) => {
      if (isForeignKeyViolation(err)) {
        throw new HttpError(404, 'NOT_FOUND', 'Compagnie introuvable.');
      }
      return duplicateAgency(err);
    });
  res.status(201).json({ agency });
});

router.patch('/:id/agencies/:agencyId', async (req, res) => {
  const { id, agencyId } = agencyParams.parse(req.params);
  const data = agencySchema.parse(req.body);
  const agency = await prisma.agency
    .update({ where: { id: agencyId, companyId: id }, data })
    .catch(duplicateAgency);
  res.json({ agency });
});

router.delete('/:id/agencies/:agencyId', async (req, res) => {
  const { id, agencyId } = agencyParams.parse(req.params);
  await prisma.agency.delete({ where: { id: agencyId, companyId: id } });
  res.status(204).end();
});

export default router;
