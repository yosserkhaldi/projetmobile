import { randomUUID } from 'node:crypto';

import {
  analyze,
  decisionRecord,
  insightsFor,
  priorClaimsOf,
} from './ai/insights.js';
import { db } from './claims.db.js';
import { badRequest, conflict, notFound } from './claims.errors.js';
import { announceChange } from './claims.socket.js';
import { canMove, Status } from './claims.workflow.js';

const aggregate = {
  events: { orderBy: { id: 'asc' } },
  documents: { orderBy: { createdAt: 'asc' } },
  requests: { orderBy: { createdAt: 'asc' } },
};

// Réservé à l'agent : la proposition et la lecture des pièces par l'IA.
export function visibleTo(user, claim) {
  if (user.role !== 'driver') return claim;
  const { aiProposal: _proposal, documents, ...rest } = claim;
  return {
    ...rest,
    ...(documents && {
      documents: documents.map(({ analysis: _analysis, ...document }) => document),
    }),
  };
}

const canSee = (user, claim) =>
  user.role !== 'driver' || claim.driverId === user.id;

const required = (value, message) => {
  const text = typeof value === 'string' ? value.trim() : '';
  if (!text) throw badRequest(message);
  return text;
};

// Applique fn et retient la réponse dans la même transaction : un renvoi avec
// la même clé rejoue la réponse sans rien refaire.
export async function once(key, fn) {
  const run = async (tx) => {
    if (key) {
      const known = await tx.processedRequest.findUnique({ where: { key } });
      if (known) return { status: known.status, body: known.body };
    }
    const { status = 200, body, claim } = await fn(tx);
    const json = JSON.parse(JSON.stringify(body));
    if (key) {
      await tx.processedRequest.create({ data: { key, status, body: json } });
    }
    return { status, body: json, claim };
  };
  const result = await db().$transaction(run);
  if (result.claim) announceChange(result.claim);
  return result;
}

async function load(tx, id, user) {
  const claim = await tx.claim.findUnique({ where: { id }, include: aggregate });
  if (!claim || !canSee(user, claim)) throw notFound();
  return claim;
}

const notify = (tx, claim, audience, body) =>
  tx.claimNotification.create({
    data: {
      claimId: claim.id,
      audience,
      body,
      recipientId: audience === 'driver' ? claim.driverId : null,
    },
  });

async function move(tx, claim, status, data = {}, detail) {
  if (!canMove(claim.status, status)) {
    throw conflict(`Passage impossible : ${claim.status} vers ${status}.`);
  }
  const label = detail ? `${status} : ${detail}` : status;
  await tx.claim.update({ where: { id: claim.id }, data: { ...data, status } });
  await tx.claimEvent.create({ data: { claimId: claim.id, label } });
  await notify(tx, claim, 'driver', `${claim.id} : ${label}`);
}

const reply = async (tx, id, user, status = 200) => {
  const claim = await load(tx, id, user);
  return { status, body: visibleTo(user, claim), claim };
};

export async function listClaims(user, { status, severity, from, to, q }) {
  const claims = await db().claim.findMany({
    where: {
      ...(user.role === 'driver' ? { driverId: user.id } : {}),
      ...(status ? { status } : {}),
      ...(severity ? { severity } : {}),
      ...(from || to
        ? {
            createdAt: {
              ...(from ? { gte: new Date(from) } : {}),
              ...(to ? { lte: new Date(to) } : {}),
            },
          }
        : {}),
      ...(q
        ? {
            OR: ['id', 'place', 'type'].map((field) => ({
              [field]: { contains: q, mode: 'insensitive' },
            })),
          }
        : {}),
    },
    include: aggregate,
    orderBy: { createdAt: 'desc' },
  });
  return claims;
}

export const getClaim = async (user, id) =>
  visibleTo(user, await load(db(), id, user));

// Dossier complet pour le serveur : l'accès est vérifié, rien n'est retiré.
export const claimForAi = (user, id) => load(db(), id, user);

