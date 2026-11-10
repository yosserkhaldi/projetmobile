import { textsIn } from './i18n.js';

// Règles métier explicables. Chaque résultat porte sa raison : l'agent doit
// pouvoir vérifier ce que le système lui propose.

export const Limits = Object.freeze({
  declarationDays: 5,
  priorClaimsPerYear: 2,
  amountOverEstimate: 2,
  expertAmount: 3000,
  slaDays: {
    Transmis: 2,
    'En instruction': 10,
    'Pièce demandée': 7,
    Expertise: 15,
  },
});

const atFault = [
  'Reculait',
  'Quittait un stationnement',
  'Changeait de file',
  'Doublait',
];
const shared = ['Virait à droite', 'Virait à gauche'];
const moving = [...atFault, ...shared];

function canonicalBox(raw) {
  const stripped = String(raw ?? '')
    .replace(/^\d{1,2}\s*[-–.)]\s*/, '')
    .trim();
  if (stripped.startsWith('En stationnement')) return 'En stationnement';
  if (stripped.startsWith('Quittait un stationnement')) return 'Quittait un stationnement';
  return stripped;
}

// Même barème que ResponsibilityProposal côté Flutter, avec les cases des
// deux conducteurs (module 4) :
// - une manœuvre à risque d'un seul côté : ce conducteur à 100 % ;
// - des deux côtés : partage ;
// - un véhicule en stationnement face à un véhicule qui roulait : 0 % pour lui ;
// - sinon, un virage ou rien de décisif : partage par défaut.
// `basis` est un code stable ; `reason` est rédigée dans la langue demandée.
export function responsibilityProposal(boxesA = [], boxesB = [], lang = 'FR') {
  const t = textsIn(lang);
  const normA = boxesA.map(canonicalBox);
  const normB = boxesB.map(canonicalBox);
  const riskyA = atFault.find((box) => normA.includes(box));
  const riskyB = atFault.find((box) => normB.includes(box));
  const parkedA = normA.includes('En stationnement');
  const parkedB = normB.includes('En stationnement');
  const share = (driverA, basis, reason) => ({ driverA, basis, reason });
  if (riskyA && riskyB) {
    return share(50, 'both', t.proposal.both(t.value(riskyA), t.value(riskyB)));
  }
  if (riskyA) return share(100, 'fault-a', t.proposal.fault(t.value(riskyA)));
  if (riskyB) return share(0, 'fault-b', t.proposal.faultB(t.value(riskyB)));
  if (parkedA && !parkedB) return share(0, 'parked-a', t.proposal.parked);
  if (parkedB && !parkedA) return share(100, 'parked-b', t.proposal.parkedB);
  const turn = shared.find((box) => normA.includes(box) || normB.includes(box));
  if (turn) return share(50, 'turn', t.proposal.turn(t.value(turn)));
  return share(50, 'unknown', t.proposal.unknown);
}

const days = (from, to) => (to - from) / 86_400_000;

// Accepte les deux formats de date du projet.
export function occurredAt(date) {
  const french = /^(\d{2})\/(\d{2})\/(\d{4})(?: (\d{2}):(\d{2}))?/.exec(date ?? '');
  if (french) {
    const [, day, month, year, hour = 0, minute = 0] = french;
    return new Date(year, month - 1, day, hour, minute);
  }
  const parsed = new Date(date);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

const amounts = (claim) =>
  claim.documents
    .map((document) => document.analysis?.amount)
    .filter((amount) => typeof amount === 'number');

// Signaux de vigilance. Ils invitent à vérifier, ils ne prouvent rien.
const vigilanceRules = [
  {
    id: 'late-declaration',
    when: ({ claim }) => {
      const accident = occurredAt(claim.date);
      return (
        accident &&
        days(accident, new Date(claim.createdAt)) > Limits.declarationDays
      );
    },
  },
  {
    id: 'repeat-claims',
    when: ({ priorClaims }) => priorClaims >= Limits.priorClaimsPerYear,
  },
  {
    id: 'contradictory-boxes',
    when: ({ claim }) => {
      const boxes = claim.circumstances.map(canonicalBox);
      return (
        boxes.includes('En stationnement') &&
        boxes.some((box) => moving.includes(box))
      );
    },
  },
  {
    id: 'severe-without-impact',
    when: ({ claim }) =>
      claim.severity === 'Grave' && claim.impactZones.length === 0,
  },
  {
    id: 'amount-over-estimate',
    when: ({ claim, estimate }) =>
      amounts(claim).some(
        (amount) => amount > estimate.high * Limits.amountOverEstimate,
      ),
  },
  {
    id: 'document-mismatch',
    when: ({ claim }) =>
      // Seulement une pièce envoyée en réponse à une demande : une photo de
      // la déclaration ne répond à aucune demande.
      claim.documents.some(
        (document) => document.requestId && document.analysis?.matchesRequest === false,
      ),
  },
];

// `label` est la pièce enregistrée (en français, c'est une donnée).
const documentRules = [
  { label: 'Devis', when: () => true },
  { label: 'PV de police', when: ({ claim }) => claim.severity === 'Grave' },
];

const normalize = (text) =>
  text.normalize('NFD').replace(/\p{M}/gu, '').toLowerCase();

function hasDocument(claim, label) {
  const wanted = normalize(label);
  return (
    claim.requests.some((request) => normalize(request.label) === wanted) ||
    claim.documents.some(
      (document) =>
        normalize(document.name).includes(wanted) ||
        normalize(document.analysis?.documentType ?? '') === wanted,
    )
  );
}

export function missingDocuments(context) {
  const t = textsIn(context.lang);
  return documentRules
    .filter((rule) => rule.when(context) && !hasDocument(context.claim, rule.label))
    .map(({ label }) => ({ label, reason: t.documentReasons[label] }));
}

// Temps passé dans le statut courant, depuis le dernier événement.
export function serviceLevel(claim, now) {
  const limit = Limits.slaDays[claim.status];
  if (!limit) return null;
  const last = claim.events.at(-1)?.createdAt ?? claim.createdAt;
  const spent = Math.floor(days(new Date(last), now));
  return { limitDays: limit, spentDays: spent, overdueDays: Math.max(0, spent - limit) };
}

export const vigilanceSignals = (context) =>
  vigilanceRules
    .filter((rule) => rule.when(context))
    .map(({ id }) => ({
      id,
      label: textsIn(context.lang).signals[id](Limits.declarationDays),
    }));

export const needsExpert = ({ claim, estimate }) =>
  !claim.expertName &&
  (claim.severity === 'Grave' || estimate.mid >= Limits.expertAmount);
