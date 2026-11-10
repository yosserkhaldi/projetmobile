import crypto from 'node:crypto';
import { CONSTAT_PUBLIC_JWK, ECDSA_PRIVATE_KEY_PEM } from './jws.js';

export const PDF_SIG_FILTER = '/Filter/MonConstat.ECDSA_P256';
export const PDF_SIG_SUBFILTER = '/SubFilter/MCD.ES256.ByteRange';
const SIG_HEX_LEN = 128; // ECDSA P-256 IEEE-P1363 (64 octets = 128 caractères hex)
const BR_PLACEHOLDER = '         0          0          0          0';

function pad10(num) {
  const s = String(num);
  if (s.length > 10) {
    throw new Error('Document PDF trop volumineux pour /ByteRange.');
  }
  return s.padStart(10, ' ');
}

function sanitizePdfAscii(value, maxLen = 96) {
  return String(value || '')
    .replace(/[^A-Za-z0-9_.:@+/ -]/g, '')
    .trim()
    .slice(0, maxLen);
}

function parsePdfTrailerMeta(buf) {
  const tailStart = Math.max(0, buf.length - 8192);
  const tail = buf.subarray(tailStart).toString('latin1');
  const sxMatches = [...tail.matchAll(/startxref[\r\n]+(\d+)[\r\n]+%%EOF/g)];
  if (sxMatches.length === 0) return null;

  const lastMatch = sxMatches[sxMatches.length - 1];
  const prevStartXref = Number.parseInt(lastMatch[1], 10);
  if (
    !Number.isFinite(prevStartXref) ||
    prevStartXref < 0 ||
    prevStartXref >= buf.length
  ) {
    return null;
  }

  const fromXref = buf
    .subarray(prevStartXref, Math.min(buf.length, prevStartXref + 4096))
    .toString('latin1');
  const dictRegion = fromXref.split('stream')[0];

  const isXRefStream = /\/Type\s*\/XRef\b/.test(dictRegion);
  const trailerSearchText = isXRefStream ? dictRegion : tail;
  const sizeMatch = trailerSearchText.match(/\/Size\s+(\d+)/);
  const rootMatch = trailerSearchText.match(/\/Root\s+(\d+\s+\d+\s+R)/);
  const infoMatch = trailerSearchText.match(/\/Info\s+(\d+\s+\d+\s+R)/);

  if (!sizeMatch || !rootMatch) return null;

  const prevSize = Number.parseInt(sizeMatch[1], 10);
  if (!Number.isFinite(prevSize) || prevSize < 1) return null;

  return {
    prevStartXref,
    isXRefStream,
    prevSize,
    rootRef: rootMatch[1],
    infoRef: infoMatch ? infoMatch[1] : null,
  };
}

function buildSigDict({
  constatId,
  contentSha256,
  signaturesSha256,
  signedAt,
}) {
  const isoDate = (signedAt instanceof Date ? signedAt : new Date(signedAt || Date.now()))
    .toISOString();
  const safeId = sanitizePdfAscii(constatId || 'constat', 80);
  const safeSha = sanitizePdfAscii(contentSha256 || '', 64);
  const safeSigSha = sanitizePdfAscii(signaturesSha256 || '', 64);

  const metaParts = [
    `/Type/Sig`,
    PDF_SIG_FILTER,
    PDF_SIG_SUBFILTER,
    `/ByteRange[${BR_PLACEHOLDER}]`,
    `/Contents<${'0'.repeat(SIG_HEX_LEN)}>`,
    `/M(${sanitizePdfAscii(isoDate, 40)})`,
    safeId ? `/ConstatId(${safeId})` : '',
    safeSha ? `/ContentSha256(${safeSha})` : '',
    safeSigSha ? `/SignaturesSha256(${safeSigSha})` : '',
    `/Reason(Certifie inalterable - Mon Constat Digital ES256)`,
  ].filter(Boolean);

  return `<<${metaParts.join('')}>>`;
}

/**
 * Indique si le buffer PDF contient déjà une signature ECDSA Mon Constat Digital.
 */
export function hasPdfSignature(pdfBuffer) {
  if (!Buffer.isBuffer(pdfBuffer)) return false;
  const tail = pdfBuffer
    .subarray(Math.max(0, pdfBuffer.length - 8192))
    .toString('latin1');
  return tail.includes(PDF_SIG_FILTER) && tail.includes('/ByteRange[');
}

/**
 * Appose une signature cryptographique ECDSA P-256 (/ByteRange) sur le PDF.
 * Utilise une mise à jour incrémentale PDF ISO 32000 lorsque le PDF comporte un XRef
 * valide, ou un bloc trailer signé pour les PDF minimaux de test.
 * Chaque octet hors du slot hexadécimal <Contents> est couvert par la signature.
 */
