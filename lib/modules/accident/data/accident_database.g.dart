// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accident_database.dart';

// ignore_for_file: type=lint
class $AccidentDraftsTable extends AccidentDrafts
    with TableInfo<$AccidentDraftsTable, AccidentDraftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccidentDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentStepMeta = const VerificationMeta(
    'currentStep',
  );
  @override
  late final GeneratedColumn<int> currentStep = GeneratedColumn<int>(
    'current_step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeMeta = const VerificationMeta('place');
  @override
  late final GeneratedColumn<String> place = GeneratedColumn<String>(
    'place',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationAccuracyMeta = const VerificationMeta(
    'locationAccuracy',
  );
  @override
  late final GeneratedColumn<double> locationAccuracy = GeneratedColumn<double>(
    'location_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<String> occurredAt = GeneratedColumn<String>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weatherMeta = const VerificationMeta(
    'weather',
  );
  @override
  late final GeneratedColumn<String> weather = GeneratedColumn<String>(
    'weather',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roadMeta = const VerificationMeta('road');
  @override
  late final GeneratedColumn<String> road = GeneratedColumn<String>(
    'road',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lightMeta = const VerificationMeta('light');
  @override
  late final GeneratedColumn<String> light = GeneratedColumn<String>(
    'light',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleCountMeta = const VerificationMeta(
    'vehicleCount',
  );
  @override
  late final GeneratedColumn<int> vehicleCount = GeneratedColumn<int>(
    'vehicle_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _injuredCountMeta = const VerificationMeta(
    'injuredCount',
  );
  @override
  late final GeneratedColumn<int> injuredCount = GeneratedColumn<int>(
    'injured_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _witnessNameMeta = const VerificationMeta(
    'witnessName',
  );
  @override
  late final GeneratedColumn<String> witnessName = GeneratedColumn<String>(
    'witness_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _witnessPhoneMeta = const VerificationMeta(
    'witnessPhone',
  );
  @override
  late final GeneratedColumn<String> witnessPhone = GeneratedColumn<String>(
    'witness_phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evidenceJsonMeta = const VerificationMeta(
    'evidenceJson',
  );
  @override
  late final GeneratedColumn<String> evidenceJson = GeneratedColumn<String>(
    'evidence_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evidencePathsJsonMeta = const VerificationMeta(
    'evidencePathsJson',
  );
  @override
  late final GeneratedColumn<String> evidencePathsJson =
      GeneratedColumn<String>(
        'evidence_paths_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _videoAddedMeta = const VerificationMeta(
    'videoAdded',
  );
  @override
  late final GeneratedColumn<bool> videoAdded = GeneratedColumn<bool>(
    'video_added',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("video_added" IN (0, 1))',
    ),
  );
  static const VerificationMeta _voiceNoteAddedMeta = const VerificationMeta(
    'voiceNoteAdded',
  );
  @override
  late final GeneratedColumn<bool> voiceNoteAdded = GeneratedColumn<bool>(
    'voice_note_added',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("voice_note_added" IN (0, 1))',
    ),
  );
  static const VerificationMeta _videoPathMeta = const VerificationMeta(
    'videoPath',
  );
  @override
  late final GeneratedColumn<String> videoPath = GeneratedColumn<String>(
    'video_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _voiceNotePathMeta = const VerificationMeta(
    'voiceNotePath',
  );
  @override
  late final GeneratedColumn<String> voiceNotePath = GeneratedColumn<String>(
    'voice_note_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _driverBNameMeta = const VerificationMeta(
    'driverBName',
  );
  @override
  late final GeneratedColumn<String> driverBName = GeneratedColumn<String>(
    'driver_b_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _driverBPermitMeta = const VerificationMeta(
    'driverBPermit',
  );
  @override
  late final GeneratedColumn<String> driverBPermit = GeneratedColumn<String>(
    'driver_b_permit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _driverBPermitExpiryMeta =
      const VerificationMeta('driverBPermitExpiry');
  @override
  late final GeneratedColumn<String> driverBPermitExpiry =
      GeneratedColumn<String>(
        'driver_b_permit_expiry',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _driverBPlateMeta = const VerificationMeta(
    'driverBPlate',
  );
  @override
  late final GeneratedColumn<String> driverBPlate = GeneratedColumn<String>(
    'driver_b_plate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _driverBInsurerMeta = const VerificationMeta(
    'driverBInsurer',
  );
  @override
  late final GeneratedColumn<String> driverBInsurer = GeneratedColumn<String>(
    'driver_b_insurer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _driverBPolicyMeta = const VerificationMeta(
    'driverBPolicy',
  );
  @override
  late final GeneratedColumn<String> driverBPolicy = GeneratedColumn<String>(
    'driver_b_policy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _circumstancesJsonMeta = const VerificationMeta(
    'circumstancesJson',
  );
  @override
  late final GeneratedColumn<String> circumstancesJson =
      GeneratedColumn<String>(
        'circumstances_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _observationsMeta = const VerificationMeta(
    'observations',
  );
  @override
  late final GeneratedColumn<String> observations = GeneratedColumn<String>(
    'observations',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _impactZonesJsonMeta = const VerificationMeta(
    'impactZonesJson',
  );
  @override
  late final GeneratedColumn<String> impactZonesJson = GeneratedColumn<String>(
    'impact_zones_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sketchConfirmedMeta = const VerificationMeta(
    'sketchConfirmed',
  );
  @override
  late final GeneratedColumn<bool> sketchConfirmed = GeneratedColumn<bool>(
    'sketch_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sketch_confirmed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _sketchStrokesJsonMeta = const VerificationMeta(
    'sketchStrokesJson',
  );
  @override
  late final GeneratedColumn<String> sketchStrokesJson =
      GeneratedColumn<String>(
        'sketch_strokes_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _driverASignedMeta = const VerificationMeta(
    'driverASigned',
  );
  @override
  late final GeneratedColumn<bool> driverASigned = GeneratedColumn<bool>(
    'driver_a_signed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("driver_a_signed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _driverBSignedMeta = const VerificationMeta(
    'driverBSigned',
  );
  @override
  late final GeneratedColumn<bool> driverBSigned = GeneratedColumn<bool>(
    'driver_b_signed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("driver_b_signed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _driverASignatureJsonMeta =
      const VerificationMeta('driverASignatureJson');
  @override
  late final GeneratedColumn<String> driverASignatureJson =
      GeneratedColumn<String>(
        'driver_a_signature_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _driverBSignatureJsonMeta =
      const VerificationMeta('driverBSignatureJson');
  @override
  late final GeneratedColumn<String> driverBSignatureJson =
      GeneratedColumn<String>(
        'driver_b_signature_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _lastSavedAtMeta = const VerificationMeta(
    'lastSavedAt',
  );
  @override
  late final GeneratedColumn<String> lastSavedAt = GeneratedColumn<String>(
    'last_saved_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentStep,
    place,
    latitude,
    longitude,
    locationAccuracy,
    occurredAt,
    weather,
    road,
    light,
    type,
    severity,
    vehicleCount,
    injuredCount,
    witnessName,
    witnessPhone,
    evidenceJson,
    evidencePathsJson,
    videoAdded,
    voiceNoteAdded,
    videoPath,
    voiceNotePath,
    driverBName,
    driverBPermit,
    driverBPermitExpiry,
    driverBPlate,
    driverBInsurer,
    driverBPolicy,
    circumstancesJson,
    observations,
    impactZonesJson,
    sketchConfirmed,
    sketchStrokesJson,
    driverASigned,
    driverBSigned,
    driverASignatureJson,
    driverBSignatureJson,
    lastSavedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accident_draft';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccidentDraftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current_step')) {
      context.handle(
        _currentStepMeta,
        currentStep.isAcceptableOrUnknown(
          data['current_step']!,
          _currentStepMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentStepMeta);
    }
    if (data.containsKey('place')) {
      context.handle(
        _placeMeta,
        place.isAcceptableOrUnknown(data['place']!, _placeMeta),
      );
    } else if (isInserting) {
      context.missing(_placeMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('location_accuracy')) {
      context.handle(
        _locationAccuracyMeta,
        locationAccuracy.isAcceptableOrUnknown(
          data['location_accuracy']!,
          _locationAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('weather')) {
      context.handle(
        _weatherMeta,
        weather.isAcceptableOrUnknown(data['weather']!, _weatherMeta),
      );
    } else if (isInserting) {
      context.missing(_weatherMeta);
    }
    if (data.containsKey('road')) {
      context.handle(
        _roadMeta,
        road.isAcceptableOrUnknown(data['road']!, _roadMeta),
      );
    } else if (isInserting) {
      context.missing(_roadMeta);
    }
    if (data.containsKey('light')) {
      context.handle(
        _lightMeta,
        light.isAcceptableOrUnknown(data['light']!, _lightMeta),
      );
    } else if (isInserting) {
      context.missing(_lightMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('vehicle_count')) {
      context.handle(
        _vehicleCountMeta,
        vehicleCount.isAcceptableOrUnknown(
          data['vehicle_count']!,
          _vehicleCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vehicleCountMeta);
    }
    if (data.containsKey('injured_count')) {
      context.handle(
        _injuredCountMeta,
        injuredCount.isAcceptableOrUnknown(
          data['injured_count']!,
          _injuredCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_injuredCountMeta);
    }
    if (data.containsKey('witness_name')) {
      context.handle(
        _witnessNameMeta,
        witnessName.isAcceptableOrUnknown(
          data['witness_name']!,
          _witnessNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_witnessNameMeta);
    }
    if (data.containsKey('witness_phone')) {
      context.handle(
        _witnessPhoneMeta,
        witnessPhone.isAcceptableOrUnknown(
          data['witness_phone']!,
          _witnessPhoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_witnessPhoneMeta);
    }
    if (data.containsKey('evidence_json')) {
      context.handle(
        _evidenceJsonMeta,
        evidenceJson.isAcceptableOrUnknown(
          data['evidence_json']!,
          _evidenceJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_evidenceJsonMeta);
    }
    if (data.containsKey('evidence_paths_json')) {
      context.handle(
        _evidencePathsJsonMeta,
        evidencePathsJson.isAcceptableOrUnknown(
          data['evidence_paths_json']!,
          _evidencePathsJsonMeta,
        ),
      );
    }
    if (data.containsKey('video_added')) {
      context.handle(
        _videoAddedMeta,
        videoAdded.isAcceptableOrUnknown(data['video_added']!, _videoAddedMeta),
      );
    } else if (isInserting) {
      context.missing(_videoAddedMeta);
    }
    if (data.containsKey('voice_note_added')) {
      context.handle(
        _voiceNoteAddedMeta,
        voiceNoteAdded.isAcceptableOrUnknown(
          data['voice_note_added']!,
          _voiceNoteAddedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_voiceNoteAddedMeta);
    }
    if (data.containsKey('video_path')) {
      context.handle(
        _videoPathMeta,
        videoPath.isAcceptableOrUnknown(data['video_path']!, _videoPathMeta),
      );
    }
    if (data.containsKey('voice_note_path')) {
      context.handle(
        _voiceNotePathMeta,
        voiceNotePath.isAcceptableOrUnknown(
          data['voice_note_path']!,
          _voiceNotePathMeta,
        ),
      );
    }
    if (data.containsKey('driver_b_name')) {
      context.handle(
        _driverBNameMeta,
        driverBName.isAcceptableOrUnknown(
          data['driver_b_name']!,
          _driverBNameMeta,
        ),
      );
    }
    if (data.containsKey('driver_b_permit')) {
      context.handle(
        _driverBPermitMeta,
        driverBPermit.isAcceptableOrUnknown(
          data['driver_b_permit']!,
          _driverBPermitMeta,
        ),
      );
    }
    if (data.containsKey('driver_b_permit_expiry')) {
      context.handle(
        _driverBPermitExpiryMeta,
        driverBPermitExpiry.isAcceptableOrUnknown(
          data['driver_b_permit_expiry']!,
          _driverBPermitExpiryMeta,
        ),
      );
    }
    if (data.containsKey('driver_b_plate')) {
      context.handle(
        _driverBPlateMeta,
        driverBPlate.isAcceptableOrUnknown(
          data['driver_b_plate']!,
          _driverBPlateMeta,
        ),
      );
    }
    if (data.containsKey('driver_b_insurer')) {
      context.handle(
        _driverBInsurerMeta,
        driverBInsurer.isAcceptableOrUnknown(
          data['driver_b_insurer']!,
          _driverBInsurerMeta,
        ),
      );
    }
    if (data.containsKey('driver_b_policy')) {
      context.handle(
        _driverBPolicyMeta,
        driverBPolicy.isAcceptableOrUnknown(
          data['driver_b_policy']!,
          _driverBPolicyMeta,
        ),
      );
    }
    if (data.containsKey('circumstances_json')) {
      context.handle(
        _circumstancesJsonMeta,
        circumstancesJson.isAcceptableOrUnknown(
          data['circumstances_json']!,
          _circumstancesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_circumstancesJsonMeta);
    }
    if (data.containsKey('observations')) {
      context.handle(
        _observationsMeta,
        observations.isAcceptableOrUnknown(
          data['observations']!,
          _observationsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observationsMeta);
    }
    if (data.containsKey('impact_zones_json')) {
      context.handle(
        _impactZonesJsonMeta,
        impactZonesJson.isAcceptableOrUnknown(
          data['impact_zones_json']!,
          _impactZonesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_impactZonesJsonMeta);
    }
    if (data.containsKey('sketch_confirmed')) {
      context.handle(
        _sketchConfirmedMeta,
        sketchConfirmed.isAcceptableOrUnknown(
          data['sketch_confirmed']!,
          _sketchConfirmedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sketchConfirmedMeta);
    }
    if (data.containsKey('sketch_strokes_json')) {
      context.handle(
        _sketchStrokesJsonMeta,
        sketchStrokesJson.isAcceptableOrUnknown(
          data['sketch_strokes_json']!,
          _sketchStrokesJsonMeta,
        ),
      );
    }
    if (data.containsKey('driver_a_signed')) {
      context.handle(
        _driverASignedMeta,
        driverASigned.isAcceptableOrUnknown(
          data['driver_a_signed']!,
          _driverASignedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_driverASignedMeta);
    }
    if (data.containsKey('driver_b_signed')) {
      context.handle(
        _driverBSignedMeta,
        driverBSigned.isAcceptableOrUnknown(
          data['driver_b_signed']!,
          _driverBSignedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_driverBSignedMeta);
    }
    if (data.containsKey('driver_a_signature_json')) {
      context.handle(
        _driverASignatureJsonMeta,
        driverASignatureJson.isAcceptableOrUnknown(
          data['driver_a_signature_json']!,
          _driverASignatureJsonMeta,
        ),
      );
    }
    if (data.containsKey('driver_b_signature_json')) {
      context.handle(
        _driverBSignatureJsonMeta,
        driverBSignatureJson.isAcceptableOrUnknown(
          data['driver_b_signature_json']!,
          _driverBSignatureJsonMeta,
        ),
      );
    }
    if (data.containsKey('last_saved_at')) {
      context.handle(
        _lastSavedAtMeta,
        lastSavedAt.isAcceptableOrUnknown(
          data['last_saved_at']!,
          _lastSavedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSavedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccidentDraftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccidentDraftRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currentStep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_step'],
      )!,
      place: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      locationAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}location_accuracy'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurred_at'],
      )!,
      weather: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather'],
      )!,
      road: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}road'],
      )!,
      light: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}light'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      vehicleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_count'],
      )!,
      injuredCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}injured_count'],
      )!,
      witnessName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}witness_name'],
      )!,
      witnessPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}witness_phone'],
      )!,
      evidenceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_json'],
      )!,
      evidencePathsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_paths_json'],
      )!,
      videoAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}video_added'],
      )!,
      voiceNoteAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}voice_note_added'],
      )!,
      videoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_path'],
      )!,
      voiceNotePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_note_path'],
      )!,
      driverBName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_b_name'],
      )!,
      driverBPermit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_b_permit'],
      )!,
      driverBPermitExpiry: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_b_permit_expiry'],
      )!,
      driverBPlate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_b_plate'],
      )!,
      driverBInsurer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_b_insurer'],
      )!,
      driverBPolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_b_policy'],
      )!,
      circumstancesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}circumstances_json'],
      )!,
      observations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observations'],
      )!,
      impactZonesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}impact_zones_json'],
      )!,
      sketchConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sketch_confirmed'],
      )!,
      sketchStrokesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sketch_strokes_json'],
      )!,
      driverASigned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}driver_a_signed'],
      )!,
      driverBSigned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}driver_b_signed'],
      )!,
      driverASignatureJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_a_signature_json'],
      )!,
      driverBSignatureJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_b_signature_json'],
      )!,
      lastSavedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_saved_at'],
      )!,
    );
  }

  @override
  $AccidentDraftsTable createAlias(String alias) {
    return $AccidentDraftsTable(attachedDatabase, alias);
  }
}

