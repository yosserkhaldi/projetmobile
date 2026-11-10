import crypto from 'node:crypto';
import QRCode from 'qrcode';

// Clé privée serveur ECDSA P-256 (PKCS#8 PEM)
// En production, cette clé peut être surchargée via la variable d'environnement CONSTAT_ECDSA_PRIVATE_KEY
export const ECDSA_PRIVATE_KEY_PEM =
  process.env.CONSTAT_ECDSA_PRIVATE_KEY ||
  `-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgrKBudG9PWF+EsSgE
xB7W6MYXFz9xBA7vP0Z8ky01FY+hRANCAAQja5RqjPTKsWKRC6vZuuXfFI5AsRPW
pK+FahwNEFxRFpuVxJXgweiVSKofgKK8DgtJCzxBimtv2oEJL4OqxzWV
-----END PRIVATE KEY-----`;

// Clé publique officielle correspondante au format standard JWK (RFC 7517)
// Utilisée par le vérificateur PWA statique sans dépendance externe
export const CONSTAT_PUBLIC_JWK = {
  kty: 'EC',
  crv: 'P-256',
  x: 'I2uUaoz0yrFikQur2brl3xSOQLET1qSvhWocDRBcURY',
  y: 'm5XEleDB6JVIqh-AorwOC0kLPEGKa2_agQkvg6rHNZU',
};

function base64url(buf) {
  return Buffer.from(buf).toString('base64url');
}

function stableSortValue(value) {
  if (Array.isArray(value)) return value.map(stableSortValue);
  if (value && typeof value === 'object' && !(value instanceof Date)) {
    const out = {};
    for (const key of Object.keys(value).sort()) {
      out[key] = stableSortValue(value[key]);
    }
    return out;
  }
  return value instanceof Date ? value.toISOString() : value;
}

export function computeCanonicalSha256(value) {
  return crypto
    .createHash('sha256')
    .update(JSON.stringify(stableSortValue(value)))
    .digest('hex');
}

function clipText(value, maxLen) {
  if (value == null) return '';
  const s = String(value).trim();
  if (s.length <= maxLen) return s;
  return `${s.slice(0, Math.max(0, maxLen - 1)).trimEnd()}…`;
}

function toIsoOrNull(value) {
  if (!value) return null;
  if (value instanceof Date) return value.toISOString();
  return String(value);
}

const OFFICIAL_CIRCUMSTANCES_LIST = [
  '1 - En stationnement / À l’arrêt',
  '2 - Quittait un stationnement / ouvrait une portière',
  '3 - Prenait un stationnement',
  '4 - Sortait d’un parking, lieu privé ou chemin',
  '5 - S’engageait dans un parking, lieu privé ou chemin',
  '6 - S’engageait sur une place à sens giratoire',
  '7 - Circulait sur une place à sens giratoire',
  '8 - Heurtait à l’arrière (même sens, même file)',
  '9 - Roulait dans le même sens sur une file différente',
  '10 - Changeait de file',
  '11 - Doublait',
  '12 - Virait à droite',
  '13 - Virait à gauche',
  '14 - Reculait',
  '15 - Empiétait sur la chaussée en sens inverse',
  '16 - Venait de droite (dans un carrefour)',
  '17 - N’avait pas observé un signal de priorité',
];

function hexToCompactB64Url(hex) {
  if (!hex || typeof hex !== 'string') return null;
  const clean = hex.trim().toLowerCase();
  if (!/^[0-9a-f]{64}$/.test(clean)) return clean;
  return Buffer.from(clean, 'hex').toString('base64url');
}

function compactCircumstanceItem(raw) {
  const s = String(raw || '').trim();
  const numMatch = s.match(/^(\d{1,2})\s*[-–.)]/);
  if (numMatch) {
    const idx = Number.parseInt(numMatch[1], 10);
    if (idx >= 1 && idx <= 17) return idx;
  }
  const normalized = s.toLowerCase();
  const foundIdx = OFFICIAL_CIRCUMSTANCES_LIST.findIndex((item) =>
    item.toLowerCase().includes(normalized),
  );
  if (foundIdx !== -1) return foundIdx + 1;
  return clipText(s, 36);
}

