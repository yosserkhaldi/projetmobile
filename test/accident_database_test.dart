import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mon_constat_digital/modules/accident/data/accident_database.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';

void main() {
  late AccidentDatabase db;

  setUp(() => db = AccidentDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('sauvegarde, recharge, met à jour et supprime le brouillon', () async {
    expect(await db.loadDraft(), isNull);

    final draft = AccidentDraft()
      ..place = 'Avenue Habib Bourguiba'
      ..latitude = 36.8
      ..longitude = 10.18
      ..injuredCount = 1
      ..videoAdded = true
      ..driverBName = 'Sami'
      ..driverASigned = true;
    draft.circumstances.add('stationnement');
    draft.sketchStrokes.add([
      {'x': 1.0, 'y': 2.0},
    ]);

    await db.saveDraft(draft, 4);
    final saved = await db.loadDraft();
    expect(saved, isNotNull);
    expect(saved!.currentStep, 4);
    expect(saved.draft.place, 'Avenue Habib Bourguiba');
    expect(saved.draft.latitude, 36.8);
    expect(saved.draft.injuredCount, 1);
    expect(saved.draft.videoAdded, isTrue);
    expect(saved.draft.driverBName, 'Sami');
    expect(saved.draft.driverASigned, isTrue);
    expect(saved.draft.circumstances, contains('stationnement'));
    expect(saved.draft.sketchStrokes.single.single['y'], 2.0);

    // Deuxième sauvegarde : remplace la ligne id = 1 (pas de doublon).
    draft.place = 'Rue de Marseille';
    await db.saveDraft(draft, 5);
    final updated = await db.loadDraft();
    expect(updated!.currentStep, 5);
    expect(updated.draft.place, 'Rue de Marseille');
    expect(await db.select(db.accidentDrafts).get(), hasLength(1));

    await db.deleteDraft();
    expect(await db.loadDraft(), isNull);
  });
}
