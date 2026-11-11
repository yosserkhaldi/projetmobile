import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

import cors from 'cors';
import express from 'express';
import swaggerUi from 'swagger-ui-express';
import { parse } from 'yaml';

import { errorHandler, notFoundHandler } from './lib/errors.js';
import accidentsRoutes from './modules/accidents/accidents.routes.js';
import claimsRoutes from './modules/claims/claims.routes.js';
import constatsRoutes from './modules/constats/constats.routes.js';
import authRoutes from './modules/users/auth.routes.js';
import companiesRoutes from './modules/users/companies.routes.js';
import privacyRoutes from './modules/users/privacy.routes.js';
import securityRoutes from './modules/users/security.routes.js';
import usersRoutes from './modules/users/users.routes.js';
import vehiclesRoutes from './modules/vehicles/vehicles.routes.js';

// Contrat d'API partagé : http://localhost:3000/api/docs
const apiDocs = parse(
  readFileSync(new URL('../openapi.yaml', import.meta.url), 'utf8'),
);

export function createApp() {
  const app = express();

  // L'application mobile n'est pas concernée. Sert à `flutter run -d chrome` en local.
  if (process.env.NODE_ENV !== 'production') {
    app.use(cors({ origin: /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/ }));
  }
  // Signatures et croquis voyagent en points : la limite par défaut (100 Ko)
  // refusait un croquis détaillé.
  app.use(express.json({ limit: '5mb' }));
  app.use((req, res, next) => {
    const start = Date.now();
    res.on('finish', () => {
      console.log(`[HTTP] ${req.method} ${req.originalUrl} -> ${res.statusCode} (${Date.now() - start}ms)`);
    });
    next();
  });

  app.get('/api/health', (_req, res) => res.json({ status: 'ok' }));
  app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(apiDocs));
  app.use(
    '/verifier',
    express.static(fileURLToPath(new URL('../../verifier-pwa', import.meta.url)), {
      setHeaders: (res) => {
        res.setHeader(
          'Content-Security-Policy',
          "default-src 'none'; script-src 'self'; style-src 'self'; img-src 'self' data:; media-src 'self' mediastream:; font-src 'self'; connect-src 'none'; object-src 'none'; base-uri 'none'; form-action 'none'; frame-ancestors 'none';",
        );
        res.setHeader('Permissions-Policy', 'camera=(self), microphone=(), geolocation=()');
        res.setHeader('X-Content-Type-Options', 'nosniff');
        res.setHeader('X-Frame-Options', 'DENY');
        res.setHeader('Referrer-Policy', 'no-referrer');
      },
    }),
  );

  // Chaque module ajoute ses endpoints dans son propre fichier de routes.
  app.use('/api/auth', authRoutes);
  app.use('/api/users', privacyRoutes);
  app.use('/api/users', securityRoutes);
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
