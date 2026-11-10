import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';

import sharp from 'sharp';
import { createWorker } from 'tesseract.js';

// Lecture des pièces d'identité (OCR Tesseract, en WebAssembly sur le
// serveur), en français/anglais et en arabe. Les modèles de langue sont livrés
// avec l'API : rien n'est téléchargé ni envoyé ailleurs.

/** Moteurs : « eng » pour les chiffres, « ara » pour les champs en arabe de
 * la CIN, « mrz » limité aux signes de la MRZ (A-Z, 0-9, <). */
const ENGINES = {
  eng: { lang: 'eng' },
  ara: { lang: 'ara' },
  mrz: {
    lang: 'eng',
    params: {
      tessedit_char_whitelist: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789<',
      tessedit_pageseg_mode: '6',
    },
  },
};

const workers = {};

/** Chaque moteur est chargé une seule fois, au premier besoin. */
function workerFor(engine) {
  workers[engine] ??= (async () => {
    const { lang, params = {} } = ENGINES[engine];
    const require = createRequire(import.meta.url);
    const langPath = join(
      dirname(require.resolve(`@tesseract.js-data/${lang}/package.json`)),
      '4.0.0',
    );
    const worker = await createWorker(lang, 1, {
      langPath,
      gzip: true,
      cacheMethod: 'none',
    });
    await worker.setParameters({ user_defined_dpi: '300', ...params });
    return worker;
  })().catch((err) => {
    delete workers[engine];
    throw err;
  });
  return workers[engine];
}

/** MRZ : bas de la page photo (à partir de `from`), agrandi et binarisé. */
async function mrzImage(upright, from) {
  const { width, height } = await sharp(upright).metadata();
  const top = Math.round(height * from);
  return sharp(upright)
    .extract({ left: 0, top, width, height: height - top })
    .greyscale()
    .resize({ width: 2000 })
    .normalise()
    .threshold(140)
    .png()
    .toBuffer();
}

async function recognize(lang, image) {
  const worker = await workerFor(lang);
  const { data } = await worker.recognize(image);
  return data.text ?? '';
}

/** Image en niveaux de gris, agrandie et contrastée : l'OCR lit mieux. */
const prepare = (buffer) =>
  sharp(buffer)
    .greyscale()
    .resize({ width: 1600 })
    .normalise()
    .png()
    .toBuffer();

// ---------------------------------------------------------------------------
// Zone de lecture automatique (MRZ) du passeport, format TD3 : 2 × 44 signes.

const MRZ_WEIGHTS = [7, 3, 1];

function mrzValue(char) {
  if (char === '<') return 0;
  if (/\d/.test(char)) return Number(char);
  return char.charCodeAt(0) - 55; // A = 10
}

/** Chiffre de contrôle d'un champ de la MRZ (norme OACI 9303). */
export function mrzCheckDigit(field) {
  let sum = 0;
  for (let i = 0; i < field.length; i++) {
    sum += mrzValue(field[i]) * MRZ_WEIGHTS[i % 3];
  }
  return String(sum % 10);
}

/** AAMMJJ vers AAAA-MM-JJ. `past` : une naissance n'est pas dans le futur. */
function mrzDate(value, past) {
  if (!/^\d{6}$/.test(value)) return null;
  const yy = Number(value.slice(0, 2));
  const now = new Date().getFullYear() % 100;
  const century = past && yy > now ? 1900 : 2000;
  return `${century + yy}-${value.slice(2, 4)}-${value.slice(4, 6)}`;
}

const mrzName = (value) =>
  value.replaceAll('<', ' ').replace(/\s+/g, ' ').trim();

// Confusions classiques de l'OCR entre chiffres et lettres.
const LOOKALIKES = { 0: 'OQD', 1: 'I', 2: 'Z', 5: 'S', 6: 'G', 8: 'B', O: '0', I: '1', Z: '2', S: '5', B: '8' };

/**
 * Lectures possibles du numéro : telle quelle si le chiffre de contrôle est
 * bon, sinon celles qui le deviennent en corrigeant un seul signe confondu.
 * Le numéro saisi par l'utilisateur doit être l'une d'elles.
 */
