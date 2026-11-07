import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/shared/widgets/drawing_pad.dart';

void main() {
  test('convertit et restaure un brouillon SQLite complet', () {
    final source = AccidentDraft()
      ..place = 'Avenue de Carthage, Tunis'
      ..latitude = 36.8008
      ..longitude = 10.1800
      ..locationAccuracy = 8.5
      ..vehicleCount = 3
      ..injuredCount = 1
      ..witnessName = 'Témoin Test'
      ..videoAdded = true
      ..observations = 'Le véhicule B changeait de voie.'
      ..sketchConfirmed = true
      ..driverASigned = true;
    source.evidence['Vue d’ensemble'] = true;
    source.evidencePaths['Vue d’ensemble'] = '/photos/vue_ensemble.jpg';
    source.driverBName = 'Conducteur B';
    source.driverBPlate = '123 TUN 4567';
    source.driverBInsurer = 'Assurance Test';
    source.circumstances.addAll(['Changeait de file', 'Virait à gauche']);
    source.impactZones.add('Avant');
    source.sketchStrokes.add([
      {'x': .1, 'y': .2},
      {'x': .8, 'y': .7},
    ]);
    source.driverASignature.add([
      {'x': .2, 'y': .5},
      {'x': .7, 'y': .4},
    ]);

    final row = source.toDatabaseMap(currentStep: 5);
    final restored = AccidentDraft.fromDatabaseMap(row);

    expect(row['current_step'], 5);
    expect(restored.place, source.place);
    expect(restored.latitude, 36.8008);
    expect(restored.longitude, 10.1800);
    expect(restored.locationAccuracy, 8.5);
    expect(restored.vehicleCount, 3);
    expect(restored.injuredCount, 1);
    expect(restored.evidence['Vue d’ensemble'], isTrue);
    expect(
      restored.evidencePaths['Vue d’ensemble'],
      '/photos/vue_ensemble.jpg',
    );
    expect(restored.driverBName, 'Conducteur B');
    expect(restored.driverBPlate, '123 TUN 4567');
    expect(restored.driverBInsurer, 'Assurance Test');
    expect(restored.circumstances, containsAll(source.circumstances));
    expect(restored.impactZones, contains('Avant'));
    expect(restored.observations, source.observations);
    expect(restored.sketchConfirmed, isTrue);
    expect(restored.sketchStrokes.single, hasLength(2));
    expect(restored.driverASignature.single, hasLength(2));
    expect(restored.driverASigned, isTrue);
    expect(restored.driverBSigned, isFalse);
  });

  testWidgets('dessine au curseur dans une zone tactile', (tester) async {
    final strokes = <List<Map<String, double>>>[];
    var saved = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DrawingPad(
            strokes: strokes,
            hint: 'Dessinez ici',
            onChanged: () => saved = true,
          ),
        ),
      ),
    );

    await tester.drag(
      find.byKey(const ValueKey('drawing-surface')),
      const Offset(120, 60),
    );
    await tester.pump();

    expect(strokes, isNotEmpty);
    expect(strokes.first.length, greaterThan(1));
    expect(saved, isTrue);
  });
}
