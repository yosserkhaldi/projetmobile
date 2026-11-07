import cors from 'cors';
import express from 'express';

import { errorHandler, notFoundHandler } from './lib/errors.js';
import accidentsRoutes from './modules/accidents/accidents.routes.js';
import claimsRoutes from './modules/claims/claims.routes.js';
import constatsRoutes from './modules/constats/constats.routes.js';
import authRoutes from './modules/users/auth.routes.js';
import companiesRoutes from './modules/users/companies.routes.js';
import usersRoutes from './modules/users/users.routes.js';
import vehiclesRoutes from './modules/vehicles/vehicles.routes.js';

export function createApp() {
  const app = express();

  // L'application mobile n'est pas concernée. Sert à `flutter run -d chrome` en local.
  if (process.env.NODE_ENV !== 'production') {
    app.use(cors({ origin: /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/ }));
  }
  app.use(express.json());

  app.get('/api/health', (_req, res) => res.json({ status: 'ok' }));

  // Chaque module ajoute ses endpoints dans son propre fichier de routes.
  app.use('/api/auth', authRoutes);
  app.use('/api/users', usersRoutes);
  app.use('/api/companies', companiesRoutes);
  app.use('/api/vehicles', vehiclesRoutes);
  app.use('/api/accidents', accidentsRoutes);
  app.use('/api/constats', constatsRoutes);
  app.use('/api/claims', claimsRoutes);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