export function mrzNumberCandidates(field, check) {
  if (mrzCheckDigit(field) === check) return [field.replaceAll('<', '')];
  const found = new Set();
  for (let i = 0; i < field.length; i++) {
    for (const swap of LOOKALIKES[field[i]] ?? '') {
      const fixed = field.slice(0, i) + swap + field.slice(i + 1);
      if (mrzCheckDigit(fixed) === check) found.add(fixed.replaceAll('<', ''));
    }
  }
  return [...found];
}

/** Lit la MRZ d'un passeport dans le texte reconnu. Un champ dont le
 * chiffre de contrôle est faux vaut null. */
export function parseMrz(text) {
  const lines = text
    .toUpperCase()
    .split('\n')
    .map((line) => line.replace(/\s/g, '').replace(/[«‹]/g, '<'))
    .filter((line) => line.length >= 30 && line.includes('<'));
  const first = lines.findIndex((line) => line.startsWith('P'));
  if (first === -1 || !lines[first + 1]) return null;
  const line1 = lines[first].padEnd(44, '<');
  // Ligne 2 recalée sur le bloc naissance + sexe + expiration (position 13),
  // si l'OCR a ajouté ou perdu un signe au début.
  let line2 = lines[first + 1];
  const dates = line2.match(/\d{7}[MFX<]\d{7}/);
  if (dates && dates.index !== 13) {
    const shift = dates.index - 13;
    line2 = shift > 0 ? line2.slice(shift) : '<'.repeat(-shift) + line2;
  }
  line2 = line2.padEnd(44, '<');

  const [surname, given = ''] = line1.slice(5).split('<<');
  const candidates = mrzNumberCandidates(line2.slice(0, 9), line2[9]);
  const birth = line2.slice(13, 19);
  const expiry = line2.slice(21, 27);
  return {
    number: candidates.length === 1 ? candidates[0] : null,
    numberCandidates: candidates,
    // Ligne des noms brute : les « < » mal lus (K, L) n'empêchent pas d'y
    // retrouver le nom du compte.
    nameLine: line1.slice(5),
    lastName: mrzName(surname) || null,
    firstName: mrzName(given) || null,
    birthDate: mrzCheckDigit(birth) === line2[19] ? mrzDate(birth, true) : null,
    expiresAt:
      mrzCheckDigit(expiry) === line2[27] ? mrzDate(expiry, false) : null,
  };
}

// ---------------------------------------------------------------------------
// Numéros de la CIN et du permis, imprimés en chiffres latins.

/** CIN : 8 chiffres d'un seul tenant. */
export function parseCinNumber(text) {
  return text.match(/(?<!\d)\d{8}(?!\d)/)?.[0] ?? null;
}

// Dates des permis : « 15/06/2015 » (JJ/MM/AAAA) ou « 2017-08-18 » (AAAA-MM-JJ,
// carte de 2017).
const DATE = /(?<!\d)(\d{2})[./-](\d{2})[./-]((?:19|20)\d{2})(?!\d)/g;
const ISO_DATE = /(?<!\d)((?:19|20)\d{2})[./-](\d{2})[./-](\d{2})(?!\d)/g;

/** Toutes les dates du texte, au format AAAA-MM-JJ, valides seulement. */
function datesIn(text) {
  return [
    ...[...text.matchAll(DATE)].map(([, d, m, y]) => `${y}-${m}-${d}`),
    ...[...text.matchAll(ISO_DATE)].map(([, y, m, d]) => `${y}-${m}-${d}`),
  ].filter((d) => {
    const month = Number(d.slice(5, 7));
    const day = Number(d.slice(8, 10));
    return month >= 1 && month <= 12 && day >= 1 && day <= 31;
  });
}

/** Permis tunisien : « 12/345678 » (avec ou sans espaces), sinon le numéro
 * de la case 5 du modèle international (2023), sinon 6, 7, 9 ou 10 chiffres.
 * Jamais 8 chiffres seuls : c'est la forme du numéro de CIN, imprimé aussi
 * sur la carte de 2017. Mieux vaut un champ vide qu'un mauvais numéro. */