export const createClaim = (tx, user, input) => {
  const id = required(input.id, 'Identifiant du dossier requis.');
  return (async () => {
    if (await tx.claim.findUnique({ where: { id } })) {
      throw conflict('Ce dossier existe déjà.');
    }
    const claim = await tx.claim.create({
      data: {
        id,
        driverId: user.id,
        type: required(input.type, 'Type requis.'),
        place: required(input.place, 'Lieu requis.'),
        date: required(input.date, 'Date requise.'),
        severity: required(input.severity, 'Gravité requise.'),
        status: Status.transmitted,
        observations: input.observations ?? '',
        circumstances: input.circumstances ?? [],
        impactZones: input.impactZones ?? [],
        events: {
          create: (input.timeline ?? [Status.transmitted]).map((label) => ({
            label,
          })),
        },
      },
    });
    await notify(tx, claim, 'agent', `Nouveau sinistre reçu : ${id}`);
    return reply(tx, id, user, 201);
  })();
};

export async function takeCharge(tx, user, id) {
  const claim = await load(tx, id, user);
  await move(tx, claim, Status.inReview, {
    agentId: user.id,
    agentName: user.name,
  });
  return reply(tx, id, user);
}

export async function requestDocument(tx, user, id, input) {
  const claim = await load(tx, id, user);
  const label = required(input.label, 'Pièce requise.');
  if (
    claim.status !== Status.inReview &&
    claim.status !== Status.documentRequested
  ) {
    throw conflict(`Demande impossible au statut ${claim.status}.`);
  }
  await tx.documentRequest.create({
    data: {
      id: input.id ?? randomUUID(),
      claimId: id,
      label,
      note: input.note ?? '',
    },
  });
  if (claim.status === Status.inReview) {
    await move(tx, claim, Status.documentRequested, {}, label);
  } else {
    await tx.claimEvent.create({
      data: { claimId: id, label: `Pièce demandée : ${label}` },
    });
    await notify(tx, claim, 'driver', `${id} : pièce demandée (${label})`);
  }
  return reply(tx, id, user);
}

// Pièces jointes d'office par la déclaration (module 3) : photos, vidéo,
// note vocale et constat PDF.
export const declarationKinds = ['Photo', 'Vidéo', 'Note vocale', 'Constat amiable'];

export async function addDocument(tx, user, id, input, file) {
  const claim = await load(tx, id, user);
  const documentId = input.id ?? randomUUID();
  const name = required(input.name ?? file?.originalname, 'Fichier requis.');
  const fromDeclaration =
    user.role === 'driver' && declarationKinds.includes(input.kind);
  await tx.claimDocument.create({
    data: {
      id: documentId,
      claimId: id,
      name,
      ...(fromDeclaration ? { kind: input.kind } : {}),
      storedName: file?.filename,
      requestId: input.requestId || null,
    },
  });
  if (input.requestId) {
    const { count } = await tx.documentRequest.updateMany({
      where: { id: input.requestId, claimId: id, documentId: null },
      data: { documentId },
    });
    if (count === 0) throw badRequest('Demande de pièce inconnue.');
  }
  // L'agent est déjà prévenu du nouveau sinistre : pas une alerte par photo.
  if (!fromDeclaration) {
    await notify(tx, claim, 'agent', `${id} : pièce déposée (${name})`);
  }

  const open = await tx.documentRequest.count({
    where: { claimId: id, documentId: null },
  });
  if (claim.status === Status.documentRequested && open === 0) {
    await move(tx, claim, Status.inReview);
  }
  return reply(tx, id, user, 201);
}

export async function scheduleExpertise(tx, user, id, input) {
  const claim = await load(tx, id, user);
  const expertName = required(input.expertName, 'Expert requis.');
  const expertAppointment = new Date(input.appointment);
  if (Number.isNaN(expertAppointment.getTime())) {
    throw badRequest('Date de rendez-vous invalide.');
  }
  const data = { expertName, expertAppointment };
  if (claim.status === Status.expertise) {
    await tx.claim.update({ where: { id }, data });
    await tx.claimEvent.create({
      data: { claimId: id, label: 'Rendez-vous déplacé' },
    });
    await notify(tx, claim, 'driver', `${id} : rendez-vous d’expertise déplacé`);
  } else {
    await move(tx, claim, Status.expertise, data);
  }
  return reply(tx, id, user);
}

