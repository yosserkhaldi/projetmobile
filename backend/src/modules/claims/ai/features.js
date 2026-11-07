import { occurredAt } from './rules.js';

// Ordre figé : model.json stocke ses poids dans cet ordre.
export const featureNames = [
  'severityLight',
  'severityGrave',
  'impactZones',
  'circumstances',
  'driverShare',
  'lateDays',
  'priorClaims',
  'collision',
];

export const featureLabels = {
  severityLight: 'gravité légère',
  severityGrave: 'gravité élevée',
  impactZones: 'nombre de points de choc',
  circumstances: 'peu de circonstances renseignées',
  driverShare: 'part non responsable',
  lateDays: 'délai de déclaration',
  priorClaims: 'sinistres récents du conducteur',
  collision: 'collision',
};

const lateDays = (claim) => {
  const accident = occurredAt(claim.date);
  if (!accident) return 0;
  const late = (new Date(claim.createdAt) - accident) / 86_400_000;
  return Math.min(30, Math.max(0, late));
};

// Au-delà, le modèle extrapolerait hors de ce qu'il a appris.
const maxPriorClaims = 3;

// [responsibility] est la part de A : la décision si elle existe, sinon la
// proposition des règles.
export const featuresOf = (claim, { responsibility, priorClaims }) => [
  claim.severity === 'Léger' ? 1 : 0,
  claim.severity === 'Grave' ? 1 : 0,
  claim.impactZones.length,
  claim.circumstances.length,
  1 - responsibility / 100,
  lateDays(claim),
  Math.min(priorClaims, maxPriorClaims),
  claim.type === 'Collision' ? 1 : 0,
];
