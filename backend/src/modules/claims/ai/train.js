// Entraîne les modèles et écrit model.json : npm run ml:train
//
// Aucun historique réel n'existe encore. L'entraînement part donc de données
// synthétiques, complétées par les dossiers terminés de la base si elle répond.
// Les métriques synthétiques montrent seulement que le modèle retrouve le
// générateur, pas qu'il est juste sur de vrais sinistres.
import { writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

import { featureNames, featuresOf } from './features.js';
import {
  areaUnderCurve,
  fitLogistic,
  fitRidge,
  fitScaler,
  meanAbsoluteError,
  predictLinear,
  predictProbability,
  rSquared,
  scale,
} from './ml.js';

// Générateur déterministe : deux entraînements donnent le même modèle.
function random(seed) {
  let state = seed;
  return () => {
    state = (state + 0x6d2b79f5) | 0;
    let t = Math.imul(state ^ (state >>> 15), 1 | state);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

const gaussian = (next) =>
  Math.sqrt(-2 * Math.log(1 - next())) * Math.cos(2 * Math.PI * next());

export function syntheticCases(count, seed = 2026) {
  const next = random(seed);
  return Array.from({ length: count }, () => {
    const pick = next();
    const light = pick >= 0.55 && pick < 0.85 ? 1 : 0;
    const grave = pick >= 0.85 ? 1 : 0;
    const zones = 1 + Math.floor(next() * 4);
    const boxes = Math.floor(next() * 4);
    const share = [0, 0.5, 1][Math.floor(next() * 3)];
    const late = Math.min(30, -Math.log(1 - next()) * 3);
    const prior = next() < 0.8 ? 0 : 1 + Math.floor(next() * 3);
    const collision = next() < 0.7 ? 1 : 0;

    const amount = Math.exp(
      6.3 + 0.7 * light + 1.6 * grave + 0.18 * zones + 0.15 * collision +
        Math.log(0.35 + 0.65 * share) + 0.3 * gaussian(next),
    );
    const duration = Math.exp(
      2.3 + 0.25 * light + 0.7 * grave + 0.05 * zones + 0.08 * prior +
        0.25 * gaussian(next),
    );
    const risk = -3.6 + 0.16 * late + 0.8 * prior - 0.5 * boxes + 0.4 * grave;
    return {
      row: [light, grave, zones, boxes, share, late, prior, collision],
      amount,
      duration,
      rejected: next() < 1 / (1 + Math.exp(-risk)) ? 1 : 0,
    };
  });
}

// Dossiers terminés de la base, au même format que les cas synthétiques.
async function realCases() {
  if (!process.env.DATABASE_URL) return [];
  const { prisma } = await import('../../../lib/prisma.js');
  try {
    const claims = await prisma.claim.findMany({
      where: { status: { in: ['Clôturé', 'Rejeté'] } },
      include: { events: { orderBy: { id: 'asc' } } },
    });
    return claims.map((claim) => {
      const end = claim.events.at(-1)?.createdAt ?? claim.updatedAt;
      return {
        row: featuresOf(claim, {
          responsibility: claim.responsibility ?? 50,
          priorClaims: 0,
        }),
        amount: claim.status === 'Clôturé' ? claim.indemnity : null,
        duration: Math.max(1, (end - claim.createdAt) / 86_400_000),
        rejected: claim.status === 'Rejeté' ? 1 : 0,
      };
    });
  } catch (error) {
    console.warn(`Base ignorée : ${error.message}`);
    return [];
  } finally {
    await prisma.$disconnect();
  }
}

const round = (value, digits = 4) => Number(value.toFixed(digits));

export function train(cases, realCount = 0) {
  const split = Math.floor(cases.length * 0.8);
  const learn = cases.slice(0, split);
  const test = cases.slice(split);
  const scaler = fitScaler(learn.map((c) => c.row));
  const scaled = (list) => list.map((c) => scale(c.row, scaler));

  const priced = (list) => list.filter((c) => c.amount > 0);
  const indemnity = fitRidge(
    scaled(priced(learn)),
    priced(learn).map((c) => Math.log(c.amount)),
  );
  const duration = fitRidge(scaled(learn), learn.map((c) => Math.log(c.duration)));
  const rejection = fitLogistic(scaled(learn), learn.map((c) => c.rejected));

  const pricedTest = priced(test);
  const amountGuess = scaled(pricedTest).map((row) =>
    Math.exp(predictLinear(indemnity, row)),
  );
  const amountActual = pricedTest.map((c) => c.amount);
  const daysGuess = scaled(test).map((row) => Math.exp(predictLinear(duration, row)));
  const daysActual = test.map((c) => c.duration);

  return {
    version: `2026.${cases.length}.${realCount}`,
    trainedOn: { synthetic: cases.length - realCount, real: realCount },
    features: featureNames,
    scaler,
    indemnity,
    duration,
    rejection,
    metrics: {
      indemnityMaeTnd: round(meanAbsoluteError(amountActual, amountGuess), 1),
      indemnityR2: round(rSquared(amountActual, amountGuess), 3),
      durationMaeDays: round(meanAbsoluteError(daysActual, daysGuess), 2),
      rejectionAuc: round(
        areaUnderCurve(
          test.map((c) => c.rejected),
          scaled(test).map((row) => predictProbability(rejection, row)),
        ),
        3,
      ),
    },
  };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const real = await realCases();
  // Les vrais dossiers passent en tête, pour rester dans l'échantillon d'apprentissage.
  const model = train([...real, ...syntheticCases(3000)], real.length);
  writeFileSync(
    new URL('./model.json', import.meta.url),
    `${JSON.stringify(model, null, 2)}\n`,
  );
  console.log(model.version, model.trainedOn, model.metrics);
}
