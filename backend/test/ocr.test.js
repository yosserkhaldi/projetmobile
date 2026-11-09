import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
  arabicMatchesLatin,
  mrzCheckDigit,
  mrzNumberCandidates,
  nameInMrz,
  parseArabicDate,
  parseCinFields,
  parseCinNumber,
  parseLicenseCategories,
  parseLicenseDates,
  parseLicenseNumber,
  parseMrz,
  sameName,
} from '../src/lib/ocr.js';

// Données fictives uniquement. MRZ : exemple officiel de la norme OACI 9303.
const ICAO_LINE1 = 'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<';
const ICAO_LINE2 = 'L898902C36UTO7408122F1204159ZE184226B<<<<<10';

test('MRZ : exemple officiel OACI 9303, chiffres de contrôle vérifiés', () => {
  assert.equal(mrzCheckDigit('L898902C3'), '6');
  const mrz = parseMrz(`${ICAO_LINE1}\n${ICAO_LINE2}`);
  assert.equal(mrz.number, 'L898902C3');
  assert.deepEqual(mrz.numberCandidates, ['L898902C3']);
  assert.equal(mrz.lastName, 'ERIKSSON');
  assert.equal(mrz.firstName, 'ANNA MARIA');
  assert.equal(mrz.birthDate, '1974-08-12');
  assert.equal(mrz.expiresAt, '2012-04-15');
});

test('MRZ : signe confondu corrigé grâce au chiffre de contrôle', () => {
  // « 0 » lu « O » dans le numéro : la lecture corrigée passe le contrôle.
  assert.ok(mrzNumberCandidates('L8989O2C3', '6').includes('L898902C3'));
  // Signe ajouté au début de la ligne 2 : recalée sur le bloc des dates.
  const shifted = parseMrz(`${ICAO_LINE1}\nX${ICAO_LINE2}`);
  assert.equal(shifted.birthDate, '1974-08-12');
  assert.equal(shifted.expiresAt, '2012-04-15');
  assert.equal(parseMrz('aucune zone lisible'), null);
});

test('MRZ : nom du compte retrouvé malgré les « < » mal lus', () => {
  const line = 'UTOERIKSSON<K<KANNALKCCLLLLLLLLLL';
  assert.ok(nameInMrz(line, 'Eriksson'));
  assert.ok(nameInMrz(line, 'Anna'));
  assert.equal(nameInMrz(line, 'Trabelsi'), false);
});

test('CIN et permis : numéros dans le texte reconnu', () => {
  assert.equal(parseCinNumber('fan 12345678\npL | al'), '12345678');
  assert.equal(parseCinNumber('2001 25'), null);
  assert.equal(parseLicenseNumber('N° 12 / 345678 B'), '12/345678');
});

test('date en arabe : mois tunisien reconnu même mal lu', () => {
  assert.equal(parseArabicDate('12 مارس 1999'), '1999-03-12');
  assert.equal(parseArabicDate('بدت د 3 اقريل2004'), '2004-04-03');
  assert.equal(parseArabicDate('28 جوان 2000'), '2000-06-28');
  assert.equal(parseArabicDate('بن محمد'), null);
});

test('champs de la CIN : nom, prénom, filiation, naissance', () => {
  // Restes de libellés (« الام » pour الاسم, « تانب » pour مكانها) écartés.
  const fields = parseCinFields(
    [
      'الطرابلسي',
      'الام سامي',
      'بن محمد بن علي',
      'بدت د 12 مارس 1999',
      'تانب صفاقس',
    ].join('\n'),
  );
  assert.deepEqual(fields, {
    lastNameAr: 'الطرابلسي',
    firstNameAr: 'سامي',
    parentsAr: 'بن محمد بن علي',
    birthDate: '1999-03-12',
    birthPlaceAr: 'صفاقس',
  });
  assert.equal(
    parseCinFields('الوسلاتي\nمنى\n12 جانفي 1999\nسيدي بوزيد').birthPlaceAr,
    'سيدي بوزيد',
  );
});

test('noms comparés sans accents ni séparateurs', () => {
  assert.ok(sameName('BEN ALI', 'Ben-Ali'));
  assert.ok(sameName('HELENE', 'Hélène'));
  assert.equal(sameName('TRABELSI', 'Ben Ali'), false);
  assert.equal(sameName(null, 'Ben Ali'), false);
});

test('permis : numéro, catégories et dates, ancien et nouveau modèle', () => {
  // Ancien modèle (données fictives).
  const old = 'REPUBLIQUE TUNISIENNE\nPERMIS DE CONDUIRE\nN° 12/345678\nB  BE  C\n02/03/1990\n15/06/2015';
  assert.equal(parseLicenseNumber(old), '12/345678');
  assert.deepEqual(parseLicenseCategories(old), ['B', 'B+E', 'C']);
  assert.deepEqual(parseLicenseDates(old, '2026-11-09'), {
    birthDate: '1990-03-02',
    issuedAt: '2015-06-15',
    expiresAt: null,
  });
  // Modèle international : cases 4a, 4b et 5.
  const card = '3. 02.03.1990 SFAX\n4a. 10.05.2024 4b. 10.05.2034\n5. 0123456789\n9. A1 B';
  assert.equal(parseLicenseNumber(card), '0123456789');
  assert.deepEqual(parseLicenseCategories(card), ['A1', 'B']);
  assert.deepEqual(parseLicenseDates(card, '2026-11-09'), {
    birthDate: '1990-03-02',
    issuedAt: '2024-05-10',
    expiresAt: '2034-05-10',
  });
});

test('nom arabe et nom latin : comparés par leurs consonnes', () => {
  assert.equal(arabicMatchesLatin('الطرابلسي', 'Trabelsi'), true);
  assert.equal(arabicMatchesLatin('بن علي', 'Ben Ali'), true);
  assert.equal(arabicMatchesLatin('محمد خليل', 'Mohamed Khalil'), true);
  assert.equal(arabicMatchesLatin('الشابي', 'Chebbi'), true);
  assert.equal(arabicMatchesLatin('قاسم', 'Kacem'), true);
  // Lettre en trop lue par l'OCR sur un nom court : tolérée.
  assert.equal(arabicMatchesLatin('سامبي', 'Sami'), true);
  assert.equal(arabicMatchesLatin('الطرابلسي', 'Ben Ali'), false);
  assert.equal(arabicMatchesLatin('سامي', 'Mouna'), false);
  assert.equal(arabicMatchesLatin(null, 'Sami'), null);
});
