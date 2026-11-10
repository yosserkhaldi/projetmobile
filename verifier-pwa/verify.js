/**
 * Mon Constat Digital - Standalone Zero-Dependency Verifier, QR Scanner & PDF Integrity Checker
 *
 * Verifies ECDSA P-256 JWS tokens and signed PDF (/ByteRange) directly in the browser using the W3C Web Crypto API.
 * 100% client-side - ZERO network calls (CSP connect-src 'none').
 * QR decoding uses native BarcodeDetector when available with local jsQR fallback.
 */

// Clé publique officielle de certification Mon Constat Digital (JWK RFC 7517)
const PUBLIC_JWK = {
  kty: 'EC',
  crv: 'P-256',
  x: 'I2uUaoz0yrFikQur2brl3xSOQLET1qSvhWocDRBcURY',
  y: 'm5XEleDB6JVIqh-AorwOC0kLPEGKa2_agQkvg6rHNZU',
};

// Exemple officiel pré-signé pour démonstration immédiate
const DEMO_JWS =
  'eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJtb24tY29uc3RhdC1kaWdpdGFsIiwic3ViIjoiQ09OU1QtMjAyNi05OTIxIiwiaWF0IjoxNzk0MzM5NDAwLCJkYXRhIjp7ImlkIjoiQ09OU1QtMjAyNi05OTIxIiwiYWNjaWRlbnRJZCI6IkFDQy0yMDI2LTQ0MTIiLCJkcml2ZXJBTmFtZSI6IkFobWVkIEJlbiBTYWxhaCIsImRyaXZlckFQbGF0ZSI6IjE0NS1UTi04ODIxIiwiZHJpdmVyQUluc3VyZXIiOiJTVEFSIEFzc3VyYW5jZXMiLCJkcml2ZXJCTmFtZSI6IkthcmltIEphemlyaSIsImRyaXZlckJQbGF0ZSI6IjIxMC1UTi0zMzA0IiwiZHJpdmVyQkluc3VyZXIiOiJHQVQgQXNzdXJhbmNlcyIsInBsYWNlIjoiUm91dGUgZGUgbGEgTWFyc2EsIFR1bmlzIiwib2NjdXJyZWRBdCI6IjIwMjYtMTEtMTBUMTQ6MzA6MDAuMDAwWiIsInNoYTI1Nkhhc2giOiJlM2IwYzQ0Mjk4ZmMxYzE0OWFmYmY0Yzg5OTZmYjkyNDI3YWU0MWU0NjQ5YjkzNGE0OTU5OTFiNzg1MmI4NTUifX0.c7UWyGBefCBmLBQX64hNnR2BP-LEMjsAus6RFMuwvg4hokoMF_N_YaNXB6yHntMbwqXRTFmQTz4DfX5vvaw8rg';

const JWS_TOKEN_REGEX = /^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/;
const PDF_SIG_FILTER = '/Filter/MonConstat.ECDSA_P256';
const PDF_SIG_HEX_LEN = 128;

let activeStream = null;
let scanFrameTimerId = null;
let scanInFlight = false;
let barcodeDetectorPromise = null;
let currentVerifiedQrData = null;

/**
 * Convertit une chaîne Base64URL en Uint8Array standard
 */
function base64UrlToUint8Array(base64Url) {
  let base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
  while (base64.length % 4) {
    base64 += '=';
  }
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
}

function hexToUint8Array(hex) {
  const bytes = new Uint8Array(hex.length / 2);
  for (let i = 0; i < bytes.length; i++) {
    bytes[i] = Number.parseInt(hex.slice(i * 2, i * 2 + 2), 16);
  }
  return bytes;
}

/**
 * Décode un segment Base64URL en chaîne UTF-8 JSON
 */
function decodeBase64UrlJson(base64Url) {
  const bytes = base64UrlToUint8Array(base64Url);
  const decoded = new TextDecoder().decode(bytes);
  return JSON.parse(decoded);
}

/**
 * Importe la clé publique ECDSA P-256 via l'API Web Crypto
 */
async function getSubtlePublicKey() {
  if (!window.crypto || !window.crypto.subtle) {
    throw new Error(
      'API Web Crypto indisponible : la vérification locale ECDSA nécessite une connexion HTTPS ou localhost.'
    );
  }
  return await window.crypto.subtle.importKey(
    'jwk',
    PUBLIC_JWK,
    {
      name: 'ECDSA',
      namedCurve: 'P-256',
    },
    false,
    ['verify']
  );
}

