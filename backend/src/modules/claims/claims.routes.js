import { mkdirSync, readFileSync } from 'node:fs';
import { randomUUID } from 'node:crypto';
import path from 'node:path';

import { Router } from 'express';
import multer from 'multer';
import swaggerUi from 'swagger-ui-express';

import { requireRole, requireUser } from './claims.auth.js';
import { HttpError } from './claims.errors.js';
import * as claims from './claims.service.js';

// Module 5 : sinistres, suivi, notifications, messagerie.
const router = Router();

const uploadDir = path.resolve(process.env.UPLOAD_DIR ?? 'uploads');
const upload = multer({
  storage: multer.diskStorage({
    destination(_req, _file, done) {
      mkdirSync(uploadDir, { recursive: true });
      done(null, uploadDir);
    },
    filename: (_req, file, done) =>
      done(null, randomUUID() + path.extname(file.originalname)),
  }),
  limits: { fileSize: 20 * 1024 * 1024 },
});

const openapi = JSON.parse(
  readFileSync(new URL('./claims.openapi.json', import.meta.url)),
);

// Écriture rejouable : la clé vient de l'en-tête Idempotency-Key.
const write = (action) => async (req, res) => {
  const result = await claims.once(req.get('idempotency-key'), (tx) =>
    action(tx, req),
  );
  res.status(result.status).json(result.body);
};

const agent = requireRole('agent');

router.get('/openapi.json', (_req, res) => res.json(openapi));
router.use('/docs', swaggerUi.serve, swaggerUi.setup(openapi));

router.use(requireUser);
router.use((req, _res, next) => {
  req.body ??= {};
  next();
});

router.get('/', async (req, res) => {
  res.json(await claims.listClaims(req.user, req.query));
});
router.post(
  '/',
  requireRole('driver'),
  write((tx, req) => claims.createClaim(tx, req.user, req.body)),
);

router.get('/sync', async (req, res) => {
  res.json(await claims.snapshot(req.user));
});

router.get('/notifications', async (req, res) => {
  res.json(await claims.notificationsFor(req.user));
});
router.post(
  '/notifications/read',
  write((tx, req) => claims.markNotificationsRead(tx, req.user, req.body.ids)),
);

for (const kind of ['document', 'message']) {
  router.get(`/files/${kind}/:id`, async (req, res) => {
    const file = await claims.storedFile(req.user, kind, req.params.id);
    res.download(path.join(uploadDir, file.storedName), file.name);
  });
}

router.get('/:id', async (req, res) => {
  res.json(await claims.getClaim(req.user, req.params.id));
});
router.post(
  '/:id/take-charge',
  agent,
  write((tx, req) => claims.takeCharge(tx, req.user, req.params.id)),
);
router.post(
  '/:id/document-requests',
  agent,
  write((tx, req) =>
    claims.requestDocument(tx, req.user, req.params.id, req.body),
  ),
);
router.post(
  '/:id/documents',
  upload.single('file'),
  write((tx, req) =>
    claims.addDocument(tx, req.user, req.params.id, req.body, req.file),
  ),
);
router.post(
  '/:id/expertise',
  agent,
  write((tx, req) =>
    claims.scheduleExpertise(tx, req.user, req.params.id, req.body),
  ),
);
router.post(
  '/:id/expert-report',
  agent,
  upload.single('file'),
  write((tx, req) =>
    claims.addExpertReport(tx, req.user, req.params.id, req.body, req.file),
  ),
);
router.post(
  '/:id/close',
  agent,
  write((tx, req) => claims.closeClaim(tx, req.user, req.params.id, req.body)),
);
router.post(
  '/:id/reject',
  agent,
  write((tx, req) => claims.rejectClaim(tx, req.user, req.params.id, req.body)),
);

router.get('/:id/messages', async (req, res) => {
  res.json(await claims.messagesFor(req.user, req.params.id));
});
router.post(
  '/:id/messages',
  upload.single('file'),
  write((tx, req) =>
    claims.sendMessage(tx, req.user, req.params.id, req.body, req.file),
  ),
);
router.post(
  '/:id/messages/read',
  write((tx, req) => claims.markMessagesRead(tx, req.user, req.params.id)),
);

router.use((error, _req, res, _next) => {
  if (error instanceof HttpError) {
    res.status(error.status).json({ error: error.message });
    return;
  }
  if (error instanceof multer.MulterError) {
    res.status(400).json({ error: error.message });
    return;
  }
  console.error(error);
  res.status(500).json({ error: 'Erreur interne.' });
});

export default router;
