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
import 'package:mon_constat_digital/core/state/app_scope.dart';
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

/// Textes visibles, pour comprendre un échec.
String onScreen() => find
    .byType(Text)
    .evaluate()
    .map((e) => (e.widget as Text).data)
    .whereType<String>()
    .take(40)
    .join(' | ');

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
  fail('Introuvable après ${timeout.inSeconds} s : $finder — à l’écran : ${onScreen()}');
}

/// Champ de saisie : par sa clé (formulaires du module 1) ou par son libellé.
/// Laisse l'interface avancer un moment. Pas de pumpAndSettle : certains
/// écrans ont une animation continue (GPS, indicateurs) qui ne s'arrête pas.
Future<void> settle(WidgetTester tester, [int ms = 800]) async {
  for (var waited = 0; waited < ms; waited += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Finder field(String label) {
  final byKey = find.byKey(ValueKey(label));
  if (byKey.evaluate().isNotEmpty) return byKey;
  return find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.labelText == label,
  );
}

Finder tab(String label) => find.byWidgetPredicate(
  (w) => w is NavigationDestination && w.label == label,
);

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await settle(tester);
  await tester.tap(finder);
  await settle(tester);
}

Future<void> type(WidgetTester tester, String label, String value) async {
  final target = field(label).first;
  await tester.ensureVisible(target);
  await settle(tester);
  await tester.enterText(target, value);
  await settle(tester);
}

/// Ouvre la zone de dessin [index], trace un trait et valide.
Future<void> draw(WidgetTester tester, int index) async {
  final zone = find.byKey(const ValueKey('drawing-field')).at(index);
  await tester.ensureVisible(zone);
  await settle(tester);
  await tester.tap(zone);
  await settle(tester, 1000);
  final surface = find.byKey(const ValueKey('fullscreen-drawing-surface'));
  await waitFor(tester, surface);
  final gesture = await tester.startGesture(tester.getCenter(surface));
  for (var i = 0; i < 12; i++) {
    await gesture.moveBy(Offset(12, i.isEven ? 8 : -8));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await settle(tester);
  await tester.tap(find.byKey(const ValueKey('drawing-done')));
  await settle(tester, 1000);
}

/// Passe à l'étape suivante : ferme la proposition d'adresse du GPS si elle
/// s'affiche (elle peut arriver tard), touche [button] et attend l'étape
/// [to] (numérotée à partir de 1).
Future<void> next(WidgetTester tester, int to, {String button = 'Continuer'}) async {
  final usePosition = find.text('Utiliser cette position');
  final reached = find.text('Étape $to sur 7');
  final end = DateTime.now().add(const Duration(seconds: 60));
  while (DateTime.now().isBefore(end)) {
    if (usePosition.evaluate().isNotEmpty) {
      await tester.tap(usePosition);
      await settle(tester);
    }
    if (reached.evaluate().isNotEmpty) return;
    final target = find.text(button);
    if (target.evaluate().isNotEmpty) {
      await tester.ensureVisible(target.last);
      await settle(tester);
      await tester.tap(target.last, warnIfMissed: false);
    }
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }
  fail('Étape $to jamais atteinte');
}

Future<void> chooseCompany(WidgetTester tester, String name) async {
  final picker = find.byType(DropdownButtonFormField<String>).first;
  await tester.ensureVisible(picker);
  await settle(tester);
  await tester.tap(picker);
  await waitFor(tester, find.text(name));
  await tester.tap(find.text(name).last);
  await settle(tester);
}

/// Touche [button] jusqu'à ce que [expected] apparaisse (écran encore en
/// chargement au premier essai).
Future<void> tapUntil(WidgetTester tester, Finder button, Finder expected) async {
  final end = DateTime.now().add(const Duration(seconds: 45));
  while (DateTime.now().isBefore(end)) {
    if (expected.evaluate().isNotEmpty) return;
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button.first, warnIfMissed: false);
    }
    await settle(tester, 1500);
  }
  fail('Après $button, introuvable : $expected — à l’écran : ${onScreen()}');
}

/// Connexion : [home] est un onglet du rôle attendu.
Future<void> login(
  WidgetTester tester,
  String id,
  String secret,
  String home,
) async {
  await waitFor(tester, find.text('Se connecter'));
  await settle(tester, 1000);
  await tester.enterText(field('E-mail ou téléphone'), id);
  await tester.enterText(field('Mot de passe'), secret);
  await settle(tester);
  await tapUntil(tester, find.text('Se connecter').last, tab(home));
}

/// Déconnexion depuis l'onglet Profil.
Future<void> logout(WidgetTester tester) async {
  await tester.tap(tab('Profil'));
  await settle(tester, 1500);
  await scrollTo(tester, find.text('Se déconnecter'));
  await tapVisible(tester, find.text('Se déconnecter'));
  await waitFor(tester, find.text('Se connecter'));
}

/// Fait défiler la liste visible jusqu'à [target].
Future<void> scrollTo(WidgetTester tester, Finder target) async {
  final end = DateTime.now().add(const Duration(seconds: 40));
  while (target.evaluate().isEmpty && DateTime.now().isBefore(end)) {
    final lists = find.byType(Scrollable);
    if (lists.evaluate().isNotEmpty) {
      await tester.drag(lists.last, const Offset(0, -300), warnIfMissed: false);
    }
    await settle(tester, 500);
  }
  expect(target, findsWidgets);
  await tester.ensureVisible(target.first);
  await settle(tester);
}