const OFFICIAL_CIRCUMSTANCES = [
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

function compactB64UrlToHex(value) {
  if (!value || typeof value !== 'string') return null;
  const trimmed = value.trim();
  if (/^[0-9a-fA-F]{64}$/.test(trimmed)) return trimmed.toLowerCase();
  try {
    const bytes = base64UrlToUint8Array(trimmed);
    if (bytes.length === 32) {
      return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
    }
  } catch (_) {}
  return trimmed;
}

function expandCircumstanceEntry(entry) {
  if (typeof entry === 'number' && Number.isInteger(entry) && entry >= 1 && entry <= 17) {
    return OFFICIAL_CIRCUMSTANCES[entry - 1];
  }
  const s = String(entry || '').trim();
  if (/^\d{1,2}$/.test(s)) {
    const num = Number.parseInt(s, 10);
    if (num >= 1 && num <= 17) return OFFICIAL_CIRCUMSTANCES[num - 1];
  }
  return s;
}

function normalizeConstatPayloadData(payload) {
  const raw = payload?.data || payload || {};
  const circARaw = Array.isArray(raw.circumstancesA)
    ? raw.circumstancesA
    : Array.isArray(raw.cA)
      ? raw.cA
      : [];
  const circBRaw = Array.isArray(raw.circumstancesB)
    ? raw.circumstancesB
    : Array.isArray(raw.cB)
      ? raw.cB
      : [];
  return {
    id: raw.id || payload?.sub || null,
    accidentId: raw.accidentId || raw.aId || null,
    driverAName: raw.driverAName || raw.aN || '',
    driverAPlate: raw.driverAPlate || raw.aP || '',
    driverAInsurer: raw.driverAInsurer || raw.aI || '',
    driverBName: raw.driverBName || raw.bN || '',
    driverBPlate: raw.driverBPlate || raw.bP || '',
    driverBInsurer: raw.driverBInsurer || raw.bI || '',
    place: raw.place || raw.pl || '',
    occurredAt: raw.occurredAt || raw.dt || null,
    sha256Hash: raw.sha256Hash || compactB64UrlToHex(raw.sh) || null,
    factsHash: raw.factsHash || compactB64UrlToHex(raw.fh) || null,
    signaturesHash: raw.signaturesHash || compactB64UrlToHex(raw.sg) || null,
    sketchHash: raw.sketchHash || compactB64UrlToHex(raw.sk) || null,
    driverASignedAt: raw.driverASignedAt || raw.sA || null,
    driverBSignedAt: raw.driverBSignedAt || raw.sB || null,
    impactZones: Array.isArray(raw.impactZones)
      ? raw.impactZones
      : Array.isArray(raw.im)
        ? raw.im
        : [],
    circumstancesA: circARaw.map(expandCircumstanceEntry).filter(Boolean),
    circumstancesB: circBRaw.map(expandCircumstanceEntry).filter(Boolean),
    observations: raw.observations || raw.ob || '',
  };
}

/**
 * Vérifie cryptographiquement un JWS (Header.Payload.Signature)
 */
async function verifyJws(jwsString) {
  const parts = jwsString.trim().split('.');
  if (parts.length !== 3) {
    throw new Error(
      'Format JWS invalide. Trois segments attendus (Header.Payload.Signature).'
    );
  }

  const [headerB64, payloadB64, signatureB64] = parts;

  // 1. Décodage structurel
  const header = decodeBase64UrlJson(headerB64);
  const payload = decodeBase64UrlJson(payloadB64);

  if (header.alg !== 'ES256') {
    throw new Error(
      `Algorithme non supporté : ${header.alg}. Seul ES256 (ECDSA P-256) est admis.`
    );
  }

  // 2. Conversion des données de signature
  const signingInput = `${headerB64}.${payloadB64}`;
  const dataBytes = new TextEncoder().encode(signingInput);
  const signatureBytes = base64UrlToUint8Array(signatureB64);

  // 3. Vérification avec window.crypto.subtle
  const cryptoKey = await getSubtlePublicKey();
  const isValid = await window.crypto.subtle.verify(
    {
      name: 'ECDSA',
      hash: { name: 'SHA-256' },
    },
    cryptoKey,
    signatureBytes,
    dataBytes
  );

  const normalizedData = normalizeConstatPayloadData(payload);

  return {
    isValid,
    header,
    payload,
    normalizedData,
    rawHash: normalizedData.sha256Hash || null,
  };
}

function extractParenField(text, fieldName) {
  const escaped = fieldName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const m = text.match(new RegExp(`/${escaped}\\(([^)]*)\\)`));
  return m ? m[1] : null;
}

/**
 * Vérifie cryptographiquement la signature ECDSA P-256 (/ByteRange) d'un fichier PDF
 */
async function verifyPdfBytesInBrowser(bytes) {
  if (
    !(bytes instanceof Uint8Array) ||
    bytes.length < 4 ||
    bytes[0] !== 0x25 ||
    bytes[1] !== 0x50 ||
    bytes[2] !== 0x44 ||
    bytes[3] !== 0x46
  ) {
    return {
      valid: false,
      reason: 'Fichier invalide : ce document n’est pas un fichier PDF valide (%PDF manquant).',
    };
  }

  const tailStart = Math.max(0, bytes.length - 8192);
  const tailText = new TextDecoder('latin1').decode(bytes.subarray(tailStart));
  const filterIdx = tailText.lastIndexOf(PDF_SIG_FILTER);
  if (filterIdx === -1) {
    return {
      valid: false,
      reason:
        'Aucune signature cryptographique ECDSA Mon Constat Digital trouvée : ce PDF a été modifié, réenregistré ou n’est pas officiel.',
    };
  }

  const sigBlock = tailText.slice(filterIdx);
  const brMatch = sigBlock.match(/\/ByteRange\[\s*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*\]/);
  const ctMatch = sigBlock.match(/\/Contents<([0-9a-fA-F]+)>/);
  if (!brMatch || !ctMatch) {
    return {
      valid: false,
      reason: 'Structure de signature PDF (/ByteRange ou /Contents) altérée ou corrompue.',
    };
  }

  const a = Number.parseInt(brMatch[1], 10);
  const b = Number.parseInt(brMatch[2], 10);
  const c = Number.parseInt(brMatch[3], 10);
  const d = Number.parseInt(brMatch[4], 10);
  const sigHex = ctMatch[1];

  if (
    a !== 0 ||
    b <= 0 ||
    c <= b ||
    d <= 0 ||
    c + d !== bytes.length ||
    c - b !== PDF_SIG_HEX_LEN + 2 ||
    sigHex.length !== PDF_SIG_HEX_LEN ||
    bytes[b] !== 0x3c ||
    bytes[c - 1] !== 0x3e
  ) {
    return {
      valid: false,
      reason: 'Document altéré : des octets ont été modifiés ou ajoutés après la signature.',
    };
  }

  const signedBytes = new Uint8Array(b + d);
  signedBytes.set(bytes.subarray(0, b), 0);
  signedBytes.set(bytes.subarray(c, c + d), b);

  const cryptoKey = await getSubtlePublicKey();
  const sigBytes = hexToUint8Array(sigHex);
  const isValid = await window.crypto.subtle.verify(
    {
      name: 'ECDSA',
      hash: { name: 'SHA-256' },
    },
    cryptoKey,
    sigBytes,
    signedBytes
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
      reason:
        'FALSIFICATION DÉTECTÉE : le contenu du PDF (texte, signatures des conducteurs, croquis, photos ou QR) a été modifié après le scellement.',
      metadata,
      byteRange: [a, b, c, d],
    };
  }

  return {
    valid: true,
    reason:
      'Intégrité PDF ECDSA P-256 confirmée : aucun octet du document (textes, signatures A & B, croquis, photos, QR) n’a été altéré.',
    metadata,
    byteRange: [a, b, c, d],
  };
}

