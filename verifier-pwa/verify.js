/**
 * Mon Constat Digital - Standalone Zero-Dependency Verifier
 * 
 * Verifies ECDSA P-256 JWS tokens directly in the browser using the W3C Web Crypto API.
 * 100% offline - ZERO external dependencies (no jsrsasign, no crypto-js, no npm packages).
 * Data is extracted from window.location.hash to guarantee Zero-Knowledge to the hosting server.
 */

// Clé publique officielle de certification Mon Constat Digital (JWK RFC 7517)
const PUBLIC_JWK = {
  kty: 'EC',
  crv: 'P-256',
  x: 'I2uUaoz0yrFikQur2brl3xSOQLET1qSvhWocDRBcURY',
  y: 'm5XEleDB6JVIqh-AorwOC0kLPEGKa2_agQkvg6rHNZU',
};

// Exemple officiel pré-signé pour démonstration immédiate
const DEMO_JWS = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJtb24tY29uc3RhdC1kaWdpdGFsIiwic3ViIjoiQ09OU1QtMjAyNi05OTIxIiwiaWF0IjoxNzk0MzM5NDAwLCJkYXRhIjp7ImlkIjoiQ09OU1QtMjAyNi05OTIxIiwiYWNjaWRlbnRJZCI6IkFDQy0yMDI2LTQ0MTIiLCJkcml2ZXJBTmFtZSI6IkFobWVkIEJlbiBTYWxhaCIsImRyaXZlckFQbGF0ZSI6IjE0NS1UTi04ODIxIiwiZHJpdmVyQUluc3VyZXIiOiJTVEFSIEFzc3VyYW5jZXMiLCJkcml2ZXJCTmFtZSI6IkthcmltIEphemlyaSIsImRyaXZlckJQbGF0ZSI6IjIxMC1UTi0zMzA0IiwiZHJpdmVyQkluc3VyZXIiOiJHQVQgQXNzdXJhbmNlcyIsInBsYWNlIjoiUm91dGUgZGUgbGEgTWFyc2EsIFR1bmlzIiwib2NjdXJyZWRBdCI6IjIwMjYtMTEtMTBUMTQ6MzA6MDAuMDAwWiIsInNoYTI1Nkhhc2giOiJlM2IwYzQ0Mjk4ZmMxYzE0OWFmYmY0Yzg5OTZmYjkyNDI3YWU0MWU0NjQ5YjkzNGE0OTU5OTFiNzg1MmI4NTUifX0.c7UWyGBefCBmLBQX64hNnR2BP-LEMjsAus6RFMuwvg4hokoMF_N_YaNXB6yHntMbwqXRTFmQTz4DfX5vvaw8rg";

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

/**
 * Vérifie cryptographiquement un JWS (Header.Payload.Signature)
 */
