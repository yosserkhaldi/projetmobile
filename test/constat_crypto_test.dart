import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mon_constat_digital/modules/constat/models/constat.dart';
import 'package:mon_constat_digital/modules/constat/services/constat_crypto_service.dart';

void main() {
  group('ConstatCryptoService', () {
    const service = ConstatCryptoService();

    test('calcule une empreinte SHA-256 exacte', () {
      final bytes = Uint8List.fromList(utf8.encode('Mon Constat Digital 2026'));
      final expected = sha256.convert(bytes).toString();

      final actual = service.computeSha256(bytes);
      expect(actual, equals(expected));
      expect(actual.length, equals(64));
    });

    test('formate le hash par blocs lisibles de 8 caractères', () {
      const hash = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
      final formatted = service.formatHash(hash);
      expect(
        formatted,
        equals(
          'e3b0c442 98fc1c14 9afbf4c8 996fb924 27ae41e4 649b934c a495991b 7852b855',
        ),
      );
    });
  });

  group('Constat Model', () {
    test('sérialisation et désérialisation JSON complètes', () {
      final now = DateTime.now();
      final constat = Constat(
        id: 'c1234567-0000-0000-0000-000000000001',
        userId: 'u1234567-0000-0000-0000-000000000001',
        status: 'SIGNED',
        sha256Hash: 'a'.repeat(64),
        pdfUrl: '/api/constats/c1234567-0000-0000-0000-000000000001/pdf',
        driverAName: 'Sami Ben Ali',
        driverAPlate: '180 TN 1234',
        driverAInsurer: 'STAR',
        driverBName: 'Karim Trabelsi',
        driverBPlate: '210 TN 5678',
        driverBInsurer: 'GAT',
        place: 'Tunis',
        occurredAt: now,
        circumstancesA: ['1 - En stationnement'],
        circumstancesB: ['2 - Quittait un stationnement'],
      );

      final json = constat.toJson();
      final decoded = Constat.fromJson(json);

      expect(decoded.id, equals(constat.id));
      expect(decoded.sha256Hash, equals(constat.sha256Hash));
      expect(decoded.driverAName, equals('Sami Ben Ali'));
      expect(decoded.driverBName, equals('Karim Trabelsi'));
      expect(decoded.circumstancesA, contains('1 - En stationnement'));
      expect(decoded.circumstancesB, contains('2 - Quittait un stationnement'));
    });
  });
}

extension on String {
  String repeat(int times) => List.filled(times, this).join();
}