/**
 * Extrait un jeton JWS valide depuis le texte brut lu dans un QR Code
 */
function extractJwsFromQrText(rawText) {
  const cleaned = String(rawText || '').trim();
  if (!cleaned) {
    throw new Error('QR Code vide.');
  }

  let candidate = cleaned;
  if (cleaned.includes('#')) {
    try {
      const parsed = new URL(cleaned);
      candidate = parsed.hash.replace(/^#/, '').trim();
    } catch (_) {
      candidate = cleaned.slice(cleaned.indexOf('#') + 1).trim();
    }
  }

  if (!JWS_TOKEN_REGEX.test(candidate)) {
    throw new Error(
      'QR Code non reconnu : aucun jeton JWS Mon Constat Digital valide détecté.'
    );
  }

  return candidate;
}

/**
 * Initialise BarcodeDetector si le navigateur supporte qr_code nativement
 */
async function getBarcodeDetector() {
  if (barcodeDetectorPromise) return barcodeDetectorPromise;

  barcodeDetectorPromise = (async () => {
    if (!('BarcodeDetector' in window)) return null;
    try {
      if (typeof window.BarcodeDetector.getSupportedFormats === 'function') {
        const formats = await window.BarcodeDetector.getSupportedFormats();
        if (!formats.includes('qr_code')) return null;
      }
      return new window.BarcodeDetector({ formats: ['qr_code'] });
    } catch (_) {
      return null;
    }
  })();

  return barcodeDetectorPromise;
}

/**
 * Décode un QR Code depuis un élément canvas (BarcodeDetector puis fallback jsQR)
 */
async function decodeQrFromCanvas(canvas, ctx) {
  const detector = await getBarcodeDetector();
  if (detector) {
    try {
      const detected = await detector.detect(canvas);
      const match = detected.find((item) => item && item.rawValue);
      if (match) return match.rawValue;
    } catch (_) {
      // Bascule transparente sur jsQR
    }
  }

  if (typeof window.jsQR === 'function') {
    const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    const decoded = window.jsQR(imageData.data, canvas.width, canvas.height, {
      inversionAttempts: 'attemptBoth',
    });
    if (decoded && decoded.data) {
      return decoded.data;
    }
  }

  return null;
}

function setScannerFeedback(message = '', isError = false) {
  const statusEl = document.getElementById('scanner-status');
  if (!statusEl) return;

  if (!message) {
    statusEl.textContent = '';
    statusEl.className = 'scanner-status hidden';
    return;
  }

  statusEl.textContent = message;
  statusEl.className = isError ? 'scanner-status error' : 'scanner-status';
}

function updateScanButtonUi(isScanning) {
  const btn = document.getElementById('start-scan-btn');
  const label = document.getElementById('start-scan-label');
  const stage = document.getElementById('scanner-stage');
  if (!btn || !label || !stage) return;

  if (isScanning) {
    btn.classList.remove('btn-primary');
    btn.classList.add('btn-danger');
    btn.setAttribute('aria-pressed', 'true');
    label.textContent = 'Arrêter la caméra';
    stage.classList.remove('hidden');
  } else {
    btn.classList.remove('btn-danger');
    btn.classList.add('btn-primary');
    btn.setAttribute('aria-pressed', 'false');
    label.textContent = 'Ouvrir la caméra et scanner';
    stage.classList.add('hidden');
  }
}

function stopCameraScan() {
  if (scanFrameTimerId !== null) {
    cancelAnimationFrame(scanFrameTimerId);
    scanFrameTimerId = null;
  }
  scanInFlight = false;

  if (activeStream) {
    for (const track of activeStream.getTracks()) {
      track.stop();
    }
    activeStream = null;
  }

  const video = document.getElementById('qr-video');
  if (video) {
    video.srcObject = null;
  }

  updateScanButtonUi(false);
}

function handleDecodedQrText(rawText) {
  try {
    const token = extractJwsFromQrText(rawText);
    stopCameraScan();
    setScannerFeedback('');
    window.location.hash = token;
    return true;
  } catch (err) {
    setScannerFeedback(err.message, true);
    return false;
  }
}

async function decodeQrRegion(canvas, ctx, source, sx, sy, sw, sh, maxDim) {
  const scale = Math.min(1, maxDim / Math.max(sw, sh));
  const targetW = Math.max(1, Math.round(sw * scale));
  const targetH = Math.max(1, Math.round(sh * scale));
  canvas.width = targetW;
  canvas.height = targetH;
  ctx.fillStyle = '#ffffff';
  ctx.fillRect(0, 0, targetW, targetH);
  ctx.drawImage(source, sx, sy, sw, sh, 0, 0, targetW, targetH);
  return await decodeQrFromCanvas(canvas, ctx);
}

async function startCameraScan() {
  if (activeStream) {
    stopCameraScan();
    setScannerFeedback('');
    return;
  }

  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
    setScannerFeedback(
      'Caméra inaccessible dans ce navigateur (contexte HTTPS requis). Utilisez « Importer une image QR ».',
      true
    );
    return;
  }

  setScannerFeedback('Activation de la caméra...');

  try {
    try {
      activeStream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: { ideal: 'environment' },
          width: { ideal: 1920 },
          height: { ideal: 1080 },
        },
        audio: false,
      });
    } catch (err) {
      if (err && err.name === 'OverconstrainedError') {
        activeStream = await navigator.mediaDevices.getUserMedia({
          video: true,
          audio: false,
        });
      } else {
        throw err;
      }
    }

    const videoTrack = activeStream.getVideoTracks()[0];
    if (videoTrack && typeof videoTrack.applyConstraints === 'function') {
      try {
        await videoTrack.applyConstraints({
          advanced: [{ focusMode: 'continuous' }],
        });
      } catch (_) {
        // Ignoré sur les webcams sans contrôle focusMode
      }
    }

    const video = document.getElementById('qr-video');
    const canvas = document.getElementById('qr-canvas');
    if (!video || !canvas) return;

    video.srcObject = activeStream;
    await video.play();
    updateScanButtonUi(true);
    setScannerFeedback('Cadrez le QR Code du PDF ou de l’écran dans le viseur...');

    const ctx = canvas.getContext('2d', { willReadFrequently: true });
    let lastAttemptAt = 0;

    const tick = async (now) => {
      if (!activeStream) return;

      if (
        !scanInFlight &&
        now - lastAttemptAt >= 140 &&
        video.readyState >= HTMLMediaElement.HAVE_ENOUGH_DATA &&
        video.videoWidth > 0 &&
        video.videoHeight > 0
      ) {
        lastAttemptAt = now;
        scanInFlight = true;
        try {
          const vw = video.videoWidth;
          const vh = video.videoHeight;

          // 1. Capture zoomée du viseur central (indispensable pour les petits QR sur PDF A4)
          const minSide = Math.min(vw, vh);
          const cropSize = Math.round(minSide * 0.62);
          const cropX = Math.max(0, Math.round((vw - cropSize) / 2));
          const cropY = Math.max(0, Math.round((vh - cropSize) / 2));

          let rawValue = await decodeQrRegion(
            canvas,
            ctx,
            video,
            cropX,
            cropY,
            cropSize,
            cropSize,
            1200
          );

          // 2. Fallback sur l'image complète haute résolution
          if (!rawValue) {
            rawValue = await decodeQrRegion(canvas, ctx, video, 0, 0, vw, vh, 1600);
          }

          if (rawValue) {
            const accepted = handleDecodedQrText(rawValue);
            if (accepted) return;
          }
        } catch (err) {
          console.error('Erreur analyse image QR :', err);
        } finally {
          scanInFlight = false;
        }
      }

      if (activeStream) {
        scanFrameTimerId = requestAnimationFrame(tick);
      }
    };

    scanFrameTimerId = requestAnimationFrame(tick);
  } catch (err) {
    stopCameraScan();
    let msg = 'Impossible d’ouvrir la caméra. Utilisez « Importer une image QR ».';
    if (err && (err.name === 'NotAllowedError' || err.name === 'PermissionDeniedError')) {
      msg = 'Accès à la caméra refusé. Autorisez la caméra dans le navigateur ou utilisez « Importer une image QR ».';
    } else if (err && (err.name === 'NotFoundError' || err.name === 'DevicesNotFoundError')) {
      msg = 'Aucune caméra détectée sur cet appareil. Utilisez « Importer une image QR ».';
    } else if (err && err.name === 'NotReadableError') {
      msg = 'Caméra déjà utilisée par une autre application. Fermez-la ou utilisez « Importer une image QR ».';
    }
    setScannerFeedback(msg, true);
  }
}

