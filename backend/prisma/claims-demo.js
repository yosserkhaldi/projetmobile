// Module 5 : dossiers de démonstration.
//
// Appelé par seed.js (sans rien écraser). Lancé seul, il remet les dossiers
// de démonstration à zéro, pour rejouer les scénarios :
//   npm run claims:demo
import { fileURLToPath } from 'node:url';

import bcrypt from 'bcryptjs';

import { prisma } from '../src/lib/prisma.js';

const day = 86_400_000;
const daysAgo = (n) => new Date(Date.now() - n * day);
const frenchDate = (date) =>
  `${String(date.getDate()).padStart(2, '0')}/${String(date.getMonth() + 1).padStart(2, '0')}/${date.getFullYear()} ` +
  `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;

// Dossiers en cours de Sami : un par situation à tester.
const OPEN = [
  {
    id: 'SIN-2026-0418',
    type: 'Collision',
    place: 'Avenue Habib Bourguiba, Tunis',
    date: '12/10/2026 18:40',
    createdAt: new Date(2026, 9, 13, 9),
    status: 'En instruction',
    severity: 'Matériel',
    circumstances: ['Changeait de file'],
    circumstancesB: [],
    impactZones: ['Avant'],
    events: ['Brouillon créé', 'Transmis', 'En instruction'],
  },
  // Nouveau, à prendre en charge. A et B manœuvraient : partage 50/50.
  {
    id: 'SIN-2026-0421',
    type: 'Collision',
    place: 'Route de la Marsa, La Marsa',
    ago: 1,
    status: 'Transmis',
    severity: 'Léger',
    circumstances: ['Reculait'],
    circumstancesB: ['Quittait un stationnement'],
    impactZones: ['Arrière'],
    observations: 'Choc à faible vitesse sur le parking du supermarché.',
    events: ['Brouillon créé', 'Transmis'],
  },
  // Grave, sans point de choc et déclaré tard : signaux et priorité haute.
  {
    id: 'SIN-2026-0422',
    type: 'Collision',
    place: 'Autoroute A1, sortie Hammamet',
    ago: 12,
    declaredAfter: 8,
    status: 'Transmis',
    severity: 'Grave',
    circumstances: ['Doublait'],
    circumstancesB: ['Virait à gauche'],
    impactZones: [],
    events: ['Brouillon créé', 'Transmis'],
  },
  // Un piéton : l'expertise est médicale, pas de véhicule à présenter.
  {
    id: 'SIN-2026-0423',
    type: 'Piéton',
    place: 'Rue de Marseille, Tunis',
    ago: 6,
    status: 'En instruction',
    severity: 'Léger',
    circumstances: [],
    circumstancesB: [],
    impactZones: ['Avant'],
    observations: 'Piéton heurté au passage clouté, blessure légère au genou.',
    events: ['Brouillon créé', 'Transmis', 'En instruction'],
  },
];

// Dossiers terminés : dossiers similaires et statistiques.
const HISTORY = [
  ['SIN-2026-0101', 'Matériel', ['Changeait de file'], ['Avant'], 100, 620, 9],
  ['SIN-2026-0102', 'Matériel', ['En stationnement'], ['Arrière'], 0, 1150, 12],
  ['SIN-2026-0103', 'Léger', ['Reculait'], ['Arrière', 'Côté droit'], 100, 480, 14],
  ['SIN-2026-0104', 'Léger', ['Virait à gauche'], ['Avant'], 50, 980, 18],
  ['SIN-2026-0105', 'Grave', ['Doublait'], ['Avant', 'Côté gauche'], 100, 2100, 31],
  ['SIN-2026-0106', 'Grave', ['En stationnement'], ['Arrière', 'Côté droit'], 0, 5400, 38],
];

// Un agent d'une autre compagnie et un sinistre chez elle : Leïla (STAR)
// ne doit ni le voir ni en être prévenue.
const OTHER_AGENT = {
  firstName: 'Karim',
  lastName: 'Jaziri',
  email: 'karim@comar.tn',
  phone: '+21620000004',
  role: 'AGENT',
};
const OTHER_DRIVER = {
  firstName: 'Hedi',
  lastName: 'Trabelsi',
  email: 'hedi@example.com',
  phone: '+21620000005',
  role: 'DRIVER',
};
const OTHER_CLAIM = {
  id: 'SIN-2026-0430',
  type: 'Collision',
  place: 'Avenue de la République, Sfax',
  ago: 2,
  status: 'Transmis',
  severity: 'Matériel',
  circumstances: ['En stationnement'],
  circumstancesB: ['Reculait'],
  impactZones: ['Arrière'],
  events: ['Brouillon créé', 'Transmis'],
};

async function account(user, companyId) {
  const passwordHash = await bcrypt.hash('Password123!', 10);
  return prisma.user.upsert({
    where: { email: user.email },
    update: companyId ? { companyId } : {},
    create: { ...user, companyId, passwordHash, phoneVerifiedAt: new Date() },
  });
}

function openClaim(claim, driverId) {
  const { ago, declaredAfter = 0, events, ...fields } = claim;
  const createdAt = fields.createdAt ?? daysAgo(ago);
  const occurred = new Date(createdAt.getTime() - declaredAfter * day);
  return {
    ...fields,
    driverId,
    createdAt,
    date: fields.date ?? frenchDate(occurred),
    agentName: fields.status === 'Transmis' ? null : 'Leïla Mansour',
    events: { create: events.map((label) => ({ label, createdAt })) },
  };
}

function closedClaim([id, severity, circumstances, impactZones, responsibility, indemnity, days]) {
  const opened = new Date(2026, 5, 1 + Number(id.slice(-1)) * 9);
  const finished = new Date(opened.getTime() + days * day);
  return {
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
  };
}

/** reset : efface d'abord les dossiers de démonstration et leurs messages. */
export async function seedClaims({ reset = false } = {}) {
  const sami = await prisma.user.findUniqueOrThrow({
    where: { email: 'sami@example.com' },
  });
  const star = await prisma.company.findUniqueOrThrow({
    where: { name: 'STAR Assurances' },
  });
  const comar = await prisma.company.findUniqueOrThrow({ where: { name: 'COMAR' } });
  await account(OTHER_AGENT, comar.id);
  const hedi = await account(OTHER_DRIVER, null);
  // Les dossiers de Sami et l'historique sont chez STAR, comme Leïla.
  const rows = [
    ...OPEN.map((claim) => ({ ...openClaim(claim, sami.id), companyId: star.id })),
    ...HISTORY.map((claim) => ({ ...closedClaim(claim), companyId: star.id })),
    { ...openClaim(OTHER_CLAIM, hedi.id), agentName: null, companyId: comar.id },
  ];
  if (reset) {
    // Les dossiers que Sami a déclarés pendant les tests partent aussi.
    const ids = [
      ...rows.map((row) => row.id),
      ...(await prisma.claim.findMany({ where: { driverId: hedi.id }, select: { id: true } })).map(
        (claim) => claim.id,
      ),
      ...(await prisma.claim.findMany({ where: { driverId: sami.id }, select: { id: true } })).map(
        (claim) => claim.id,
      ),
    ];
    await prisma.claimNotification.deleteMany({ where: { claimId: { in: ids } } });
    await prisma.claimAiNote.deleteMany({ where: { claimId: { in: ids } } });
    await prisma.claim.deleteMany({ where: { id: { in: ids } } });
  }
  for (const data of rows) {
    await prisma.claim.upsert({
      where: { id: data.id },
      update: { driverId: data.driverId, companyId: data.companyId },
      create: data,
    });
  }
  const fresh = [...OPEN, OTHER_CLAIM].filter((claim) => claim.status === 'Transmis');
  for (const claim of fresh) {
    const known = await prisma.claimNotification.findFirst({
      where: { claimId: claim.id, audience: 'agent' },
    });
    if (!known) {
      await prisma.claimNotification.create({
        data: { claimId: claim.id, audience: 'agent', body: `Nouveau sinistre reçu : ${claim.id}` },
      });
    }
  }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  if (process.env.NODE_ENV === 'production') {
    throw new Error('Données de démonstration interdites en production.');
  }
  await seedClaims({ reset: true });
  console.log('Dossiers de démonstration du module 5 remis à zéro.');
  await prisma.$disconnect();
}
