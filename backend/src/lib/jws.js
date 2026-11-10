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

/**
 * Signe les données brutes canoniques du constat avec ECDSA P-256 (ES256)
 * et génère un jeton JWS compact (Header.Payload.Signature).
 *
 * Évite la boucle de hachage infinie ("Infinite Hash Loop") en signant
 * les données structurelles brutes et non le document PDF binaire lui-même.
 */
export function signConstatJws(facts) {
  const header = {
    alg: 'ES256',
    typ: 'JWT',
  };

  const canonicalPayload = {
    iss: 'mon-constat-digital',
    sub: facts.id || facts.accidentId || 'constat-cert',
    iat: Math.floor(Date.now() / 1000),
    data: {
      id: facts.id,
      accidentId: facts.accidentId || null,
      driverAName: facts.driverAName,
      driverAPlate: facts.driverAPlate,
      driverAInsurer: facts.driverAInsurer,
      driverBName: facts.driverBName,
      driverBPlate: facts.driverBPlate,
      driverBInsurer: facts.driverBInsurer,
      place: facts.place,
      occurredAt: facts.occurredAt,
      sha256Hash: facts.sha256Hash,
    },
  };

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
 * Génère un QR Code haute résolution contenant l'URL de vérification autonome.
 * Le JWS est injecté dans le fragment d'URL (#) pour garantir qu'aucune donnée
 * n'est transmise au serveur lors du chargement de la PWA (Zero-Knowledge).
 */
export async function generateConstatQr(jws, domain = null) {
  const verifierDomain =
    domain ||
    process.env.VERIFIER_DOMAIN ||
    'https://mon-constat-verifier.web.app';

  // Format sécurisé : domaine + fragment hash
  const verifierUrl = `${verifierDomain.replace(/\/$/, '')}/#${jws}`;

  // Génération PNG en Base64 avec les couleurs de la charte (#0B1626)
  const dataUrl = await QRCode.toDataURL(verifierUrl, {
    errorCorrectionLevel: 'M',
    margin: 2,
    width: 320,
    color: {
      dark: '#0B1626',
      light: '#FFFFFF',
    },
  });

  const base64Only = dataUrl.replace(/^data:image\/png;base64,/, '');

  return {
    verifierUrl,
    qrDataUrl: dataUrl,
    qrCodeBase64: base64Only,
  };
}