async function decodeImageSource(file) {
  if (typeof window.createImageBitmap === 'function') {
    return await window.createImageBitmap(file);
  }

  return await new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      const img = new Image();
      img.onload = () => resolve(img);
      img.onerror = () => reject(new Error('Image illisible.'));
      img.src = reader.result;
    };
    reader.onerror = () => reject(new Error('Impossible de lire le fichier image.'));
    reader.readAsDataURL(file);
  });
}

async function handleQrImageUpload(file) {
  if (!file) return;
  stopCameraScan();
  setScannerFeedback('Analyse du QR Code dans l’image...');

  let source = null;
  try {
    source = await decodeImageSource(file);
    const width = source.width || source.naturalWidth;
    const height = source.height || source.naturalHeight;
    if (!width || !height) {
      throw new Error('Dimensions d’image invalides.');
    }

    const canvas = document.getElementById('qr-canvas');
    const ctx = canvas.getContext('2d', { willReadFrequently: true });

    // 1. Image complète en haute résolution (2400px)
    let rawValue = await decodeQrRegion(canvas, ctx, source, 0, 0, width, height, 2400);

    // 2. Fallback sur l'en-tête haut-droite (capture complète de page PDF A4)
    if (!rawValue) {
      rawValue = await decodeQrRegion(
        canvas,
        ctx,
        source,
        Math.round(width * 0.52),
        0,
        Math.round(width * 0.48),
        Math.round(height * 0.36),
        1400
      );
    }

    // 3. Fallback centré
    if (!rawValue) {
      const side = Math.round(Math.min(width, height) * 0.65);
      rawValue = await decodeQrRegion(
        canvas,
        ctx,
        source,
        Math.max(0, Math.round((width - side) / 2)),
        Math.max(0, Math.round((height - side) / 2)),
        side,
        side,
        1400
      );
    }

    if (!rawValue) {
      setScannerFeedback(
        'Aucun QR Code détecté dans cette image. Essayez une capture plus nette ou mieux cadrée.',
        true
      );
      return;
    }

    handleDecodedQrText(rawValue);
  } catch (err) {
    console.error('Échec lecture image QR :', err);
    setScannerFeedback(
      'Impossible de décoder cette image. Choisissez un PNG ou JPEG contenant le QR Code.',
      true
    );
  } finally {
    if (source && typeof source.close === 'function') {
      source.close();
    }
  }
}

