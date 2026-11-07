import 'dart:convert';

class AccidentDraft {
  AccidentDraft();

  String place = 'Position GPS détectée — Tunis';
  DateTime occurredAt = DateTime.now();
  String weather = 'Ensoleillé';
  String road = 'Sèche';
  String light = 'Jour';
  String type = 'Collision';
  String severity = 'Matériel';
  int vehicleCount = 2;
  int injuredCount = 0;
  String witnessName = '';
  String witnessPhone = '';
  final Map<String, bool> evidence = {
    'Vue d’ensemble': false,
    'Dégâts véhicule A': false,
    'Dégâts véhicule B': false,
    'Plaques': false,
  };
  bool videoAdded = false;
  bool voiceNoteAdded = false;
  final Set<String> circumstances = <String>{};
  String observations = '';
  final Set<String> impactZones = <String>{};
  bool sketchConfirmed = false;
  bool driverASigned = false;
  bool driverBSigned = false;
  DateTime lastSavedAt = DateTime.now();

  bool get hasInjured => injuredCount > 0;
  int get evidenceCount => evidence.values.where((value) => value).length;

  void touch() => lastSavedAt = DateTime.now();

  Map<String, Object?> toDatabaseMap({required int currentStep}) => {
    'id': 1,
    'current_step': currentStep,
    'place': place,
    'occurred_at': occurredAt.toIso8601String(),
    'weather': weather,
    'road': road,
    'light': light,
    'type': type,
    'severity': severity,
    'vehicle_count': vehicleCount,
    'injured_count': injuredCount,
    'witness_name': witnessName,
    'witness_phone': witnessPhone,
    'evidence_json': jsonEncode(evidence),
    'video_added': videoAdded ? 1 : 0,
    'voice_note_added': voiceNoteAdded ? 1 : 0,
    'circumstances_json': jsonEncode(circumstances.toList()),
    'observations': observations,
    'impact_zones_json': jsonEncode(impactZones.toList()),
    'sketch_confirmed': sketchConfirmed ? 1 : 0,
    'driver_a_signed': driverASigned ? 1 : 0,
    'driver_b_signed': driverBSigned ? 1 : 0,
    'last_saved_at': lastSavedAt.toIso8601String(),
  };

  factory AccidentDraft.fromDatabaseMap(Map<String, Object?> row) {
    final draft = AccidentDraft()
      ..place = row['place'] as String? ?? ''
      ..occurredAt =
          DateTime.tryParse(row['occurred_at'] as String? ?? '') ??
          DateTime.now()
      ..weather = row['weather'] as String? ?? 'Ensoleillé'
      ..road = row['road'] as String? ?? 'Sèche'
      ..light = row['light'] as String? ?? 'Jour'
      ..type = row['type'] as String? ?? 'Collision'
      ..severity = row['severity'] as String? ?? 'Matériel'
      ..vehicleCount = row['vehicle_count'] as int? ?? 2
      ..injuredCount = row['injured_count'] as int? ?? 0
      ..witnessName = row['witness_name'] as String? ?? ''
      ..witnessPhone = row['witness_phone'] as String? ?? ''
      ..videoAdded = row['video_added'] == 1
      ..voiceNoteAdded = row['voice_note_added'] == 1
      ..observations = row['observations'] as String? ?? ''
      ..sketchConfirmed = row['sketch_confirmed'] == 1
      ..driverASigned = row['driver_a_signed'] == 1
      ..driverBSigned = row['driver_b_signed'] == 1
      ..lastSavedAt =
          DateTime.tryParse(row['last_saved_at'] as String? ?? '') ??
          DateTime.now();

    final savedEvidence = _decodeMap(row['evidence_json'] as String?);
    if (savedEvidence.isNotEmpty) {
      draft.evidence
        ..clear()
        ..addAll(savedEvidence);
    }
    draft.circumstances.addAll(
      _decodeList(row['circumstances_json'] as String?),
    );
    draft.impactZones.addAll(_decodeList(row['impact_zones_json'] as String?));
    return draft;
  }

  static Map<String, bool> _decodeMap(String? value) {
    if (value == null || value.isEmpty) return {};
    final decoded = jsonDecode(value) as Map<String, dynamic>;
    return decoded.map((key, item) => MapEntry(key, item == true));
  }

  static List<String> _decodeList(String? value) {
    if (value == null || value.isEmpty) return [];
    return (jsonDecode(value) as List<dynamic>).cast<String>();
  }
}
