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

// Même barème que ResponsibilityProposal côté Flutter.
export function responsibilityProposal(boxes = []) {
  const fault = atFault.find((box) => boxes.includes(box));
  if (fault) {
    return { driverA: 100, reason: `${fault} : manœuvre à risque de A.` };
  }
  if (boxes.includes('En stationnement')) {
    return { driverA: 0, reason: 'A était en stationnement.' };
  }
  const turn = shared.find((box) => boxes.includes(box));
  if (turn) return { driverA: 50, reason: `${turn} : partage par défaut.` };
  return { driverA: 50, reason: 'Cases insuffisantes : partage par défaut.' };
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
    label: `Déclaré plus de ${Limits.declarationDays} jours après l’accident.`,
  },
  {
    id: 'repeat-claims',
    when: ({ priorClaims }) => priorClaims >= Limits.priorClaimsPerYear,
    label: 'Plusieurs sinistres de ce conducteur sur 12 mois.',
  },
  {
    id: 'contradictory-boxes',
    when: ({ claim }) =>
      claim.circumstances.includes('En stationnement') &&
      claim.circumstances.some((box) => moving.includes(box)),
    label: 'Cases contradictoires : à l’arrêt et en manœuvre.',
  },
  {
    id: 'severe-without-impact',
    when: ({ claim }) =>
      claim.severity === 'Grave' && claim.impactZones.length === 0,
    label: 'Sinistre grave sans point de choc renseigné.',
  },
  {
    id: 'amount-over-estimate',
    when: ({ claim, estimate }) =>
      amounts(claim).some(
        (amount) => amount > estimate.high * Limits.amountOverEstimate,
      ),
    label: 'Montant d’une pièce très supérieur à l’estimation.',
  },
  {
    id: 'document-mismatch',
    when: ({ claim }) =>
      claim.documents.some((document) => document.analysis?.matchesRequest === false),
    label: 'Une pièce ne correspond pas à ce qui était demandé.',
  },
];

const documentRules = [
  { label: 'Devis', when: () => true, reason: 'Nécessaire pour chiffrer.' },
  {
    label: 'PV de police',
    when: ({ claim }) => claim.severity === 'Grave',
    reason: 'Requis pour un sinistre grave.',
  },
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
  return documentRules
    .filter((rule) => rule.when(context) && !hasDocument(context.claim, rule.label))
    .map(({ label, reason }) => ({ label, reason }));
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
    .map(({ id, label }) => ({ id, label }));

export const needsExpert = ({ claim, estimate }) =>
  !claim.expertName &&
  (claim.severity === 'Grave' || estimate.mid >= Limits.expertAmount);
