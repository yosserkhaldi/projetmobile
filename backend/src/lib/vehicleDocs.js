import sharp from 'sharp';

import { recognize, recognizeNear } from './ocr.js';

// Module 2 : lecture de la carte grise (certificat d'immatriculation) et de
// l'attestation d'assurance tunisiennes. Même OCR que les pièces d'identité,
// sur le serveur ; rien n'est enregistré. Une photo prise à la main : on
// fait plusieurs lectures (contraste, encre seule, photo tournée) et on garde,
// champ par champ, ce qui a la bonne forme. Un champ douteux reste vide.

/** Marques courantes en Tunisie, écrites comme sur la carte (points ignorés). */
export const BRANDS = [
  'Peugeot', 'Renault', 'Citroen', 'Dacia', 'Volkswagen', 'Seat', 'Skoda',
  'Audi', 'BMW', 'Mercedes', 'Opel', 'Fiat', 'Ford', 'Toyota', 'Nissan',
  'Hyundai', 'Kia', 'Suzuki', 'Mitsubishi', 'Isuzu', 'Mazda', 'Honda',
  'Chery', 'Geely', 'BYD', 'Haval', 'MG', 'Chevrolet', 'Mahindra', 'Tata',
  'DFSK', 'Wallyscar', 'Jeep', 'Land Rover', 'Volvo', 'Mini', 'Porsche',
  'Alfa Romeo', 'Lancia', 'Iveco', 'JAC', 'Great Wall', 'Changan', 'Jetour',
  'Cupra', 'DS', 'Lexus', 'Infiniti', 'Subaru', 'Ssangyong', 'Proton',
];

/** Compagnies d'assurance tunisiennes : nom sur l'attestation → nom usuel. */
export const INSURERS = [
  ['BH ASSURANCE', 'BH Assurance'],
  ['STAR', 'STAR Assurances'],
  ['COMAR', 'COMAR'],
  ['GAT', 'GAT Assurances'],
  ['ASTREE', 'Assurances Astree'],
  ['MAGHREBIA', 'Maghrebia'],
  ['LLOYD', 'Lloyd Tunisien'],
  ['AMI', 'AMI Assurances'],
  ['CARTE', 'CARTE Assurances'],
  ['ZITOUNA', 'Zitouna Takaful'],
  ['ATTIJARI', 'Attijari Assurance'],
  ['BIAT', 'Assurances BIAT'],
  ['CTAMA', 'CTAMA'],
  ['MAE', 'MAE Assurances'],
  ['HAYETT', 'Hayett'],
  ['TAKAFULIA', 'Takafulia'],
];

const lettersOnly = (text) =>
  text
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toUpperCase();

/** Marque trouvée dans le texte : « M.G. » = MG, « PEUGEOT » = Peugeot. */
export function brandIn(text) {
  const upper = lettersOnly(text);
  for (const brand of BRANDS) {
    const letters = brand.toUpperCase().replace(/\s+/g, '');
    // Lettres séparées par des points ou des espaces : M.G. ou M G.
    const pattern = letters.split('').map((c) => c.replace(/[^A-Z0-9]/, '')).join('[.\\s]?');
    if (new RegExp(`(^|[^A-Z])${pattern}\\.?($|[^A-Z])`).test(upper)) return brand;
  }
  return null;
}

/**
 * Plaque tunisienne « série TU numéro » : 244 TU 9432. Accepte 9432TU244
 * (attestation), « TN », ou les deux nombres lus séparément sur la bande
 * verticale de la carte grise. La série a 1 à 3 chiffres, le numéro 1 à 4.
 */
export function formatPlate(first, second) {
  const [series, number] =
    first.length <= 3 && second.length === 4
      ? [first, second]
      : second.length <= 3 && first.length === 4
        ? [second, first]
        : [first, second];
  return `${Number(series)} TU ${number}`;
}

export function plateIn(text) {
  const match = text.match(/(?<!\d)(\d{1,4})\s*(?:TU|TN|تونس)\s*(\d{1,4})(?!\d)/i);
  return match ? formatPlate(match[1], match[2]) : null;
}

/** Plaque lue sur la bande verticale (photo tournée) : un nombre de 4
 * chiffres et un de 1 à 3, seuls sur leur ligne, pas pris dans un plus
 * long nombre de la carte (CIN, série du type). */