/**
 * Helper de création d'éléments DOM sécurisé (Zéro innerHTML = Zéro XSS)
 */
function el(tag, className = null, text = null, children = []) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text !== null && text !== undefined) node.textContent = String(text);
  for (const child of children) {
    if (child) node.appendChild(child);
  }
  return node;
}

function formatDateTimeFr(isoString, fallback = 'Non spécifiée') {
  if (!isoString) return fallback;
  try {
    return new Date(isoString).toLocaleString('fr-TN', {
      dateStyle: 'full',
      timeStyle: 'short',
    });
  } catch (_) {
    return String(isoString);
  }
}

function renderStatusBanner(type, icon, headline, description) {
  return el('div', `status-banner ${type}`, null, [
    el('div', 'status-icon', icon),
    el('div', 'status-headline', headline),
    el('div', 'status-description', description),
  ]);
}

function buildVehiclePanel(panelClass, badgeText, avatarText, name, plate, insurer) {
  return el('div', `vehicle-panel ${panelClass}`, null, [
    el('div', 'vehicle-tag', null, [
      el('span', 'vehicle-avatar', avatarText),
      document.createTextNode(badgeText),
    ]),
    el('div', 'vehicle-name', name),
    el('div', 'vehicle-plate', plate),
    el('div', 'vehicle-insurer', insurer),
  ]);
}

