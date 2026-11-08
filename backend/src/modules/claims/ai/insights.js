import { readFileSync } from 'node:fs';

import { Status } from '../claims.workflow.js';
import { featuresOf } from './features.js';
import { langOf, textsIn } from './i18n.js';
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
    // Durée habituelle déjà dépassée : « encore 1 jour » chaque jour serait faux.
    late: total - spent < 0.5,
  };
}

// `level` reste un code (faible, moyen, élevé) ; `label` est traduit.
function estimateRisk(row, t) {
  const probability = predictProbability(model.rejection, row);
  const factors = contributions(model.rejection, row)
    .map((value, j) => ({ value, name: model.features[j] }))
    .filter(({ value }) => value > 0.15)
    .sort((a, b) => b.value - a.value)
    .slice(0, 3)
    .map(({ name }) => t.features[name]);
  const level = probability >= 0.4 ? 'élevé' : probability >= 0.15 ? 'moyen' : 'faible';
  return {
    probability: Number(probability.toFixed(3)),
    level,
    label: t.risk[level],
    factors,
  };
}

function nextAction(claim, { missing, expert, overdue }, t) {
  const open = claim.requests.filter((request) => !request.documentId).length;
  const action = (code, ...args) => ({ code, label: t.next[code](...args) });
  if (claim.status === Status.transmitted) return action('take-charge');
  if (claim.status === Status.documentRequested) {
    return overdue ? action('remind') : action('wait', open);
  }
  if (claim.status === Status.expertise) {
    const report = claim.documents.some((d) => d.kind === "Rapport d'expertise");
    if (report) return { code: 'decide', label: t.next['decide-report']() };
    if (claim.appointmentState === 'proposed') {
      return action(claim.appointmentBy === 'driver' ? 'answer-slot' : 'wait-slot');
    }
    return action('report');
  }
  if (missing.length > 0) return action('request', t.value(missing[0].label));
  if (expert) return action('expert');
  return action('decide');
}

function priority(claim, { service, signals, risk }, t) {
  const reasons = [];
  let score = 10;
  const add = (points, reason) => {
    score += points;
    if (reason) reasons.push(reason);
  };
  if (claim.severity === 'Grave') add(35, t.priority.grave);
  else if (claim.severity === 'Léger') add(10);
  if (service?.overdueDays > 0) {
    add(Math.min(30, 10 + service.overdueDays * 2), t.priority.overdue(service.overdueDays));
  }
  if (claim.status === Status.transmitted) add(10, t.priority.untouched);
  if (signals.length > 0) add(Math.min(15, signals.length * 8), t.priority.signal);
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
// Les textes sont rédigés dans `lang` (FR, AR, EN) ; les codes ne changent pas.
export function analyze(
  claim,
  { priorClaims = 0, history = [], now = new Date(), lang = 'FR' } = {},
) {
  const t = textsIn(lang);
  const proposal = responsibilityProposal(claim.circumstances, lang);
  const features = featuresOf(claim, {
    responsibility: claim.responsibility ?? proposal.driverA,
    priorClaims,
  });
  const row = scale(features, model.scaler);
  const estimate = estimateAmount(row);
  const risk = estimateRisk(row, t);
  const context = { claim, priorClaims, estimate, lang };
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
      ? priority(claim, { service, signals, risk }, t)
      : { score: 0, reasons: [] },
    nextAction: active
      ? nextAction(claim, { missing, expert, overdue: service?.overdueDays > 0 }, t)
      : { code: 'none', label: t.next.none() },
    similar: similarCases(claim, row, history),
  };
}


// Ce que le conducteur a le droit de voir. Liste blanche : un champ ajouté à
// l'analyse reste réservé à l'agent tant qu'il n'est pas ajouté ici.
export function driverView(claim, analysis, lang = 'FR') {
  const t = textsIn(lang);
  const todo = claim.requests
    .filter((request) => !request.documentId)
    .map((request) => t.todo.upload(t.value(request.label)));
  if (claim.expertAppointment && claim.status === Status.expertise) {
    if (claim.appointmentState === 'proposed') {
      todo.push(claim.appointmentBy === 'driver' ? t.todo.waitAgent : t.todo.confirm);
    }
    todo.push(claim.expertKind === 'Corporelle' ? t.todo.expertBody : t.todo.expert);
  }
  return {
    headline: t.guidance[claim.status] ?? t.guidance.default,
    todo,
    remainingDays:
      finished.includes(claim.status) || analysis.duration.late
        ? null
        : analysis.duration.remainingDays,
    late: !finished.includes(claim.status) && analysis.duration.late,
  };
}

// Analyses de tous les dossiers visibles, selon le rôle.
export function insightsFor(user, claims, now = new Date()) {
  const lang = langOf(user);
  const history = user.role === 'driver' ? [] : historyOf(claims);
  return Object.fromEntries(
    claims.map((claim) => {
      const analysis = analyze(claim, {
        priorClaims: priorClaimsOf(claim, claims),
        history,
        now,
        lang,
      });
      return [
        claim.id,
        user.role === 'driver' ? { driver: driverView(claim, analysis, lang) } : analysis,
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
