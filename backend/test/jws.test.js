import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import test from 'node:test';
import QRCode from 'qrcode';

import {
  CONSTAT_PUBLIC_JWK,
  computeCanonicalSha256,
  generateConstatQr,
  signConstatJws,
} from '../src/lib/jws.js';
import {
  hasPdfSignature,
  signPdfBuffer,
  verifyPdfBuffer,
} from '../src/lib/pdf-signature.js';

test('génération et signature JWS ECDSA P-256 (ES256)', async () => {
  const facts = {
    id: 'constat-unit-01',
    accidentId: 'acc-unit-01',
    driverAName: 'Ahmed Test',
    driverAPlate: '100-TN-001',
    driverAInsurer: 'Assureur A',
    driverBName: 'Karim Test',
    driverBPlate: '200-TN-002',
    driverBInsurer: 'Assureur B',
    place: 'Tunis Centre',
    occurredAt: '2026-11-10T12:00:00.000Z',
    sha256Hash: 'a'.repeat(64),
  };

  const { jws, payload } = signConstatJws(facts);
  assert.ok(jws, 'Le jeton JWS doit être défini');
  const parts = jws.split('.');
  assert.equal(parts.length, 3, 'Le jeton JWS doit comporter 3 segments');

  // Décodage et vérification de l'en-tête
  const header = JSON.parse(Buffer.from(parts[0], 'base64url').toString('utf8'));
  assert.equal(header.alg, 'ES256');
  assert.equal(header.typ, 'JWT');

  // Décodage du payload canonique compact (v: 2)
  const decodedPayload = JSON.parse(Buffer.from(parts[1], 'base64url').toString('utf8'));
  assert.equal(decodedPayload.sub, 'constat-unit-01');
  assert.equal(decodedPayload.data.v, 2);
  assert.equal(decodedPayload.data.aP, '100-TN-001');
  assert.equal(
    decodedPayload.data.sh,
    Buffer.from('a'.repeat(64), 'hex').toString('base64url'),
  );

  // Vérification cryptographique via Web Crypto API (standard W3C)
  const dataBytes = new TextEncoder().encode(`${parts[0]}.${parts[1]}`);
  const sigBytes = Buffer.from(parts[2], 'base64url');

  const cryptoKey = await crypto.webcrypto.subtle.importKey(
    'jwk',
    CONSTAT_PUBLIC_JWK,
    { name: 'ECDSA', namedCurve: 'P-256' },
    false,
    ['verify'],
  );

  const isValid = await crypto.webcrypto.subtle.verify(
    { name: 'ECDSA', hash: { name: 'SHA-256' } },
    cryptoKey,
    sigBytes,
    dataBytes,
  );
  assert.equal(isValid, true, 'La signature originale doit être valide');

  // Altération des données -> vérification doit échouer
  const tamperedDataBytes = new TextEncoder().encode(
    `${parts[0]}.${Buffer.from('{"tampered":true}').toString('base64url')}`,
  );
  const isTamperedValid = await crypto.webcrypto.subtle.verify(
    { name: 'ECDSA', hash: { name: 'SHA-256' } },
    cryptoKey,
    sigBytes,
    tamperedDataBytes,
  );
  assert.equal(isTamperedValid, false, 'Une donnée altérée doit échouer la vérification');
});

test('génération du QR Code et format strict ${VERIFIER_BASE_URL}/#[JWS_TOKEN]', async () => {
  const dummyJws = 'header.payload.signature';
  
  // Test avec override explicite
  const qr = await generateConstatQr(dummyJws, 'https://verif-constat.tn');
  assert.equal(
    qr.verifierUrl,
    'https://verif-constat.tn/#header.payload.signature',
  );
  assert.ok(qr.qrCodeBase64.length > 50, 'Le QR code en base64 doit être généré');
  assert.ok(qr.qrDataUrl.startsWith('data:image/png;base64,'));

  // Test avec injection de process.env.VERIFIER_BASE_URL
  const oldBase = process.env.VERIFIER_BASE_URL;
  try {
    process.env.VERIFIER_BASE_URL = 'https://mon-constat.vercel.app';
    const envQr = await generateConstatQr(dummyJws);
    assert.equal(
      envQr.verifierUrl,
      'https://mon-constat.vercel.app/#header.payload.signature',
    );
  } finally {
    process.env.VERIFIER_BASE_URL = oldBase;
  }
});

