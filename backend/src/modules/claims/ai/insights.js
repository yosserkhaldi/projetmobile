import { readFileSync } from 'node:fs';

import { Status } from '../claims.workflow.js';
import { featureLabels, featuresOf } from './features.js';
import {
  contributions,
  nearest,
  predictLinear,
  predictProbability,
  scale,
} from './ml.js';
import {
  missingDocuments,
  needsExpert,
  responsibilityProposal,
  serviceLevel,
  vigilanceSignals,
} from './rules.js';

export const model = JSON.parse(
  readFileSync(new URL('./model.json', import.meta.url)),
);

const finished = [Status.closed, Status.rejected];
const toTen = (value) => Math.round(value / 10) * 10;
const yearMs = 365 * 86_400_000;

// Intervalle à 80 % d'une loi log-normale.
const spread = 1.28;

function estimateAmount(row) {
  const center = predictLinear(model.indemnity, row);
  return {
    low: toTen(Math.exp(center - spread * model.indemnity.sigma)),
    mid: toTen(Math.exp(center)),
    high: toTen(Math.exp(center + spread * model.indemnity.sigma)),
  };
}

function estimateDuration(row, claim, now) {
  const total = Math.exp(predictLinear(model.duration, row));
  const spent = (now - new Date(claim.createdAt)) / 86_400_000;
  return {
    totalDays: Math.round(total),
    remainingDays: Math.max(1, Math.round(total - spent)),
  };
}

function estimateRisk(row) {
  const probability = predictProbability(model.rejection, row);
  const factors = contributions(model.rejection, row)
    .map((value, j) => ({ value, name: model.features[j] }))
    .filter(({ value }) => value > 0.15)
    .sort((a, b) => b.value - a.value)
    .slice(0, 3)
    .map(({ name }) => featureLabels[name]);
  const level = probability >= 0.4 ? 'élevé' : probability >= 0.15 ? 'moyen' : 'faible';
  return { probability: Number(probability.toFixed(3)), level, factors };
}

function nextAction(claim, { missing, expert, overdue }) {
  const open = claim.requests.filter((request) => !request.documentId).length;
  if (claim.status === Status.transmitted) {
    return { code: 'take-charge', label: 'Prendre le dossier en charge.' };
  }
  if (claim.status === Status.documentRequested) {
    return overdue
      ? { code: 'remind', label: 'Relancer le conducteur : pièce en retard.' }
      : { code: 'wait', label: `Attendre ${open} pièce(s) du conducteur.` };
  }
  if (claim.status === Status.expertise) {
    const report = claim.documents.some((d) => d.kind === "Rapport d'expertise");
    return report
      ? { code: 'decide', label: 'Rapport reçu : prendre la décision.' }
      : { code: 'report', label: 'Attendre et joindre le rapport d’expertise.' };
  }
  if (missing.length > 0) {
    return { code: 'request', label: `Demander : ${missing[0].label}.` };
  }
  if (expert) return { code: 'expert', label: 'Désigner un expert.' };
  return { code: 'decide', label: 'Dossier complet : prendre la décision.' };
}

function priority(claim, { service, signals, risk }) {
  const reasons = [];
  let score = 10;
  const add = (points, reason) => {
    score += points;
    if (reason) reasons.push(reason);
  };
  if (claim.severity === 'Grave') add(35, 'Sinistre grave');
  else if (claim.severity === 'Léger') add(10);
  if (service?.overdueDays > 0) {
    add(Math.min(30, 10 + service.overdueDays * 2), `En retard de ${service.overdueDays} j`);
  }
  if (claim.status === Status.transmitted) add(10, 'Pas encore pris en charge');
  if (signals.length > 0) add(Math.min(15, signals.length * 8), 'Signal à vérifier');
  if (risk.level === 'élevé') add(10);
  return { score: Math.min(100, score), reasons };
}

function similarCases(claim, row, history) {
  const candidates = history
    .filter((past) => past.claim.id !== claim.id)
    .map((past) => ({ ...past, row: scale(past.features, model.scaler) }));
  return nearest(row, candidates).map(({ candidate, distance }) => ({
    id: candidate.claim.id,
    similarity: Math.round(100 / (1 + distance)),
    outcome: candidate.claim.status,
    responsibility: candidate.claim.responsibility,
    indemnity: candidate.claim.indemnity,
  }));
}

