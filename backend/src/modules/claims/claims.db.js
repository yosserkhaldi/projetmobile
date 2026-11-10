import { prisma } from '../../lib/prisma.js';

export const db = () => prisma;