function buildMetaRow(label, value, isMono = false) {
  return el('tr', null, null, [
    el('td', 'label', label),
    el('td', isMono ? 'value mono-value' : 'value', value),
  ]);
}

function buildTagRow(title, items, pillClass = '') {
  return el('div', null, null, [
    el('div', 'detail-section-label', title),
    el(
      'div',
      'tag-list',
      null,
      items.map((item) => el('span', `tag-pill ${pillClass}`.trim(), item))
    ),
  ]);
}

function buildConstatDetailsCards(data) {
  const vehiclesCard = el('div', 'card', null, [
    el('h2', 'card-title', 'Véhicules Impliqués'),
    el('div', 'vehicles-grid', null, [
      buildVehiclePanel(
        'vehicle-a',
        'Véhicule A',
        'A',
        data.driverAName || 'Conducteur A',
        data.driverAPlate || 'Immatriculation A',
        data.driverAInsurer || 'Assureur A'
      ),
      buildVehiclePanel(
        'vehicle-b',
        'Véhicule B',
        'B',
        data.driverBName || 'Conducteur B',
        data.driverBPlate || 'Immatriculation B',
        data.driverBInsurer || 'Assureur B'
      ),
    ]),
  ]);

  const metaRows = [
    buildMetaRow('Lieu certifié', data.place || 'Non renseigné'),
    buildMetaRow('Date & Heure', formatDateTimeFr(data.occurredAt)),
    buildMetaRow('Identifiant Constat', data.id || data.accidentId || 'N/A', true),
  ];
  if (data.driverASignedAt) {
    metaRows.push(buildMetaRow('Signature Conducteur A', formatDateTimeFr(data.driverASignedAt)));
  }
  if (data.driverBSignedAt) {
    metaRows.push(buildMetaRow('Signature Conducteur B', formatDateTimeFr(data.driverBSignedAt)));
  }

  const detailsCard = el('div', 'card', null, [
    el('h2', 'card-title', "Détails de l'Événement & Signatures"),
    el('table', 'meta-table', null, metaRows),
  ]);

  const cards = [vehiclesCard, detailsCard];

  const circA = Array.isArray(data.circumstancesA) ? data.circumstancesA : [];
  const circB = Array.isArray(data.circumstancesB) ? data.circumstancesB : [];
  const impacts = Array.isArray(data.impactZones) ? data.impactZones : [];
  const obs = data.observations ? String(data.observations).trim() : '';

  if (circA.length || circB.length || impacts.length || obs) {
    const circChildren = [el('h2', 'card-title', 'Circonstances, Choc & Observations')];
    if (circA.length) circChildren.push(buildTagRow('Circonstances Conducteur A', circA, 'a'));
    if (circB.length) circChildren.push(buildTagRow('Circonstances Conducteur B', circB, 'b'));
    if (impacts.length) circChildren.push(buildTagRow('Zones de choc', impacts));
    if (obs) {
      circChildren.push(el('div', 'detail-section-label', 'Observations certifiées'));
      circChildren.push(el('div', 'obs-box', obs));
    }
    cards.push(el('div', 'card', null, circChildren));
  }

  return cards;
}

