import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_pdf_service.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/vehicles/models/vehicle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('génère un constat PDF avec croquis et signatures', () async {
    final draft = AccidentDraft()
      ..place = 'Avenue Habib Bourguiba, Tunis'
      ..driverBName = 'Conducteur B'
      ..driverBPlate = '123 TUN 4567'
      ..driverBInsurer = 'Assurance test'
      ..observations = 'Choc à faible vitesse'
      ..sketchConfirmed = true
      ..driverASigned = true
      ..driverBSigned = true;
    draft.circumstancesA.add('Changeait de file');
    draft.impactZones.add('Avant gauche');
    draft.sketchStrokes.add([
      {'x': .1, 'y': .2},
      {'x': .8, 'y': .7},
    ]);
    draft.driverASignature.add([
      {'x': .1, 'y': .5},
      {'x': .9, 'y': .5},
    ]);
    draft.driverBSignature.add([
      {'x': .2, 'y': .6},
      {'x': .8, 'y': .4},
    ]);

    final bytes = await AccidentPdfService().build(draft);

    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('injecte le QR code JWS dans l en-tête PDF (80x80 pt) sans erreur', () async {
    final draft = AccidentDraft()
      ..place = 'Route de la Marsa, Tunis'
      ..driverBName = 'Karim Test'
      ..driverBPlate = '210 TUN 3304'
      ..driverBInsurer = 'GAT Assurances';

    final dummyPngBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
    );

    final bytes = await AccidentPdfService().build(
      draft,
      qrCodeBytes: dummyPngBytes,
    );

    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('génère un PDF valide avec horodatage figé via generatedAt et QR Code', () async {
    final draft = AccidentDraft()
      ..place = 'Tunis Centre'
      ..driverBName = 'Karim Test'
      ..driverBPlate = '210 TUN 3304'
      ..driverBInsurer = 'GAT Assurances';
    final fixedDate = DateTime.utc(2026, 11, 10, 14, 30, 0);
    final dummyPngBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
    );

    final service = AccidentPdfService();
    final run1 = await service.build(
      draft,
      qrCodeBytes: dummyPngBytes,
      generatedAt: fixedDate,
    );
    final run2 = await service.build(
      draft,
      qrCodeBytes: dummyPngBytes,
      generatedAt: fixedDate,
    );

    expect(String.fromCharCodes(run1.take(4)), '%PDF');
    expect(String.fromCharCodes(run2.take(4)), '%PDF');
    expect(run1.length, greaterThan(1000));
    expect(run2.length, greaterThan(1000));
  });

  test('génère un Constat Amiable tunisien complet A + B + Circonstances + Policy B + Témoins', () async {
    final user = AppUser(
      id: 'u1',
      firstName: 'Sami',
      lastName: 'Ben Ali',
      email: 'sami@example.com',
      phone: '+21620111222',
      phoneVerified: true,
      role: UserRole.driver,
      active: true,
      language: AppLanguage.fr,
      licenseNumber: '12/894512',
      licenseCategory: 'B',
      licenseIssuedAt: '2018-05-14',
      companyId: 'c1',
      companyName: 'STAR Assurances',
      identity: const Identity(
        status: IdentityStatus.verified,
        cinNumber: '09876543',
      ),
    );
    final vehicle = Vehicle(
      id: 'v1',
      plate: '198 TUN 4321',
      brand: 'Renault',
      model: 'Clio 5',
      year: '2022',
      policy: 'POL-STAR-2026-991',
      insurerName: 'STAR Assurances',
      insuranceExpiry: '2027-06-30',
      companyId: 'c1',
      companyName: 'STAR Assurances',
    );
    final driverA = ConstatDriverAData.fromUserAndVehicle(
      user: user,
      vehicle: vehicle,
    );

    final draft = AccidentDraft()
      ..place = 'Croisement Avenue Mohamed V, Tunis'
      ..latitude = 36.8065
      ..longitude = 10.1815
      ..locationAccuracy = 8
      ..vehicleCount = 2
      ..injuredCount = 1
      ..witnessName = 'Amine Trabelsi'
      ..witnessPhone = '+21622333444'
      ..driverBName = 'Karim Mansouri'
      ..driverBPermit = '14/221100'
      ..driverBPermitExpiry = '2029-09-01'
      ..driverBPlate = '210 TUN 3304'
      ..driverBInsurer = 'GAT Assurances'
      ..driverBPolicy = 'POL-GAT-7741'
      ..observations = 'Le véhicule B quittait son stationnement sans clignotant.'
      ..sketchConfirmed = true
      ..driverASigned = true
      ..driverBSigned = true;
    draft.circumstancesA.addAll([
      '9 - Roulait dans le même sens sur une file différente',
      '10 - Changeait de file',
    ]);
    draft.circumstancesB.addAll([
      '2 - Quittait un stationnement / ouvrait une portière',
      'Circonstance particulière déclarée',
    ]);
    draft.impactZones.addAll(['Avant', 'Côté droit']);
    draft.sketchStrokes.add([
      {'x': .15, 'y': .25},
      {'x': .85, 'y': .75},
    ]);
    draft.driverASignature.add([
      {'x': .2, 'y': .5},
    ]);
    draft.driverBSignature.add([
      {'x': .2, 'y': .6},
      {'x': .8, 'y': .4},
    ]);

    final dummyPngBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
    );

    final bytes = await AccidentPdfService().build(
      draft,
      driverA: driverA,
      qrCodeBytes: dummyPngBytes,
      verifierUrl:
          'https://verif-constat-digital.vercel.app/#eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.${'a'.padRight(600, 'b')}.${'c'.padRight(86, 'd')}',
      generatedAt: DateTime.utc(2026, 11, 10, 16, 45),
      constatRef: 'C1111111',
      sha256Hex: 'a'.padRight(64, 'b'),
    );

    expect(bytes.length, greaterThan(3000));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    // Un constat sans photo doit tenir sur 1 page (recto officiel) !
    final asciiPdf = String.fromCharCodes(bytes);
    final pageMatches = RegExp(r'/Type\s*/Page\b(?!s)').allMatches(asciiPdf).length;
    expect(pageMatches, equals(1));
  });
}