class AccidentDraftRow extends DataClass
    implements Insertable<AccidentDraftRow> {
  final int id;
  final int currentStep;
  final String place;
  final double? latitude;
  final double? longitude;
  final double? locationAccuracy;
  final String occurredAt;
  final String weather;
  final String road;
  final String light;
  final String type;
  final String severity;
  final int vehicleCount;
  final int injuredCount;
  final String witnessName;
  final String witnessPhone;
  final String evidenceJson;
  final String evidencePathsJson;
  final bool videoAdded;
  final bool voiceNoteAdded;
  final String videoPath;
  final String voiceNotePath;
  final String driverBName;
  final String driverBPermit;
  final String driverBPermitExpiry;
  final String driverBPlate;
  final String driverBInsurer;
  final String driverBPolicy;
  final String circumstancesJson;
  final String observations;
  final String impactZonesJson;
  final bool sketchConfirmed;
  final String sketchStrokesJson;
  final bool driverASigned;
  final bool driverBSigned;
  final String driverASignatureJson;
  final String driverBSignatureJson;
  final String lastSavedAt;
  const AccidentDraftRow({
    required this.id,
    required this.currentStep,
    required this.place,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    required this.occurredAt,
    required this.weather,
    required this.road,
    required this.light,
    required this.type,
    required this.severity,
    required this.vehicleCount,
    required this.injuredCount,
    required this.witnessName,
    required this.witnessPhone,
    required this.evidenceJson,
    required this.evidencePathsJson,
    required this.videoAdded,
    required this.voiceNoteAdded,
    required this.videoPath,
    required this.voiceNotePath,
    required this.driverBName,
    required this.driverBPermit,
    required this.driverBPermitExpiry,
    required this.driverBPlate,
    required this.driverBInsurer,
    required this.driverBPolicy,
    required this.circumstancesJson,
    required this.observations,
    required this.impactZonesJson,
    required this.sketchConfirmed,
    required this.sketchStrokesJson,
    required this.driverASigned,
    required this.driverBSigned,
    required this.driverASignatureJson,
    required this.driverBSignatureJson,
    required this.lastSavedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['current_step'] = Variable<int>(currentStep);
    map['place'] = Variable<String>(place);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || locationAccuracy != null) {
      map['location_accuracy'] = Variable<double>(locationAccuracy);
    }
    map['occurred_at'] = Variable<String>(occurredAt);
    map['weather'] = Variable<String>(weather);
    map['road'] = Variable<String>(road);
    map['light'] = Variable<String>(light);
    map['type'] = Variable<String>(type);
    map['severity'] = Variable<String>(severity);
    map['vehicle_count'] = Variable<int>(vehicleCount);
    map['injured_count'] = Variable<int>(injuredCount);
    map['witness_name'] = Variable<String>(witnessName);
    map['witness_phone'] = Variable<String>(witnessPhone);
    map['evidence_json'] = Variable<String>(evidenceJson);
    map['evidence_paths_json'] = Variable<String>(evidencePathsJson);
    map['video_added'] = Variable<bool>(videoAdded);
    map['voice_note_added'] = Variable<bool>(voiceNoteAdded);
    map['video_path'] = Variable<String>(videoPath);
    map['voice_note_path'] = Variable<String>(voiceNotePath);
    map['driver_b_name'] = Variable<String>(driverBName);
    map['driver_b_permit'] = Variable<String>(driverBPermit);
    map['driver_b_permit_expiry'] = Variable<String>(driverBPermitExpiry);
    map['driver_b_plate'] = Variable<String>(driverBPlate);
    map['driver_b_insurer'] = Variable<String>(driverBInsurer);
    map['driver_b_policy'] = Variable<String>(driverBPolicy);
    map['circumstances_json'] = Variable<String>(circumstancesJson);
    map['observations'] = Variable<String>(observations);
    map['impact_zones_json'] = Variable<String>(impactZonesJson);
    map['sketch_confirmed'] = Variable<bool>(sketchConfirmed);
    map['sketch_strokes_json'] = Variable<String>(sketchStrokesJson);
    map['driver_a_signed'] = Variable<bool>(driverASigned);
    map['driver_b_signed'] = Variable<bool>(driverBSigned);
    map['driver_a_signature_json'] = Variable<String>(driverASignatureJson);
    map['driver_b_signature_json'] = Variable<String>(driverBSignatureJson);
    map['last_saved_at'] = Variable<String>(lastSavedAt);
    return map;
  }

  AccidentDraftsCompanion toCompanion(bool nullToAbsent) {
    return AccidentDraftsCompanion(
      id: Value(id),
      currentStep: Value(currentStep),
      place: Value(place),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      locationAccuracy: locationAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(locationAccuracy),
      occurredAt: Value(occurredAt),
      weather: Value(weather),
      road: Value(road),
      light: Value(light),
      type: Value(type),
      severity: Value(severity),
      vehicleCount: Value(vehicleCount),
      injuredCount: Value(injuredCount),
      witnessName: Value(witnessName),
      witnessPhone: Value(witnessPhone),
      evidenceJson: Value(evidenceJson),
      evidencePathsJson: Value(evidencePathsJson),
      videoAdded: Value(videoAdded),
      voiceNoteAdded: Value(voiceNoteAdded),
      videoPath: Value(videoPath),
      voiceNotePath: Value(voiceNotePath),
      driverBName: Value(driverBName),
      driverBPermit: Value(driverBPermit),
      driverBPermitExpiry: Value(driverBPermitExpiry),
      driverBPlate: Value(driverBPlate),
      driverBInsurer: Value(driverBInsurer),
      driverBPolicy: Value(driverBPolicy),
      circumstancesJson: Value(circumstancesJson),
      observations: Value(observations),
      impactZonesJson: Value(impactZonesJson),
      sketchConfirmed: Value(sketchConfirmed),
      sketchStrokesJson: Value(sketchStrokesJson),
      driverASigned: Value(driverASigned),
      driverBSigned: Value(driverBSigned),
      driverASignatureJson: Value(driverASignatureJson),
      driverBSignatureJson: Value(driverBSignatureJson),
      lastSavedAt: Value(lastSavedAt),
    );
  }

  factory AccidentDraftRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccidentDraftRow(
      id: serializer.fromJson<int>(json['id']),
      currentStep: serializer.fromJson<int>(json['currentStep']),
      place: serializer.fromJson<String>(json['place']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      locationAccuracy: serializer.fromJson<double?>(json['locationAccuracy']),
      occurredAt: serializer.fromJson<String>(json['occurredAt']),
      weather: serializer.fromJson<String>(json['weather']),
      road: serializer.fromJson<String>(json['road']),
      light: serializer.fromJson<String>(json['light']),
      type: serializer.fromJson<String>(json['type']),
      severity: serializer.fromJson<String>(json['severity']),
      vehicleCount: serializer.fromJson<int>(json['vehicleCount']),
      injuredCount: serializer.fromJson<int>(json['injuredCount']),
      witnessName: serializer.fromJson<String>(json['witnessName']),
      witnessPhone: serializer.fromJson<String>(json['witnessPhone']),
      evidenceJson: serializer.fromJson<String>(json['evidenceJson']),
      evidencePathsJson: serializer.fromJson<String>(json['evidencePathsJson']),
      videoAdded: serializer.fromJson<bool>(json['videoAdded']),
      voiceNoteAdded: serializer.fromJson<bool>(json['voiceNoteAdded']),
      videoPath: serializer.fromJson<String>(json['videoPath']),
      voiceNotePath: serializer.fromJson<String>(json['voiceNotePath']),
      driverBName: serializer.fromJson<String>(json['driverBName']),
      driverBPermit: serializer.fromJson<String>(json['driverBPermit']),
      driverBPermitExpiry: serializer.fromJson<String>(
        json['driverBPermitExpiry'],
      ),
      driverBPlate: serializer.fromJson<String>(json['driverBPlate']),
      driverBInsurer: serializer.fromJson<String>(json['driverBInsurer']),
      driverBPolicy: serializer.fromJson<String>(json['driverBPolicy']),
      circumstancesJson: serializer.fromJson<String>(json['circumstancesJson']),
      observations: serializer.fromJson<String>(json['observations']),
      impactZonesJson: serializer.fromJson<String>(json['impactZonesJson']),
      sketchConfirmed: serializer.fromJson<bool>(json['sketchConfirmed']),
      sketchStrokesJson: serializer.fromJson<String>(json['sketchStrokesJson']),
      driverASigned: serializer.fromJson<bool>(json['driverASigned']),
      driverBSigned: serializer.fromJson<bool>(json['driverBSigned']),
      driverASignatureJson: serializer.fromJson<String>(
        json['driverASignatureJson'],
      ),
      driverBSignatureJson: serializer.fromJson<String>(
        json['driverBSignatureJson'],
      ),
      lastSavedAt: serializer.fromJson<String>(json['lastSavedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currentStep': serializer.toJson<int>(currentStep),
      'place': serializer.toJson<String>(place),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'locationAccuracy': serializer.toJson<double?>(locationAccuracy),
      'occurredAt': serializer.toJson<String>(occurredAt),
      'weather': serializer.toJson<String>(weather),
      'road': serializer.toJson<String>(road),
      'light': serializer.toJson<String>(light),
      'type': serializer.toJson<String>(type),
      'severity': serializer.toJson<String>(severity),
      'vehicleCount': serializer.toJson<int>(vehicleCount),
      'injuredCount': serializer.toJson<int>(injuredCount),
      'witnessName': serializer.toJson<String>(witnessName),
      'witnessPhone': serializer.toJson<String>(witnessPhone),
      'evidenceJson': serializer.toJson<String>(evidenceJson),
      'evidencePathsJson': serializer.toJson<String>(evidencePathsJson),
      'videoAdded': serializer.toJson<bool>(videoAdded),
      'voiceNoteAdded': serializer.toJson<bool>(voiceNoteAdded),
      'videoPath': serializer.toJson<String>(videoPath),
      'voiceNotePath': serializer.toJson<String>(voiceNotePath),
      'driverBName': serializer.toJson<String>(driverBName),
      'driverBPermit': serializer.toJson<String>(driverBPermit),
      'driverBPermitExpiry': serializer.toJson<String>(driverBPermitExpiry),
      'driverBPlate': serializer.toJson<String>(driverBPlate),
      'driverBInsurer': serializer.toJson<String>(driverBInsurer),
      'driverBPolicy': serializer.toJson<String>(driverBPolicy),
      'circumstancesJson': serializer.toJson<String>(circumstancesJson),
      'observations': serializer.toJson<String>(observations),
      'impactZonesJson': serializer.toJson<String>(impactZonesJson),
      'sketchConfirmed': serializer.toJson<bool>(sketchConfirmed),
      'sketchStrokesJson': serializer.toJson<String>(sketchStrokesJson),
      'driverASigned': serializer.toJson<bool>(driverASigned),
      'driverBSigned': serializer.toJson<bool>(driverBSigned),
      'driverASignatureJson': serializer.toJson<String>(driverASignatureJson),
      'driverBSignatureJson': serializer.toJson<String>(driverBSignatureJson),
      'lastSavedAt': serializer.toJson<String>(lastSavedAt),
    };
  }

  AccidentDraftRow copyWith({
    int? id,
    int? currentStep,
    String? place,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<double?> locationAccuracy = const Value.absent(),
    String? occurredAt,
    String? weather,
    String? road,
    String? light,
    String? type,
    String? severity,
    int? vehicleCount,
    int? injuredCount,
    String? witnessName,
    String? witnessPhone,
    String? evidenceJson,
    String? evidencePathsJson,
    bool? videoAdded,
    bool? voiceNoteAdded,
    String? videoPath,
    String? voiceNotePath,
    String? driverBName,
    String? driverBPermit,
    String? driverBPermitExpiry,
    String? driverBPlate,
    String? driverBInsurer,
    String? driverBPolicy,
    String? circumstancesJson,
    String? observations,
    String? impactZonesJson,
    bool? sketchConfirmed,
    String? sketchStrokesJson,
    bool? driverASigned,
    bool? driverBSigned,
    String? driverASignatureJson,
    String? driverBSignatureJson,
    String? lastSavedAt,
  }) => AccidentDraftRow(
    id: id ?? this.id,
    currentStep: currentStep ?? this.currentStep,
    place: place ?? this.place,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    locationAccuracy: locationAccuracy.present
        ? locationAccuracy.value
        : this.locationAccuracy,
    occurredAt: occurredAt ?? this.occurredAt,
    weather: weather ?? this.weather,
    road: road ?? this.road,
    light: light ?? this.light,
    type: type ?? this.type,
    severity: severity ?? this.severity,
    vehicleCount: vehicleCount ?? this.vehicleCount,
    injuredCount: injuredCount ?? this.injuredCount,
    witnessName: witnessName ?? this.witnessName,
    witnessPhone: witnessPhone ?? this.witnessPhone,
    evidenceJson: evidenceJson ?? this.evidenceJson,
    evidencePathsJson: evidencePathsJson ?? this.evidencePathsJson,
    videoAdded: videoAdded ?? this.videoAdded,
    voiceNoteAdded: voiceNoteAdded ?? this.voiceNoteAdded,
    videoPath: videoPath ?? this.videoPath,
    voiceNotePath: voiceNotePath ?? this.voiceNotePath,
    driverBName: driverBName ?? this.driverBName,
    driverBPermit: driverBPermit ?? this.driverBPermit,
    driverBPermitExpiry: driverBPermitExpiry ?? this.driverBPermitExpiry,
    driverBPlate: driverBPlate ?? this.driverBPlate,
    driverBInsurer: driverBInsurer ?? this.driverBInsurer,
    driverBPolicy: driverBPolicy ?? this.driverBPolicy,
    circumstancesJson: circumstancesJson ?? this.circumstancesJson,
    observations: observations ?? this.observations,
    impactZonesJson: impactZonesJson ?? this.impactZonesJson,
    sketchConfirmed: sketchConfirmed ?? this.sketchConfirmed,
    sketchStrokesJson: sketchStrokesJson ?? this.sketchStrokesJson,
    driverASigned: driverASigned ?? this.driverASigned,
    driverBSigned: driverBSigned ?? this.driverBSigned,
    driverASignatureJson: driverASignatureJson ?? this.driverASignatureJson,
    driverBSignatureJson: driverBSignatureJson ?? this.driverBSignatureJson,
    lastSavedAt: lastSavedAt ?? this.lastSavedAt,
  );
  AccidentDraftRow copyWithCompanion(AccidentDraftsCompanion data) {
    return AccidentDraftRow(
      id: data.id.present ? data.id.value : this.id,
      currentStep: data.currentStep.present
          ? data.currentStep.value
          : this.currentStep,
      place: data.place.present ? data.place.value : this.place,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      locationAccuracy: data.locationAccuracy.present
          ? data.locationAccuracy.value
          : this.locationAccuracy,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      weather: data.weather.present ? data.weather.value : this.weather,
      road: data.road.present ? data.road.value : this.road,
      light: data.light.present ? data.light.value : this.light,
      type: data.type.present ? data.type.value : this.type,
      severity: data.severity.present ? data.severity.value : this.severity,
      vehicleCount: data.vehicleCount.present
          ? data.vehicleCount.value
          : this.vehicleCount,
      injuredCount: data.injuredCount.present
          ? data.injuredCount.value
          : this.injuredCount,
      witnessName: data.witnessName.present
          ? data.witnessName.value
          : this.witnessName,
      witnessPhone: data.witnessPhone.present
          ? data.witnessPhone.value
          : this.witnessPhone,
      evidenceJson: data.evidenceJson.present
          ? data.evidenceJson.value
          : this.evidenceJson,
      evidencePathsJson: data.evidencePathsJson.present
          ? data.evidencePathsJson.value
          : this.evidencePathsJson,
      videoAdded: data.videoAdded.present
          ? data.videoAdded.value
          : this.videoAdded,
      voiceNoteAdded: data.voiceNoteAdded.present
          ? data.voiceNoteAdded.value
          : this.voiceNoteAdded,
      videoPath: data.videoPath.present ? data.videoPath.value : this.videoPath,
      voiceNotePath: data.voiceNotePath.present
          ? data.voiceNotePath.value
          : this.voiceNotePath,
      driverBName: data.driverBName.present
          ? data.driverBName.value
          : this.driverBName,
      driverBPermit: data.driverBPermit.present
          ? data.driverBPermit.value
          : this.driverBPermit,
      driverBPermitExpiry: data.driverBPermitExpiry.present
          ? data.driverBPermitExpiry.value
          : this.driverBPermitExpiry,
      driverBPlate: data.driverBPlate.present
          ? data.driverBPlate.value
          : this.driverBPlate,
      driverBInsurer: data.driverBInsurer.present
          ? data.driverBInsurer.value
          : this.driverBInsurer,
      driverBPolicy: data.driverBPolicy.present
          ? data.driverBPolicy.value
          : this.driverBPolicy,
      circumstancesJson: data.circumstancesJson.present
          ? data.circumstancesJson.value
          : this.circumstancesJson,
      observations: data.observations.present
          ? data.observations.value
          : this.observations,
      impactZonesJson: data.impactZonesJson.present
          ? data.impactZonesJson.value
          : this.impactZonesJson,
      sketchConfirmed: data.sketchConfirmed.present
          ? data.sketchConfirmed.value
          : this.sketchConfirmed,
      sketchStrokesJson: data.sketchStrokesJson.present
          ? data.sketchStrokesJson.value
          : this.sketchStrokesJson,
      driverASigned: data.driverASigned.present
          ? data.driverASigned.value
          : this.driverASigned,
      driverBSigned: data.driverBSigned.present
          ? data.driverBSigned.value
          : this.driverBSigned,
      driverASignatureJson: data.driverASignatureJson.present
          ? data.driverASignatureJson.value
          : this.driverASignatureJson,
      driverBSignatureJson: data.driverBSignatureJson.present
          ? data.driverBSignatureJson.value
          : this.driverBSignatureJson,
      lastSavedAt: data.lastSavedAt.present
          ? data.lastSavedAt.value
          : this.lastSavedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccidentDraftRow(')
          ..write('id: $id, ')
          ..write('currentStep: $currentStep, ')
          ..write('place: $place, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationAccuracy: $locationAccuracy, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('weather: $weather, ')
          ..write('road: $road, ')
          ..write('light: $light, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('vehicleCount: $vehicleCount, ')
          ..write('injuredCount: $injuredCount, ')
          ..write('witnessName: $witnessName, ')
          ..write('witnessPhone: $witnessPhone, ')
          ..write('evidenceJson: $evidenceJson, ')
          ..write('evidencePathsJson: $evidencePathsJson, ')
          ..write('videoAdded: $videoAdded, ')
          ..write('voiceNoteAdded: $voiceNoteAdded, ')
          ..write('videoPath: $videoPath, ')
          ..write('voiceNotePath: $voiceNotePath, ')
          ..write('driverBName: $driverBName, ')
          ..write('driverBPermit: $driverBPermit, ')
          ..write('driverBPermitExpiry: $driverBPermitExpiry, ')
          ..write('driverBPlate: $driverBPlate, ')
          ..write('driverBInsurer: $driverBInsurer, ')
          ..write('driverBPolicy: $driverBPolicy, ')
          ..write('circumstancesJson: $circumstancesJson, ')
          ..write('observations: $observations, ')
          ..write('impactZonesJson: $impactZonesJson, ')
          ..write('sketchConfirmed: $sketchConfirmed, ')
          ..write('sketchStrokesJson: $sketchStrokesJson, ')
          ..write('driverASigned: $driverASigned, ')
          ..write('driverBSigned: $driverBSigned, ')
          ..write('driverASignatureJson: $driverASignatureJson, ')
          ..write('driverBSignatureJson: $driverBSignatureJson, ')
          ..write('lastSavedAt: $lastSavedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    currentStep,
    place,
    latitude,
    longitude,
    locationAccuracy,
    occurredAt,
    weather,
    road,
    light,
    type,
    severity,
    vehicleCount,
    injuredCount,
    witnessName,
    witnessPhone,
    evidenceJson,
    evidencePathsJson,
    videoAdded,
    voiceNoteAdded,
    videoPath,
    voiceNotePath,
    driverBName,
    driverBPermit,
    driverBPermitExpiry,
    driverBPlate,
    driverBInsurer,
    driverBPolicy,
    circumstancesJson,
    observations,
    impactZonesJson,
    sketchConfirmed,
    sketchStrokesJson,
    driverASigned,
    driverBSigned,
    driverASignatureJson,
    driverBSignatureJson,
    lastSavedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccidentDraftRow &&
          other.id == this.id &&
          other.currentStep == this.currentStep &&
          other.place == this.place &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.locationAccuracy == this.locationAccuracy &&
          other.occurredAt == this.occurredAt &&
          other.weather == this.weather &&
          other.road == this.road &&
          other.light == this.light &&
          other.type == this.type &&
          other.severity == this.severity &&
          other.vehicleCount == this.vehicleCount &&
          other.injuredCount == this.injuredCount &&
          other.witnessName == this.witnessName &&
          other.witnessPhone == this.witnessPhone &&
          other.evidenceJson == this.evidenceJson &&
          other.evidencePathsJson == this.evidencePathsJson &&
          other.videoAdded == this.videoAdded &&
          other.voiceNoteAdded == this.voiceNoteAdded &&
          other.videoPath == this.videoPath &&
          other.voiceNotePath == this.voiceNotePath &&
          other.driverBName == this.driverBName &&
          other.driverBPermit == this.driverBPermit &&
          other.driverBPermitExpiry == this.driverBPermitExpiry &&
          other.driverBPlate == this.driverBPlate &&
          other.driverBInsurer == this.driverBInsurer &&
          other.driverBPolicy == this.driverBPolicy &&
          other.circumstancesJson == this.circumstancesJson &&
          other.observations == this.observations &&
          other.impactZonesJson == this.impactZonesJson &&
          other.sketchConfirmed == this.sketchConfirmed &&
          other.sketchStrokesJson == this.sketchStrokesJson &&
          other.driverASigned == this.driverASigned &&
          other.driverBSigned == this.driverBSigned &&
          other.driverASignatureJson == this.driverASignatureJson &&
          other.driverBSignatureJson == this.driverBSignatureJson &&
          other.lastSavedAt == this.lastSavedAt);
}

class AccidentDraftsCompanion extends UpdateCompanion<AccidentDraftRow> {
  final Value<int> id;
  final Value<int> currentStep;
  final Value<String> place;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> locationAccuracy;
  final Value<String> occurredAt;
  final Value<String> weather;
  final Value<String> road;
  final Value<String> light;
  final Value<String> type;
  final Value<String> severity;
  final Value<int> vehicleCount;
  final Value<int> injuredCount;
  final Value<String> witnessName;
  final Value<String> witnessPhone;
  final Value<String> evidenceJson;
  final Value<String> evidencePathsJson;
  final Value<bool> videoAdded;
  final Value<bool> voiceNoteAdded;
  final Value<String> videoPath;
  final Value<String> voiceNotePath;
  final Value<String> driverBName;
  final Value<String> driverBPermit;
  final Value<String> driverBPermitExpiry;
  final Value<String> driverBPlate;
  final Value<String> driverBInsurer;
  final Value<String> driverBPolicy;
  final Value<String> circumstancesJson;
  final Value<String> observations;
  final Value<String> impactZonesJson;
  final Value<bool> sketchConfirmed;
  final Value<String> sketchStrokesJson;
  final Value<bool> driverASigned;
  final Value<bool> driverBSigned;
  final Value<String> driverASignatureJson;
  final Value<String> driverBSignatureJson;
  final Value<String> lastSavedAt;
  const AccidentDraftsCompanion({
    this.id = const Value.absent(),
    this.currentStep = const Value.absent(),
    this.place = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationAccuracy = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.weather = const Value.absent(),
    this.road = const Value.absent(),
    this.light = const Value.absent(),
    this.type = const Value.absent(),
    this.severity = const Value.absent(),
    this.vehicleCount = const Value.absent(),
    this.injuredCount = const Value.absent(),
    this.witnessName = const Value.absent(),
    this.witnessPhone = const Value.absent(),
    this.evidenceJson = const Value.absent(),
    this.evidencePathsJson = const Value.absent(),
    this.videoAdded = const Value.absent(),
    this.voiceNoteAdded = const Value.absent(),
    this.videoPath = const Value.absent(),
    this.voiceNotePath = const Value.absent(),
    this.driverBName = const Value.absent(),
    this.driverBPermit = const Value.absent(),
    this.driverBPermitExpiry = const Value.absent(),
    this.driverBPlate = const Value.absent(),
    this.driverBInsurer = const Value.absent(),
    this.driverBPolicy = const Value.absent(),
    this.circumstancesJson = const Value.absent(),
    this.observations = const Value.absent(),
    this.impactZonesJson = const Value.absent(),
    this.sketchConfirmed = const Value.absent(),
    this.sketchStrokesJson = const Value.absent(),
    this.driverASigned = const Value.absent(),
    this.driverBSigned = const Value.absent(),
    this.driverASignatureJson = const Value.absent(),
    this.driverBSignatureJson = const Value.absent(),
    this.lastSavedAt = const Value.absent(),
  });
  AccidentDraftsCompanion.insert({
    this.id = const Value.absent(),
    required int currentStep,
    required String place,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationAccuracy = const Value.absent(),
    required String occurredAt,
    required String weather,
    required String road,
    required String light,
    required String type,
    required String severity,
    required int vehicleCount,
    required int injuredCount,
    required String witnessName,
    required String witnessPhone,
    required String evidenceJson,
    this.evidencePathsJson = const Value.absent(),
    required bool videoAdded,
    required bool voiceNoteAdded,
    this.videoPath = const Value.absent(),
    this.voiceNotePath = const Value.absent(),
    this.driverBName = const Value.absent(),
    this.driverBPermit = const Value.absent(),
    this.driverBPermitExpiry = const Value.absent(),
    this.driverBPlate = const Value.absent(),
    this.driverBInsurer = const Value.absent(),
    this.driverBPolicy = const Value.absent(),
    required String circumstancesJson,
    required String observations,
    required String impactZonesJson,
    required bool sketchConfirmed,
    this.sketchStrokesJson = const Value.absent(),
    required bool driverASigned,
    required bool driverBSigned,
    this.driverASignatureJson = const Value.absent(),
    this.driverBSignatureJson = const Value.absent(),
    required String lastSavedAt,
  }) : currentStep = Value(currentStep),
       place = Value(place),
       occurredAt = Value(occurredAt),
       weather = Value(weather),
       road = Value(road),
       light = Value(light),
       type = Value(type),
       severity = Value(severity),
       vehicleCount = Value(vehicleCount),
       injuredCount = Value(injuredCount),
       witnessName = Value(witnessName),
       witnessPhone = Value(witnessPhone),
       evidenceJson = Value(evidenceJson),
       videoAdded = Value(videoAdded),
       voiceNoteAdded = Value(voiceNoteAdded),
       circumstancesJson = Value(circumstancesJson),
       observations = Value(observations),
       impactZonesJson = Value(impactZonesJson),
       sketchConfirmed = Value(sketchConfirmed),
       driverASigned = Value(driverASigned),
       driverBSigned = Value(driverBSigned),
       lastSavedAt = Value(lastSavedAt);
  static Insertable<AccidentDraftRow> custom({
    Expression<int>? id,
    Expression<int>? currentStep,
    Expression<String>? place,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? locationAccuracy,
    Expression<String>? occurredAt,
    Expression<String>? weather,
    Expression<String>? road,
    Expression<String>? light,
    Expression<String>? type,
    Expression<String>? severity,
    Expression<int>? vehicleCount,
    Expression<int>? injuredCount,
    Expression<String>? witnessName,
    Expression<String>? witnessPhone,
    Expression<String>? evidenceJson,
    Expression<String>? evidencePathsJson,
    Expression<bool>? videoAdded,
    Expression<bool>? voiceNoteAdded,
    Expression<String>? videoPath,
    Expression<String>? voiceNotePath,
    Expression<String>? driverBName,
    Expression<String>? driverBPermit,
    Expression<String>? driverBPermitExpiry,
    Expression<String>? driverBPlate,
    Expression<String>? driverBInsurer,
    Expression<String>? driverBPolicy,
    Expression<String>? circumstancesJson,
    Expression<String>? observations,
    Expression<String>? impactZonesJson,
    Expression<bool>? sketchConfirmed,
    Expression<String>? sketchStrokesJson,
    Expression<bool>? driverASigned,
    Expression<bool>? driverBSigned,
    Expression<String>? driverASignatureJson,
    Expression<String>? driverBSignatureJson,
    Expression<String>? lastSavedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentStep != null) 'current_step': currentStep,
      if (place != null) 'place': place,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationAccuracy != null) 'location_accuracy': locationAccuracy,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (weather != null) 'weather': weather,
      if (road != null) 'road': road,
      if (light != null) 'light': light,
      if (type != null) 'type': type,
      if (severity != null) 'severity': severity,
      if (vehicleCount != null) 'vehicle_count': vehicleCount,
      if (injuredCount != null) 'injured_count': injuredCount,
      if (witnessName != null) 'witness_name': witnessName,
      if (witnessPhone != null) 'witness_phone': witnessPhone,
      if (evidenceJson != null) 'evidence_json': evidenceJson,
      if (evidencePathsJson != null) 'evidence_paths_json': evidencePathsJson,
      if (videoAdded != null) 'video_added': videoAdded,
      if (voiceNoteAdded != null) 'voice_note_added': voiceNoteAdded,
      if (videoPath != null) 'video_path': videoPath,
      if (voiceNotePath != null) 'voice_note_path': voiceNotePath,
      if (driverBName != null) 'driver_b_name': driverBName,
      if (driverBPermit != null) 'driver_b_permit': driverBPermit,
      if (driverBPermitExpiry != null)
        'driver_b_permit_expiry': driverBPermitExpiry,
      if (driverBPlate != null) 'driver_b_plate': driverBPlate,
      if (driverBInsurer != null) 'driver_b_insurer': driverBInsurer,
      if (driverBPolicy != null) 'driver_b_policy': driverBPolicy,
      if (circumstancesJson != null) 'circumstances_json': circumstancesJson,
      if (observations != null) 'observations': observations,
      if (impactZonesJson != null) 'impact_zones_json': impactZonesJson,
      if (sketchConfirmed != null) 'sketch_confirmed': sketchConfirmed,
      if (sketchStrokesJson != null) 'sketch_strokes_json': sketchStrokesJson,
      if (driverASigned != null) 'driver_a_signed': driverASigned,
      if (driverBSigned != null) 'driver_b_signed': driverBSigned,
      if (driverASignatureJson != null)
        'driver_a_signature_json': driverASignatureJson,
      if (driverBSignatureJson != null)
        'driver_b_signature_json': driverBSignatureJson,
      if (lastSavedAt != null) 'last_saved_at': lastSavedAt,
    });
  }

  AccidentDraftsCompanion copyWith({
    Value<int>? id,
    Value<int>? currentStep,
    Value<String>? place,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double?>? locationAccuracy,
    Value<String>? occurredAt,
    Value<String>? weather,
    Value<String>? road,
    Value<String>? light,
    Value<String>? type,
    Value<String>? severity,
    Value<int>? vehicleCount,
    Value<int>? injuredCount,
    Value<String>? witnessName,
    Value<String>? witnessPhone,
    Value<String>? evidenceJson,
    Value<String>? evidencePathsJson,
    Value<bool>? videoAdded,
    Value<bool>? voiceNoteAdded,
    Value<String>? videoPath,
    Value<String>? voiceNotePath,
    Value<String>? driverBName,
    Value<String>? driverBPermit,
    Value<String>? driverBPermitExpiry,
    Value<String>? driverBPlate,
    Value<String>? driverBInsurer,
    Value<String>? driverBPolicy,
    Value<String>? circumstancesJson,
    Value<String>? observations,
    Value<String>? impactZonesJson,
    Value<bool>? sketchConfirmed,
    Value<String>? sketchStrokesJson,
    Value<bool>? driverASigned,
    Value<bool>? driverBSigned,
    Value<String>? driverASignatureJson,
    Value<String>? driverBSignatureJson,
    Value<String>? lastSavedAt,
  }) {
    return AccidentDraftsCompanion(
      id: id ?? this.id,
      currentStep: currentStep ?? this.currentStep,
      place: place ?? this.place,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      occurredAt: occurredAt ?? this.occurredAt,
      weather: weather ?? this.weather,
      road: road ?? this.road,
      light: light ?? this.light,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      vehicleCount: vehicleCount ?? this.vehicleCount,
      injuredCount: injuredCount ?? this.injuredCount,
      witnessName: witnessName ?? this.witnessName,
      witnessPhone: witnessPhone ?? this.witnessPhone,
      evidenceJson: evidenceJson ?? this.evidenceJson,
      evidencePathsJson: evidencePathsJson ?? this.evidencePathsJson,
      videoAdded: videoAdded ?? this.videoAdded,
      voiceNoteAdded: voiceNoteAdded ?? this.voiceNoteAdded,
      videoPath: videoPath ?? this.videoPath,
      voiceNotePath: voiceNotePath ?? this.voiceNotePath,
      driverBName: driverBName ?? this.driverBName,
      driverBPermit: driverBPermit ?? this.driverBPermit,
      driverBPermitExpiry: driverBPermitExpiry ?? this.driverBPermitExpiry,
      driverBPlate: driverBPlate ?? this.driverBPlate,
      driverBInsurer: driverBInsurer ?? this.driverBInsurer,
      driverBPolicy: driverBPolicy ?? this.driverBPolicy,
      circumstancesJson: circumstancesJson ?? this.circumstancesJson,
      observations: observations ?? this.observations,
      impactZonesJson: impactZonesJson ?? this.impactZonesJson,
      sketchConfirmed: sketchConfirmed ?? this.sketchConfirmed,
      sketchStrokesJson: sketchStrokesJson ?? this.sketchStrokesJson,
      driverASigned: driverASigned ?? this.driverASigned,
      driverBSigned: driverBSigned ?? this.driverBSigned,
      driverASignatureJson: driverASignatureJson ?? this.driverASignatureJson,
      driverBSignatureJson: driverBSignatureJson ?? this.driverBSignatureJson,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currentStep.present) {
      map['current_step'] = Variable<int>(currentStep.value);
    }
    if (place.present) {
      map['place'] = Variable<String>(place.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (locationAccuracy.present) {
      map['location_accuracy'] = Variable<double>(locationAccuracy.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<String>(occurredAt.value);
    }
    if (weather.present) {
      map['weather'] = Variable<String>(weather.value);
    }
    if (road.present) {
      map['road'] = Variable<String>(road.value);
    }
    if (light.present) {
      map['light'] = Variable<String>(light.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (vehicleCount.present) {
      map['vehicle_count'] = Variable<int>(vehicleCount.value);
    }
    if (injuredCount.present) {
      map['injured_count'] = Variable<int>(injuredCount.value);
    }
    if (witnessName.present) {
      map['witness_name'] = Variable<String>(witnessName.value);
    }
    if (witnessPhone.present) {
      map['witness_phone'] = Variable<String>(witnessPhone.value);
    }
    if (evidenceJson.present) {
      map['evidence_json'] = Variable<String>(evidenceJson.value);
    }
    if (evidencePathsJson.present) {
      map['evidence_paths_json'] = Variable<String>(evidencePathsJson.value);
    }
    if (videoAdded.present) {
      map['video_added'] = Variable<bool>(videoAdded.value);
    }
    if (voiceNoteAdded.present) {
      map['voice_note_added'] = Variable<bool>(voiceNoteAdded.value);
    }
    if (videoPath.present) {
      map['video_path'] = Variable<String>(videoPath.value);
    }
    if (voiceNotePath.present) {
      map['voice_note_path'] = Variable<String>(voiceNotePath.value);
    }
    if (driverBName.present) {
      map['driver_b_name'] = Variable<String>(driverBName.value);
    }
    if (driverBPermit.present) {
      map['driver_b_permit'] = Variable<String>(driverBPermit.value);
    }
    if (driverBPermitExpiry.present) {
      map['driver_b_permit_expiry'] = Variable<String>(
        driverBPermitExpiry.value,
      );
    }
    if (driverBPlate.present) {
      map['driver_b_plate'] = Variable<String>(driverBPlate.value);
    }
    if (driverBInsurer.present) {
      map['driver_b_insurer'] = Variable<String>(driverBInsurer.value);
    }
    if (driverBPolicy.present) {
      map['driver_b_policy'] = Variable<String>(driverBPolicy.value);
    }
    if (circumstancesJson.present) {
      map['circumstances_json'] = Variable<String>(circumstancesJson.value);
    }
    if (observations.present) {
      map['observations'] = Variable<String>(observations.value);
    }
    if (impactZonesJson.present) {
      map['impact_zones_json'] = Variable<String>(impactZonesJson.value);
    }
    if (sketchConfirmed.present) {
      map['sketch_confirmed'] = Variable<bool>(sketchConfirmed.value);
    }
    if (sketchStrokesJson.present) {
      map['sketch_strokes_json'] = Variable<String>(sketchStrokesJson.value);
    }
    if (driverASigned.present) {
      map['driver_a_signed'] = Variable<bool>(driverASigned.value);
    }
    if (driverBSigned.present) {
      map['driver_b_signed'] = Variable<bool>(driverBSigned.value);
    }
    if (driverASignatureJson.present) {
      map['driver_a_signature_json'] = Variable<String>(
        driverASignatureJson.value,
      );
    }
    if (driverBSignatureJson.present) {
      map['driver_b_signature_json'] = Variable<String>(
        driverBSignatureJson.value,
      );
    }
    if (lastSavedAt.present) {
      map['last_saved_at'] = Variable<String>(lastSavedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccidentDraftsCompanion(')
          ..write('id: $id, ')
          ..write('currentStep: $currentStep, ')
          ..write('place: $place, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationAccuracy: $locationAccuracy, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('weather: $weather, ')
          ..write('road: $road, ')
          ..write('light: $light, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('vehicleCount: $vehicleCount, ')
          ..write('injuredCount: $injuredCount, ')
          ..write('witnessName: $witnessName, ')
          ..write('witnessPhone: $witnessPhone, ')
          ..write('evidenceJson: $evidenceJson, ')
          ..write('evidencePathsJson: $evidencePathsJson, ')
          ..write('videoAdded: $videoAdded, ')
          ..write('voiceNoteAdded: $voiceNoteAdded, ')
          ..write('videoPath: $videoPath, ')
          ..write('voiceNotePath: $voiceNotePath, ')
          ..write('driverBName: $driverBName, ')
          ..write('driverBPermit: $driverBPermit, ')
          ..write('driverBPermitExpiry: $driverBPermitExpiry, ')
          ..write('driverBPlate: $driverBPlate, ')
          ..write('driverBInsurer: $driverBInsurer, ')
          ..write('driverBPolicy: $driverBPolicy, ')
          ..write('circumstancesJson: $circumstancesJson, ')
          ..write('observations: $observations, ')
          ..write('impactZonesJson: $impactZonesJson, ')
          ..write('sketchConfirmed: $sketchConfirmed, ')
          ..write('sketchStrokesJson: $sketchStrokesJson, ')
          ..write('driverASigned: $driverASigned, ')
          ..write('driverBSigned: $driverBSigned, ')
          ..write('driverASignatureJson: $driverASignatureJson, ')
          ..write('driverBSignatureJson: $driverBSignatureJson, ')
          ..write('lastSavedAt: $lastSavedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AccidentDatabase extends GeneratedDatabase {
  _$AccidentDatabase(QueryExecutor e) : super(e);
  $AccidentDatabaseManager get managers => $AccidentDatabaseManager(this);
  late final $AccidentDraftsTable accidentDrafts = $AccidentDraftsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [accidentDrafts];
}

typedef $$AccidentDraftsTableCreateCompanionBuilder =
    AccidentDraftsCompanion Function({
      Value<int> id,
      required int currentStep,
      required String place,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> locationAccuracy,
      required String occurredAt,
      required String weather,
      required String road,
      required String light,
      required String type,
      required String severity,
      required int vehicleCount,
      required int injuredCount,
      required String witnessName,
      required String witnessPhone,
      required String evidenceJson,
      Value<String> evidencePathsJson,
      required bool videoAdded,
      required bool voiceNoteAdded,
      Value<String> videoPath,
      Value<String> voiceNotePath,
      Value<String> driverBName,
      Value<String> driverBPermit,
      Value<String> driverBPermitExpiry,
      Value<String> driverBPlate,
      Value<String> driverBInsurer,
      Value<String> driverBPolicy,
      required String circumstancesJson,
      required String observations,
      required String impactZonesJson,
      required bool sketchConfirmed,
      Value<String> sketchStrokesJson,
      required bool driverASigned,
      required bool driverBSigned,
      Value<String> driverASignatureJson,
      Value<String> driverBSignatureJson,
      required String lastSavedAt,
    });
typedef $$AccidentDraftsTableUpdateCompanionBuilder =
    AccidentDraftsCompanion Function({
      Value<int> id,
      Value<int> currentStep,
      Value<String> place,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> locationAccuracy,
      Value<String> occurredAt,
      Value<String> weather,
      Value<String> road,
      Value<String> light,
      Value<String> type,
      Value<String> severity,
      Value<int> vehicleCount,
      Value<int> injuredCount,
      Value<String> witnessName,
      Value<String> witnessPhone,
      Value<String> evidenceJson,
      Value<String> evidencePathsJson,
      Value<bool> videoAdded,
      Value<bool> voiceNoteAdded,
      Value<String> videoPath,
      Value<String> voiceNotePath,
      Value<String> driverBName,
      Value<String> driverBPermit,
      Value<String> driverBPermitExpiry,
      Value<String> driverBPlate,
      Value<String> driverBInsurer,
      Value<String> driverBPolicy,
      Value<String> circumstancesJson,
      Value<String> observations,
      Value<String> impactZonesJson,
      Value<bool> sketchConfirmed,
      Value<String> sketchStrokesJson,
      Value<bool> driverASigned,
      Value<bool> driverBSigned,
      Value<String> driverASignatureJson,
      Value<String> driverBSignatureJson,
      Value<String> lastSavedAt,
    });

class $$AccidentDraftsTableFilterComposer
    extends Composer<_$AccidentDatabase, $AccidentDraftsTable> {
  $$AccidentDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get locationAccuracy => $composableBuilder(
    column: $table.locationAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get road => $composableBuilder(
    column: $table.road,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get light => $composableBuilder(
    column: $table.light,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vehicleCount => $composableBuilder(
    column: $table.vehicleCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get injuredCount => $composableBuilder(
    column: $table.injuredCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get witnessName => $composableBuilder(
    column: $table.witnessName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get witnessPhone => $composableBuilder(
    column: $table.witnessPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidencePathsJson => $composableBuilder(
    column: $table.evidencePathsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get videoAdded => $composableBuilder(
    column: $table.videoAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get voiceNoteAdded => $composableBuilder(
    column: $table.voiceNoteAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoPath => $composableBuilder(
    column: $table.videoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voiceNotePath => $composableBuilder(
    column: $table.voiceNotePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverBName => $composableBuilder(
    column: $table.driverBName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverBPermit => $composableBuilder(
    column: $table.driverBPermit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverBPermitExpiry => $composableBuilder(
    column: $table.driverBPermitExpiry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverBPlate => $composableBuilder(
    column: $table.driverBPlate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverBInsurer => $composableBuilder(
    column: $table.driverBInsurer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverBPolicy => $composableBuilder(
    column: $table.driverBPolicy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get circumstancesJson => $composableBuilder(
    column: $table.circumstancesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get impactZonesJson => $composableBuilder(
    column: $table.impactZonesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sketchConfirmed => $composableBuilder(
    column: $table.sketchConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sketchStrokesJson => $composableBuilder(
    column: $table.sketchStrokesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get driverASigned => $composableBuilder(
    column: $table.driverASigned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get driverBSigned => $composableBuilder(
    column: $table.driverBSigned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverASignatureJson => $composableBuilder(
    column: $table.driverASignatureJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverBSignatureJson => $composableBuilder(
    column: $table.driverBSignatureJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSavedAt => $composableBuilder(
    column: $table.lastSavedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccidentDraftsTableOrderingComposer
    extends Composer<_$AccidentDatabase, $AccidentDraftsTable> {
  $$AccidentDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get locationAccuracy => $composableBuilder(
    column: $table.locationAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get road => $composableBuilder(
    column: $table.road,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get light => $composableBuilder(
    column: $table.light,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vehicleCount => $composableBuilder(
    column: $table.vehicleCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get injuredCount => $composableBuilder(
    column: $table.injuredCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get witnessName => $composableBuilder(
    column: $table.witnessName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get witnessPhone => $composableBuilder(
    column: $table.witnessPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidencePathsJson => $composableBuilder(
    column: $table.evidencePathsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get videoAdded => $composableBuilder(
    column: $table.videoAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get voiceNoteAdded => $composableBuilder(
    column: $table.voiceNoteAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoPath => $composableBuilder(
    column: $table.videoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voiceNotePath => $composableBuilder(
    column: $table.voiceNotePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverBName => $composableBuilder(
    column: $table.driverBName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverBPermit => $composableBuilder(
    column: $table.driverBPermit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverBPermitExpiry => $composableBuilder(
    column: $table.driverBPermitExpiry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverBPlate => $composableBuilder(
    column: $table.driverBPlate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverBInsurer => $composableBuilder(
    column: $table.driverBInsurer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverBPolicy => $composableBuilder(
    column: $table.driverBPolicy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get circumstancesJson => $composableBuilder(
    column: $table.circumstancesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get impactZonesJson => $composableBuilder(
    column: $table.impactZonesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sketchConfirmed => $composableBuilder(
    column: $table.sketchConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sketchStrokesJson => $composableBuilder(
    column: $table.sketchStrokesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get driverASigned => $composableBuilder(
    column: $table.driverASigned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get driverBSigned => $composableBuilder(
    column: $table.driverBSigned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverASignatureJson => $composableBuilder(
    column: $table.driverASignatureJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverBSignatureJson => $composableBuilder(
    column: $table.driverBSignatureJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSavedAt => $composableBuilder(
    column: $table.lastSavedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccidentDraftsTableAnnotationComposer
    extends Composer<_$AccidentDatabase, $AccidentDraftsTable> {
  $$AccidentDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => column,
  );

  GeneratedColumn<String> get place =>
      $composableBuilder(column: $table.place, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get locationAccuracy => $composableBuilder(
    column: $table.locationAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weather =>
      $composableBuilder(column: $table.weather, builder: (column) => column);

  GeneratedColumn<String> get road =>
      $composableBuilder(column: $table.road, builder: (column) => column);

  GeneratedColumn<String> get light =>
      $composableBuilder(column: $table.light, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<int> get vehicleCount => $composableBuilder(
    column: $table.vehicleCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get injuredCount => $composableBuilder(
    column: $table.injuredCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get witnessName => $composableBuilder(
    column: $table.witnessName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get witnessPhone => $composableBuilder(
    column: $table.witnessPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evidencePathsJson => $composableBuilder(
    column: $table.evidencePathsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get videoAdded => $composableBuilder(
    column: $table.videoAdded,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get voiceNoteAdded => $composableBuilder(
    column: $table.voiceNoteAdded,
    builder: (column) => column,
  );

  GeneratedColumn<String> get videoPath =>
      $composableBuilder(column: $table.videoPath, builder: (column) => column);

  GeneratedColumn<String> get voiceNotePath => $composableBuilder(
    column: $table.voiceNotePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get driverBName => $composableBuilder(
    column: $table.driverBName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get driverBPermit => $composableBuilder(
    column: $table.driverBPermit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get driverBPermitExpiry => $composableBuilder(
    column: $table.driverBPermitExpiry,
    builder: (column) => column,
  );

  GeneratedColumn<String> get driverBPlate => $composableBuilder(
    column: $table.driverBPlate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get driverBInsurer => $composableBuilder(
    column: $table.driverBInsurer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get driverBPolicy => $composableBuilder(
    column: $table.driverBPolicy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get circumstancesJson => $composableBuilder(
    column: $table.circumstancesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get impactZonesJson => $composableBuilder(
    column: $table.impactZonesJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sketchConfirmed => $composableBuilder(
    column: $table.sketchConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sketchStrokesJson => $composableBuilder(
    column: $table.sketchStrokesJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get driverASigned => $composableBuilder(
    column: $table.driverASigned,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get driverBSigned => $composableBuilder(
    column: $table.driverBSigned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get driverASignatureJson => $composableBuilder(
    column: $table.driverASignatureJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get driverBSignatureJson => $composableBuilder(
    column: $table.driverBSignatureJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSavedAt => $composableBuilder(
    column: $table.lastSavedAt,
    builder: (column) => column,
  );
}

class $$AccidentDraftsTableTableManager
    extends
        RootTableManager<
          _$AccidentDatabase,
          $AccidentDraftsTable,
          AccidentDraftRow,
          $$AccidentDraftsTableFilterComposer,
          $$AccidentDraftsTableOrderingComposer,
          $$AccidentDraftsTableAnnotationComposer,
          $$AccidentDraftsTableCreateCompanionBuilder,
          $$AccidentDraftsTableUpdateCompanionBuilder,
          (
            AccidentDraftRow,
            BaseReferences<
              _$AccidentDatabase,
              $AccidentDraftsTable,
              AccidentDraftRow
            >,
          ),
          AccidentDraftRow,
          PrefetchHooks Function()
        > {
  $$AccidentDraftsTableTableManager(
    _$AccidentDatabase db,
    $AccidentDraftsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccidentDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccidentDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccidentDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentStep = const Value.absent(),
                Value<String> place = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> locationAccuracy = const Value.absent(),
                Value<String> occurredAt = const Value.absent(),
                Value<String> weather = const Value.absent(),
                Value<String> road = const Value.absent(),
                Value<String> light = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<int> vehicleCount = const Value.absent(),
                Value<int> injuredCount = const Value.absent(),
                Value<String> witnessName = const Value.absent(),
                Value<String> witnessPhone = const Value.absent(),
                Value<String> evidenceJson = const Value.absent(),
                Value<String> evidencePathsJson = const Value.absent(),
                Value<bool> videoAdded = const Value.absent(),
                Value<bool> voiceNoteAdded = const Value.absent(),
                Value<String> videoPath = const Value.absent(),
                Value<String> voiceNotePath = const Value.absent(),
                Value<String> driverBName = const Value.absent(),
                Value<String> driverBPermit = const Value.absent(),
                Value<String> driverBPermitExpiry = const Value.absent(),
                Value<String> driverBPlate = const Value.absent(),
                Value<String> driverBInsurer = const Value.absent(),
                Value<String> driverBPolicy = const Value.absent(),
                Value<String> circumstancesJson = const Value.absent(),
                Value<String> observations = const Value.absent(),
                Value<String> impactZonesJson = const Value.absent(),
                Value<bool> sketchConfirmed = const Value.absent(),
                Value<String> sketchStrokesJson = const Value.absent(),
                Value<bool> driverASigned = const Value.absent(),
                Value<bool> driverBSigned = const Value.absent(),
                Value<String> driverASignatureJson = const Value.absent(),
                Value<String> driverBSignatureJson = const Value.absent(),
                Value<String> lastSavedAt = const Value.absent(),
              }) => AccidentDraftsCompanion(
                id: id,
                currentStep: currentStep,
                place: place,
                latitude: latitude,
                longitude: longitude,
                locationAccuracy: locationAccuracy,
                occurredAt: occurredAt,
                weather: weather,
                road: road,
                light: light,
                type: type,
                severity: severity,
                vehicleCount: vehicleCount,
                injuredCount: injuredCount,
                witnessName: witnessName,
                witnessPhone: witnessPhone,
                evidenceJson: evidenceJson,
                evidencePathsJson: evidencePathsJson,
                videoAdded: videoAdded,
                voiceNoteAdded: voiceNoteAdded,
                videoPath: videoPath,
                voiceNotePath: voiceNotePath,
                driverBName: driverBName,
                driverBPermit: driverBPermit,
                driverBPermitExpiry: driverBPermitExpiry,
                driverBPlate: driverBPlate,
                driverBInsurer: driverBInsurer,
                driverBPolicy: driverBPolicy,
                circumstancesJson: circumstancesJson,
                observations: observations,
                impactZonesJson: impactZonesJson,
                sketchConfirmed: sketchConfirmed,
                sketchStrokesJson: sketchStrokesJson,
                driverASigned: driverASigned,
                driverBSigned: driverBSigned,
                driverASignatureJson: driverASignatureJson,
                driverBSignatureJson: driverBSignatureJson,
                lastSavedAt: lastSavedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int currentStep,
                required String place,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> locationAccuracy = const Value.absent(),
                required String occurredAt,
                required String weather,
                required String road,
                required String light,
                required String type,
                required String severity,
                required int vehicleCount,
                required int injuredCount,
                required String witnessName,
                required String witnessPhone,
                required String evidenceJson,
                Value<String> evidencePathsJson = const Value.absent(),
                required bool videoAdded,
                required bool voiceNoteAdded,
                Value<String> videoPath = const Value.absent(),
                Value<String> voiceNotePath = const Value.absent(),
                Value<String> driverBName = const Value.absent(),
                Value<String> driverBPermit = const Value.absent(),
                Value<String> driverBPermitExpiry = const Value.absent(),
                Value<String> driverBPlate = const Value.absent(),
                Value<String> driverBInsurer = const Value.absent(),
                Value<String> driverBPolicy = const Value.absent(),
                required String circumstancesJson,
                required String observations,
                required String impactZonesJson,
                required bool sketchConfirmed,
                Value<String> sketchStrokesJson = const Value.absent(),
                required bool driverASigned,
                required bool driverBSigned,
                Value<String> driverASignatureJson = const Value.absent(),
                Value<String> driverBSignatureJson = const Value.absent(),
                required String lastSavedAt,
              }) => AccidentDraftsCompanion.insert(
                id: id,
                currentStep: currentStep,
                place: place,
                latitude: latitude,
                longitude: longitude,
                locationAccuracy: locationAccuracy,
                occurredAt: occurredAt,
                weather: weather,
                road: road,
                light: light,
                type: type,
                severity: severity,
                vehicleCount: vehicleCount,
                injuredCount: injuredCount,
                witnessName: witnessName,
                witnessPhone: witnessPhone,
                evidenceJson: evidenceJson,
                evidencePathsJson: evidencePathsJson,
                videoAdded: videoAdded,
                voiceNoteAdded: voiceNoteAdded,
                videoPath: videoPath,
                voiceNotePath: voiceNotePath,
                driverBName: driverBName,
                driverBPermit: driverBPermit,
                driverBPermitExpiry: driverBPermitExpiry,
                driverBPlate: driverBPlate,
                driverBInsurer: driverBInsurer,
                driverBPolicy: driverBPolicy,
                circumstancesJson: circumstancesJson,
                observations: observations,
                impactZonesJson: impactZonesJson,
                sketchConfirmed: sketchConfirmed,
                sketchStrokesJson: sketchStrokesJson,
                driverASigned: driverASigned,
                driverBSigned: driverBSigned,
                driverASignatureJson: driverASignatureJson,
                driverBSignatureJson: driverBSignatureJson,
                lastSavedAt: lastSavedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccidentDraftsTable, AccidentDraftRow>(table),
                  BaseReferences<
                    _$AccidentDatabase,
                    $AccidentDraftsTable,
                    AccidentDraftRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccidentDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AccidentDatabase,
      $AccidentDraftsTable,
      AccidentDraftRow,
      $$AccidentDraftsTableFilterComposer,
      $$AccidentDraftsTableOrderingComposer,
      $$AccidentDraftsTableAnnotationComposer,
      $$AccidentDraftsTableCreateCompanionBuilder,
      $$AccidentDraftsTableUpdateCompanionBuilder,
      (
        AccidentDraftRow,
        BaseReferences<
          _$AccidentDatabase,
          $AccidentDraftsTable,
          AccidentDraftRow
        >,
      ),
      AccidentDraftRow,
      PrefetchHooks Function()
    >;

class $AccidentDatabaseManager {
  final _$AccidentDatabase _db;
  $AccidentDatabaseManager(this._db);
  $$AccidentDraftsTableTableManager get accidentDrafts =>
      $$AccidentDraftsTableTableManager(_db, _db.accidentDrafts);
}