/**
 * Rendu de l'interface utilisateur selon le résultat cryptographique du QR JWS
 */
function renderResult(result, errorMsg = null) {
  const resultContainer = document.getElementById('result-area');
  const detailsContainer = document.getElementById('details-area');
  const postActions = document.getElementById('post-verify-actions');

  postActions?.classList.remove('hidden');

  if (errorMsg || !result || !result.isValid) {
    currentVerifiedQrData = null;
    const safeDesc =
      errorMsg ||
      "La signature cryptographique ne correspond pas à l'autorité officielle ou le contenu du constat a été altéré.";
    resultContainer.replaceChildren(
      renderStatusBanner('invalid', '✕', 'DOCUMENT FALSIFIÉ', safeDesc)
    );
    detailsContainer.classList.add('hidden');
    detailsContainer.replaceChildren();
    return;
  }

  const data = result.normalizedData || normalizeConstatPayloadData(result.payload);
  currentVerifiedQrData = data;

  resultContainer.replaceChildren(
    renderStatusBanner(
      'valid',
      '✓',
      'SCELLÉ & AUTHENTIQUE',
      "Certifié inaltérable par l'autorité Mon Constat Digital (ECDSA P-256). Vérification locale réussie sans dépendance serveur."
    )
  );

  detailsContainer.classList.remove('hidden');
  detailsContainer.replaceChildren(...buildConstatDetailsCards(data));
}

function buildPdfVerificationCard(file, pdfResult) {
  const meta = pdfResult.metadata || {};
  const sizeKb = (file.size / 1024).toFixed(1);
  const rows = [
    buildMetaRow('Fichier analysé', `${file.name} (${sizeKb} Ko)`),
    buildMetaRow('Constat associé', meta.constatId || 'Non renseigné', true),
    buildMetaRow('Horodatage scellement', formatDateTimeFr(meta.signedAt)),
  ];
  if (pdfResult.byteRange) {
    rows.push(
      buildMetaRow(
        'Octets couverts (/ByteRange)',
        `${pdfResult.byteRange[1] + pdfResult.byteRange[3]} / ${file.size} octets`,
        true
      )
    );
  }

  const cardChildren = [
    el('h2', 'card-title', 'Contrôle Cryptographique du Fichier PDF'),
    el('table', 'meta-table', null, rows),
  ];

  return el('div', 'card', null, cardChildren);
}

async function handlePdfUpload(file) {
  if (!file) return;
  stopCameraScan();
  setScannerFeedback('Contrôle cryptographique ECDSA P-256 du fichier PDF...');

  const resultArea = document.getElementById('result-area');
  const detailsArea = document.getElementById('details-area');
  const scannerBox = document.getElementById('scanner-box');
  const postActions = document.getElementById('post-verify-actions');

  try {
    const arrayBuffer = await file.arrayBuffer();
    const bytes = new Uint8Array(arrayBuffer);
    const pdfResult = await verifyPdfBytesInBrowser(bytes);

    setScannerFeedback('');
    scannerBox?.classList.add('hidden');
    postActions?.classList.remove('hidden');

    if (!pdfResult.valid) {
      resultArea?.replaceChildren(
        renderStatusBanner('invalid', '✕', 'PDF MODIFIÉ OU FALSIFIÉ', pdfResult.reason)
      );
      const cards = [buildPdfVerificationCard(file, pdfResult)];
      if (currentVerifiedQrData) {
        cards.push(...buildConstatDetailsCards(currentVerifiedQrData));
      }
      detailsArea?.classList.remove('hidden');
      detailsArea?.replaceChildren(...cards);
      return;
    }

    const pdfConstatId = pdfResult.metadata?.constatId || null;
    const pdfContentSha = pdfResult.metadata?.contentSha256 || null;

    if (currentVerifiedQrData) {
      const idMatches =
        !pdfConstatId ||
        !currentVerifiedQrData.id ||
        pdfConstatId === currentVerifiedQrData.id;
      const shaMatches =
        !pdfContentSha ||
        !currentVerifiedQrData.sha256Hash ||
        pdfContentSha.toLowerCase() === currentVerifiedQrData.sha256Hash.toLowerCase();

      if (!idMatches || !shaMatches) {
        resultArea?.replaceChildren(
          renderStatusBanner(
            'warning',
            '!',
            'PDF AUTHENTIQUE MAIS DIFFÉRENT DU QR CODE',
            `Ce fichier PDF est authentique (${pdfConstatId || 'N/A'}), mais il ne correspond pas au constat du QR code affiché (${currentVerifiedQrData.id || 'N/A'}).`
          )
        );
      } else {
        resultArea?.replaceChildren(
          renderStatusBanner(
            'valid',
            '✓',
            'QR & PDF 100 % AUTHENTIQUES & INTACTS',
            pdfResult.reason
          )
        );
      }
      detailsArea?.classList.remove('hidden');
      detailsArea?.replaceChildren(
        buildPdfVerificationCard(file, pdfResult),
        ...buildConstatDetailsCards(currentVerifiedQrData)
      );
      return;
    }

    resultArea?.replaceChildren(
      renderStatusBanner('valid', '✓', 'PDF AUTHENTIQUE & INTACT', pdfResult.reason)
    );
    detailsArea?.classList.remove('hidden');
    detailsArea?.replaceChildren(buildPdfVerificationCard(file, pdfResult));
  } catch (err) {
    console.error('Échec contrôle PDF :', err);
    setScannerFeedback(err.message || 'Impossible d’analyser ce fichier PDF.', true);
  }
}

