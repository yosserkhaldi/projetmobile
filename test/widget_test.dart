import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_workshops_5sae1_2627/main.dart';

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
    expect(find.text('Dossiers'), findsOneWidget);
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
}
