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
await prisma.$disconnect();
