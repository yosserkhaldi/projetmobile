import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';

void main() {
  test('convertit et restaure un brouillon SQLite complet', () {
    final source = AccidentDraft()
      ..place = 'Avenue de Carthage, Tunis'
      ..vehicleCount = 3
      ..injuredCount = 1
      ..witnessName = 'Témoin Test'
      ..videoAdded = true
      ..observations = 'Le véhicule B changeait de voie.'
      ..sketchConfirmed = true
      ..driverASigned = true;
    source.evidence['Vue d’ensemble'] = true;
    source.circumstances.addAll(['Changeait de file', 'Virait à gauche']);
    source.impactZones.add('Avant');

    final row = source.toDatabaseMap(currentStep: 5);
    final restored = AccidentDraft.fromDatabaseMap(row);

    expect(row['current_step'], 5);
    expect(restored.place, source.place);
    expect(restored.vehicleCount, 3);
    expect(restored.injuredCount, 1);
    expect(restored.evidence['Vue d’ensemble'], isTrue);
    expect(restored.circumstances, containsAll(source.circumstances));
    expect(restored.impactZones, contains('Avant'));
    expect(restored.observations, source.observations);
    expect(restored.sketchConfirmed, isTrue);
    expect(restored.driverASigned, isTrue);
    expect(restored.driverBSigned, isFalse);
  });
}
