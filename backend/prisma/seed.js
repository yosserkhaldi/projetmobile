import { PrismaClient } from '@prisma/client';

// Dossier de démonstration, le même que sur l'application.
const prisma = new PrismaClient();
const id = 'SIN-2026-0418';

await prisma.claim.upsert({
  where: { id },
  update: {},
  create: {
    id,
    driverId: 'demo-driver',
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

// Dossiers terminés : ils alimentent les dossiers similaires et les statistiques.
const history = [
  ['SIN-2026-0101', 'Matériel', ['Changeait de file'], ['Avant'], 100, 620, 9],
  ['SIN-2026-0102', 'Matériel', ['En stationnement'], ['Arrière'], 0, 1150, 12],
  ['SIN-2026-0103', 'Léger', ['Reculait'], ['Arrière', 'Côté droit'], 100, 480, 14],
  ['SIN-2026-0104', 'Léger', ['Virait à gauche'], ['Avant'], 50, 980, 18],
  ['SIN-2026-0105', 'Grave', ['Doublait'], ['Avant', 'Côté gauche'], 100, 2100, 31],
  ['SIN-2026-0106', 'Grave', ['En stationnement'], ['Arrière', 'Côté droit'], 0, 5400, 38],
];
for (const [claimId, severity, circumstances, impactZones, responsibility, indemnity, days] of history) {
  const opened = new Date(2026, 5, 1 + Number(claimId.slice(-1)) * 9);
  const finished = new Date(opened.getTime() + days * 86_400_000);
  await prisma.claim.upsert({
    where: { id: claimId },
    update: {},
    create: {
      id: claimId,
      driverId: `demo-history-${claimId.slice(-1)}`,
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
await prisma.$disconnect();