export function signPdfBuffer(pdfBuffer, meta = {}) {
  const baseBuf = Buffer.isBuffer(pdfBuffer) ? pdfBuffer : Buffer.from(pdfBuffer);
  if (baseBuf.length < 4 || baseBuf.subarray(0, 4).toString('ascii') !== '%PDF') {
    throw new Error('Document PDF invalide (%PDF attendu).');
  }

  const trailerMeta = parsePdfTrailerMeta(baseBuf);
  const needsLeadingNewline =
    baseBuf[baseBuf.length - 1] !== 0x0a && baseBuf[baseBuf.length - 1] !== 0x0d;
  const prefix = needsLeadingNewline ? '\n' : '';
  const appendStart = baseBuf.length;
  const sigDict = buildSigDict(meta);

  let combined;
  if (trailerMeta && trailerMeta.isXRefStream) {
    const sigObjNum = trailerMeta.prevSize;
    const xrefObjNum = sigObjNum + 1;
    const newSize = sigObjNum + 2;

    const sigObjStr = `${prefix}${sigObjNum} 0 obj\n${sigDict}\nendobj\n`;
    const sigOffset = appendStart + Buffer.byteLength(prefix, 'latin1');
    const xrefOffset = appendStart + Buffer.byteLength(sigObjStr, 'latin1');

    const entryFor = (off) =>
      Buffer.from([
        0x01,
        (off >>> 24) & 0xff,
        (off >>> 16) & 0xff,
        (off >>> 8) & 0xff,
        off & 0xff,
        0x00,
      ]);

    const infoEntry = trailerMeta.infoRef ? `/Info ${trailerMeta.infoRef}` : '';
    const xrefHead = Buffer.from(
      `${xrefObjNum} 0 obj\n<</Type/XRef/Size ${newSize}/Index[${sigObjNum} 2]/W[1 4 1]/Prev ${trailerMeta.prevStartXref}/Root ${trailerMeta.rootRef}${infoEntry}/Length 12>>stream\n`,
      'latin1',
    );
    const xrefRows = Buffer.concat([entryFor(sigOffset), entryFor(xrefOffset)]);
    const xrefTail = Buffer.from(
      `\nendstream\nendobj\nstartxref\n${xrefOffset}\n%%EOF\n`,
      'latin1',
    );

    combined = Buffer.concat([
      baseBuf,
      Buffer.from(sigObjStr, 'latin1'),
      xrefHead,
      xrefRows,
      xrefTail,
    ]);
  } else if (trailerMeta && !trailerMeta.isXRefStream) {
    const sigObjNum = trailerMeta.prevSize;
    const newSize = sigObjNum + 1;

    const sigObjStr = `${prefix}${sigObjNum} 0 obj\n${sigDict}\nendobj\n`;
    const sigOffset = appendStart + Buffer.byteLength(prefix, 'latin1');
    const xrefOffset = appendStart + Buffer.byteLength(sigObjStr, 'latin1');

    const entryLine = `${String(sigOffset).padStart(10, '0')} 00000 n \n`;
    const infoEntry = trailerMeta.infoRef ? `/Info ${trailerMeta.infoRef}` : '';
    const xrefStr = `xref\n${sigObjNum} 1\n${entryLine}trailer\n<</Size ${newSize}/Prev ${trailerMeta.prevStartXref}/Root ${trailerMeta.rootRef}${infoEntry}>>\nstartxref\n${xrefOffset}\n%%EOF\n`;

    combined = Buffer.concat([
      baseBuf,
      Buffer.from(sigObjStr + xrefStr, 'latin1'),
    ]);
  } else {
    // Repli pour buffers PDF minimaux (ex. tests unitaires)
    const commentTrailer = `${prefix}%MCD-SIG-V1 ${sigDict}\n%%EOF\n`;
    combined = Buffer.concat([baseBuf, Buffer.from(commentTrailer, 'latin1')]);
  }

  const brMarker = combined.indexOf('/ByteRange[', appendStart);
  const ctMarker = combined.indexOf('/Contents<', appendStart);
  if (brMarker === -1 || ctMarker === -1) {
    throw new Error('Erreur interne construction /ByteRange PDF.');
  }

  const ltPos = ctMarker + '/Contents'.length;
  const hexStart = ltPos + 1;
  const gtPos = hexStart + SIG_HEX_LEN;

  const part1Len = ltPos;
  const part2Start = gtPos + 1;
  const part2Len = combined.length - part2Start;

  const brValue = `${pad10(0)} ${pad10(part1Len)} ${pad10(part2Start)} ${pad10(part2Len)}`;
  if (brValue.length !== BR_PLACEHOLDER.length) {
    throw new Error('Longueur /ByteRange inattendue.');
  }

  Buffer.from(brValue, 'latin1').copy(
    combined,
    brMarker + '/ByteRange['.length,
  );

  const signedPayload = Buffer.concat([
    combined.subarray(0, part1Len),
    combined.subarray(part2Start),
  ]);

  const signature = crypto.sign('SHA256', signedPayload, {
    key: ECDSA_PRIVATE_KEY_PEM,
    dsaEncoding: 'ieee-p1363',
  });

  Buffer.from(signature.toString('hex'), 'latin1').copy(combined, hexStart);

  return combined;
}