async function verifyJws(jwsString) {
  const parts = jwsString.trim().split('.');
  if (parts.length !== 3) {
    throw new Error("Format JWS invalide. Trois segments attendus (Header.Payload.Signature).");
  }

  const [headerB64, payloadB64, signatureB64] = parts;

  // 1. Décodage structurel
  const header = decodeBase64UrlJson(headerB64);
  const payload = decodeBase64UrlJson(payloadB64);

  if (header.alg !== 'ES256') {
    throw new Error(`Algorithme non supporté : ${header.alg}. Seul ES256 (ECDSA P-256) est admis.`);
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

  return {
    isValid,
    header,
    payload,
    rawHash: payload.data?.sha256Hash || null,
  };
}

/**
 * Rendu de l'interface utilisateur selon le résultat cryptographique
 */
function renderResult(result, errorMsg = null) {
  const resultContainer = document.getElementById('result-area');
  const detailsContainer = document.getElementById('details-area');

  if (errorMsg || !result || !result.isValid) {
    resultContainer.innerHTML = `
      <div class="status-banner invalid">
        <div class="status-icon">✕</div>
        <div class="status-headline">DOCUMENT FALSIFIÉ</div>
        <div class="status-description">
          ${errorMsg || "La signature cryptographique ne correspond pas à l'autorité officielle ou le contenu du constat a été altéré."}
        </div>
      </div>
    `;
    detailsContainer.style.display = 'none';
    return;
  }

  const data = result.payload.data || result.payload;

  resultContainer.innerHTML = `
    <div class="status-banner valid">
      <div class="status-icon">✓</div>
      <div class="status-headline">SCELLÉ & AUTHENTIQUE</div>
      <div class="status-description">
        Certifié inaltérable par l'autorité Mon Constat Digital (ECDSA P-256).
        Vérification locale réussie sans dépendance serveur.
      </div>
    </div>
  `;

  // Formatage de la date
  let formattedDate = data.occurredAt || 'Non spécifiée';
  try {
    if (data.occurredAt) {
      formattedDate = new Date(data.occurredAt).toLocaleString('fr-TN', {
        dateStyle: 'full',
        timeStyle: 'short',
      });
    }
  } catch (_) {}

  // Formatage du hash SHA-256
  const sha = data.sha256Hash || 'N/A';
  let formattedSha = sha;
  if (sha.length === 64) {
    formattedSha = sha.match(/.{1,8}/g).join(' ');
  }

  detailsContainer.style.display = 'block';
  detailsContainer.innerHTML = `
    <!-- Récapitulatif Véhicules A & B -->
    <div class="card">
      <div class="card-title">Véhicules Impliqués</div>
      <div class="vehicles-grid">
        <div class="vehicle-panel vehicle-a">
          <div class="vehicle-tag">
            <span class="vehicle-avatar">A</span>
            Véhicule A
          </div>
          <div class="vehicle-name">${escapeHtml(data.driverAName || 'Conducteur A')}</div>
          <div class="vehicle-plate">${escapeHtml(data.driverAPlate || 'Immatriculation A')}</div>
          <div class="vehicle-insurer">${escapeHtml(data.driverAInsurer || 'Assureur A')}</div>
        </div>

        <div class="vehicle-panel vehicle-b">
          <div class="vehicle-tag">
            <span class="vehicle-avatar">B</span>
            Véhicule B
          </div>
          <div class="vehicle-name">${escapeHtml(data.driverBName || 'Conducteur B')}</div>
          <div class="vehicle-plate">${escapeHtml(data.driverBPlate || 'Immatriculation B')}</div>
          <div class="vehicle-insurer">${escapeHtml(data.driverBInsurer || 'Assureur B')}</div>
        </div>
      </div>
    </div>

    <!-- Détails de l'Accident -->
    <div class="card">
      <div class="card-title">Détails de l'Événement</div>
      <table class="meta-table">
        <tr>
          <td class="label">Lieu certifié</td>
          <td class="value">${escapeHtml(data.place || 'Non renseigné')}</td>
        </tr>
        <tr>
          <td class="label">Date & Heure</td>
          <td class="value">${escapeHtml(formattedDate)}</td>
        </tr>
        <tr>
          <td class="label">Identifiant Constat</td>
          <td class="value" style="font-family: var(--font-mono); font-size: 11px;">
            ${escapeHtml(data.id || data.accidentId || 'N/A')}
          </td>
        </tr>
      </table>
    </div>

    <!-- Empreinte Cryptographique SHA-256 -->
    <div class="crypto-box">
      <div class="crypto-box-header">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
          <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/>
        </svg>
        Empreinte Numérique Certifiée (SHA-256)
      </div>
      <div class="mono-display">${escapeHtml(formattedSha)}</div>
      <div class="crypto-caption">
        Cette empreinte garantit que les déclarations et le document PDF sont rigoureusement identiques à l'exemplaire signé bilatéralement.
      </div>
    </div>
  `;
}

function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

/**
 * Traite le fragment d'URL actuel ou la saisie manuelle
 */
async function processCurrentLocation() {
  const hash = window.location.hash.replace(/^#/, '').trim();
  const manualBox = document.getElementById('manual-box');

  if (!hash) {
    manualBox.style.display = 'block';
    document.getElementById('result-area').innerHTML = `
      <div class="status-banner pending">
        <div class="status-icon">⚡</div>
        <div class="status-headline">En Attente de Données</div>
        <div class="status-description">
          Scannez le QR Code officiel sur le constat ou collez votre jeton cryptographique JWS ci-dessous pour vérification instantanée hors-ligne.
        </div>
      </div>
    `;
    return;
  }

  manualBox.style.display = 'none';
  document.getElementById('result-area').innerHTML = `
    <div class="status-banner pending">
      <div class="status-icon">⏳</div>
      <div class="status-headline">Vérification en Cours...</div>
      <div class="status-description">Calcul de la signature ECDSA P-256 via Web Crypto API...</div>
    </div>
  `;

  try {
    const result = await verifyJws(hash);
    renderResult(result);
  } catch (err) {
    console.error("Échec vérification JWS :", err);
    renderResult(null, err.message);
  }
}

// Initialisation au chargement de la page et lors du changement de hash
window.addEventListener('DOMContentLoaded', () => {
  processCurrentLocation();

  document.getElementById('verify-btn')?.addEventListener('click', () => {
    const rawInput = document.getElementById('manual-token').value.trim();
    if (!rawInput) return;
    let token = rawInput;
    if (token.includes('#')) {
      token = token.split('#')[1];
    }
    window.location.hash = token;
  });

  document.getElementById('demo-btn')?.addEventListener('click', () => {
    window.location.hash = DEMO_JWS;
  });
});

window.addEventListener('hashchange', processCurrentLocation);