/// Messagerie ouverte : écrit et envoie [text], attend qu'il s'affiche.
Future<void> sendMessage(WidgetTester tester, String text) async {
  final input = find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.hintText == 'Votre message',
  );
  await waitFor(tester, input);
  await tester.enterText(input, text);
  await settle(tester);
  await tester.tap(find.byTooltip('Envoyer'));
  await waitFor(tester, find.text(text));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('conducteur, puis agent : déclaration, constat scellé, dossier instruit, messagerie', (
    tester,
  ) async {
    expect(email, isNotEmpty, reason: 'E2E_EMAIL manquant');
    final photo = File('${Directory.systemTemp.path}/e2e-photo.jpg')
      ..writeAsBytesSync(_jpeg);
    ImagePickerPlatform.instance = FakeCamera(photo.path);

    app.main();
    // ── Connexion ──────────────────────────────────────────────────────────
    await login(tester, email, password, 'Véhicules');

    // ── Module 2 : ajout d'un véhicule ─────────────────────────────────────
    await tapUntil(tester, tab('Véhicules'), find.byTooltip('Ajouter un véhicule'));
    await waitFor(tester, find.byTooltip('Ajouter un véhicule'));
    await tapUntil(
      tester,
      find.byTooltip('Ajouter un véhicule'),
      find.text('Identification du véhicule'),
    );
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
    await tapUntil(tester, tab('Accueil'), find.text('Commencer une déclaration'));
    await tapUntil(
      tester,
      find.text('Commencer une déclaration'),
      find.text('Étape 1 sur 7'),
    );
    await waitFor(tester, find.text('Étape 1 sur 7'));
    // Laisse au GPS le temps de proposer l'adresse.
    await tester.pump(const Duration(seconds: 2));
    await next(tester, 2); // contexte
    await next(tester, 3); // description
    await tapVisible(tester, find.text('Vue d’ensemble'));
    await waitFor(tester, find.text('Photo enregistrée • touchez pour reprendre'));
    await tapVisible(tester, find.text('Plaques'));
    await settle(tester, 1000);
    await next(tester, 4, button: 'Continuer vers le constat');

    // ── Module 4 : conducteur B, circonstances, croquis, signatures ────────
    await waitFor(tester, field('Nom complet *'));
    await type(tester, 'Nom complet *', 'Karim Mejri');
    await type(tester, 'Immatriculation *', '198 TU 4521');
    await waitFor(tester, find.byType(DropdownButtonFormField<String>));
    await chooseCompany(tester, 'COMAR');
    await next(tester, 5);

    await waitFor(tester, find.byType(Checkbox));
    await tapVisible(tester, find.byType(Checkbox).at(0)); // A : case 1
    await tapVisible(tester, find.byType(Checkbox).at(3)); // B : case 2
    await next(tester, 6);

    await waitFor(tester, find.text('Croquis et point de choc'));
    await draw(tester, 0);
    await tapVisible(tester, find.text('Arrière'));
    await next(tester, 7);

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
    await settle(tester, 3000);

    // Numéro du dossier créé par la déclaration.
    final stores = AppScope.of(tester.element(find.byType(Scaffold).first));
    final claimId = stores.claims.claims
        .map((c) => c.id)
        .firstWhere((id) => RegExp(r'^SIN-\d{6}-').hasMatch(id));
    Navigator.of(
      tester.element(find.byType(Scaffold).first),
    ).popUntil((route) => route.isFirst);
    await settle(tester, 1500);

    // ── Module 5 : l'agent de l'assureur reçoit et instruit le dossier ────
    await logout(tester);
    await login(tester, 'leila@assurance.tn', 'Password123!', 'Sinistres');
    await tester.tap(tab('Sinistres'));
    await settle(tester, 2000);
    await scrollTo(tester, find.text(claimId));
    await tapVisible(tester, find.text(claimId).first);
    await waitFor(tester, find.text('Prendre en charge'));
    await tapVisible(tester, find.text('Prendre en charge'));
    await waitFor(tester, find.text('Demander une pièce'));

    const agentMessage = 'Bonjour, je prends votre dossier en charge.';
    await tapUntil(
      tester,
      find.byTooltip('Messagerie'),
      find.byTooltip('Envoyer'),
    );
    await sendMessage(tester, agentMessage);

    // ── Le conducteur lit la réponse et répond ────────────────────────────
    Navigator.of(
      tester.element(find.byType(Scaffold).first),
    ).popUntil((route) => route.isFirst);
    await settle(tester, 1500);
    await logout(tester);
    await login(tester, email, password, 'Messages');
    await tester.tap(tab('Messages'));
    await settle(tester, 2000);
    await waitFor(tester, find.text(claimId));
    await tapVisible(tester, find.text(claimId).first);
    await waitFor(tester, find.text(agentMessage));
    await sendMessage(tester, 'Merci, je reste disponible.');
    // Le serveur a reçu la réponse avant la fin du test.
    await settle(tester, 4000);
  });
}
