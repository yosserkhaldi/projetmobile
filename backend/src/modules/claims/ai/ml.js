// Modèles linéaires écrits à la main : assez petits pour tourner partout, et
// chaque prédiction se décompose par variable, ce qui permet de l'expliquer.

const dot = (a, b) => a.reduce((sum, value, i) => sum + value * b[i], 0);
const sigmoid = (z) => 1 / (1 + Math.exp(-z));

export function fitScaler(rows) {
  const size = rows[0].length;
  const mean = Array.from({ length: size }, (_, j) =>
    rows.reduce((sum, row) => sum + row[j], 0) / rows.length,
  );
  const std = mean.map((m, j) => {
    const variance =
      rows.reduce((sum, row) => sum + (row[j] - m) ** 2, 0) / rows.length;
    return Math.sqrt(variance) || 1;
  });
  return { mean, std };
}

export const scale = (row, { mean, std }) =>
  row.map((value, j) => (value - mean[j]) / std[j]);

// Pivot de Gauss sur le système (A)x = b.
function solve(matrix, vector) {
  const a = matrix.map((row, i) => [...row, vector[i]]);
  const n = a.length;
  for (let col = 0; col < n; col++) {
    let pivot = col;
    for (let row = col + 1; row < n; row++) {
      if (Math.abs(a[row][col]) > Math.abs(a[pivot][col])) pivot = row;
    }
    [a[col], a[pivot]] = [a[pivot], a[col]];
    for (let row = 0; row < n; row++) {
      if (row === col) continue;
      const factor = a[row][col] / a[col][col];
      for (let k = col; k <= n; k++) a[row][k] -= factor * a[col][k];
    }
  }
  return a.map((row, i) => row[n] / row[i]);
}

// Régression ridge, résolue directement. Les lignes sont déjà normalisées.
export function fitRidge(rows, targets, lambda = 1) {
  const bias = targets.reduce((sum, y) => sum + y, 0) / targets.length;
  const size = rows[0].length;
  const gram = Array.from({ length: size }, (_, i) =>
    Array.from({ length: size }, (_, j) =>
      rows.reduce((sum, row) => sum + row[i] * row[j], 0) + (i === j ? lambda : 0),
    ),
  );
  const moment = Array.from({ length: size }, (_, i) =>
    rows.reduce((sum, row, r) => sum + row[i] * (targets[r] - bias), 0),
  );
  const weights = solve(gram, moment);
  const residuals = rows.map((row, r) => targets[r] - bias - dot(weights, row));
  const sigma = Math.sqrt(
    residuals.reduce((sum, e) => sum + e * e, 0) / rows.length,
  );
  return { weights, bias, sigma };
}

// Régression logistique par descente de gradient.
export function fitLogistic(rows, labels, { steps = 2000, rate = 0.3, l2 = 0.001 } = {}) {
  const size = rows[0].length;
  const weights = new Array(size).fill(0);
  let bias = 0;
  for (let step = 0; step < steps; step++) {
    const gradient = new Array(size).fill(0);
    let biasGradient = 0;
    rows.forEach((row, r) => {
      const error = sigmoid(bias + dot(weights, row)) - labels[r];
      biasGradient += error;
      for (let j = 0; j < size; j++) gradient[j] += error * row[j];
    });
    bias -= (rate * biasGradient) / rows.length;
    for (let j = 0; j < size; j++) {
      weights[j] -= rate * (gradient[j] / rows.length + l2 * weights[j]);
    }
  }
  return { weights, bias };
}

export const predictLinear = (model, row) => model.bias + dot(model.weights, row);
export const predictProbability = (model, row) => sigmoid(predictLinear(model, row));

export const contributions = (model, row) =>
  row.map((value, j) => value * model.weights[j]);

export const meanAbsoluteError = (actual, predicted) =>
  actual.reduce((sum, y, i) => sum + Math.abs(y - predicted[i]), 0) / actual.length;

export function rSquared(actual, predicted) {
  const mean = actual.reduce((sum, y) => sum + y, 0) / actual.length;
  const total = actual.reduce((sum, y) => sum + (y - mean) ** 2, 0);
  const residual = actual.reduce((sum, y, i) => sum + (y - predicted[i]) ** 2, 0);
  return 1 - residual / total;
}

// Probabilité qu'un positif soit mieux classé qu'un négatif.
export function areaUnderCurve(labels, scores) {
  const positive = scores.filter((_, i) => labels[i] === 1);
  const negative = scores.filter((_, i) => labels[i] === 0);
  let wins = 0;
  for (const p of positive) {
    for (const n of negative) wins += p > n ? 1 : p === n ? 0.5 : 0;
  }
  return wins / (positive.length * negative.length);
}

// Dossiers passés les plus proches, en distance normalisée.
export function nearest(row, candidates, count = 3) {
  return candidates
    .map((candidate) => ({
      candidate,
      distance: Math.sqrt(
        row.reduce((sum, value, j) => sum + (value - candidate.row[j]) ** 2, 0),
      ),
    }))
    .sort((a, b) => a.distance - b.distance)
    .slice(0, count);
}
