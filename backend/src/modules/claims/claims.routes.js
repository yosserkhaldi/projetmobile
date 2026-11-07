import { mkdirSync, readFileSync } from 'node:fs';
import { randomUUID } from 'node:crypto';
import path from 'node:path';

import { Router } from 'express';
import multer from 'multer';
import swaggerUi from 'swagger-ui-express';

import { analytics } from './ai/analytics.js';
import {
  analyzeDocument,
  askAssistant,
  loadContext,
  suggestReplies,
  summarize,
} from './ai/assistant.js';
import { claudeEnabled, claudeModel } from './ai/claude.js';
import { driverView, model } from './ai/insights.js';
import { requireRole, requireUser } from './claims.auth.js';
import { db } from './claims.db.js';
import { badRequest, HttpError } from './claims.errors.js';
import * as claims from './claims.service.js';
import { announceChange } from './claims.socket.js';

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

// Limite les appels payants : au plus 30 par minute et par utilisateur.
const aiCalls = new Map();
function aiLimit(req, res, next) {
  const now = Date.now();
  const recent = (aiCalls.get(req.user.id) ?? []).filter((t) => now - t < 60_000);
  if (recent.length >= 30) {
    res.status(429).json({ error: 'Trop de demandes, réessayez dans une minute.' });
    return;
  }
  aiCalls.set(req.user.id, [...recent, now]);
  next();
}

// Une question : historique borné, seuls les derniers échanges comptent.
function conversation(input) {
  if (!Array.isArray(input) || input.length === 0) {
    throw badRequest('Conversation requise.');
  }
  const messages = input.slice(-12).map(({ role, content }) => {
    if (!['user', 'assistant'].includes(role) || typeof content !== 'string') {
      throw badRequest('Message invalide.');
    }
    return { role, content: content.trim().slice(0, 2000) };
  });
  if (messages.at(-1).role !== 'user' || !messages.at(-1).content) {
    throw badRequest('Question requise.');
  }
  // L'API attend une conversation qui commence par l'utilisateur.
  while (messages[0].role !== 'user') messages.shift();
  return messages;
}

// Lit les pièces reçues, après la réponse : l'utilisateur n'attend pas Claude.
async function readDocuments(claimId) {
  if (!claudeEnabled()) return;
  const claim = await db().claim.findUnique({
    where: { id: claimId },
    include: { documents: true, requests: true },
  });
  if (!claim) return;
  let changed = false;
  for (const document of claim.documents) {
    if (document.analysis || !document.storedName) continue;
    const analysis = await analyzeDocument(document, claim, uploadDir);
    if (!analysis) continue;
    await db().claimDocument.update({
      where: { id: document.id },
      data: { analysis },
    });
    changed = true;
  }
  if (changed) announceChange(claim);
}

const thenRead = (req, res, next) => {
  res.on('finish', () => {
    if (res.statusCode < 400) {
      readDocuments(req.params.id).catch((error) =>
        console.warn(`Lecture de pièce : ${error.message}`),
      );
    }
  });
  next();
};

// L'application web de développement appelle l'API depuis un autre port.
router.use((req, res, next) => {
  res.set({
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers':
      'authorization, content-type, idempotency-key, x-user-id, x-user-name, x-user-role',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  });
  if (req.method === 'OPTIONS') {
    res.sendStatus(204);
    return;
  }
  next();
});

router.get('/openapi.json', (_req, res) => res.json(openapi));
router.use('/docs', swaggerUi.serve, swaggerUi.setup(openapi));

router.use(requireUser);
router.use((req, _res, next) => {
  req.body ??= {};
  next();
});

router.get('/', async (req, res) => {
  const list = await claims.listClaims(req.user, req.query);
  res.json(list.map((claim) => claims.visibleTo(req.user, claim)));
});
router.post(
  '/',
  requireRole('driver'),
  write((tx, req) => claims.createClaim(tx, req.user, req.body)),
);

router.get('/sync', async (req, res) => {
  res.json(await claims.snapshot(req.user));
});

router.get('/ai/status', (_req, res) => {
  res.json({
    claude: claudeEnabled(),
    claudeModel: claudeEnabled() ? claudeModel() : null,
    ml: { version: model.version, trainedOn: model.trainedOn },
  });
});

router.get('/analytics', agent, async (_req, res) => {
  const [all, calls] = await Promise.all([
    claims.listClaims({ role: 'agent' }, {}),
    db().aiCall.findMany({ select: { source: true, ok: true } }),
  ]);
  res.json(analytics(all, calls));
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
  thenRead,
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
  thenRead,
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

router.get('/:id/insights', async (req, res) => {
  const claim = await claims.claimForAi(req.user, req.params.id);
  const analysis = await loadContext(claim, req.user.role);
  res.json(
    req.user.role === 'driver'
      ? { driver: driverView(claim, analysis) }
      : analysis,
  );
});
router.post('/:id/ai/assistant', aiLimit, async (req, res) => {
  const claim = await claims.claimForAi(req.user, req.params.id);
  res.json(await askAssistant(claim, req.user, conversation(req.body.messages)));
});
router.post('/:id/ai/summary', agent, aiLimit, async (req, res) => {
  const claim = await claims.claimForAi(req.user, req.params.id);
  res.json(await summarize(claim, req.user));
});
router.post('/:id/ai/replies', agent, aiLimit, async (req, res) => {
  const claim = await claims.claimForAi(req.user, req.params.id);
  res.json(await suggestReplies(claim, req.user));
});

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