export function plateFromBand(turnedTexts, flatTexts) {
  const longNumbers = flatTexts.join(' ').match(/\d{5,}/g) ?? [];
  const inLong = (n) => longNumbers.some((long) => long.includes(n));
  const count = (pattern) => {
    const votes = new Map();
    for (const text of turnedTexts) {
      for (const line of text.split('\n')) {
        const token = line.trim();
        if (pattern.test(token) && !inLong(token)) {
          votes.set(token, (votes.get(token) ?? 0) + 1);
        }
      }
    }
    return [...votes.entries()].sort((a, b) => b[1] - a[1])[0]?.[0] ?? null;
  };
  const number = count(/^\d{4}$/);
  const series = count(/^\d{2,3}$/);
  return number && series ? formatPlate(series, number) : null;
}

/** Dates JJ/MM/AAAA ou AAAA/MM/JJ ; « 2410712025 » (barres lues 1) aussi.
 * Renvoyées en AAAA-MM-JJ, valides seulement. */
export function datesIn(text) {
  const found = [];
  const add = (y, m, d) => {
    const iso = `${y}-${m.padStart(2, '0')}-${d.padStart(2, '0')}`;
    const date = new Date(`${iso}T00:00:00Z`);
    if (!Number.isNaN(date.getTime()) && date.getUTCDate() === Number(d)) found.push(iso);
  };
  for (const [, d, m, y] of text.matchAll(/(?<!\d)(\d{1,2})[/.-](\d{1,2})[/.-]((?:19|20)\d{2})(?!\d)/g)) add(y, m, d);
  for (const [, y, m, d] of text.matchAll(/(?<!\d)((?:19|20)\d{2})[/.-](\d{1,2})[/.-](\d{1,2})(?!\d)/g)) add(y, m, d);
  // Barres lues comme des 1 : 24 1 07 1 2025.
  for (const [, d, m, y] of text.matchAll(/(?<!\d)(\d{2})1(\d{2})1((?:19|20)\d{2})(?!\d)/g)) add(y, m, d);
  return found;
}

const lines = (texts) => texts.flatMap((t) => t.split('\n')).map((l) => l.trim()).filter(Boolean);

/**
 * Carte grise. [flat] : lectures de la carte à l'endroit ; [turned] : la
 * photo tournée d'un quart de tour, où la bande verticale de gauche (numéro
 * d'immatriculation) se lit à l'horizontale.
 */
export function parseRegistration({ flat, turned = [] }) {
  const all = [...flat, ...turned];
  const text = all.join('\n');
  const brand = brandIn(flat.join('\n')) ?? brandIn(text);

  // Modèle : « Type commercial », écrit avec la marque (« MG ZS »).
  // Un code constructeur (« SZS111AB1PAJC5LEP », lettres et chiffres mêlés,
  // 8 signes ou plus) n'est jamais un modèle. La ligne qui suit « Type
  // commercial » passe en premier.
  let model = null;
  if (brand) {
    const pattern = brand.toUpperCase().split('').join('[.\\s]?');
    const isCode = (value) =>
      value.split(/\s+/).some((t) => t.length >= 8 && /\d/.test(t) && /[A-Z]/.test(t));
    const all = lines(flat);
    const after = all.findIndex((l) => /commercial/i.test(l));
    const ordered = after === -1 ? all : [...all.slice(after), ...all.slice(0, after)];
    for (const line of ordered) {
      const match = lettersOnly(line).match(new RegExp(`^${pattern}\\.?\\s+([A-Z0-9][A-Z0-9 -]{0,20})$`));
      if (match && !isCode(match[1])) {
        model = match[1].trim();
        break;
      }
    }
  }

  // Année : date de première mise en circulation (DPMC).
  const dpmcLine = lines(flat).find((l) => /DPMC/i.test(l) && datesIn(l).length);
  const today = new Date().toISOString().slice(0, 10);
  const firstRegistration =
    (dpmcLine && datesIn(dpmcLine)[0]) ??
    datesIn(flat.join('\n')).filter((d) => d <= today).sort().at(-1) ??
    null;

  return {
    plate: plateIn(text) ?? plateFromBand(turned, flat),
    brand,
    model,
    year: firstRegistration ? Number(firstRegistration.slice(0, 4)) : null,
    firstRegistration,
  };
}

/** Assureur nommé sur l'attestation, hors mentions génériques
 * (« Attestation d'Assurance », « Fédération … des Sociétés d'Assurances »). */
export function insurerIn(text) {
  const upper = lettersOnly(text)
    .replace(/ATTESTATION D.ASSURANCE/g, ' ')
    .replace(/ENTREPRISE D.ASSURANCE/g, ' ')
    .replace(/SOCIETES D.ASSURANCES/g, ' ');
  for (const [key, name] of INSURERS) {
    const pattern = key.replace(/\s+/g, '\\s*');
    if (new RegExp(`(^|[^A-Z])${pattern}($|[^A-Z])`).test(upper)) return name;
  }
  return null;
}