// Dossiers terminés, prêts à servir de comparaison.
export const historyOf = (claims) =>
  claims
    .filter((claim) => finished.includes(claim.status))
    .map((claim) => ({
      claim,
      features: featuresOf(claim, {
        responsibility: claim.responsibility ?? 50,
        priorClaims: 0,
      }),
    }));

// Sinistres du même conducteur sur les 12 mois précédant ce dossier.
export function priorClaimsOf(claim, claims) {
  const created = new Date(claim.createdAt);
  return claims.filter(
    (other) =>
      other.id !== claim.id &&
      other.driverId === claim.driverId &&
      new Date(other.createdAt) <= created &&
      created - new Date(other.createdAt) <= yearMs,
  ).length;
}

// Orchestration : règles, puis modèles, puis synthèse. Aucune écriture.
export function analyze(claim, { priorClaims = 0, history = [], now = new Date() } = {}) {
  const proposal = responsibilityProposal(claim.circumstances);
  const features = featuresOf(claim, {
    responsibility: claim.responsibility ?? proposal.driverA,
    priorClaims,
  });
  const row = scale(features, model.scaler);
  const estimate = estimateAmount(row);
  const risk = estimateRisk(row);
  const context = { claim, priorClaims, estimate };
  const signals = vigilanceSignals(context);
  const active = !finished.includes(claim.status);
  const missing = active ? missingDocuments(context) : [];
  const service = active ? serviceLevel(claim, now) : null;
  const expert = active && needsExpert(context);

  return {
    modelVersion: model.version,
    proposal,
    estimate,
    duration: estimateDuration(row, claim, now),
    risk,
    signals,
    missingDocuments: missing,
    recommendExpert: expert,
    service,
    priority: active
      ? priority(claim, { service, signals, risk })
      : { score: 0, reasons: [] },
    nextAction: active
      ? nextAction(claim, { missing, expert, overdue: service?.overdueDays > 0 })
      : { code: 'none', label: 'Dossier terminé.' },
    similar: similarCases(claim, row, history),
  };
}

const guidance = {
  [Status.transmitted]: 'Votre dossier est reçu. Un agent va le prendre en charge.',
  [Status.inReview]: 'Un agent étudie votre dossier.',
  [Status.documentRequested]: 'Votre dossier attend des pièces de votre part.',
  [Status.expertise]: 'Un expert va examiner votre véhicule.',
  [Status.closed]: 'Votre dossier est clôturé.',
  [Status.rejected]: 'Votre dossier a été rejeté.',
};

// Ce que le conducteur a le droit de voir. Liste blanche : un champ ajouté à
// l'analyse reste réservé à l'agent tant qu'il n'est pas ajouté ici.
export function driverView(claim, analysis) {
  const todo = claim.requests
    .filter((request) => !request.documentId)
    .map((request) => `Déposer : ${request.label}`);
  if (claim.expertAppointment && claim.status === Status.expertise) {
    todo.push('Présenter le véhicule à l’expert au rendez-vous.');
  }
  return {
    headline: guidance[claim.status] ?? 'Votre dossier est en préparation.',
    todo,
    remainingDays: finished.includes(claim.status)
      ? null
      : analysis.duration.remainingDays,
  };
}

// Analyses de tous les dossiers visibles, selon le rôle.
export function insightsFor(user, claims, now = new Date()) {
  const history = user.role === 'driver' ? [] : historyOf(claims);
  return Object.fromEntries(
    claims.map((claim) => {
      const analysis = analyze(claim, {
        priorClaims: priorClaimsOf(claim, claims),
        history,
        now,
      });
      return [
        claim.id,
        user.role === 'driver' ? { driver: driverView(claim, analysis) } : analysis,
      ];
    }),
  );
}

// Retenu au moment de la décision, pour mesurer ensuite l'écart avec l'agent.
export const decisionRecord = (analysis) => ({
  modelVersion: analysis.modelVersion,
  responsibility: analysis.proposal.driverA,
  estimate: analysis.estimate,
  riskProbability: analysis.risk.probability,
});
