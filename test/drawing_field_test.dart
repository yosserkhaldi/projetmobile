import 'package:flutter/material.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/modules/constat/widgets/constat_steps.dart';
import 'package:mon_constat_digital/shared/widgets/drawing_pad.dart';

Future<List<List<Map<String, double>>>> pumpField(WidgetTester tester) async {
  final strokes = <List<Map<String, double>>>[];
  var changes = 0;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fr'),
      home: Scaffold(
        body: ListView(
          children: [
            StatefulBuilder(
              builder: (context, setState) => DrawingField(
                strokes: strokes,
                title: 'Croquis de l’accident',
                hint: 'Dessinez',
                onChanged: () => setState(() => changes++),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return strokes;
}

Future<void> drawLine(WidgetTester tester) async {
  final surface = find.byKey(const ValueKey('fullscreen-drawing-surface'));
  final center = tester.getCenter(surface);
  final gesture = await tester.startGesture(center - const Offset(60, 0));
  await gesture.moveBy(const Offset(40, 10));
  await gesture.moveBy(const Offset(40, 10));
  await gesture.up();
  await tester.pump();
}

void main() {
  testWidgets('dessin : plein écran, « Terminé » garde le dessin', (
    tester,
  ) async {
    final strokes = await pumpField(tester);
    // Aperçu dans la page : on y touche, on ne dessine pas (pas de défilement).
    await tester.tap(find.byKey(const ValueKey('drawing-field')));
    await tester.pumpAndSettle();
    expect(find.text('Croquis de l’accident'), findsOneWidget);
    await drawLine(tester);
    await tester.tap(find.byKey(const ValueKey('drawing-done')));
    await tester.pumpAndSettle();
    expect(strokes, hasLength(1));
    expect(strokes.single.length, greaterThan(1));
    // Coordonnées relatives (0 à 1), comme dans le PDF.
    for (final point in strokes.single) {
      expect(point['x'], inInclusiveRange(0, 1));
      expect(point['y'], inInclusiveRange(0, 1));
    }
  });

  testWidgets('dessin : la croix ferme sans rien changer', (tester) async {
    final strokes = await pumpField(tester);
    await tester.tap(find.byKey(const ValueKey('drawing-field')));
    await tester.pumpAndSettle();
    await drawLine(tester);
    await tester.tap(find.byTooltip('Fermer sans enregistrer'));
    await tester.pumpAndSettle();
    expect(strokes, isEmpty);
  });

  testWidgets('dessin : annuler le dernier trait', (tester) async {
    final strokes = await pumpField(tester);
    await tester.tap(find.byKey(const ValueKey('drawing-field')));
    await tester.pumpAndSettle();
    await drawLine(tester);
    await drawLine(tester);
    await tester.tap(find.byTooltip('Annuler le dernier trait'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('drawing-done')));
    await tester.pumpAndSettle();
    expect(strokes, hasLength(1));
  });

  test('date : formats reconnus, texte quelconque refusé', () {
    expect(DateField.normalize('2031-05-12'), '12/05/2031');
    expect(DateField.normalize('12-05-2031'), '12/05/2031');
    expect(DateField.normalize('1.5.2031'), '01/05/2031');
    expect(DateField.normalize('bientôt'), '');
    expect(DateField.normalize('31/02/2031'), '');
    expect(DateField.parse('12/05/2031'), DateTime(2031, 5, 12));
  });

  testWidgets('date : choisie dans un calendrier, pas tapée', (tester) async {
    var value = '';
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fr'),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => DateField(
              value: value,
              label: 'Date de validité du permis',
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('Date de validité du permis'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('15'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(value, matches(RegExp(r'^15/\d{2}/\d{4}$')));
  });
}