/** Un an moins un jour : la durée des contrats automobiles annuels. */
function oneYearAfter(iso) {
  const date = new Date(`${iso}T00:00:00Z`);
  date.setUTCFullYear(date.getUTCFullYear() + 1);
  date.setUTCDate(date.getUTCDate() - 1);
  return date.toISOString().slice(0, 10);
}

/**
 * Attestation d'assurance. [policyVotes] : lectures du numéro à côté de
 * « Contrat N° » (recognizeNear) ; retenu seulement s'il revient au moins
 * deux fois ou s'il figure aussi dans le texte.
 */
export function parseInsurance({ flat, turned = [], policyVotes = [] }) {
  const all = [...flat, ...turned];
  const text = all.join('\n');

  let policy = null;
  const inText = text.match(/contrat\s*n\S*\s*[:.]?\s*(\d{8,16})/i)?.[1];
  const best = policyVotes[0];
  if (inText) policy = inText;
  else if (best && (best[1] >= 2 || text.includes(best[0]))) policy = best[0];

  const dateOf = (labels) => {
    for (const line of lines(all)) {
      if (labels.test(line) && datesIn(line).length) return datesIn(line)[0];
    }
    return null;
  };
  const dates = [...new Set(datesIn(text))].sort();
  // Contrat annuel : deux dates à un an (moins un jour) l'une de l'autre sont
  // le début et la fin. Sinon la date du libellé « Au », ou la plus tardive
  // de l'attestation (la fin de validité) ; le début reste alors vide plutôt
  // que faux.
  const pair = dates.find((d) => dates.includes(oneYearAfter(d)));
  const from = dateOf(/\bdu\b/i);
  const startsAt = pair ?? from ?? null;
  let expiresAt = pair
    ? oneYearAfter(pair)
    : (dateOf(/\bau\b/i) ?? dates.filter((d) => !from || d > from).at(-1) ?? null);
  // Fin illisible : un an après le début, signalé comme estimé.
  const expiresAtEstimated = !expiresAt && Boolean(startsAt);
  if (expiresAtEstimated) expiresAt = oneYearAfter(startsAt);

  return {
    insurer: insurerIn(text),
    policy,
    startsAt,
    expiresAt,
    expiresAtEstimated,
    plate: plateIn(text),
    brand: brandIn(text),
  };
}

// ---------------------------------------------------------------------------
// Lectures de la photo.

/** Encre seule (texte imprimé sombre) : efface le fond coloré et le
 * filigrane clair des attestations. */
async function inkOnly(image, limit = 110) {
  const { data, info } = await sharp(image).removeAlpha().raw().toBuffer({ resolveWithObject: true });
  const ink = Buffer.alloc(info.width * info.height);
  for (let i = 0, j = 0; i < data.length; i += info.channels, j++) {
    ink[j] = Math.max(data[i], data[i + 1], data[i + 2]) < limit ? 0 : 255;
  }
  return sharp(ink, { raw: { width: info.width, height: info.height, channels: 1 } })
    .median(3)
    .png()
    .toBuffer();
}

const grey = (image, angle = 0) =>
  sharp(image)
    .rotate(angle)
    .greyscale()
    .resize(angle % 180 ? { height: 2400 } : { width: 2400 })
    .normalise()
    .png()
    .toBuffer();

/**
 * Lit une carte grise (`REGISTRATION`) ou une attestation d'assurance
 * (`INSURANCE`). Plusieurs lectures, puis les champs qui ont la bonne forme.
 */
export async function readVehicleDocument(buffer, kind) {
  const upright = await sharp(buffer).rotate().toBuffer();
  const base = await grey(upright);
  const colour = await sharp(upright).resize({ width: 2400 }).toBuffer();
  const flat = [
    await recognize('sparse', base),
    await recognize('eng', base),
    await recognize('eng', await inkOnly(colour)),
    await recognize('sparse', await inkOnly(colour)),
  ];
  // Bande verticale de la carte grise, ou attestation photographiée en
  // paysage : la photo tournée d'un quart de tour, dans les deux sens.
  const turned = [
    await recognize('sparse', await grey(upright, 90)),
    await recognize('sparse', await grey(upright, 270)),
  ];
  if (kind === 'REGISTRATION') return parseRegistration({ flat, turned });
  const first = parseInsurance({ flat, turned });
  if (first.policy) return first;
  // Numéro du contrat pas lu dans le texte : relu de près, à côté du libellé.
  const policyVotes = await recognizeNear(base, /^contrat$/i, /\d{8,16}/);
  return parseInsurance({ flat, turned, policyVotes });
}

/** Point d'entrée remplaçable dans les tests (comme documentReader). */
export const vehicleDocReader = { read: readVehicleDocument };
