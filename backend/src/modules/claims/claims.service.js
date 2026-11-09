import { randomUUID } from 'node:crypto';

import {
  analyze,
  decisionRecord,
  insightsFor,
  priorClaimsOf,
} from './ai/insights.js';
import { companyScope } from '../../middleware/auth.js';
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

// Qui voit quels sinistres (module 1, companyScope) :
// - conducteur : les siens ;
// - agent : ceux de sa compagnie, et ceux dont la compagnie est inconnue
//   (la déclaration ne dit pas toujours quel véhicule est concerné) ;
// - administrateur : tous.
// Un agent sans compagnie est refusé (403) par companyScope.
export function scopeOf(user) {
  if (user.role === 'driver') return { driverId: user.id };
  const scope = companyScope({
    user: { role: user.role.toUpperCase(), companyId: user.companyId },
  });
  if (!scope.companyId) return scope;
  return { OR: [scope, { companyId: null }] };
}

const canSee = (user, claim) => {
  if (user.role === 'driver') return claim.driverId === user.id;
  scopeOf(user);
  return (
    user.role !== 'agent' || !claim.companyId || claim.companyId === user.companyId
  );
};

const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// Constat scellé du module 4, s'il appartient bien au conducteur. Un
// constat scellé hors ligne (identifiant local) n'est pas encore connu.
async function constatOf(tx, driverId, requested) {
  if (typeof requested !== 'string' || !uuid.test(requested)) return null;
  const constat = await tx.constat.findUnique({ where: { id: requested } });
  return constat?.userId === driverId ? constat.id : null;
}

// Compagnie du sinistre : celle du contrat choisi dans l'application, sinon,
// côté serveur, l'unique compagnie des véhicules du conducteur. Une compagnie
// inconnue n'empêche pas la déclaration : le sinistre reste sans compagnie.
async function companyOf(tx, driverId, requested) {
  if (typeof requested === 'string' && uuid.test(requested)) {
    const company = await tx.company.findUnique({ where: { id: requested } });
    if (company) return company.id;
  }
  const vehicles = await tx.vehicle.findMany({
    where: { userId: driverId, archived: false, companyId: { not: null } },
    select: { companyId: true },
  });
  const companies = [...new Set(vehicles.map((v) => v.companyId))];
  return companies.length === 1 ? companies[0] : null;
}

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
      // AND : la recherche texte a son propre OR, qui écraserait le périmètre.
      AND: [scopeOf(user)],
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
        companyId: await companyOf(tx, user.id, input.companyId),
        constatId: await constatOf(tx, user.id, input.constatId),
        circumstances: input.circumstances ?? [],
        circumstancesB: input.circumstancesB ?? [],
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

export const expertKinds = ['Véhicule', 'Corporelle'];

// Un piéton blessé n'a pas de véhicule à montrer : l'expertise est médicale.
export const defaultExpertKind = (claim) =>
  claim.type === 'Piéton' ? 'Corporelle' : 'Véhicule';

function appointmentDate(value) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    throw badRequest('Date de rendez-vous invalide.');
  }
  if (date.getTime() < Date.now() - 60 * 60_000) {
    throw badRequest('Le rendez-vous doit être dans le futur.');
  }
  return date;
}

const optional = (value) =>
  typeof value === 'string' && value.trim() ? value.trim() : null;

// L'agent propose un rendez-vous complet ; le conducteur l'accepte ou en
// propose un autre (respondAppointment).
export async function scheduleExpertise(tx, user, id, input) {
  const claim = await load(tx, id, user);
  const expertKind = input.expertKind ?? defaultExpertKind(claim);
  if (!expertKinds.includes(expertKind)) {
    throw badRequest('Type d’expertise : Véhicule ou Corporelle.');
  }
  const data = {
    expertName: required(input.expertName, 'Expert requis.'),
    expertPhone: optional(input.expertPhone),
    expertPlace: optional(input.expertPlace),
    expertKind,
    expertAppointment: appointmentDate(input.appointment),
    appointmentState: 'proposed',
    appointmentBy: 'agent',
    appointmentNote: optional(input.note),
  };
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

// Réponse au dernier créneau proposé par l'autre partie.
export async function respondAppointment(tx, user, id, input) {
  const claim = await load(tx, id, user);
  if (claim.status !== Status.expertise || !claim.expertAppointment) {
    throw conflict('Aucun rendez-vous d’expertise à confirmer.');
  }
  const role = user.role === 'driver' ? 'driver' : 'agent';
  const other = role === 'driver' ? 'agent' : 'driver';
  if (input.action === 'accept') {
    if (claim.appointmentState !== 'proposed' || claim.appointmentBy === role) {
      throw conflict('Ce créneau attend la réponse de l’autre partie.');
    }
    await tx.claim.update({
      where: { id },
      data: { appointmentState: 'accepted' },
    });
    await tx.claimEvent.create({
      data: { claimId: id, label: 'Rendez-vous confirmé' },
    });
    await notify(tx, claim, other, `${id} : rendez-vous d’expertise confirmé`);
    return reply(tx, id, user);
  }
  if (input.action !== 'propose') {
    throw badRequest('Action : accept ou propose.');
  }
  await tx.claim.update({
    where: { id },
    data: {
      expertAppointment: appointmentDate(input.appointment),
      appointmentState: 'proposed',
      appointmentBy: role,
      appointmentNote: optional(input.note),
    },
  });
  await tx.claimEvent.create({
    data: { claimId: id, label: 'Autre créneau proposé' },
  });
  await notify(tx, claim, other, `${id} : autre créneau proposé pour l’expertise`);
  return reply(tx, id, user);
}

// Corrige une erreur après la décision : le dossier revient en instruction,
// la décision précédente reste dans la chronologie.
export async function reopenClaim(tx, user, id, input) {
  const claim = await load(tx, id, user);
  const reason = required(input.reason, 'Motif requis.');
  if (claim.status !== Status.closed && claim.status !== Status.rejected) {
    throw conflict('Seul un dossier clôturé ou rejeté peut être rouvert.');
  }
  await tx.claim.update({
    where: { id },
    data: {
      status: Status.inReview,
      responsibility: null,
      indemnity: null,
      decisionReason: null,
      aiProposal: null,
    },
  });
  const label = `Rouvert : ${reason}`;
  await tx.claimEvent.create({ data: { claimId: id, label } });
  await notify(tx, claim, 'driver', `${id} : ${label}`);
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

// Un agent ne voit que les notifications des sinistres de son périmètre.
async function notificationScope(user) {
  if (user.role === 'driver') {
    return { audience: 'driver', recipientId: user.id };
  }
  const visible = await db().claim.findMany({
    where: scopeOf(user),
    select: { id: true },
  });
  return {
    audience: user.role,
    OR: [{ claimId: null }, { claimId: { in: visible.map((c) => c.id) } }],
  };
}

export const notificationsFor = async (user) =>
  db().claimNotification.findMany({
    where: await notificationScope(user),
    orderBy: { createdAt: 'desc' },
  });

export async function markNotificationsRead(tx, user, ids) {
  if (!Array.isArray(ids)) throw badRequest('Liste d’identifiants requise.');
  await tx.claimNotification.updateMany({
    where: { id: { in: ids }, ...(await notificationScope(user)) },
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