/**
 * Signe les données brutes canoniques du constat avec ECDSA P-256 (ES256)
 * et génère un jeton JWS compact (Header.Payload.Signature).
 *
 * Utilise un format canonique compact (v: 2) avec empreintes 256 bits en Base64URL
 * et codes de circonstances FTUSA afin de maintenir le QR Code sous ~93–105 modules
 * pour une lecture caméra instantanée sur écran et sur PDF A4 imprimé.
 */
export function signConstatJws(facts) {
  const header = {
    alg: 'ES256',
    typ: 'JWT',
  };

  const fullCircA = Array.isArray(facts.circumstancesA)
    ? facts.circumstancesA.map((s) => String(s).trim()).filter(Boolean)
    : [];
  const fullCircB = Array.isArray(facts.circumstancesB)
    ? facts.circumstancesB.map((s) => String(s).trim()).filter(Boolean)
    : [];
  const fullImpacts = Array.isArray(facts.impactZones)
    ? facts.impactZones.map((s) => String(s).trim()).filter(Boolean)
    : [];
  const fullObs = facts.observations ? String(facts.observations).trim() : '';
  const signedAtA = toIsoOrNull(facts.driverASignedAt);
  const signedAtB = toIsoOrNull(facts.driverBSignedAt);

  const factsHash = computeCanonicalSha256({
    id: facts.id || null,
    accidentId: facts.accidentId || null,
    driverAName: facts.driverAName,
    driverAPlate: facts.driverAPlate,
    driverAInsurer: facts.driverAInsurer,
    driverBName: facts.driverBName,
    driverBPlate: facts.driverBPlate,
    driverBInsurer: facts.driverBInsurer,
    place: facts.place,
    occurredAt: toIsoOrNull(facts.occurredAt),
    circumstancesA: fullCircA,
    circumstancesB: fullCircB,
    impactZones: fullImpacts,
    observations: fullObs,
    driverASignedAt: signedAtA,
    driverBSignedAt: signedAtB,
  });

  const sketchHash = facts.sketchHash
    ? String(facts.sketchHash).toLowerCase()
    : facts.sketchData !== undefined && facts.sketchData !== null
      ? computeCanonicalSha256(facts.sketchData)
      : null;

  const signaturesHash = facts.signaturesHash
    ? String(facts.signaturesHash).toLowerCase()
    : null;

  const compactCA = fullCircA.map(compactCircumstanceItem);
  const compactCB = fullCircB.map(compactCircumstanceItem);
  const compactImpacts = fullImpacts.slice(0, 4).map((s) => clipText(s, 28));

  const compactData = {
    v: 2,
    ...(facts.accidentId ? { aId: facts.accidentId } : {}),
    aN: clipText(facts.driverAName, 48),
    aP: clipText(facts.driverAPlate, 20),
    aI: clipText(facts.driverAInsurer, 36),
    bN: clipText(facts.driverBName, 48),
    bP: clipText(facts.driverBPlate, 20),
    bI: clipText(facts.driverBInsurer, 36),
    pl: clipText(facts.place, 64),
    dt: toIsoOrNull(facts.occurredAt),
    sh: hexToCompactB64Url(facts.sha256Hash),
    fh: hexToCompactB64Url(factsHash),
    ...(signaturesHash ? { sg: hexToCompactB64Url(signaturesHash) } : {}),
    ...(sketchHash ? { sk: hexToCompactB64Url(sketchHash) } : {}),
    ...(signedAtA ? { sA: signedAtA } : {}),
    ...(signedAtB ? { sB: signedAtB } : {}),
    ...(compactImpacts.length ? { im: compactImpacts } : {}),
    ...(compactCA.length ? { cA: compactCA } : {}),
    ...(compactCB.length ? { cB: compactCB } : {}),
    ...(fullObs ? { ob: clipText(fullObs, 80) } : {}),
  };

  let canonicalPayload = {
    iss: 'mon-constat-digital',
    sub: facts.id || facts.accidentId || 'constat-cert',
    iat: Math.floor(Date.now() / 1000),
    data: compactData,
  };

  // Garde de densité QR : garantit un QR basse densité (<= 600 octets JSON => <= ~960 car. URL)
  if (Buffer.byteLength(JSON.stringify(canonicalPayload), 'utf8') > 600) {
    const trimmed = { ...compactData };
    trimmed.pl = clipText(facts.place, 42);
    if (trimmed.ob) trimmed.ob = clipText(fullObs, 52);
    if (Array.isArray(trimmed.im)) trimmed.im = trimmed.im.slice(0, 2);
    canonicalPayload = { ...canonicalPayload, data: trimmed };
  }
  if (Buffer.byteLength(JSON.stringify(canonicalPayload), 'utf8') > 600) {
    const lean = { ...canonicalPayload.data };
    delete lean.aId;
    delete lean.sA;
    delete lean.sB;
    canonicalPayload = { ...canonicalPayload, data: lean };
  }
  if (Buffer.byteLength(JSON.stringify(canonicalPayload), 'utf8') > 600) {
    const minimal = { ...canonicalPayload.data };
    delete minimal.ob;
    canonicalPayload = { ...canonicalPayload, data: minimal };
  }

  const encodedHeader = base64url(JSON.stringify(header));
  const encodedPayload = base64url(JSON.stringify(canonicalPayload));
  const signingInput = `${encodedHeader}.${encodedPayload}`;

  // Signature ECDSA P-256 avec encodage ieee-p1363 (64 octets : R || S)
  // Requis pour la conformité JWS ES256 (RFC 7518) et Web Crypto API
  const signature = crypto.sign('SHA256', Buffer.from(signingInput), {
    key: ECDSA_PRIVATE_KEY_PEM,
    dsaEncoding: 'ieee-p1363',
  });

  const encodedSignature = base64url(signature);
  const jws = `${signingInput}.${encodedSignature}`;

  return {
    jws,
    payload: canonicalPayload,
  };
}

