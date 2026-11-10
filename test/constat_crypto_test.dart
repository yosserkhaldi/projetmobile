import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/network/token_storage.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_pdf_service.dart';
import 'package:mon_constat_digital/modules/constat/models/constat.dart';
import 'package:mon_constat_digital/modules/constat/screens/constat_sealed_screen.dart';
import 'package:mon_constat_digital/modules/constat/services/constat_crypto_service.dart';
import 'package:mon_constat_digital/modules/constat/state/constat_store.dart';

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

    test('calcule un signaturesHash déterministe sensible à toute altération', () {
      final sigA = [
        [
          {'x': 0.1, 'y': 0.5},
          {'x': 0.9, 'y': 0.5},
        ],
      ];
      final sigB = [
        [
          {'x': 0.2, 'y': 0.6},
          {'x': 0.8, 'y': 0.4},
        ],
      ];
      final sigBTampered = [
        [
          {'x': 0.21, 'y': 0.6},
          {'x': 0.8, 'y': 0.4},
        ],
      ];

      final h1 = service.computeSignaturesHash(sigA, sigB);
      final h2 = service.computeSignaturesHash(sigA, sigB);
      final hTampered = service.computeSignaturesHash(sigA, sigBTampered);

      expect(h1.length, equals(64));
      expect(h1, equals(h2));
      expect(hTampered, isNot(equals(h1)));
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
        qrCodeBase64: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        jwsToken: 'header.payload.signature',
        verifierUrl: 'https://verifier.mon-constat.tn/#token',
      );

      final json = constat.toJson();
      final decoded = Constat.fromJson(json);

      expect(decoded.id, equals(constat.id));
      expect(decoded.sha256Hash, equals(constat.sha256Hash));
      expect(decoded.driverAName, equals('Sami Ben Ali'));
      expect(decoded.driverBName, equals('Karim Trabelsi'));
      expect(decoded.circumstancesA, contains('1 - En stationnement'));
      expect(decoded.circumstancesB, contains('2 - Quittait un stationnement'));
      expect(decoded.qrCodeBase64, equals(constat.qrCodeBase64));
      expect(decoded.jwsToken, equals('header.payload.signature'));
      expect(decoded.verifierUrl, equals('https://verifier.mon-constat.tn/#token'));
    });
  });

  group('ConstatStore 2-step seal & finalizePdf', () {
    test('envoie deferEmail + signaturesHash puis finalise avec les octets ECDSA exacts', () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      const tinyPngB64 =
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
      final finalizedSignedPdf = Uint8List.fromList(
        utf8.encode('%PDF-1.5\n%signed-by-ecdsa-server\n%%EOF\n'),
      );
      Map<String, dynamic>? sealPayload;
      bool finalizeCalled = false;

      final mockClient = MockClient((request) async {
        if (request.method == 'POST' && request.url.path.endsWith('/constats')) {
          final bodyStr = utf8.decode(request.bodyBytes, allowMalformed: true);
          final dataMatch = RegExp(r'name="data"\r\n\r\n(\{[\s\S]*?\})\r\n').firstMatch(bodyStr);
          if (dataMatch != null) {
            sealPayload = jsonDecode(dataMatch.group(1)!) as Map<String, dynamic>;
          }
          return http.Response(
            jsonEncode({
              'constat': {
                'id': 'c1111111-1111-4111-8111-111111111111',
                'userId': 'u1111111-1111-4111-8111-111111111111',
                'status': 'SIGNED',
                'sha256Hash': sealPayload?['sha256Hash'] ?? 'a'.repeat(64),
                'pdfUrl': '/api/constats/c1111111-1111-4111-8111-111111111111/pdf',
                'driverAName': 'Sami Ben Ali',
                'driverAPlate': '180 TN 1234',
                'driverAInsurer': 'STAR',
                'driverBName': 'Karim Trabelsi',
                'driverBPlate': '210 TN 5678',
                'driverBInsurer': 'GAT',
                'place': 'Tunis',
                'occurredAt': '2026-11-10T14:30:00.000Z',
                'qrCodeBase64': tinyPngB64,
                'jwsToken': 'h.p.s',
                'verifierUrl': 'https://verif-constat-digital.vercel.app/#h.p.s',
              },
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'POST' &&
            request.url.path.endsWith('/constats/c1111111-1111-4111-8111-111111111111/finalize-pdf')) {
          finalizeCalled = true;
          return http.Response.bytes(
            finalizedSignedPdf,
            200,
            headers: {'content-type': 'application/pdf'},
          );
        }

        return http.Response('{}', 404);
      });

      final api = ApiClient(
        storage: _TestStorage(),
        httpClient: mockClient,
        baseUrl: 'http://localhost:3000/api',
      );
      final store = ConstatStore(api: api);
      final draft = AccidentDraft()
        ..place = 'Tunis'
        ..driverBName = 'Karim Trabelsi'
        ..driverBPlate = '210 TN 5678'
        ..driverBInsurer = 'GAT'
        ..driverBPolicy = 'POL-GAT-882'
        ..driverASignature.add([
          {'x': 0.1, 'y': 0.5},
          {'x': 0.8, 'y': 0.5},
        ])
        ..driverBSignature.add([
          {'x': 0.2, 'y': 0.4},
          {'x': 0.7, 'y': 0.6},
        ]);

      final sealed = await store.sealAndSubmit(
        draft: draft,
        driverAName: 'Sami Ben Ali',
        driverAPlate: '180 TN 1234',
        driverAInsurer: 'STAR',
        driverAPolicy: 'POL-STAR-441',
        driverA: const ConstatDriverAData(
          fullName: 'Sami Ben Ali',
          plate: '180 TN 1234',
          insurerName: 'STAR',
          policyNumber: 'POL-STAR-441',
          vehicleBrand: 'Peugeot',
          vehicleModel: '208',
        ),
      );

      expect(sealPayload, isNotNull);
      expect(sealPayload!['deferEmail'], isTrue);
      expect(sealPayload!['signaturesHash'], hasLength(64));
      expect(sealPayload!['driverASignedAt'], isNotEmpty);
      expect(sealPayload!['driverAPolicy'], equals('POL-STAR-441'));
      expect(sealPayload!['driverBPolicy'], equals('POL-GAT-882'));
      expect(finalizeCalled, isTrue);
      expect(sealed.id, equals('c1111111-1111-4111-8111-111111111111'));
      expect(store.lastSealedPdfBytes, equals(finalizedSignedPdf));
    });
  });

  group('ConstatSealedScreen UI', () {
    testWidgets('masque la carte technique SHA-256 à l’écran final', (tester) async {
      final hash = '67b9a4529c651f75f146235f9321f440020c8bed08728ccdeab5b72d5bf68768';
      final constat = Constat(
        id: 'c1234567-0000-0000-0000-000000000001',
        userId: 'u1234567-0000-0000-0000-000000000001',
        status: 'SIGNED',
        sha256Hash: hash,
        pdfUrl: '/api/constats/c1234567-0000-0000-0000-000000000001/pdf',
        driverAName: 'Sami Ben Ali',
        driverAPlate: '180 TN 1234',
        driverAInsurer: 'STAR',
        driverBName: 'Karim Trabelsi',
        driverBPlate: '210 TN 5678',
        driverBInsurer: 'GAT',
        place: 'Tunis',
        occurredAt: DateTime(2026, 11, 10, 14, 30),
      );
      final draft = AccidentDraft()
        ..place = 'Tunis'
        ..driverBName = 'Karim Trabelsi';

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppPalette.light]),
          home: ConstatSealedScreen(constat: constat, draft: draft),
        ),
      );

      expect(find.text('Constat scellé et transmis'), findsOneWidget);
      expect(find.text('CERTIFICATION HORS-LIGNE (JWS)'), findsOneWidget);
      expect(find.text('EMPREINTE DE SÉCURITÉ (SHA-256)'), findsNothing);
      expect(find.textContaining('67b9a452'), findsNothing);

      await tester.scrollUntilVisible(find.text('Sami Ben Ali'), 200);
      expect(find.text('Sami Ben Ali'), findsOneWidget);
      expect(find.text('EMPREINTE DE SÉCURITÉ (SHA-256)'), findsNothing);
      expect(find.textContaining('67b9a452'), findsNothing);
    });
  });
}

class _TestStorage implements SessionStorage {
  final Map<String, String> _map = {};
  @override
  Future<void> delete(String key) async => _map.remove(key);
  @override
  Future<String?> read(String key) async => _map[key];
  @override
  Future<void> write(String key, String value) async => _map[key] = value;
}

extension on String {
  String repeat(int times) => List.filled(times, this).join();
}