function extractParenField(text, fieldName) {
  const escaped = fieldName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const m = text.match(new RegExp(`/${escaped}\\(([^)]*)\\)`));
  return m ? m[1] : null;
}

/**
 * Vérifie cryptographiquement la signature ECDSA P-256 (/ByteRange) d'un PDF.
 * Utilise l'API W3C Web Crypto (identique au vérificateur PWA navigateur).
 */
export async function verifyPdfBuffer(pdfBuffer, publicJwk = CONSTAT_PUBLIC_JWK) {
  const bytes = pdfBuffer instanceof Uint8Array ? pdfBuffer : Buffer.from(pdfBuffer);
  if (
    bytes.length < 4 ||
    bytes[0] !== 0x25 ||
    bytes[1] !== 0x50 ||
    bytes[2] !== 0x44 ||
    bytes[3] !== 0x46
  ) {
    return { valid: false, reason: 'Fichier PDF invalide (en-tête %PDF manquant).' };
  }

  const tailStart = Math.max(0, bytes.length - 8192);
  const tailText = Buffer.from(bytes.subarray(tailStart)).toString('latin1');
  const filterIdx = tailText.lastIndexOf(PDF_SIG_FILTER);
  if (filterIdx === -1) {
    return {
      valid: false,
      reason: 'Aucune signature électronique ECDSA Mon Constat Digital trouvée dans ce PDF.',
    };
  }

  const sigBlock = tailText.slice(filterIdx);
  const brMatch = sigBlock.match(/\/ByteRange\[\s*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*\]/);
  const ctMatch = sigBlock.match(/\/Contents<([0-9a-fA-F]+)>/);
  if (!brMatch || !ctMatch) {
    return { valid: false, reason: 'Structure de signature PDF (/ByteRange ou /Contents) corrompue.' };
  }

  const a = Number.parseInt(brMatch[1], 10);
  const b = Number.parseInt(brMatch[2], 10);
  const c = Number.parseInt(brMatch[3], 10);
  const d = Number.parseInt(brMatch[4], 10);
  const sigHex = ctMatch[1];

  // Garde stricte anti-altération / anti-append
  if (
    a !== 0 ||
    b <= 0 ||
    c <= b ||
    d <= 0 ||
    c + d !== bytes.length ||
    c - b !== SIG_HEX_LEN + 2 ||
    sigHex.length !== SIG_HEX_LEN ||
    bytes[b] !== 0x3c ||
    bytes[c - 1] !== 0x3e
  ) {
    return {
      valid: false,
      reason: 'Plage signée (/ByteRange) invalide ou octets ajoutés après signature.',
    };
  }

  const signedBytes = new Uint8Array(b + d);
  signedBytes.set(bytes.subarray(0, b), 0);
  signedBytes.set(bytes.subarray(c, c + d), b);

  const sigBytes = Buffer.from(sigHex, 'hex');
  const cryptoKey = await crypto.webcrypto.subtle.importKey(
    'jwk',
    publicJwk,
    { name: 'ECDSA', namedCurve: 'P-256' },
    false,
    ['verify'],
  );

  const isValid = await crypto.webcrypto.subtle.verify(
    { name: 'ECDSA', hash: { name: 'SHA-256' } },
    cryptoKey,
    sigBytes,
    signedBytes,
  );

  const metadata = {
    constatId: extractParenField(sigBlock, 'ConstatId'),
    contentSha256: extractParenField(sigBlock, 'ContentSha256'),
    signaturesSha256: extractParenField(sigBlock, 'SignaturesSha256'),
    signedAt: extractParenField(sigBlock, 'M'),
    reason: extractParenField(sigBlock, 'Reason'),
  };

  if (!isValid) {
    return {
      valid: false,
      reason: 'Le contenu du PDF a été modifié ou la signature ECDSA P-256 est falsifiée.',
      metadata,
      byteRange: [a, b, c, d],
    };
  }

  return {
    valid: true,
    reason: 'Signature ECDSA P-256 authentique — aucun octet du PDF n’a été altéré.',
    metadata,
    byteRange: [a, b, c, d],
  };
}