/**
 * Résout l'URL de base du vérificateur PWA statique.
 * Priorité absolue donnée à la variable d'environnement VERIFIER_BASE_URL.
 * En l'absence de configuration, utilise un repli local de développement
 * tout en émettant un avertissement explicite dans les logs.
 */
export function getVerifierBaseUrl(overrideDomain = null) {
  if (overrideDomain && typeof overrideDomain === 'string' && overrideDomain.trim()) {
    return overrideDomain.trim().replace(/\/+$/, '');
  }

  const envUrl = process.env.VERIFIER_BASE_URL || process.env.VERIFIER_DOMAIN;
  if (envUrl && typeof envUrl === 'string' && envUrl.trim()) {
    return envUrl.trim().replace(/\/+$/, '');
  }

  const port = process.env.PORT || 3000;
  const devFallback = `http://localhost:${port}/verifier`;

  console.warn(
    '\x1b[33m%s\x1b[0m',
    `[SECURITY WARNING] VERIFIER_BASE_URL n'est pas défini dans l'environnement ! Utilisation du fallback développement : "${devFallback}". En production ou lors de la soutenance (scan 4G), définissez impérativement VERIFIER_BASE_URL (ex: https://verif-constat.tn).`
  );

  return devFallback;
}

/**
 * Génère un QR Code haute résolution contenant l'URL de vérification autonome.
 * Le JWS est injecté dans le fragment d'URL (#) pour garantir qu'aucune donnée
 * n'est transmise au serveur lors du chargement de la PWA (Zero-Knowledge).
 *
 * Format strict : ${VERIFIER_BASE_URL}/#[JWS_TOKEN]
 */
export async function generateConstatQr(jws, domain = null) {
  const baseUrl = getVerifierBaseUrl(domain);

  // Format de production strict : ${VERIFIER_BASE_URL}/#[JWS_TOKEN]
  const verifierUrl = `${baseUrl}/#${jws}`;

  // Niveau L pour les URL JWS complètes (> 650 car.) et M sinon : divise par ~3 le
  // nombre de modules pour rendre la lecture caméra instantanée sur PDF et écran.
  // scale: 8 + margin: 4 + noir pur #000000 garantit des pixels entiers sans flou.
  const preferredEcl = verifierUrl.length > 650 ? 'L' : 'M';
  const qrOptions = {
    errorCorrectionLevel: preferredEcl,
    margin: 4,
    scale: 8,
    color: {
      dark: '#000000',
      light: '#FFFFFF',
    },
  };

  let dataUrl;
  try {
    dataUrl = await QRCode.toDataURL(verifierUrl, qrOptions);
  } catch {
    dataUrl = await QRCode.toDataURL(verifierUrl, {
      ...qrOptions,
      errorCorrectionLevel: 'L',
    });
  }

  const base64Only = dataUrl.replace(/^data:image\/png;base64,/, '');

  return {
    verifierUrl,
    qrDataUrl: dataUrl,
    qrCodeBase64: base64Only,
  };
}

