import { PrismaClient } from '@prisma/client';

let client;

// Créé au premier usage : /api/health répond sans base de données.
export function db() {
  client ??= new PrismaClient();
  return client;
}