export async function addExpertReport(tx, user, id, input, file) {
  const claim = await load(tx, id, user);
  if (claim.status !== Status.expertise) {
    throw conflict('Le dossier n’est pas en expertise.');
  }
  await tx.claimDocument.create({
    data: {
      id: input.id ?? randomUUID(),
      claimId: id,
      name: required(input.name ?? file?.originalname, 'Fichier requis.'),
      kind: "Rapport d'expertise",
      storedName: file?.filename,
    },
  });
  await tx.claimEvent.create({
    data: { claimId: id, label: 'Rapport d’expertise joint' },
  });
  return reply(tx, id, user, 201);
}

async function proposalAtDecision(tx, claim) {
  const others = await tx.claim.findMany({
    where: { driverId: claim.driverId },
    select: { id: true, driverId: true, createdAt: true },
  });
  return decisionRecord(
    analyze(claim, { priorClaims: priorClaimsOf(claim, others) }),
  );
}

export async function closeClaim(tx, user, id, input) {
  const claim = await load(tx, id, user);
  const { responsibility, indemnity } = input;
  if (![0, 50, 100].includes(responsibility)) {
    throw badRequest('Responsabilité : 0, 50 ou 100.');
  }
  if (typeof indemnity !== 'number' || !(indemnity >= 0)) {
    throw badRequest('Montant invalide.');
  }
  await move(tx, claim, Status.closed, {
    responsibility,
    indemnity,
    aiProposal: await proposalAtDecision(tx, claim),
  });
  return reply(tx, id, user);
}

export async function rejectClaim(tx, user, id, input) {
  const claim = await load(tx, id, user);
  const decisionReason = required(input.reason, 'Motif requis.');
  await move(tx, claim, Status.rejected, {
    decisionReason,
    aiProposal: await proposalAtDecision(tx, claim),
  });
  return reply(tx, id, user);
}

export const notificationsFor = (user) =>
  db().claimNotification.findMany({
    where:
      user.role === 'driver'
        ? { audience: 'driver', recipientId: user.id }
        : { audience: user.role },
    orderBy: { createdAt: 'desc' },
  });

export async function markNotificationsRead(tx, user, ids) {
  if (!Array.isArray(ids)) throw badRequest('Liste d’identifiants requise.');
  await tx.claimNotification.updateMany({
    where: {
      id: { in: ids },
      audience: user.role,
      ...(user.role === 'driver' ? { recipientId: user.id } : {}),
    },
    data: { read: true },
  });
  return { body: { ok: true } };
}

export async function messagesFor(user, id) {
  await load(db(), id, user);
  return db().chatMessage.findMany({
    where: { claimId: id },
    orderBy: { sentAt: 'asc' },
  });
}

export async function sendMessage(tx, user, id, input, file) {
  const claim = await load(tx, id, user);
  const body = (input.body ?? '').trim();
  if (!body && !file) throw badRequest('Message vide.');
  const message = await tx.chatMessage.create({
    data: {
      id: input.id ?? randomUUID(),
      claimId: id,
      author: user.name,
      senderRole: user.role,
      body,
      attachmentName: input.attachmentName ?? file?.originalname,
      attachmentStored: file?.filename,
    },
  });
  return { status: 201, body: message, claim };
}

export async function markMessagesRead(tx, user, id) {
  const claim = await load(tx, id, user);
  await tx.chatMessage.updateMany({
    where: { claimId: id, read: false, senderRole: { not: user.role } },
    data: { read: true },
  });
  return { body: { ok: true }, claim };
}

export async function storedFile(user, kind, id) {
  const record =
    kind === 'document'
      ? await db().claimDocument.findUnique({ where: { id } })
      : await db().chatMessage.findUnique({ where: { id } });
  if (!record) throw notFound();
  await load(db(), record.claimId, user);
  const storedName = record.storedName ?? record.attachmentStored;
  if (!storedName) throw notFound();
  return { storedName, name: record.name ?? record.attachmentName };
}

// Tout ce dont l'application a besoin pour se mettre à jour.
export async function snapshot(user) {
  const claims = await listClaims(user, {});
  const [notifications, messages] = await Promise.all([
    notificationsFor(user),
    db().chatMessage.findMany({
      where: { claimId: { in: claims.map((claim) => claim.id) } },
      orderBy: { sentAt: 'asc' },
    }),
  ]);
  return {
    claims: claims.map((claim) => visibleTo(user, claim)),
    notifications,
    messages,
    insights: insightsFor(user, claims),
  };
}