test('scelle toutes les données, signaturesHash, sketchHash et garde de densité QR', async () => {
  const longText = 'Véhicule B a reculé sans visibilité rue Habib Bourguiba '.repeat(25);
  const facts = {
    id: 'constat-full-01',
    accidentId: 'acc-full-01',
    driverAName: 'Sami Ben Ali',
    driverAPlate: '180 TN 4567',
    driverAInsurer: 'STAR',
    driverBName: 'Karim Trabelsi',
    driverBPlate: '210 TN 8901',
    driverBInsurer: 'GAT',
    place: 'Avenue Habib Bourguiba, Tunis',
    occurredAt: '2026-11-10T10:15:00.000Z',
    sha256Hash: 'c'.repeat(64),
    signaturesHash: 'd'.repeat(64),
    circumstancesA: ['1 - En stationnement', '4 - Sortait d’un parking'],
    circumstancesB: ['14 - Reculait', '15 - Empiétait sur la voie opposée', '17 - Refus de priorité', '18 - Autre manœuvre'],
    impactZones: ['Avant gauche', 'Pare-chocs avant', 'Aile droite', 'Phare gauche'],
    observations: longText,
    sketchData: [[{ x: 0.1, y: 0.2 }, { x: 0.8, y: 0.9 }]],
    driverASignedAt: '2026-11-10T10:16:00.000Z',
    driverBSignedAt: '2026-11-10T10:17:00.000Z',
  };

  const { jws, payload } = signConstatJws(facts);
  const b64 = (hex) => Buffer.from(hex, 'hex').toString('base64url');
  assert.equal(payload.sub, 'constat-full-01');
  assert.equal(payload.data.sg, b64('d'.repeat(64)));
  assert.equal(payload.data.sk, b64(computeCanonicalSha256(facts.sketchData)));
  assert.match(payload.data.fh, /^[A-Za-z0-9_-]{43}$/);
  assert.deepEqual(payload.data.cA, [1, 4]);
  assert.ok(Buffer.byteLength(JSON.stringify(payload), 'utf8') <= 600);

  const qr = await generateConstatQr(jws, 'https://verif-constat-digital.vercel.app');
  assert.ok(qr.qrCodeBase64.length > 100);
  const qrMatrix = QRCode.create(qr.verifierUrl, { errorCorrectionLevel: 'L' });
  assert.ok(
    qrMatrix.modules.size <= 105,
    `QR trop dense (${qrMatrix.modules.size} modules) pour un scan PDF fiable`,
  );
});

function buildClassicXrefPdf() {
  const objs = [
    '1 0 obj\n<</Type/Catalog/Pages 2 0 R>>\nendobj\n',
    '2 0 obj\n<</Type/Pages/Count 1/Kids[3 0 R]>>\nendobj\n',
    '3 0 obj\n<</Type/Page/Parent 2 0 R/MediaBox[0 0 200 200]>>\nendobj\n',
  ];
  let out = '%PDF-1.4\n';
  const offsets = [0];
  for (const obj of objs) {
    offsets.push(Buffer.byteLength(out, 'latin1'));
    out += obj;
  }
  const xrefPos = Buffer.byteLength(out, 'latin1');
  out += `xref\n0 ${offsets.length}\n0000000000 65535 f \n`;
  for (let i = 1; i < offsets.length; i++) {
    out += `${String(offsets[i]).padStart(10, '0')} 00000 n \n`;
  }
  out += `trailer\n<</Size ${offsets.length}/Root 1 0 R>>\nstartxref\n${xrefPos}\n%%EOF\n`;
  return Buffer.from(out, 'latin1');
}

