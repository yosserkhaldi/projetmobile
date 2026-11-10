import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import test from 'node:test';

import {
  CONSTAT_PUBLIC_JWK,
  generateConstatQr,
  signConstatJws,
} from '../src/lib/jws.js';

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

  // Décodage du payload canonique
  const decodedPayload = JSON.parse(Buffer.from(parts[1], 'base64url').toString('utf8'));
  assert.equal(decodedPayload.data.id, 'constat-unit-01');
  assert.equal(decodedPayload.data.driverAPlate, '100-TN-001');

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

test('génération du QR Code et fragment d URL Zero-Knowledge', async () => {
  const dummyJws = 'header.payload.signature';
  const qr = await generateConstatQr(dummyJws, 'https://test-verifier.local');

  assert.equal(
    qr.verifierUrl,
    'https://test-verifier.local/#header.payload.signature',
  );
  assert.ok(qr.qrCodeBase64.length > 50, 'Le QR code en base64 doit être généré');
  assert.ok(qr.qrDataUrl.startsWith('data:image/png;base64,'));
});
