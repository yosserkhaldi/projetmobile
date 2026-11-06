import express from 'express';

import accidentsRoutes from './modules/accidents/accidents.routes.js';
import claimsRoutes from './modules/claims/claims.routes.js';
import constatsRoutes from './modules/constats/constats.routes.js';
import usersRoutes from './modules/users/users.routes.js';
import vehiclesRoutes from './modules/vehicles/vehicles.routes.js';

export function createApp() {
  const app = express();
  app.use(express.json());

  app.get('/api/health', (_req, res) => res.json({ status: 'ok' }));

  // Chaque module ajoute ses endpoints dans son propre fichier de routes.
  app.use('/api/users', usersRoutes);
  app.use('/api/vehicles', vehiclesRoutes);
  app.use('/api/accidents', accidentsRoutes);
  app.use('/api/constats', constatsRoutes);
  app.use('/api/claims', claimsRoutes);

  return app;
}