export function parseLicenseNumber(text) {
  const old = text.match(/(?<!\d)(\d{2})\s*\/\s*(\d{5,8})(?!\d)/);
  if (old) return `${old[1]}/${old[2]}`;
  // Case 5 : un numéro (au moins un chiffre), pas une ville.
  const field5 = text.match(/(?:^|\s)5\s*[.:]\s*([A-Z0-9]*\d[A-Z0-9]*)\b/m);
  if (field5 && field5[1].length >= 6) return field5[1];
  const withoutDates = text.replace(DATE, ' ').replace(ISO_DATE, ' ');
  return (
    [...withoutDates.matchAll(/(?<!\d)\d{6,10}(?!\d)/g)]
      .map((m) => m[0])
      .find((digits) => digits.length !== 8) ?? null
  );
}

// Mots imprimés sur toutes les cartes, jamais un nom.
const LICENSE_WORDS = new Set([
  'REPUBLIQUE', 'TUNISIENNE', 'PERMIS', 'CONDUIRE', 'DRIVING', 'LICENCE',
  'LICENSE', 'TUNISIA', 'TUNISIE',
]);

/**
 * Titulaire du permis (carte de 2017) : nom (case 3), prénom (case 4), en
 * lettres latines. Si les numéros de case ne sont pas lus, les deux lignes
 * en majuscules juste avant celle du lieu de naissance (qui porte une date).
 * Les lignes de légende, en minuscules, sont écartées.
 */
