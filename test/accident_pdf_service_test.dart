import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_pdf_service.dart';

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
}
