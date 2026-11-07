// Comptes et compagnies de démonstration. Jamais en production.
import bcrypt from 'bcryptjs';

import { prisma } from '../src/lib/prisma.js';

if (process.env.NODE_ENV === 'production') {
  throw new Error('Le seed de démonstration est interdit en production.');
}

const PASSWORD = 'Password123!';

const COMPANIES = [
  { name: 'STAR Assurances', agencies: [['Agence Lac', 'Tunis'], ['Agence Ariana', 'Ariana']] },
  { name: 'COMAR', agencies: [['Agence Centre', 'Tunis'], ['Agence Sfax', 'Sfax']] },
  { name: 'GAT Assurances', agencies: [['Agence Ben Arous', 'Ben Arous']] },
];

const passwordHash = await bcrypt.hash(PASSWORD, 10);

for (const { name, agencies } of COMPANIES) {
  await prisma.company.upsert({
    where: { name },
    update: {},
    create: {
      name,
      agencies: {
        create: agencies.map(([agency, city]) => ({ name: agency, city })),
      },
    },
  });
}
const star = await prisma.company.findUniqueOrThrow({
  where: { name: 'STAR Assurances' },
});

const USERS = [
  {
    firstName: 'Sami',
    lastName: 'Ben Ali',
    email: 'sami@example.com',
    phone: '+21620000001',
    role: 'DRIVER',
  },
  {
    firstName: 'Leïla',
    lastName: 'Mansour',
    email: 'leila@assurance.tn',
    phone: '+21620000002',
    role: 'AGENT',
    companyId: star.id,
  },
  {
    firstName: 'Admin',
    lastName: 'MCD',
    email: 'admin@monconstat.tn',
    phone: '+21620000003',
    role: 'ADMIN',
  },
];

for (const user of USERS) {
  await prisma.user.upsert({
    where: { email: user.email },
    update: {},
    create: { ...user, passwordHash, phoneVerifiedAt: new Date() },
  });
}

// Module 5 : un dossier en cours pour Sami, et des dossiers terminés qui
// alimentent les dossiers similaires et les statistiques.
const sami = await prisma.user.findUniqueOrThrow({
  where: { email: 'sami@example.com' },
});
const demoClaim = 'SIN-2026-0418';
await prisma.claim.upsert({
  where: { id: demoClaim },
  update: { driverId: sami.id },
  create: {
    id: demoClaim,
    driverId: sami.id,
    agentName: 'Leïla Mansour',
    type: 'Collision',
    place: 'Avenue Habib Bourguiba, Tunis',
    date: '12/10/2026 18:40',
    createdAt: new Date(2026, 9, 13, 9),
    status: 'En instruction',
    severity: 'Matériel',
    circumstances: ['Changeait de file'],
    events: {
      create: ['Brouillon créé', 'Transmis', 'En instruction'].map((label) => ({
        label,
      })),
    },
  },
});

const HISTORY = [
  ['SIN-2026-0101', 'Matériel', ['Changeait de file'], ['Avant'], 100, 620, 9],
  ['SIN-2026-0102', 'Matériel', ['En stationnement'], ['Arrière'], 0, 1150, 12],
  ['SIN-2026-0103', 'Léger', ['Reculait'], ['Arrière', 'Côté droit'], 100, 480, 14],
  ['SIN-2026-0104', 'Léger', ['Virait à gauche'], ['Avant'], 50, 980, 18],
  ['SIN-2026-0105', 'Grave', ['Doublait'], ['Avant', 'Côté gauche'], 100, 2100, 31],
  ['SIN-2026-0106', 'Grave', ['En stationnement'], ['Arrière', 'Côté droit'], 0, 5400, 38],
];
for (const [id, severity, circumstances, impactZones, responsibility, indemnity, days] of HISTORY) {
  const opened = new Date(2026, 5, 1 + Number(id.slice(-1)) * 9);
  const finished = new Date(opened.getTime() + days * 86_400_000);
  await prisma.claim.upsert({
    where: { id },
    update: {},
    create: {
      id,
      driverId: `demo-history-${id.slice(-1)}`,
      agentName: 'Leïla Mansour',
      type: 'Collision',
      place: 'Tunis',
      date: opened.toISOString().slice(0, 16).replace('T', ' '),
      createdAt: opened,
      status: 'Clôturé',
      severity,
      circumstances,
      impactZones,
      responsibility,
      indemnity,
      events: {
        create: [
          { label: 'Transmis', createdAt: opened },
          { label: 'Clôturé', createdAt: finished },
        ],
      },
    },
  });
}

console.log(`Seed terminé. Comptes de démonstration, mot de passe : ${PASSWORD}`);
await prisma.$disconnect();