export function parseLicenseHolder(text) {
  const upperWords = (line) =>
    (line.match(/\b[A-Z][A-Z'-]{2,}\b/g) ?? []).filter(
      (word) => !LICENSE_WORDS.has(word),
    );
  const labelled = (field) =>
    text
      .match(new RegExp(`(?:^|\\s)${field}\\s*[.,:]\\s*([A-Z][A-Z' -]{2,40})`, 'm'))?.[1]
      .trim()
      .split(/\s{2,}/)[0] ?? null;
  let lastName = labelled(3);
  let firstName = labelled(4);
  if (!lastName || !firstName) {
    const lines = text
      .split('\n')
      .filter((line) => !/[a-zé]{4,}/.test(line) && upperWords(line).length);
    const place = lines.findIndex((line) => datesIn(line).length);
    const names = lines
      .slice(0, place === -1 ? lines.length : place)
      .map((line) => upperWords(line).join(' '));
    lastName ??= names.at(-2) ?? null;
    firstName ??= names.at(-1) ?? null;
  }
  return { lastName, firstName };
}

// Catégories du permis tunisien (décret 2021-510), dans l'ordre officiel.
export const LICENSE_CATEGORIES = ['A1', 'A', 'B', 'B+E', 'C', 'C+E', 'D', 'D1', 'D+E', 'H'];

/** Catégories lues : codes seuls sur la carte (« BE » ou « B+E » = B+E).
 * De préférence dans les lignes du tableau, qui en portent plusieurs. */
export function parseLicenseCategories(text) {
  // Majuscules seulement : « de » (dans « Date de délivrance ») n'est pas D+E.
  const codeOf = (token) => {
    const code = token.replace(/^([BCD])\+?E$/, '$1+E');
    return LICENSE_CATEGORIES.includes(code) ? code : null;
  };
  const codesIn = (line) =>
    line
      .split(/[\s|,;:()[\]]+/)
      .map(codeOf)
      .filter(Boolean);
  // Seulement les lignes du tableau des catégories, qui en portent au moins
  // deux : un mot isolé (« PERMIS DE CONDUIRE ») ne compte pas.
  const table = text
    .split('\n')
    .map(codesIn)
    .filter((codes) => codes.length >= 2)
    .flat();
  const found = new Set(table);
  return LICENSE_CATEGORIES.filter((code) => found.has(code));
}

/**
 * Dates du permis. Cases 4a ou 2 (délivrance) et 4b (expiration) si l'IA les
 * trouve ; sinon : la plus ancienne est la naissance, la plus récente avant
 * aujourd'hui la délivrance, une date future l'expiration.
 */
export function parseLicenseDates(text, today = new Date().toISOString().slice(0, 10)) {
  const labelled = (label) => {
    const after = text.match(
      new RegExp(`(?:^|\\s)${label}\\s*[.:]\\s*([0-9./ -]{10,12})`, 'im'),
    );
    return after ? (datesIn(after[1])[0] ?? null) : null;
  };
  const dates = datesIn(text).sort();
  const past = dates.filter((d) => d <= today);
  return {
    birthDate: past.length > 1 ? past[0] : null,
    // Case 4a (modèle international) ou 2 (carte de 2017).
    issuedAt: labelled('4a') ?? labelled('2') ?? past.at(-1) ?? null,
    expiresAt: labelled('4b') ?? dates.find((d) => d > today) ?? null,
  };
}

// ---------------------------------------------------------------------------
// CIN : champs en arabe, à droite de la photo.

const MONTHS = [
  'جانفي',
  'فيفري',
  'مارس',
  'افريل',
  'ماي',
  'جوان',
  'جويلية',
  'اوت',
  'سبتمبر',
  'اكتوبر',
  'نوفمبر',
  'ديسمبر',
];

/** Lettres arabes ramenées à une forme simple : أ إ آ → ا, ى → ي, ة → ه. */
const simplify = (word) =>
  word
    .replace(/[ً-ْـ]/g, '')
    .replace(/[أإآ]/g, 'ا')
    .replace(/ى/g, 'ي')
    .replace(/ة/g, 'ه');

/** Distance d'édition (Levenshtein) entre deux mots. */
function distance(a, b) {
  const row = Array.from({ length: b.length + 1 }, (_, i) => i);
  for (let i = 1; i <= a.length; i++) {
    let previous = row[0];
    row[0] = i;
    for (let j = 1; j <= b.length; j++) {
      const saved = row[j];
      row[j] = Math.min(
        row[j] + 1,
        row[j - 1] + 1,
        previous + (a[i - 1] === b[j - 1] ? 0 : 1),
      );
      previous = saved;
    }
  }
  return row[b.length];
}

/** « 12 مارس 1999 » → 1999-03-12. Le mois est reconnu même mal lu (اقريل pour افريل). */
export function parseArabicDate(line) {
  const match = line.match(/(\d{1,2})\s*([؀-ۿ]+)\s*((?:19|20)\d{2})/);
  if (!match) return null;
  const word = simplify(match[2]);
  let best = -1;
  let bestDistance = 3;
  MONTHS.forEach((month, index) => {
    const d = distance(word, month);
    if (d < bestDistance) [best, bestDistance] = [index, d];
  });
  const day = Number(match[1]);
  if (best === -1 || day < 1 || day > 31) return null;
  const pad = (n) => String(n).padStart(2, '0');
  return `${match[3]}-${pad(best + 1)}-${pad(day)}`;
}

/** Libellés imprimés sur la carte, dont l'OCR garde parfois un morceau. */
const LABELS = ['اللقب', 'الاسم', 'تاريخ', 'الولاده', 'مكانها'];

const isLabel = (word) => {
  const w = simplify(word);
  return LABELS.some(
    (label) => distance(w, label) <= 1 || (w.length >= 3 && label.includes(w)),
  );
};

/** Mots arabes d'une ligne, sans les restes de libellés. */
const arabicWords = (line) =>
  (line.match(/[؀-ۿ]+/g) ?? []).filter(
    (w) => w.length > 2 && !isLabel(w),
  );

// Premiers mots des lieux en deux mots : سيدي بوزيد، بن عروس، منزل بورقيبة…
const PLACE_PREFIXES = ['سيدي', 'بن', 'منزل', 'حمام', 'راس', 'قصر', 'برج', 'جبل', 'وادي', 'بئر', 'بير'];

/** Lieu de naissance : le dernier mot, avec son préfixe s'il en a un. Les
 * restes du libellé « مكانها » restent devant. */
function placeOf(line) {
  const words = (line.match(/[؀-ۿ]+/g) ?? []).filter(
    (w) => w.length > 1,
  );
  const last = words.at(-1);
  if (!last) return null;
  const before = words.at(-2);
  return before && PLACE_PREFIXES.includes(simplify(before))
    ? `${before} ${last}`
    : last;
}

const PARENT = /(^|\s)بن\s/;

/**
 * Ordre des lignes sur la CIN : nom, prénom, filiation (« بن … »), date et
 * lieu de naissance. La filiation et la date servent de repères.
 */
export function parseCinFields(text) {
  const lines = text
    .split('\n')
    .map((line) => line.trim())
    .filter((line) => /[؀-ۿ]{2}/.test(line));
  const dateIndex = lines.findIndex((line) => parseArabicDate(line));
  const parentIndex = lines.findIndex((line) => PARENT.test(line));
  const end = parentIndex === -1 ? dateIndex : parentIndex;
  const names = lines
    .slice(0, end === -1 ? lines.length : end)
    .map(arabicWords)
    .filter((words) => words.length);
  const parentLine = lines[parentIndex] ?? '';
  const place = dateIndex === -1 ? null : placeOf(lines[dateIndex + 1] ?? '');
  return {
    lastNameAr: names.at(-2)?.join(' ') ?? null,
    firstNameAr: names.at(-1)?.join(' ') ?? null,
    parentsAr:
      parentIndex === -1
        ? null
        : parentLine.slice(parentLine.search(PARENT)).trim(),
    birthDate: dateIndex === -1 ? null : parseArabicDate(lines[dateIndex]),
    birthPlaceAr: place,
  };
}

/**
 * Zone des champs, repérée par la photo : à droite du visage, de son haut
 * jusqu'au bas de la carte. Seule l'encre sombre est gardée, ce qui efface
 * les libellés violets (اللقب، الاسم…) et le fond guilloché.
 */
async function cinFieldsImage(upright, box) {
  const { width, height } = await sharp(upright).metadata();
  const left = Math.min(0.95, box.x + box.width * 2);
  const top = Math.max(0, box.y - box.height * 0.05);
  const right = Math.min(1, box.x + box.width * 5.8);
  const bottom = Math.min(1, box.y + box.height * 1.35);
  const region = {
    left: Math.round(left * width),
    top: Math.round(top * height),
    width: Math.max(1, Math.round((right - left) * width)),
    height: Math.max(1, Math.round((bottom - top) * height)),
  };
  const { data, info } = await sharp(upright)
    .extract(region)
    .resize({ width: 1800 })
    .removeAlpha()
    .raw()
    .toBuffer({ resolveWithObject: true });
  const ink = Buffer.alloc(info.width * info.height);
  for (let i = 0, j = 0; i < data.length; i += info.channels, j++) {
    ink[j] = Math.max(data[i], data[i + 1], data[i + 2]) < 130 ? 0 : 255;
  }
  return sharp(ink, {
    raw: { width: info.width, height: info.height, channels: 1 },
  })
    .median(3)
    .png()
    .toBuffer();
}

/** Champs de la MRZ dont le chiffre de contrôle est bon. */
const mrzScore = (mrz) =>
  mrz
    ? Number(mrz.numberCandidates.length > 0) +
      Number(Boolean(mrz.birthDate)) +
      Number(Boolean(mrz.expiresAt))
    : -1;

/**
 * MRZ lue sur plusieurs hauteurs de découpe (la page n'est jamais cadrée
 * pareil) : on garde la lecture où le plus de champs passent le contrôle.
 */
async function readMrz(upright) {
  let best = null;
  for (const from of [0.78, 0.72, 0.84]) {
    const mrz = parseMrz(await recognize('mrz', await mrzImage(upright, from)));
    if (mrzScore(mrz) > mrzScore(best)) best = mrz;
    if (mrzScore(best) === 3) return best;
  }
  return best ?? parseMrz(await recognize('mrz', await prepare(upright)));
}

// ---------------------------------------------------------------------------
// Verso : la CIN y porte un code-barres et la date de délivrance en arabe.

/**
 * Code-barres : une bande où chaque ligne de pixels alterne souvent entre
 * noir et blanc, et où les lignes successives sont identiques (barres
 * verticales). Un texte alterne aussi, mais change d'une ligne à l'autre.
 */
export async function hasBarcode(upright) {
  // Photo prise en paysage ou en portrait : les barres sont verticales dans
  // l'un des deux sens.
  for (const angle of [0, 90]) {
    const { data, info } = await sharp(upright)
      .rotate(angle)
      .greyscale()
      .resize({ width: 900 })
      .normalise()
      .raw()
      .toBuffer({ resolveWithObject: true });
    if (stripedBand(data, info.width, info.height)) return true;
  }
  return false;
}

/** Bande de barres verticales. Seuil de noir propre à chaque ligne, pour
 * résister aux ombres et aux reflets d'une photo prise au téléphone. */
function stripedBand(data, width, height) {
  const from = Math.round(width * 0.05);
  const to = Math.round(width * 0.95);
  const row = (y) => {
    let sum = 0;
    for (let x = from; x < to; x++) sum += data[y * width + x];
    const mean = sum / (to - from);
    const bits = new Uint8Array(to - from);
    for (let x = from; x < to; x++) {
      bits[x - from] = data[y * width + x] < mean ? 1 : 0;
    }
    return bits;
  };
  const transitions = (bits) => {
    let count = 0;
    for (let i = 1; i < bits.length; i++) if (bits[i] !== bits[i - 1]) count++;
    return count;
  };
  const step = Math.max(1, Math.round(height / 300));
  let band = 0;
  let best = 0;
  for (let y = 0; y + step < height; y += step) {
    const a = row(y);
    const b = row(y + step);
    let same = 0;
    for (let i = 0; i < a.length; i++) if (a[i] === b[i]) same++;
    const striped = transitions(a) >= 50 && same / a.length > 0.9;
    band = striped ? band + step : 0;
    best = Math.max(best, band);
  }
  // Barres sur au moins 5 % de la hauteur (réglé sur des photos de téléphone).
  return best >= height * 0.05;
}

/** Date de délivrance au verso : « تونس في 24 جوان 2022 », en encre sombre. */
async function backIssueDate(upright) {
  const { data, info } = await sharp(upright)
    .resize({ width: 1800 })
    .removeAlpha()
    .raw()
    .toBuffer({ resolveWithObject: true });
  const ink = Buffer.alloc(info.width * info.height);
  for (let i = 0, j = 0; i < data.length; i += info.channels, j++) {
    ink[j] = Math.max(data[i], data[i + 1], data[i + 2]) < 130 ? 0 : 255;
  }
  const image = await sharp(ink, {
    raw: { width: info.width, height: info.height, channels: 1 },
  })
    .median(3)
    .png()
    .toBuffer();
  const lines = (await recognize('ara', image)).split('\n');
  for (const line of lines) {
    const date = parseArabicDate(line);
    if (date) return date;
  }
  return null;
}

export const documentReader = {
  /**
   * Reconnaît un verso. CIN : code-barres (et date de délivrance lue en
   * plus). Permis : catégories ou dates. `recognized` vaut false sinon.
   */
  async readBack(buffer, documentType) {
    const upright = await sharp(buffer).rotate().toBuffer();
    if (documentType === 'LICENSE') {
      const text = await recognize('eng', await prepare(upright));
      const categories = parseLicenseCategories(text);
      const dates = parseLicenseDates(text);
      return {
        recognized: categories.length > 0 || Boolean(dates.issuedAt),
        categories,
      };
    }
    // Code-barres ou date de délivrance (« تونس في … ») : l'un des deux
    // suffit. Un recto, qui porte aussi une date, est déjà écarté par son
    // visage.
    const barcode = await hasBarcode(upright);
    const issuedAt = await backIssueDate(upright);
    return { recognized: barcode || Boolean(issuedAt), barcode, issuedAt };
  },

  /**
   * Lit le recto d'une pièce : le numéro, et selon la pièce le nom, la
   * filiation et la naissance (CIN, en arabe) ou toute la MRZ (passeport).
   * `box` : cadre du visage trouvé par l'IA, qui situe les champs de la CIN ;
   * `rotation` : angle qui remet la pièce à l'endroit (photo de travers).
   * Un champ illisible vaut null.
   */
  async read(buffer, documentType, { box, rotation = 0 } = {}) {
    // EXIF, puis le sens où l'IA a trouvé le visage à l'endroit.
    const exif = await sharp(buffer).rotate().toBuffer();
    const upright = rotation
      ? await sharp(exif).rotate(rotation).toBuffer()
      : exif;
    if (documentType === 'PASSPORT') {
      return { type: documentType, ...((await readMrz(upright)) ?? { number: null }) };
    }
    const text = await recognize('eng', await prepare(upright));
    if (documentType === 'LICENSE') {
      // Le numéro de CIN (case 6 de la carte de 2017) est une suite de
      // 8 chiffres ; le numéro du permis, lui, porte une barre.
      const withoutNumber = text.replace(/\d{2}\s*\/\s*\d{5,8}/g, ' ');
      return {
        type: documentType,
        number: parseLicenseNumber(text),
        categories: parseLicenseCategories(text),
        ...parseLicenseDates(text),
        ...parseLicenseHolder(text),
        cinNumber: parseCinNumber(withoutNumber.replace(ISO_DATE, ' ')),
      };
    }
    const fields = box
      ? parseCinFields(
          await recognize('ara', await cinFieldsImage(upright, box)),
        )
      : {};
    return { type: documentType, number: parseCinNumber(text), ...fields };
  },
};

const lettersOf = (value) =>
  value
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toUpperCase()
    .replace(/[^A-Z]/g, '');

/** Le nom du compte figure-t-il dans la ligne des noms de la MRZ ? */
export function nameInMrz(nameLine, name) {
  const wanted = lettersOf(name ?? '');
  return wanted.length > 1 && lettersOf(nameLine ?? '').includes(wanted);
}

// ---------------------------------------------------------------------------
// Nom en arabe (CIN) comparé au nom du compte, en lettres latines.
//
// Les voyelles s'écrivent de mille façons (Trabelsi, Trablsi, Tarabelsi) : on
// compare le « squelette » des consonnes. الطرابلسي → TRBLS, Trabelsi → TRBLS.

const ARABIC_CONSONANTS = {
  ب: 'B', ت: 'T', ث: 'T', ج: 'J', ح: 'H', خ: 'K', د: 'D', ذ: 'D', ر: 'R',
  ز: 'Z', س: 'S', ش: 'C', ص: 'S', ض: 'D', ط: 'T', ظ: 'Z', غ: 'G', ف: 'F',
  ق: 'K', ك: 'K', ل: 'L', م: 'M', ن: 'N', ه: 'H',
};

const collapse = (value) => value.replace(/(.)\1+/g, '$1');

/** Squelette d'un nom arabe, sans l'article « ال » des noms de famille. */
export function arabicSkeleton(name) {
  return collapse(
    (name ?? '')
      .split(/\s+/)
      .map((word) => word.replace(/^ال/, ''))
      .join('')
      .split('')
      .map((char) => ARABIC_CONSONANTS[char] ?? '')
      .join(''),
  );
}

/** Squelette d'un nom écrit en lettres latines (transcription française). */
export function latinSkeleton(name) {
  return collapse(
    lettersOf(name ?? '')
      .replace(/^(EL|AL)(?=[A-Z]{3})/, '')
      .replace(/DJ/g, 'J')
      .replace(/CH|SH/g, '%')
      .replace(/KH/g, 'K')
      .replace(/GH/g, 'G')
      .replace(/TH/g, 'T')
      .replace(/C(?=[EI])/g, 'S')
      .replace(/Q|C/g, 'K')
      .replace(/%/g, 'C')
      .replace(/[AEIOUYW]/g, ''),
  );
}

/**
 * Le nom arabe lu sur la CIN correspond-il au nom du compte ? Une lettre de
 * différence est tolérée sur un nom d'au moins 4 consonnes (OCR,
 * transcription). null si rien à comparer.
 */
export function arabicMatchesLatin(arabic, latin) {
  const a = arabicSkeleton(arabic);
  const b = latinSkeleton(latin);
  if (a.length < 2 || b.length < 2) return null;
  const d = distance(a, b);
  if (Math.min(a.length, b.length) >= 4) return d <= 1;
  // Nom court : une lettre en trop ou en moins (OCR) passe, une lettre
  // différente non (HB ≠ HM).
  return d === 0 || (d === 1 && a.length !== b.length);
}

/** Noms comparés sans accents, tirets ni espaces : « Ben-Ali » = « BEN ALI ». */
export function sameName(a, b) {
  const clean = (value) =>
    value
      .normalize('NFD')
      .replace(/[̀-ͯ]/g, '')
      .toUpperCase()
      .replace(/[^A-Z]/g, '');
  return Boolean(a && b) && clean(a) === clean(b);
}
