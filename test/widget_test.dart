import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/main.dart';

void main() {
  testWidgets('connexion conducteur et accès aux cinq modules', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MonConstatApp());
    expect(find.text('Mon Constat Digital'), findsOneWidget);
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Bonjour'), findsOneWidget);
    expect(find.text('Véhicules'), findsOneWidget);
    expect(find.text('Déclarations'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  testWidgets('démarre le parcours de déclaration', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MonConstatApp());
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Commencer une déclaration'));
    await tester.pumpAndSettle();
    expect(find.text('Contexte'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets('ouvre le profil depuis le raccourci Mon permis', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MonConstatApp());
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Mon permis'));
    await tester.tap(find.text('Mon permis'));
    await tester.pumpAndSettle();
    expect(find.text('Mon profil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exige deux preuves avant le constat', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MonConstatApp());
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Commencer une déclaration'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Que s’est-il passé ?'), findsOneWidget);

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Photos guidées'), findsOneWidget);

    await tester.tap(find.text('Continuer vers le constat'));
    await tester.pump();
    expect(
      find.text('Ajoutez au moins 2 photos avant de continuer.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Vue d’ensemble'));
    await tester.tap(find.text('Dégâts véhicule A'));
    await tester.pump();
    await tester.tap(find.text('Continuer vers le constat'));
    await tester.pumpAndSettle();
    expect(find.text('Mode invité isolé'), findsOneWidget);
  });

  testWidgets('le raccourci Constat ouvre les déclarations', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MonConstatApp());
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Constat'));
    await tester.tap(find.text('Constat'));
    await tester.pumpAndSettle();
    expect(find.text('Mes déclarations'), findsOneWidget);
    expect(find.text('DÉCLARATIONS TRANSMISES'), findsOneWidget);
    expect(find.text('Conducteur B'), findsNothing);
  });

  testWidgets('reprend un brouillon à la dernière étape', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MonConstatApp());
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Commencer une déclaration'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Que s’est-il passé ?'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Constat'));
    await tester.tap(find.text('Constat'));
    await tester.pumpAndSettle();
    expect(find.text('Étape 2 sur 7'), findsOneWidget);
    await tester.tap(find.text('Reprendre'));
    await tester.pumpAndSettle();
    expect(find.text('Que s’est-il passé ?'), findsOneWidget);
  });
}
