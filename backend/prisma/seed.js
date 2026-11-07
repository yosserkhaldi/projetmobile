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

console.log(`Seed terminé. Comptes de démonstration, mot de passe : ${PASSWORD}`);
await prisma.$disconnect();