function buildXRefStreamPdf() {
  const objs = [
    '1 0 obj\n<</Type/Catalog/Pages 2 0 R>>\nendobj\n',
    '2 0 obj\n<</Type/Pages/Count 1/Kids[3 0 R]>>\nendobj\n',
    '3 0 obj\n<</Type/Page/Parent 2 0 R/MediaBox[0 0 200 200]>>\nendobj\n',
  ];
  let out = Buffer.from('%PDF-1.5\n', 'latin1');
  const offsets = [0];
  for (const o of objs) {
    offsets.push(out.length);
    out = Buffer.concat([out, Buffer.from(o, 'latin1')]);
  }
  const xrefOffset = out.length;
  offsets.push(xrefOffset);
  const entry = (t, off) =>
    Buffer.from([t, (off >>> 24) & 0xff, (off >>> 16) & 0xff, (off >>> 8) & 0xff, off & 0xff, 0]);
  const rows = Buffer.concat([
    entry(0, 0),
    entry(1, offsets[1]),
    entry(1, offsets[2]),
    entry(1, offsets[3]),
    entry(1, offsets[4]),
  ]);
  const head = Buffer.from(
    `4 0 obj\n<</Type/XRef/Size 5/W[1 4 1]/Root 1 0 R/Length ${rows.length}>>stream\n`,
    'latin1',
  );
  const tail = Buffer.from(`\nendstream\nendobj\nstartxref\n${xrefOffset}\n%%EOF\n`, 'latin1');
  return Buffer.concat([out, head, rows, tail]);
}

test('signature PDF ECDSA P-256 (/ByteRange) détecte toute altération (1 octet, métadonnée ou append)', async () => {
  for (const basePdf of [
    Buffer.from('%PDF-1.4\n% minimal constat body\n%%EOF\n', 'latin1'),
    buildClassicXrefPdf(),
    buildXRefStreamPdf(),
  ]) {
    assert.equal(hasPdfSignature(basePdf), false);
    const unsignedCheck = await verifyPdfBuffer(basePdf);
    assert.equal(unsignedCheck.valid, false);

    const signed = signPdfBuffer(basePdf, {
      constatId: '11111111-1111-4111-8111-111111111111',
      contentSha256: 'a'.repeat(64),
      signaturesSha256: 'b'.repeat(64),
      signedAt: '2026-11-10T21:00:00.000Z',
    });

    assert.equal(hasPdfSignature(signed), true);
    const ok = await verifyPdfBuffer(signed);
    assert.equal(ok.valid, true);
    assert.equal(ok.metadata.constatId, '11111111-1111-4111-8111-111111111111');
    assert.equal(ok.metadata.contentSha256, 'a'.repeat(64));
    assert.equal(ok.metadata.signaturesSha256, 'b'.repeat(64));

    // Altération d'un octet dans le corps du document (texte/croquis/signature)
    const bodyTampered = Buffer.from(signed);
    bodyTampered[12] ^= 0x01;
    assert.equal((await verifyPdfBuffer(bodyTampered)).valid, false);

    // Altération d'une métadonnée signée (/ConstatId)
    const metaPos = signed.indexOf('11111111-1111-4111-8111-111111111111');
    assert.ok(metaPos > 0);
    const metaTampered = Buffer.from(signed);
    metaTampered[metaPos] = 0x39; // '9'
    assert.equal((await verifyPdfBuffer(metaTampered)).valid, false);

    // Ajout d'octets après la signature
    const appended = Buffer.concat([signed, Buffer.from('\n% injected', 'latin1')]);
    assert.equal((await verifyPdfBuffer(appended)).valid, false);
  }
});