/**
 * Traite le fragment d'URL actuel ou affiche le scanner QR + vérificateur PDF
 */
async function processCurrentLocation() {
  const hash = window.location.hash.replace(/^#/, '').trim();
  const scannerBox = document.getElementById('scanner-box');
  const postActions = document.getElementById('post-verify-actions');
  const resultArea = document.getElementById('result-area');
  const detailsArea = document.getElementById('details-area');

  if (!hash) {
    currentVerifiedQrData = null;
    scannerBox?.classList.remove('hidden');
    postActions?.classList.add('hidden');
    detailsArea?.classList.add('hidden');
    detailsArea?.replaceChildren();
    resultArea?.replaceChildren(
      renderStatusBanner(
        'pending',
        '⚡',
        'Prêt pour le Contrôle Hors-Ligne',
        'Scannez le QR Code du constat ou importez directement le fichier PDF pour vérifier son intégrité binaire.'
      )
    );
    return;
  }

  stopCameraScan();
  setScannerFeedback('');
  scannerBox?.classList.add('hidden');
  resultArea?.replaceChildren(
    renderStatusBanner(
      'pending',
      '⏳',
      'Vérification en Cours...',
      'Calcul de la signature ECDSA P-256 via Web Crypto API...'
    )
  );

  try {
    const result = await verifyJws(hash);
    renderResult(result);
  } catch (err) {
    console.error('Échec vérification JWS :', err);
    renderResult(null, err.message);
  }
}

window.addEventListener('DOMContentLoaded', () => {
  processCurrentLocation();

  document.getElementById('start-scan-btn')?.addEventListener('click', startCameraScan);

  const qrFileInput = document.getElementById('qr-file-input');
  document.getElementById('upload-scan-btn')?.addEventListener('click', () => {
    qrFileInput?.click();
  });

  qrFileInput?.addEventListener('change', async (event) => {
    const file = event.target.files?.[0];
    event.target.value = '';
    if (file) {
      await handleQrImageUpload(file);
    }
  });

  const pdfFileInput = document.getElementById('pdf-file-input');
  document.getElementById('verify-pdf-btn')?.addEventListener('click', () => {
    pdfFileInput?.click();
  });
  document.getElementById('post-verify-pdf-btn')?.addEventListener('click', () => {
    pdfFileInput?.click();
  });

  pdfFileInput?.addEventListener('change', async (event) => {
    const file = event.target.files?.[0];
    event.target.value = '';
    if (file) {
      await handlePdfUpload(file);
    }
  });

  document.getElementById('demo-btn')?.addEventListener('click', () => {
    window.location.hash = DEMO_JWS;
  });

  document.getElementById('rescan-btn')?.addEventListener('click', () => {
    stopCameraScan();
    currentVerifiedQrData = null;
    history.replaceState(null, '', window.location.pathname + window.location.search);
    processCurrentLocation();
    startCameraScan();
  });
});

window.addEventListener('hashchange', processCurrentLocation);
window.addEventListener('pagehide', stopCameraScan);
document.addEventListener('visibilitychange', () => {
  if (document.hidden) stopCameraScan();
});
