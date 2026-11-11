import 'dart:convert';

class AccidentDraft {
  AccidentDraft();

  /// Véhicule du conducteur A (module 2), choisi au début de la déclaration.
  /// Son assureur reçoit le sinistre.
  String? vehicleId;

  /// Conducteur A, repris du profil et du véhicule au moment de signer
  /// (pas enregistré : recalculé à partir de [vehicleId] et du compte).
  String driverAName = '';
  String driverALicense = '';
  String driverAPlate = '';
  String driverAVehicle = '';
  String driverAInsurer = '';
  String driverAPolicy = '';
  String? driverACompanyId;

  /// Identifiant de la déclaration sur le serveur (/api/accidents), une fois
  /// envoyée.
  String? serverId;

  /// Identifiant de la déclaration pour le serveur, créé avec le brouillon
  /// et gardé avec lui : un nouvel envoi met à jour la même déclaration au
  /// lieu d'en créer une seconde.
  String clientId = 'acc-${DateTime.now().microsecondsSinceEpoch}';

  /// Vide jusqu'à la position GPS ou la saisie : jamais un lieu inventé.
  String place = '';
  double? latitude;
  double? longitude;
  double? locationAccuracy;
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
  final Map<String, String?> evidencePaths = {};
  bool videoAdded = false;
  bool voiceNoteAdded = false;
  String videoPath = '';
  String voiceNotePath = '';
  String driverBName = '';
  String driverBPermit = '';
  String driverBPermitExpiry = '';
  String driverBPlate = '';
  String driverBInsurer = '';
  /// UUID de la compagnie d'assurance du conducteur B (via CompanyPicker).
  /// Nul si non sélectionné (mode hors-ligne ou QR guest non complété).
  String? driverBCompanyId;
  String driverBPolicy = '';
  final Set<String> circumstancesA = <String>{};
  final Set<String> circumstancesB = <String>{};
  String observations = '';
  final Set<String> impactZones = <String>{};
  bool sketchConfirmed = false;
  final List<List<Map<String, double>>> sketchStrokes = [];
  bool driverASigned = false;
  bool driverBSigned = false;
  final List<List<Map<String, double>>> driverASignature = [];
  final List<List<Map<String, double>>> driverBSignature = [];
  DateTime lastSavedAt = DateTime.now();

  bool get hasInjured => injuredCount > 0;
  int get evidenceCount => evidence.values.where((value) => value).length;

  void touch() => lastSavedAt = DateTime.now();

  Map<String, Object?> toDatabaseMap({required int currentStep}) => {
    'id': 1,
    'current_step': currentStep,
    'client_id': clientId,
    'vehicle_id': vehicleId,
    'place': place,
    'latitude': latitude,
    'longitude': longitude,
    'location_accuracy': locationAccuracy,
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
    'evidence_paths_json': jsonEncode(evidencePaths),
    'video_added': videoAdded ? 1 : 0,
    'voice_note_added': voiceNoteAdded ? 1 : 0,
    'video_path': videoPath,
    'voice_note_path': voiceNotePath,
    'driver_b_name': driverBName,
    'driver_b_permit': driverBPermit,
    'driver_b_permit_expiry': driverBPermitExpiry,
    'driver_b_plate': driverBPlate,
    'driver_b_insurer': driverBInsurer,
    'driver_b_company_id': driverBCompanyId,
    'driver_b_policy': driverBPolicy,
    'circumstances_json': jsonEncode({
      'A': circumstancesA.toList(),
      'B': circumstancesB.toList(),
    }),
    'observations': observations,
    'impact_zones_json': jsonEncode(impactZones.toList()),
    'sketch_confirmed': sketchConfirmed ? 1 : 0,
    'sketch_strokes_json': jsonEncode(sketchStrokes),
    'driver_a_signed': driverASigned ? 1 : 0,
    'driver_b_signed': driverBSigned ? 1 : 0,
    'driver_a_signature_json': jsonEncode(driverASignature),
    'driver_b_signature_json': jsonEncode(driverBSignature),
    'last_saved_at': lastSavedAt.toIso8601String(),
  };

  factory AccidentDraft.fromDatabaseMap(Map<String, Object?> row) {
    final draft = AccidentDraft()
      ..clientId = row['client_id'] as String? ?? 'acc-${DateTime.now().microsecondsSinceEpoch}'
      ..vehicleId = row['vehicle_id'] as String?
      ..place = row['place'] as String? ?? ''
      ..latitude = (row['latitude'] as num?)?.toDouble()
      ..longitude = (row['longitude'] as num?)?.toDouble()
      ..locationAccuracy = (row['location_accuracy'] as num?)?.toDouble()
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
      ..videoPath = row['video_path'] as String? ?? ''
      ..voiceNotePath = row['voice_note_path'] as String? ?? ''
      ..driverBName = row['driver_b_name'] as String? ?? ''
      ..driverBPermit = row['driver_b_permit'] as String? ?? ''
      ..driverBPermitExpiry = row['driver_b_permit_expiry'] as String? ?? ''
      ..driverBPlate = row['driver_b_plate'] as String? ?? ''
      ..driverBInsurer = row['driver_b_insurer'] as String? ?? ''
      ..driverBCompanyId = row['driver_b_company_id'] as String?
      ..driverBPolicy = row['driver_b_policy'] as String? ?? ''
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
    draft.evidencePaths.addAll(
      _decodeNullableStringMap(row['evidence_paths_json'] as String?),
    );
    final rawCircumstances = row['circumstances_json'];
    if (rawCircumstances is String && rawCircumstances.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawCircumstances);
        if (decoded is Map) {
          draft.circumstancesA.addAll((decoded['A'] as List?)?.map((e) => e.toString()) ?? []);
          draft.circumstancesB.addAll((decoded['B'] as List?)?.map((e) => e.toString()) ?? []);
        } else if (decoded is List) {
          draft.circumstancesA.addAll(decoded.map((e) => e.toString()));
        }
      } catch (_) {
        draft.circumstancesA.addAll(_decodeList(rawCircumstances));
      }
    }
    draft.impactZones.addAll(_decodeList(row['impact_zones_json'] as String?));
    draft.sketchStrokes.addAll(
      _decodeStrokes(row['sketch_strokes_json'] as String?),
    );
    draft.driverASignature.addAll(
      _decodeStrokes(row['driver_a_signature_json'] as String?),
    );
    draft.driverBSignature.addAll(
      _decodeStrokes(row['driver_b_signature_json'] as String?),
    );
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

  static Map<String, String?> _decodeNullableStringMap(String? value) {
    if (value == null || value.isEmpty) return {};
    final decoded = jsonDecode(value) as Map<String, dynamic>;
    return decoded.map((key, item) => MapEntry(key, item?.toString()));
  }

  static List<List<Map<String, double>>> _decodeStrokes(String? value) {
    if (value == null || value.isEmpty) return [];
    final decoded = jsonDecode(value) as List<dynamic>;
    return decoded
        .map(
          (stroke) => (stroke as List<dynamic>)
              .map(
                (point) => (point as Map<String, dynamic>).map(
                  (key, coordinate) =>
                      MapEntry(key, (coordinate as num).toDouble()),
                ),
              )
              .toList(),
        )
        .toList();
  }
}
