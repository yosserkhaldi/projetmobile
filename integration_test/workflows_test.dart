// Parcours principal sur un vrai téléphone, contre l'API locale :
// connexion, ajout d'un véhicule, déclaration complète, double signature et
// scellement du constat, sinistre transmis.
//
//   adb reverse tcp:3000 tcp:3000
//   flutter test integration_test/workflows_test.dart -d <appareil> \
//     --dart-define=E2E_EMAIL=... --dart-define=E2E_PASSWORD=...
//
// Le compte doit avoir un profil complet et une identité vérifiée.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mon_constat_digital/main.dart' as app;

const email = String.fromEnvironment('E2E_EMAIL');
const password = String.fromEnvironment('E2E_PASSWORD');
const plate = String.fromEnvironment('E2E_PLATE', defaultValue: '321 TU 7654');

/// Caméra remplacée par une photo fixe : le reste du parcours est réel.
class FakeCamera extends ImagePickerPlatform {
  FakeCamera(this.photo);
  final String photo;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async => XFile(photo);

  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async => XFile(photo);
}

// JPEG 1×1 valide.
const _jpeg = [
  0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x00, 0x00, 0x01,
  0x00, 0x01, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43, 0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08,
  0x07, 0x07, 0x07, 0x09, 0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
  0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20, 0x24, 0x2E, 0x27, 0x20,
  0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29, 0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27,
  0x39, 0x3D, 0x38, 0x32, 0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01,
  0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x14, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0xFF, 0xC4,
  0x00, 0x14, 0x10, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3F, 0x00, 0x2A, 0x9F,
  0xFF, 0xD9,
];

/// Attend qu'un élément apparaisse (appels réseau réels).
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Introuvable après ${timeout.inSeconds} s : $finder');
}

Finder field(String label) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.labelText == label,
);

Finder tab(String label) => find.byWidgetPredicate(
  (w) => w is NavigationDestination && w.label == label,
);

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> type(WidgetTester tester, String label, String value) async {
  final target = field(label).first;
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.enterText(target, value);
  await tester.pumpAndSettle();
}

/// Ouvre la zone de dessin [index], trace un trait et valide.
Future<void> draw(WidgetTester tester, int index) async {
  final zone = find.byKey(const ValueKey('drawing-field')).at(index);
  await tester.ensureVisible(zone);
  await tester.pumpAndSettle();
  await tester.tap(zone);
  await tester.pumpAndSettle(const Duration(seconds: 1));
  final surface = find.byKey(const ValueKey('fullscreen-drawing-surface'));
  await waitFor(tester, surface);
  final gesture = await tester.startGesture(tester.getCenter(surface));
  for (var i = 0; i < 12; i++) {
    await gesture.moveBy(Offset(12, i.isEven ? 8 : -8));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('drawing-done')));
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> chooseCompany(WidgetTester tester, String name) async {
  final picker = find.byType(DropdownButtonFormField<String>).first;
  await tester.ensureVisible(picker);
  await tester.pumpAndSettle();
  await tester.tap(picker);
  await waitFor(tester, find.text(name));
  await tester.tap(find.text(name).last);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('conducteur : véhicule, déclaration, constat scellé, sinistre', (
    tester,
  ) async {
    expect(email, isNotEmpty, reason: 'E2E_EMAIL manquant');
    final photo = File('${Directory.systemTemp.path}/e2e-photo.jpg')
      ..writeAsBytesSync(_jpeg);
    ImagePickerPlatform.instance = FakeCamera(photo.path);

    app.main();
    // ── Connexion ──────────────────────────────────────────────────────────
    await waitFor(tester, find.text('Se connecter'));
    await tester.enterText(field('E-mail ou téléphone'), email);
    await tester.enterText(field('Mot de passe'), password);
    await tester.tap(find.text('Se connecter'));
    await waitFor(tester, tab('Véhicules'));

    // ── Module 2 : ajout d'un véhicule ─────────────────────────────────────
    await tester.tap(tab('Véhicules'));
    await tester.pumpAndSettle();
    await waitFor(tester, find.byTooltip('Ajouter un véhicule'));
    await tester.tap(find.byTooltip('Ajouter un véhicule'));
    await waitFor(tester, field('Immatriculation *'));
    await type(tester, 'Immatriculation *', plate);
    await type(tester, 'Marque *', 'Kia');
    await type(tester, 'Modèle *', 'Picanto');
    await type(tester, 'Année *', '2021');
    await waitFor(tester, find.byType(DropdownButtonFormField<String>));
    await chooseCompany(tester, 'STAR Assurances');
    await type(tester, 'N° de police *', 'E2E-2026-0001');
    await type(tester, 'Date d\'expiration assurance *', '31/12/2027');
    await tapVisible(tester, find.text('Ajouter le véhicule'));
    await waitFor(tester, find.text(plate));

    // ── Module 3 : déclaration ─────────────────────────────────────────────
    await tester.tap(tab('Accueil'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Commencer une déclaration'));
    await waitFor(tester, find.text('Continuer'));
    // Lieu : la position GPS peut prendre un instant.
    await tester.pump(const Duration(seconds: 3));
    final place = find.byWidgetPredicate(
      (w) => w is TextFormField || w is TextField,
    );
    expect(place, findsWidgets);
    await tapVisible(tester, find.text('Continuer')); // contexte
    await waitFor(tester, find.text('Description'));
    await tapVisible(tester, find.text('Continuer')); // description
    await waitFor(tester, find.text('Vue d’ensemble'));
    await tapVisible(tester, find.text('Vue d’ensemble'));
    await waitFor(tester, find.text('Photo enregistrée • touchez pour reprendre'));
    await tapVisible(tester, find.text('Plaques'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tapVisible(tester, find.text('Continuer vers le constat'));

    // ── Module 4 : conducteur B, circonstances, croquis, signatures ────────
    await waitFor(tester, field('Nom complet *'));
    await type(tester, 'Nom complet *', 'Karim Mejri');
    await type(tester, 'Immatriculation *', '198 TU 4521');
    await waitFor(tester, find.byType(DropdownButtonFormField<String>));
    await chooseCompany(tester, 'COMAR');
    await tapVisible(tester, find.text('Continuer'));

    await waitFor(tester, find.byType(Checkbox));
    await tapVisible(tester, find.byType(Checkbox).at(0)); // A : case 1
    await tapVisible(tester, find.byType(Checkbox).at(3)); // B : case 2
    await tapVisible(tester, find.text('Continuer'));

    await waitFor(tester, find.text('Croquis et point de choc'));
    await draw(tester, 0);
    await tapVisible(tester, find.text('Arrière'));
    await tapVisible(tester, find.text('Continuer'));

    await waitFor(tester, find.text('Signature conducteur A'));
    await draw(tester, 0);
    await draw(tester, 1);
    await tapVisible(tester, find.text('Signer et transmettre'));

    // Scellement sur le serveur, PDF signé, sinistre transmis.
    await waitFor(
      tester,
      find.text('Constat scellé et transmis'),
      timeout: const Duration(seconds: 120),
    );
    await tester.pump(const Duration(seconds: 5));
  });
}
