// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claims_database.dart';

// ignore_for_file: type=lint
class $ClaimsTable extends Claims with TableInfo<$ClaimsTable, ClaimRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClaimsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _placeMeta = const VerificationMeta('place');
  @override
  late final GeneratedColumn<String> place = GeneratedColumn<String>(
    'place',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
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
  static const VerificationMeta _observationsMeta = const VerificationMeta(
    'observations',
  );
  @override
  late final GeneratedColumn<String> observations = GeneratedColumn<String>(
    'observations',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _circumstancesMeta = const VerificationMeta(
    'circumstances',
  );
  @override
  late final GeneratedColumn<String> circumstances = GeneratedColumn<String>(
    'circumstances',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _impactZonesMeta = const VerificationMeta(
    'impactZones',
  );
  @override
  late final GeneratedColumn<String> impactZones = GeneratedColumn<String>(
    'impact_zones',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _agentNameMeta = const VerificationMeta(
    'agentName',
  );
  @override
  late final GeneratedColumn<String> agentName = GeneratedColumn<String>(
    'agent_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expertNameMeta = const VerificationMeta(
    'expertName',
  );
  @override
  late final GeneratedColumn<String> expertName = GeneratedColumn<String>(
    'expert_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expertAppointmentMeta = const VerificationMeta(
    'expertAppointment',
  );
  @override
  late final GeneratedColumn<DateTime> expertAppointment =
      GeneratedColumn<DateTime>(
        'expert_appointment',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _responsibilityMeta = const VerificationMeta(
    'responsibility',
  );
  @override
  late final GeneratedColumn<int> responsibility = GeneratedColumn<int>(
    'responsibility',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _indemnityMeta = const VerificationMeta(
    'indemnity',
  );
  @override
  late final GeneratedColumn<double> indemnity = GeneratedColumn<double>(
    'indemnity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decisionReasonMeta = const VerificationMeta(
    'decisionReason',
  );
  @override
  late final GeneratedColumn<String> decisionReason = GeneratedColumn<String>(
    'decision_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    place,
    date,
    status,
    severity,
    observations,
    circumstances,
    impactZones,
    agentName,
    expertName,
    expertAppointment,
    responsibility,
    indemnity,
    decisionReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'claims';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClaimRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('place')) {
      context.handle(
        _placeMeta,
        place.isAcceptableOrUnknown(data['place']!, _placeMeta),
      );
    } else if (isInserting) {
      context.missing(_placeMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('observations')) {
      context.handle(
        _observationsMeta,
        observations.isAcceptableOrUnknown(
          data['observations']!,
          _observationsMeta,
        ),
      );
    }
    if (data.containsKey('circumstances')) {
      context.handle(
        _circumstancesMeta,
        circumstances.isAcceptableOrUnknown(
          data['circumstances']!,
          _circumstancesMeta,
        ),
      );
    }
    if (data.containsKey('impact_zones')) {
      context.handle(
        _impactZonesMeta,
        impactZones.isAcceptableOrUnknown(
          data['impact_zones']!,
          _impactZonesMeta,
        ),
      );
    }
    if (data.containsKey('agent_name')) {
      context.handle(
        _agentNameMeta,
        agentName.isAcceptableOrUnknown(data['agent_name']!, _agentNameMeta),
      );
    }
    if (data.containsKey('expert_name')) {
      context.handle(
        _expertNameMeta,
        expertName.isAcceptableOrUnknown(data['expert_name']!, _expertNameMeta),
      );
    }
    if (data.containsKey('expert_appointment')) {
      context.handle(
        _expertAppointmentMeta,
        expertAppointment.isAcceptableOrUnknown(
          data['expert_appointment']!,
          _expertAppointmentMeta,
        ),
      );
    }
    if (data.containsKey('responsibility')) {
      context.handle(
        _responsibilityMeta,
        responsibility.isAcceptableOrUnknown(
          data['responsibility']!,
          _responsibilityMeta,
        ),
      );
    }
    if (data.containsKey('indemnity')) {
      context.handle(
        _indemnityMeta,
        indemnity.isAcceptableOrUnknown(data['indemnity']!, _indemnityMeta),
      );
    }
    if (data.containsKey('decision_reason')) {
      context.handle(
        _decisionReasonMeta,
        decisionReason.isAcceptableOrUnknown(
          data['decision_reason']!,
          _decisionReasonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClaimRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClaimRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      place: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      observations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observations'],
      )!,
      circumstances: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}circumstances'],
      )!,
      impactZones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}impact_zones'],
      )!,
      agentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_name'],
      ),
      expertName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expert_name'],
      ),
      expertAppointment: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expert_appointment'],
      ),
      responsibility: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}responsibility'],
      ),
      indemnity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}indemnity'],
      ),
      decisionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_reason'],
      ),
    );
  }

  @override
  $ClaimsTable createAlias(String alias) {
    return $ClaimsTable(attachedDatabase, alias);
  }
}

class ClaimRow extends DataClass implements Insertable<ClaimRow> {
  final String id;
  final String type;
  final String place;
  final String date;
  final String status;
  final String severity;
  final String observations;

  /// Listes encodées en JSON.
  final String circumstances;
  final String impactZones;
  final String? agentName;
  final String? expertName;
  final DateTime? expertAppointment;
  final int? responsibility;
  final double? indemnity;
  final String? decisionReason;
  const ClaimRow({
    required this.id,
    required this.type,
    required this.place,
    required this.date,
    required this.status,
    required this.severity,
    required this.observations,
    required this.circumstances,
    required this.impactZones,
    this.agentName,
    this.expertName,
    this.expertAppointment,
    this.responsibility,
    this.indemnity,
    this.decisionReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['place'] = Variable<String>(place);
    map['date'] = Variable<String>(date);
    map['status'] = Variable<String>(status);
    map['severity'] = Variable<String>(severity);
    map['observations'] = Variable<String>(observations);
    map['circumstances'] = Variable<String>(circumstances);
    map['impact_zones'] = Variable<String>(impactZones);
    if (!nullToAbsent || agentName != null) {
      map['agent_name'] = Variable<String>(agentName);
    }
    if (!nullToAbsent || expertName != null) {
      map['expert_name'] = Variable<String>(expertName);
    }
    if (!nullToAbsent || expertAppointment != null) {
      map['expert_appointment'] = Variable<DateTime>(expertAppointment);
    }
    if (!nullToAbsent || responsibility != null) {
      map['responsibility'] = Variable<int>(responsibility);
    }
    if (!nullToAbsent || indemnity != null) {
      map['indemnity'] = Variable<double>(indemnity);
    }
    if (!nullToAbsent || decisionReason != null) {
      map['decision_reason'] = Variable<String>(decisionReason);
    }
    return map;
  }

  ClaimsCompanion toCompanion(bool nullToAbsent) {
    return ClaimsCompanion(
      id: Value(id),
      type: Value(type),
      place: Value(place),
      date: Value(date),
      status: Value(status),
      severity: Value(severity),
      observations: Value(observations),
      circumstances: Value(circumstances),
      impactZones: Value(impactZones),
      agentName: agentName == null && nullToAbsent
          ? const Value.absent()
          : Value(agentName),
      expertName: expertName == null && nullToAbsent
          ? const Value.absent()
          : Value(expertName),
      expertAppointment: expertAppointment == null && nullToAbsent
          ? const Value.absent()
          : Value(expertAppointment),
      responsibility: responsibility == null && nullToAbsent
          ? const Value.absent()
          : Value(responsibility),
      indemnity: indemnity == null && nullToAbsent
          ? const Value.absent()
          : Value(indemnity),
      decisionReason: decisionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(decisionReason),
    );
  }

  factory ClaimRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClaimRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      place: serializer.fromJson<String>(json['place']),
      date: serializer.fromJson<String>(json['date']),
      status: serializer.fromJson<String>(json['status']),
      severity: serializer.fromJson<String>(json['severity']),
      observations: serializer.fromJson<String>(json['observations']),
      circumstances: serializer.fromJson<String>(json['circumstances']),
      impactZones: serializer.fromJson<String>(json['impactZones']),
      agentName: serializer.fromJson<String?>(json['agentName']),
      expertName: serializer.fromJson<String?>(json['expertName']),
      expertAppointment: serializer.fromJson<DateTime?>(
        json['expertAppointment'],
      ),
      responsibility: serializer.fromJson<int?>(json['responsibility']),
      indemnity: serializer.fromJson<double?>(json['indemnity']),
      decisionReason: serializer.fromJson<String?>(json['decisionReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'place': serializer.toJson<String>(place),
      'date': serializer.toJson<String>(date),
      'status': serializer.toJson<String>(status),
      'severity': serializer.toJson<String>(severity),
      'observations': serializer.toJson<String>(observations),
      'circumstances': serializer.toJson<String>(circumstances),
      'impactZones': serializer.toJson<String>(impactZones),
      'agentName': serializer.toJson<String?>(agentName),
      'expertName': serializer.toJson<String?>(expertName),
      'expertAppointment': serializer.toJson<DateTime?>(expertAppointment),
      'responsibility': serializer.toJson<int?>(responsibility),
      'indemnity': serializer.toJson<double?>(indemnity),
      'decisionReason': serializer.toJson<String?>(decisionReason),
    };
  }

  ClaimRow copyWith({
    String? id,
    String? type,
    String? place,
    String? date,
    String? status,
    String? severity,
    String? observations,
    String? circumstances,
    String? impactZones,
    Value<String?> agentName = const Value.absent(),
    Value<String?> expertName = const Value.absent(),
    Value<DateTime?> expertAppointment = const Value.absent(),
    Value<int?> responsibility = const Value.absent(),
    Value<double?> indemnity = const Value.absent(),
    Value<String?> decisionReason = const Value.absent(),
  }) => ClaimRow(
    id: id ?? this.id,
    type: type ?? this.type,
    place: place ?? this.place,
    date: date ?? this.date,
    status: status ?? this.status,
    severity: severity ?? this.severity,
    observations: observations ?? this.observations,
    circumstances: circumstances ?? this.circumstances,
    impactZones: impactZones ?? this.impactZones,
    agentName: agentName.present ? agentName.value : this.agentName,
    expertName: expertName.present ? expertName.value : this.expertName,
    expertAppointment: expertAppointment.present
        ? expertAppointment.value
        : this.expertAppointment,
    responsibility: responsibility.present
        ? responsibility.value
        : this.responsibility,
    indemnity: indemnity.present ? indemnity.value : this.indemnity,
    decisionReason: decisionReason.present
        ? decisionReason.value
        : this.decisionReason,
  );
  ClaimRow copyWithCompanion(ClaimsCompanion data) {
    return ClaimRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      place: data.place.present ? data.place.value : this.place,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      severity: data.severity.present ? data.severity.value : this.severity,
      observations: data.observations.present
          ? data.observations.value
          : this.observations,
      circumstances: data.circumstances.present
          ? data.circumstances.value
          : this.circumstances,
      impactZones: data.impactZones.present
          ? data.impactZones.value
          : this.impactZones,
      agentName: data.agentName.present ? data.agentName.value : this.agentName,
      expertName: data.expertName.present
          ? data.expertName.value
          : this.expertName,
      expertAppointment: data.expertAppointment.present
          ? data.expertAppointment.value
          : this.expertAppointment,
      responsibility: data.responsibility.present
          ? data.responsibility.value
          : this.responsibility,
      indemnity: data.indemnity.present ? data.indemnity.value : this.indemnity,
      decisionReason: data.decisionReason.present
          ? data.decisionReason.value
          : this.decisionReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClaimRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('place: $place, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('severity: $severity, ')
          ..write('observations: $observations, ')
          ..write('circumstances: $circumstances, ')
          ..write('impactZones: $impactZones, ')
          ..write('agentName: $agentName, ')
          ..write('expertName: $expertName, ')
          ..write('expertAppointment: $expertAppointment, ')
          ..write('responsibility: $responsibility, ')
          ..write('indemnity: $indemnity, ')
          ..write('decisionReason: $decisionReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    place,
    date,
    status,
    severity,
    observations,
    circumstances,
    impactZones,
    agentName,
    expertName,
    expertAppointment,
    responsibility,
    indemnity,
    decisionReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClaimRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.place == this.place &&
          other.date == this.date &&
          other.status == this.status &&
          other.severity == this.severity &&
          other.observations == this.observations &&
          other.circumstances == this.circumstances &&
          other.impactZones == this.impactZones &&
          other.agentName == this.agentName &&
          other.expertName == this.expertName &&
          other.expertAppointment == this.expertAppointment &&
          other.responsibility == this.responsibility &&
          other.indemnity == this.indemnity &&
          other.decisionReason == this.decisionReason);
}

class ClaimsCompanion extends UpdateCompanion<ClaimRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> place;
  final Value<String> date;
  final Value<String> status;
  final Value<String> severity;
  final Value<String> observations;
  final Value<String> circumstances;
  final Value<String> impactZones;
  final Value<String?> agentName;
  final Value<String?> expertName;
  final Value<DateTime?> expertAppointment;
  final Value<int?> responsibility;
  final Value<double?> indemnity;
  final Value<String?> decisionReason;
  final Value<int> rowid;
  const ClaimsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.place = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.severity = const Value.absent(),
    this.observations = const Value.absent(),
    this.circumstances = const Value.absent(),
    this.impactZones = const Value.absent(),
    this.agentName = const Value.absent(),
    this.expertName = const Value.absent(),
    this.expertAppointment = const Value.absent(),
    this.responsibility = const Value.absent(),
    this.indemnity = const Value.absent(),
    this.decisionReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClaimsCompanion.insert({
    required String id,
    required String type,
    required String place,
    required String date,
    required String status,
    required String severity,
    this.observations = const Value.absent(),
    this.circumstances = const Value.absent(),
    this.impactZones = const Value.absent(),
    this.agentName = const Value.absent(),
    this.expertName = const Value.absent(),
    this.expertAppointment = const Value.absent(),
    this.responsibility = const Value.absent(),
    this.indemnity = const Value.absent(),
    this.decisionReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       place = Value(place),
       date = Value(date),
       status = Value(status),
       severity = Value(severity);
  static Insertable<ClaimRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? place,
    Expression<String>? date,
    Expression<String>? status,
    Expression<String>? severity,
    Expression<String>? observations,
    Expression<String>? circumstances,
    Expression<String>? impactZones,
    Expression<String>? agentName,
    Expression<String>? expertName,
    Expression<DateTime>? expertAppointment,
    Expression<int>? responsibility,
    Expression<double>? indemnity,
    Expression<String>? decisionReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (place != null) 'place': place,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (severity != null) 'severity': severity,
      if (observations != null) 'observations': observations,
      if (circumstances != null) 'circumstances': circumstances,
      if (impactZones != null) 'impact_zones': impactZones,
      if (agentName != null) 'agent_name': agentName,
      if (expertName != null) 'expert_name': expertName,
      if (expertAppointment != null) 'expert_appointment': expertAppointment,
      if (responsibility != null) 'responsibility': responsibility,
      if (indemnity != null) 'indemnity': indemnity,
      if (decisionReason != null) 'decision_reason': decisionReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClaimsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? place,
    Value<String>? date,
    Value<String>? status,
    Value<String>? severity,
    Value<String>? observations,
    Value<String>? circumstances,
    Value<String>? impactZones,
    Value<String?>? agentName,
    Value<String?>? expertName,
    Value<DateTime?>? expertAppointment,
    Value<int?>? responsibility,
    Value<double?>? indemnity,
    Value<String?>? decisionReason,
    Value<int>? rowid,
  }) {
    return ClaimsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      place: place ?? this.place,
      date: date ?? this.date,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      observations: observations ?? this.observations,
      circumstances: circumstances ?? this.circumstances,
      impactZones: impactZones ?? this.impactZones,
      agentName: agentName ?? this.agentName,
      expertName: expertName ?? this.expertName,
      expertAppointment: expertAppointment ?? this.expertAppointment,
      responsibility: responsibility ?? this.responsibility,
      indemnity: indemnity ?? this.indemnity,
      decisionReason: decisionReason ?? this.decisionReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (place.present) {
      map['place'] = Variable<String>(place.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (observations.present) {
      map['observations'] = Variable<String>(observations.value);
    }
    if (circumstances.present) {
      map['circumstances'] = Variable<String>(circumstances.value);
    }
    if (impactZones.present) {
      map['impact_zones'] = Variable<String>(impactZones.value);
    }
    if (agentName.present) {
      map['agent_name'] = Variable<String>(agentName.value);
    }
    if (expertName.present) {
      map['expert_name'] = Variable<String>(expertName.value);
    }
    if (expertAppointment.present) {
      map['expert_appointment'] = Variable<DateTime>(expertAppointment.value);
    }
    if (responsibility.present) {
      map['responsibility'] = Variable<int>(responsibility.value);
    }
    if (indemnity.present) {
      map['indemnity'] = Variable<double>(indemnity.value);
    }
    if (decisionReason.present) {
      map['decision_reason'] = Variable<String>(decisionReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClaimsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('place: $place, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('severity: $severity, ')
          ..write('observations: $observations, ')
          ..write('circumstances: $circumstances, ')
          ..write('impactZones: $impactZones, ')
          ..write('agentName: $agentName, ')
          ..write('expertName: $expertName, ')
          ..write('expertAppointment: $expertAppointment, ')
          ..write('responsibility: $responsibility, ')
          ..write('indemnity: $indemnity, ')
          ..write('decisionReason: $decisionReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClaimTimelineEventsTable extends ClaimTimelineEvents
    with TableInfo<$ClaimTimelineEventsTable, TimelineEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClaimTimelineEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _claimIdMeta = const VerificationMeta(
    'claimId',
  );
  @override
  late final GeneratedColumn<String> claimId = GeneratedColumn<String>(
    'claim_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES claims (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, claimId, label, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'claim_timeline_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimelineEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('claim_id')) {
      context.handle(
        _claimIdMeta,
        claimId.isAcceptableOrUnknown(data['claim_id']!, _claimIdMeta),
      );
    } else if (isInserting) {
      context.missing(_claimIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimelineEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimelineEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      claimId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ClaimTimelineEventsTable createAlias(String alias) {
    return $ClaimTimelineEventsTable(attachedDatabase, alias);
  }
}

class TimelineEventRow extends DataClass
    implements Insertable<TimelineEventRow> {
  final int id;
  final String claimId;
  final String label;
  final DateTime createdAt;
  const TimelineEventRow({
    required this.id,
    required this.claimId,
    required this.label,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['claim_id'] = Variable<String>(claimId);
    map['label'] = Variable<String>(label);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClaimTimelineEventsCompanion toCompanion(bool nullToAbsent) {
    return ClaimTimelineEventsCompanion(
      id: Value(id),
      claimId: Value(claimId),
      label: Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory TimelineEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimelineEventRow(
      id: serializer.fromJson<int>(json['id']),
      claimId: serializer.fromJson<String>(json['claimId']),
      label: serializer.fromJson<String>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'claimId': serializer.toJson<String>(claimId),
      'label': serializer.toJson<String>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TimelineEventRow copyWith({
    int? id,
    String? claimId,
    String? label,
    DateTime? createdAt,
  }) => TimelineEventRow(
    id: id ?? this.id,
    claimId: claimId ?? this.claimId,
    label: label ?? this.label,
    createdAt: createdAt ?? this.createdAt,
  );
  TimelineEventRow copyWithCompanion(ClaimTimelineEventsCompanion data) {
    return TimelineEventRow(
      id: data.id.present ? data.id.value : this.id,
      claimId: data.claimId.present ? data.claimId.value : this.claimId,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimelineEventRow(')
          ..write('id: $id, ')
          ..write('claimId: $claimId, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, claimId, label, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineEventRow &&
          other.id == this.id &&
          other.claimId == this.claimId &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class ClaimTimelineEventsCompanion extends UpdateCompanion<TimelineEventRow> {
  final Value<int> id;
  final Value<String> claimId;
  final Value<String> label;
  final Value<DateTime> createdAt;
  const ClaimTimelineEventsCompanion({
    this.id = const Value.absent(),
    this.claimId = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClaimTimelineEventsCompanion.insert({
    this.id = const Value.absent(),
    required String claimId,
    required String label,
    this.createdAt = const Value.absent(),
  }) : claimId = Value(claimId),
       label = Value(label);
  static Insertable<TimelineEventRow> custom({
    Expression<int>? id,
    Expression<String>? claimId,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (claimId != null) 'claim_id': claimId,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClaimTimelineEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? claimId,
    Value<String>? label,
    Value<DateTime>? createdAt,
  }) {
    return ClaimTimelineEventsCompanion(
      id: id ?? this.id,
      claimId: claimId ?? this.claimId,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (claimId.present) {
      map['claim_id'] = Variable<String>(claimId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClaimTimelineEventsCompanion(')
          ..write('id: $id, ')
          ..write('claimId: $claimId, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ClaimDocumentsTable extends ClaimDocuments
    with TableInfo<$ClaimDocumentsTable, DocumentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClaimDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _claimIdMeta = const VerificationMeta(
    'claimId',
  );
  @override
  late final GeneratedColumn<String> claimId = GeneratedColumn<String>(
    'claim_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES claims (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Pièce'),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uid,
    claimId,
    name,
    kind,
    path,
    requestId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'claim_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    }
    if (data.containsKey('claim_id')) {
      context.handle(
        _claimIdMeta,
        claimId.isAcceptableOrUnknown(data['claim_id']!, _claimIdMeta),
      );
    } else if (isInserting) {
      context.missing(_claimIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      claimId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      ),
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ClaimDocumentsTable createAlias(String alias) {
    return $ClaimDocumentsTable(attachedDatabase, alias);
  }
}

class DocumentRow extends DataClass implements Insertable<DocumentRow> {
  final int id;
  final String uid;
  final String claimId;
  final String name;
  final String kind;
  final String? path;
  final String? requestId;
  final DateTime createdAt;
  const DocumentRow({
    required this.id,
    required this.uid,
    required this.claimId,
    required this.name,
    required this.kind,
    this.path,
    this.requestId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    map['claim_id'] = Variable<String>(claimId);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    if (!nullToAbsent || requestId != null) {
      map['request_id'] = Variable<String>(requestId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClaimDocumentsCompanion toCompanion(bool nullToAbsent) {
    return ClaimDocumentsCompanion(
      id: Value(id),
      uid: Value(uid),
      claimId: Value(claimId),
      name: Value(name),
      kind: Value(kind),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      requestId: requestId == null && nullToAbsent
          ? const Value.absent()
          : Value(requestId),
      createdAt: Value(createdAt),
    );
  }

  factory DocumentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentRow(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      claimId: serializer.fromJson<String>(json['claimId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      path: serializer.fromJson<String?>(json['path']),
      requestId: serializer.fromJson<String?>(json['requestId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'claimId': serializer.toJson<String>(claimId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'path': serializer.toJson<String?>(path),
      'requestId': serializer.toJson<String?>(requestId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DocumentRow copyWith({
    int? id,
    String? uid,
    String? claimId,
    String? name,
    String? kind,
    Value<String?> path = const Value.absent(),
    Value<String?> requestId = const Value.absent(),
    DateTime? createdAt,
  }) => DocumentRow(
    id: id ?? this.id,
    uid: uid ?? this.uid,
    claimId: claimId ?? this.claimId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    path: path.present ? path.value : this.path,
    requestId: requestId.present ? requestId.value : this.requestId,
    createdAt: createdAt ?? this.createdAt,
  );
  DocumentRow copyWithCompanion(ClaimDocumentsCompanion data) {
    return DocumentRow(
      id: data.id.present ? data.id.value : this.id,
      uid: data.uid.present ? data.uid.value : this.uid,
      claimId: data.claimId.present ? data.claimId.value : this.claimId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      path: data.path.present ? data.path.value : this.path,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRow(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('claimId: $claimId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('path: $path, ')
          ..write('requestId: $requestId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, uid, claimId, name, kind, path, requestId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentRow &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.claimId == this.claimId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.path == this.path &&
          other.requestId == this.requestId &&
          other.createdAt == this.createdAt);
}

class ClaimDocumentsCompanion extends UpdateCompanion<DocumentRow> {
  final Value<int> id;
  final Value<String> uid;
  final Value<String> claimId;
  final Value<String> name;
  final Value<String> kind;
  final Value<String?> path;
  final Value<String?> requestId;
  final Value<DateTime> createdAt;
  const ClaimDocumentsCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.claimId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.path = const Value.absent(),
    this.requestId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClaimDocumentsCompanion.insert({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    required String claimId,
    required String name,
    this.kind = const Value.absent(),
    this.path = const Value.absent(),
    this.requestId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : claimId = Value(claimId),
       name = Value(name);
  static Insertable<DocumentRow> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<String>? claimId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? path,
    Expression<String>? requestId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (claimId != null) 'claim_id': claimId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (path != null) 'path': path,
      if (requestId != null) 'request_id': requestId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClaimDocumentsCompanion copyWith({
    Value<int>? id,
    Value<String>? uid,
    Value<String>? claimId,
    Value<String>? name,
    Value<String>? kind,
    Value<String?>? path,
    Value<String?>? requestId,
    Value<DateTime>? createdAt,
  }) {
    return ClaimDocumentsCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      claimId: claimId ?? this.claimId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      path: path ?? this.path,
      requestId: requestId ?? this.requestId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (claimId.present) {
      map['claim_id'] = Variable<String>(claimId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClaimDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('claimId: $claimId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('path: $path, ')
          ..write('requestId: $requestId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DocumentRequestsTable extends DocumentRequests
    with TableInfo<$DocumentRequestsTable, DocumentRequestRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _claimIdMeta = const VerificationMeta(
    'claimId',
  );
  @override
  late final GeneratedColumn<String> claimId = GeneratedColumn<String>(
    'claim_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES claims (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    claimId,
    label,
    note,
    documentId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentRequestRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('claim_id')) {
      context.handle(
        _claimIdMeta,
        claimId.isAcceptableOrUnknown(data['claim_id']!, _claimIdMeta),
      );
    } else if (isInserting) {
      context.missing(_claimIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentRequestRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentRequestRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      claimId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DocumentRequestsTable createAlias(String alias) {
    return $DocumentRequestsTable(attachedDatabase, alias);
  }
}

class DocumentRequestRow extends DataClass
    implements Insertable<DocumentRequestRow> {
  final String id;
  final String claimId;
  final String label;
  final String note;
  final String? documentId;
  final DateTime createdAt;
  const DocumentRequestRow({
    required this.id,
    required this.claimId,
    required this.label,
    required this.note,
    this.documentId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['claim_id'] = Variable<String>(claimId);
    map['label'] = Variable<String>(label);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || documentId != null) {
      map['document_id'] = Variable<String>(documentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DocumentRequestsCompanion toCompanion(bool nullToAbsent) {
    return DocumentRequestsCompanion(
      id: Value(id),
      claimId: Value(claimId),
      label: Value(label),
      note: Value(note),
      documentId: documentId == null && nullToAbsent
          ? const Value.absent()
          : Value(documentId),
      createdAt: Value(createdAt),
    );
  }

  factory DocumentRequestRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentRequestRow(
      id: serializer.fromJson<String>(json['id']),
      claimId: serializer.fromJson<String>(json['claimId']),
      label: serializer.fromJson<String>(json['label']),
      note: serializer.fromJson<String>(json['note']),
      documentId: serializer.fromJson<String?>(json['documentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'claimId': serializer.toJson<String>(claimId),
      'label': serializer.toJson<String>(label),
      'note': serializer.toJson<String>(note),
      'documentId': serializer.toJson<String?>(documentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DocumentRequestRow copyWith({
    String? id,
    String? claimId,
    String? label,
    String? note,
    Value<String?> documentId = const Value.absent(),
    DateTime? createdAt,
  }) => DocumentRequestRow(
    id: id ?? this.id,
    claimId: claimId ?? this.claimId,
    label: label ?? this.label,
    note: note ?? this.note,
    documentId: documentId.present ? documentId.value : this.documentId,
    createdAt: createdAt ?? this.createdAt,
  );
  DocumentRequestRow copyWithCompanion(DocumentRequestsCompanion data) {
    return DocumentRequestRow(
      id: data.id.present ? data.id.value : this.id,
      claimId: data.claimId.present ? data.claimId.value : this.claimId,
      label: data.label.present ? data.label.value : this.label,
      note: data.note.present ? data.note.value : this.note,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRequestRow(')
          ..write('id: $id, ')
          ..write('claimId: $claimId, ')
          ..write('label: $label, ')
          ..write('note: $note, ')
          ..write('documentId: $documentId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, claimId, label, note, documentId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentRequestRow &&
          other.id == this.id &&
          other.claimId == this.claimId &&
          other.label == this.label &&
          other.note == this.note &&
          other.documentId == this.documentId &&
          other.createdAt == this.createdAt);
}

class DocumentRequestsCompanion extends UpdateCompanion<DocumentRequestRow> {
  final Value<String> id;
  final Value<String> claimId;
  final Value<String> label;
  final Value<String> note;
  final Value<String?> documentId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DocumentRequestsCompanion({
    this.id = const Value.absent(),
    this.claimId = const Value.absent(),
    this.label = const Value.absent(),
    this.note = const Value.absent(),
    this.documentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentRequestsCompanion.insert({
    required String id,
    required String claimId,
    required String label,
    this.note = const Value.absent(),
    this.documentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       claimId = Value(claimId),
       label = Value(label);
  static Insertable<DocumentRequestRow> custom({
    Expression<String>? id,
    Expression<String>? claimId,
    Expression<String>? label,
    Expression<String>? note,
    Expression<String>? documentId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (claimId != null) 'claim_id': claimId,
      if (label != null) 'label': label,
      if (note != null) 'note': note,
      if (documentId != null) 'document_id': documentId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? claimId,
    Value<String>? label,
    Value<String>? note,
    Value<String?>? documentId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DocumentRequestsCompanion(
      id: id ?? this.id,
      claimId: claimId ?? this.claimId,
      label: label ?? this.label,
      note: note ?? this.note,
      documentId: documentId ?? this.documentId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (claimId.present) {
      map['claim_id'] = Variable<String>(claimId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRequestsCompanion(')
          ..write('id: $id, ')
          ..write('claimId: $claimId, ')
          ..write('label: $label, ')
          ..write('note: $note, ')
          ..write('documentId: $documentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClaimNotificationsTable extends ClaimNotifications
    with TableInfo<$ClaimNotificationsTable, NotificationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClaimNotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _claimIdMeta = const VerificationMeta(
    'claimId',
  );
  @override
  late final GeneratedColumn<String> claimId = GeneratedColumn<String>(
    'claim_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audienceMeta = const VerificationMeta(
    'audience',
  );
  @override
  late final GeneratedColumn<String> audience = GeneratedColumn<String>(
    'audience',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('driver'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uid,
    claimId,
    audience,
    body,
    isRead,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'claim_notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    }
    if (data.containsKey('claim_id')) {
      context.handle(
        _claimIdMeta,
        claimId.isAcceptableOrUnknown(data['claim_id']!, _claimIdMeta),
      );
    }
    if (data.containsKey('audience')) {
      context.handle(
        _audienceMeta,
        audience.isAcceptableOrUnknown(data['audience']!, _audienceMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      claimId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_id'],
      ),
      audience: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audience'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ClaimNotificationsTable createAlias(String alias) {
    return $ClaimNotificationsTable(attachedDatabase, alias);
  }
}

class NotificationRow extends DataClass implements Insertable<NotificationRow> {
  final int id;
  final String uid;
  final String? claimId;
  final String audience;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  const NotificationRow({
    required this.id,
    required this.uid,
    this.claimId,
    required this.audience,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    if (!nullToAbsent || claimId != null) {
      map['claim_id'] = Variable<String>(claimId);
    }
    map['audience'] = Variable<String>(audience);
    map['body'] = Variable<String>(body);
    map['is_read'] = Variable<bool>(isRead);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClaimNotificationsCompanion toCompanion(bool nullToAbsent) {
    return ClaimNotificationsCompanion(
      id: Value(id),
      uid: Value(uid),
      claimId: claimId == null && nullToAbsent
          ? const Value.absent()
          : Value(claimId),
      audience: Value(audience),
      body: Value(body),
      isRead: Value(isRead),
      createdAt: Value(createdAt),
    );
  }

  factory NotificationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationRow(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      claimId: serializer.fromJson<String?>(json['claimId']),
      audience: serializer.fromJson<String>(json['audience']),
      body: serializer.fromJson<String>(json['body']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'claimId': serializer.toJson<String?>(claimId),
      'audience': serializer.toJson<String>(audience),
      'body': serializer.toJson<String>(body),
      'isRead': serializer.toJson<bool>(isRead),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NotificationRow copyWith({
    int? id,
    String? uid,
    Value<String?> claimId = const Value.absent(),
    String? audience,
    String? body,
    bool? isRead,
    DateTime? createdAt,
  }) => NotificationRow(
    id: id ?? this.id,
    uid: uid ?? this.uid,
    claimId: claimId.present ? claimId.value : this.claimId,
    audience: audience ?? this.audience,
    body: body ?? this.body,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt ?? this.createdAt,
  );
  NotificationRow copyWithCompanion(ClaimNotificationsCompanion data) {
    return NotificationRow(
      id: data.id.present ? data.id.value : this.id,
      uid: data.uid.present ? data.uid.value : this.uid,
      claimId: data.claimId.present ? data.claimId.value : this.claimId,
      audience: data.audience.present ? data.audience.value : this.audience,
      body: data.body.present ? data.body.value : this.body,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRow(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('claimId: $claimId, ')
          ..write('audience: $audience, ')
          ..write('body: $body, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, uid, claimId, audience, body, isRead, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationRow &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.claimId == this.claimId &&
          other.audience == this.audience &&
          other.body == this.body &&
          other.isRead == this.isRead &&
          other.createdAt == this.createdAt);
}

class ClaimNotificationsCompanion extends UpdateCompanion<NotificationRow> {
  final Value<int> id;
  final Value<String> uid;
  final Value<String?> claimId;
  final Value<String> audience;
  final Value<String> body;
  final Value<bool> isRead;
  final Value<DateTime> createdAt;
  const ClaimNotificationsCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.claimId = const Value.absent(),
    this.audience = const Value.absent(),
    this.body = const Value.absent(),
    this.isRead = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClaimNotificationsCompanion.insert({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.claimId = const Value.absent(),
    this.audience = const Value.absent(),
    required String body,
    this.isRead = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : body = Value(body);
  static Insertable<NotificationRow> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<String>? claimId,
    Expression<String>? audience,
    Expression<String>? body,
    Expression<bool>? isRead,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (claimId != null) 'claim_id': claimId,
      if (audience != null) 'audience': audience,
      if (body != null) 'body': body,
      if (isRead != null) 'is_read': isRead,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClaimNotificationsCompanion copyWith({
    Value<int>? id,
    Value<String>? uid,
    Value<String?>? claimId,
    Value<String>? audience,
    Value<String>? body,
    Value<bool>? isRead,
    Value<DateTime>? createdAt,
  }) {
    return ClaimNotificationsCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      claimId: claimId ?? this.claimId,
      audience: audience ?? this.audience,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (claimId.present) {
      map['claim_id'] = Variable<String>(claimId.value);
    }
    if (audience.present) {
      map['audience'] = Variable<String>(audience.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClaimNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('claimId: $claimId, ')
          ..write('audience: $audience, ')
          ..write('body: $body, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _claimIdMeta = const VerificationMeta(
    'claimId',
  );
  @override
  late final GeneratedColumn<String> claimId = GeneratedColumn<String>(
    'claim_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderRoleMeta = const VerificationMeta(
    'senderRole',
  );
  @override
  late final GeneratedColumn<String> senderRole = GeneratedColumn<String>(
    'sender_role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('driver'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attachmentNameMeta = const VerificationMeta(
    'attachmentName',
  );
  @override
  late final GeneratedColumn<String> attachmentName = GeneratedColumn<String>(
    'attachment_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attachmentPathMeta = const VerificationMeta(
    'attachmentPath',
  );
  @override
  late final GeneratedColumn<String> attachmentPath = GeneratedColumn<String>(
    'attachment_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uid,
    claimId,
    author,
    senderRole,
    body,
    attachmentName,
    attachmentPath,
    isRead,
    sentAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    }
    if (data.containsKey('claim_id')) {
      context.handle(
        _claimIdMeta,
        claimId.isAcceptableOrUnknown(data['claim_id']!, _claimIdMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('sender_role')) {
      context.handle(
        _senderRoleMeta,
        senderRole.isAcceptableOrUnknown(data['sender_role']!, _senderRoleMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('attachment_name')) {
      context.handle(
        _attachmentNameMeta,
        attachmentName.isAcceptableOrUnknown(
          data['attachment_name']!,
          _attachmentNameMeta,
        ),
      );
    }
    if (data.containsKey('attachment_path')) {
      context.handle(
        _attachmentPathMeta,
        attachmentPath.isAcceptableOrUnknown(
          data['attachment_path']!,
          _attachmentPathMeta,
        ),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      claimId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_id'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      senderRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_role'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      attachmentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_name'],
      ),
      attachmentPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_path'],
      ),
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessageRow extends DataClass implements Insertable<ChatMessageRow> {
  final int id;
  final String uid;
  final String? claimId;
  final String author;
  final String senderRole;
  final String body;
  final String? attachmentName;
  final String? attachmentPath;
  final bool isRead;
  final DateTime sentAt;
  const ChatMessageRow({
    required this.id,
    required this.uid,
    this.claimId,
    required this.author,
    required this.senderRole,
    required this.body,
    this.attachmentName,
    this.attachmentPath,
    required this.isRead,
    required this.sentAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    if (!nullToAbsent || claimId != null) {
      map['claim_id'] = Variable<String>(claimId);
    }
    map['author'] = Variable<String>(author);
    map['sender_role'] = Variable<String>(senderRole);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || attachmentName != null) {
      map['attachment_name'] = Variable<String>(attachmentName);
    }
    if (!nullToAbsent || attachmentPath != null) {
      map['attachment_path'] = Variable<String>(attachmentPath);
    }
    map['is_read'] = Variable<bool>(isRead);
    map['sent_at'] = Variable<DateTime>(sentAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      uid: Value(uid),
      claimId: claimId == null && nullToAbsent
          ? const Value.absent()
          : Value(claimId),
      author: Value(author),
      senderRole: Value(senderRole),
      body: Value(body),
      attachmentName: attachmentName == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentName),
      attachmentPath: attachmentPath == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentPath),
      isRead: Value(isRead),
      sentAt: Value(sentAt),
    );
  }

  factory ChatMessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageRow(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      claimId: serializer.fromJson<String?>(json['claimId']),
      author: serializer.fromJson<String>(json['author']),
      senderRole: serializer.fromJson<String>(json['senderRole']),
      body: serializer.fromJson<String>(json['body']),
      attachmentName: serializer.fromJson<String?>(json['attachmentName']),
      attachmentPath: serializer.fromJson<String?>(json['attachmentPath']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'claimId': serializer.toJson<String?>(claimId),
      'author': serializer.toJson<String>(author),
      'senderRole': serializer.toJson<String>(senderRole),
      'body': serializer.toJson<String>(body),
      'attachmentName': serializer.toJson<String?>(attachmentName),
      'attachmentPath': serializer.toJson<String?>(attachmentPath),
      'isRead': serializer.toJson<bool>(isRead),
      'sentAt': serializer.toJson<DateTime>(sentAt),
    };
  }

  ChatMessageRow copyWith({
    int? id,
    String? uid,
    Value<String?> claimId = const Value.absent(),
    String? author,
    String? senderRole,
    String? body,
    Value<String?> attachmentName = const Value.absent(),
    Value<String?> attachmentPath = const Value.absent(),
    bool? isRead,
    DateTime? sentAt,
  }) => ChatMessageRow(
    id: id ?? this.id,
    uid: uid ?? this.uid,
    claimId: claimId.present ? claimId.value : this.claimId,
    author: author ?? this.author,
    senderRole: senderRole ?? this.senderRole,
    body: body ?? this.body,
    attachmentName: attachmentName.present
        ? attachmentName.value
        : this.attachmentName,
    attachmentPath: attachmentPath.present
        ? attachmentPath.value
        : this.attachmentPath,
    isRead: isRead ?? this.isRead,
    sentAt: sentAt ?? this.sentAt,
  );
  ChatMessageRow copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessageRow(
      id: data.id.present ? data.id.value : this.id,
      uid: data.uid.present ? data.uid.value : this.uid,
      claimId: data.claimId.present ? data.claimId.value : this.claimId,
      author: data.author.present ? data.author.value : this.author,
      senderRole: data.senderRole.present
          ? data.senderRole.value
          : this.senderRole,
      body: data.body.present ? data.body.value : this.body,
      attachmentName: data.attachmentName.present
          ? data.attachmentName.value
          : this.attachmentName,
      attachmentPath: data.attachmentPath.present
          ? data.attachmentPath.value
          : this.attachmentPath,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageRow(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('claimId: $claimId, ')
          ..write('author: $author, ')
          ..write('senderRole: $senderRole, ')
          ..write('body: $body, ')
          ..write('attachmentName: $attachmentName, ')
          ..write('attachmentPath: $attachmentPath, ')
          ..write('isRead: $isRead, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uid,
    claimId,
    author,
    senderRole,
    body,
    attachmentName,
    attachmentPath,
    isRead,
    sentAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageRow &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.claimId == this.claimId &&
          other.author == this.author &&
          other.senderRole == this.senderRole &&
          other.body == this.body &&
          other.attachmentName == this.attachmentName &&
          other.attachmentPath == this.attachmentPath &&
          other.isRead == this.isRead &&
          other.sentAt == this.sentAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessageRow> {
  final Value<int> id;
  final Value<String> uid;
  final Value<String?> claimId;
  final Value<String> author;
  final Value<String> senderRole;
  final Value<String> body;
  final Value<String?> attachmentName;
  final Value<String?> attachmentPath;
  final Value<bool> isRead;
  final Value<DateTime> sentAt;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.claimId = const Value.absent(),
    this.author = const Value.absent(),
    this.senderRole = const Value.absent(),
    this.body = const Value.absent(),
    this.attachmentName = const Value.absent(),
    this.attachmentPath = const Value.absent(),
    this.isRead = const Value.absent(),
    this.sentAt = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.claimId = const Value.absent(),
    required String author,
    this.senderRole = const Value.absent(),
    required String body,
    this.attachmentName = const Value.absent(),
    this.attachmentPath = const Value.absent(),
    this.isRead = const Value.absent(),
    this.sentAt = const Value.absent(),
  }) : author = Value(author),
       body = Value(body);
  static Insertable<ChatMessageRow> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<String>? claimId,
    Expression<String>? author,
    Expression<String>? senderRole,
    Expression<String>? body,
    Expression<String>? attachmentName,
    Expression<String>? attachmentPath,
    Expression<bool>? isRead,
    Expression<DateTime>? sentAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (claimId != null) 'claim_id': claimId,
      if (author != null) 'author': author,
      if (senderRole != null) 'sender_role': senderRole,
      if (body != null) 'body': body,
      if (attachmentName != null) 'attachment_name': attachmentName,
      if (attachmentPath != null) 'attachment_path': attachmentPath,
      if (isRead != null) 'is_read': isRead,
      if (sentAt != null) 'sent_at': sentAt,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? uid,
    Value<String?>? claimId,
    Value<String>? author,
    Value<String>? senderRole,
    Value<String>? body,
    Value<String?>? attachmentName,
    Value<String?>? attachmentPath,
    Value<bool>? isRead,
    Value<DateTime>? sentAt,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      claimId: claimId ?? this.claimId,
      author: author ?? this.author,
      senderRole: senderRole ?? this.senderRole,
      body: body ?? this.body,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (claimId.present) {
      map['claim_id'] = Variable<String>(claimId.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (senderRole.present) {
      map['sender_role'] = Variable<String>(senderRole.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (attachmentName.present) {
      map['attachment_name'] = Variable<String>(attachmentName.value);
    }
    if (attachmentPath.present) {
      map['attachment_path'] = Variable<String>(attachmentPath.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('claimId: $claimId, ')
          ..write('author: $author, ')
          ..write('senderRole: $senderRole, ')
          ..write('body: $body, ')
          ..write('attachmentName: $attachmentName, ')
          ..write('attachmentPath: $attachmentPath, ')
          ..write('isRead: $isRead, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _multipartMeta = const VerificationMeta(
    'multipart',
  );
  @override
  late final GeneratedColumn<bool> multipart = GeneratedColumn<bool>(
    'multipart',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("multipart" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorRoleMeta = const VerificationMeta(
    'actorRole',
  );
  @override
  late final GeneratedColumn<String> actorRole = GeneratedColumn<String>(
    'actor_role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorNameMeta = const VerificationMeta(
    'actorName',
  );
  @override
  late final GeneratedColumn<String> actorName = GeneratedColumn<String>(
    'actor_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    id,
    method,
    path,
    body,
    multipart,
    filePath,
    actorId,
    actorRole,
    actorName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('multipart')) {
      context.handle(
        _multipartMeta,
        multipart.isAcceptableOrUnknown(data['multipart']!, _multipartMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('actor_role')) {
      context.handle(
        _actorRoleMeta,
        actorRole.isAcceptableOrUnknown(data['actor_role']!, _actorRoleMeta),
      );
    } else if (isInserting) {
      context.missing(_actorRoleMeta);
    }
    if (data.containsKey('actor_name')) {
      context.handle(
        _actorNameMeta,
        actorName.isAcceptableOrUnknown(data['actor_name']!, _actorNameMeta),
      );
    } else if (isInserting) {
      context.missing(_actorNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      multipart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}multipart'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      )!,
      actorRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_role'],
      )!,
      actorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_name'],
      )!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final int seq;
  final String id;
  final String method;
  final String path;
  final String body;
  final bool multipart;
  final String? filePath;

  /// Auteur du changement : le rôle actif peut changer avant l'envoi.
  final String actorId;
  final String actorRole;
  final String actorName;
  const OutboxRow({
    required this.seq,
    required this.id,
    required this.method,
    required this.path,
    required this.body,
    required this.multipart,
    this.filePath,
    required this.actorId,
    required this.actorRole,
    required this.actorName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['id'] = Variable<String>(id);
    map['method'] = Variable<String>(method);
    map['path'] = Variable<String>(path);
    map['body'] = Variable<String>(body);
    map['multipart'] = Variable<bool>(multipart);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    map['actor_id'] = Variable<String>(actorId);
    map['actor_role'] = Variable<String>(actorRole);
    map['actor_name'] = Variable<String>(actorName);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      seq: Value(seq),
      id: Value(id),
      method: Value(method),
      path: Value(path),
      body: Value(body),
      multipart: Value(multipart),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      actorId: Value(actorId),
      actorRole: Value(actorRole),
      actorName: Value(actorName),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      seq: serializer.fromJson<int>(json['seq']),
      id: serializer.fromJson<String>(json['id']),
      method: serializer.fromJson<String>(json['method']),
      path: serializer.fromJson<String>(json['path']),
      body: serializer.fromJson<String>(json['body']),
      multipart: serializer.fromJson<bool>(json['multipart']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      actorId: serializer.fromJson<String>(json['actorId']),
      actorRole: serializer.fromJson<String>(json['actorRole']),
      actorName: serializer.fromJson<String>(json['actorName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'id': serializer.toJson<String>(id),
      'method': serializer.toJson<String>(method),
      'path': serializer.toJson<String>(path),
      'body': serializer.toJson<String>(body),
      'multipart': serializer.toJson<bool>(multipart),
      'filePath': serializer.toJson<String?>(filePath),
      'actorId': serializer.toJson<String>(actorId),
      'actorRole': serializer.toJson<String>(actorRole),
      'actorName': serializer.toJson<String>(actorName),
    };
  }

  OutboxRow copyWith({
    int? seq,
    String? id,
    String? method,
    String? path,
    String? body,
    bool? multipart,
    Value<String?> filePath = const Value.absent(),
    String? actorId,
    String? actorRole,
    String? actorName,
  }) => OutboxRow(
    seq: seq ?? this.seq,
    id: id ?? this.id,
    method: method ?? this.method,
    path: path ?? this.path,
    body: body ?? this.body,
    multipart: multipart ?? this.multipart,
    filePath: filePath.present ? filePath.value : this.filePath,
    actorId: actorId ?? this.actorId,
    actorRole: actorRole ?? this.actorRole,
    actorName: actorName ?? this.actorName,
  );
  OutboxRow copyWithCompanion(SyncOutboxCompanion data) {
    return OutboxRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      id: data.id.present ? data.id.value : this.id,
      method: data.method.present ? data.method.value : this.method,
      path: data.path.present ? data.path.value : this.path,
      body: data.body.present ? data.body.value : this.body,
      multipart: data.multipart.present ? data.multipart.value : this.multipart,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      actorRole: data.actorRole.present ? data.actorRole.value : this.actorRole,
      actorName: data.actorName.present ? data.actorName.value : this.actorName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('seq: $seq, ')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('body: $body, ')
          ..write('multipart: $multipart, ')
          ..write('filePath: $filePath, ')
          ..write('actorId: $actorId, ')
          ..write('actorRole: $actorRole, ')
          ..write('actorName: $actorName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    id,
    method,
    path,
    body,
    multipart,
    filePath,
    actorId,
    actorRole,
    actorName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.seq == this.seq &&
          other.id == this.id &&
          other.method == this.method &&
          other.path == this.path &&
          other.body == this.body &&
          other.multipart == this.multipart &&
          other.filePath == this.filePath &&
          other.actorId == this.actorId &&
          other.actorRole == this.actorRole &&
          other.actorName == this.actorName);
}

class SyncOutboxCompanion extends UpdateCompanion<OutboxRow> {
  final Value<int> seq;
  final Value<String> id;
  final Value<String> method;
  final Value<String> path;
  final Value<String> body;
  final Value<bool> multipart;
  final Value<String?> filePath;
  final Value<String> actorId;
  final Value<String> actorRole;
  final Value<String> actorName;
  const SyncOutboxCompanion({
    this.seq = const Value.absent(),
    this.id = const Value.absent(),
    this.method = const Value.absent(),
    this.path = const Value.absent(),
    this.body = const Value.absent(),
    this.multipart = const Value.absent(),
    this.filePath = const Value.absent(),
    this.actorId = const Value.absent(),
    this.actorRole = const Value.absent(),
    this.actorName = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String id,
    required String method,
    required String path,
    this.body = const Value.absent(),
    this.multipart = const Value.absent(),
    this.filePath = const Value.absent(),
    required String actorId,
    required String actorRole,
    required String actorName,
  }) : id = Value(id),
       method = Value(method),
       path = Value(path),
       actorId = Value(actorId),
       actorRole = Value(actorRole),
       actorName = Value(actorName);
  static Insertable<OutboxRow> custom({
    Expression<int>? seq,
    Expression<String>? id,
    Expression<String>? method,
    Expression<String>? path,
    Expression<String>? body,
    Expression<bool>? multipart,
    Expression<String>? filePath,
    Expression<String>? actorId,
    Expression<String>? actorRole,
    Expression<String>? actorName,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (id != null) 'id': id,
      if (method != null) 'method': method,
      if (path != null) 'path': path,
      if (body != null) 'body': body,
      if (multipart != null) 'multipart': multipart,
      if (filePath != null) 'file_path': filePath,
      if (actorId != null) 'actor_id': actorId,
      if (actorRole != null) 'actor_role': actorRole,
      if (actorName != null) 'actor_name': actorName,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<int>? seq,
    Value<String>? id,
    Value<String>? method,
    Value<String>? path,
    Value<String>? body,
    Value<bool>? multipart,
    Value<String?>? filePath,
    Value<String>? actorId,
    Value<String>? actorRole,
    Value<String>? actorName,
  }) {
    return SyncOutboxCompanion(
      seq: seq ?? this.seq,
      id: id ?? this.id,
      method: method ?? this.method,
      path: path ?? this.path,
      body: body ?? this.body,
      multipart: multipart ?? this.multipart,
      filePath: filePath ?? this.filePath,
      actorId: actorId ?? this.actorId,
      actorRole: actorRole ?? this.actorRole,
      actorName: actorName ?? this.actorName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (multipart.present) {
      map['multipart'] = Variable<bool>(multipart.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (actorRole.present) {
      map['actor_role'] = Variable<String>(actorRole.value);
    }
    if (actorName.present) {
      map['actor_name'] = Variable<String>(actorName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('body: $body, ')
          ..write('multipart: $multipart, ')
          ..write('filePath: $filePath, ')
          ..write('actorId: $actorId, ')
          ..write('actorRole: $actorRole, ')
          ..write('actorName: $actorName')
          ..write(')'))
        .toString();
  }
}

abstract class _$ClaimsDatabase extends GeneratedDatabase {
  _$ClaimsDatabase(QueryExecutor e) : super(e);
  $ClaimsDatabaseManager get managers => $ClaimsDatabaseManager(this);
  late final $ClaimsTable claims = $ClaimsTable(this);
  late final $ClaimTimelineEventsTable claimTimelineEvents =
      $ClaimTimelineEventsTable(this);
  late final $ClaimDocumentsTable claimDocuments = $ClaimDocumentsTable(this);
  late final $DocumentRequestsTable documentRequests = $DocumentRequestsTable(
    this,
  );
  late final $ClaimNotificationsTable claimNotifications =
      $ClaimNotificationsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final Index claimDocumentsUid = Index(
    'claim_documents_uid',
    'CREATE UNIQUE INDEX claim_documents_uid ON claim_documents (uid)',
  );
  late final Index claimNotificationsUid = Index(
    'claim_notifications_uid',
    'CREATE UNIQUE INDEX claim_notifications_uid ON claim_notifications (uid)',
  );
  late final Index chatMessagesUid = Index(
    'chat_messages_uid',
    'CREATE UNIQUE INDEX chat_messages_uid ON chat_messages (uid)',
  );
  late final ClaimsDao claimsDao = ClaimsDao(this as ClaimsDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    claims,
    claimTimelineEvents,
    claimDocuments,
    documentRequests,
    claimNotifications,
    chatMessages,
    syncOutbox,
    claimDocumentsUid,
    claimNotificationsUid,
    chatMessagesUid,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'claims',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('claim_timeline_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'claims',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('claim_documents', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'claims',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_requests', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ClaimsTableCreateCompanionBuilder =
    ClaimsCompanion Function({
      required String id,
      required String type,
      required String place,
      required String date,
      required String status,
      required String severity,
      Value<String> observations,
      Value<String> circumstances,
      Value<String> impactZones,
      Value<String?> agentName,
      Value<String?> expertName,
      Value<DateTime?> expertAppointment,
      Value<int?> responsibility,
      Value<double?> indemnity,
      Value<String?> decisionReason,
      Value<int> rowid,
    });
typedef $$ClaimsTableUpdateCompanionBuilder =
    ClaimsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> place,
      Value<String> date,
      Value<String> status,
      Value<String> severity,
      Value<String> observations,
      Value<String> circumstances,
      Value<String> impactZones,
      Value<String?> agentName,
      Value<String?> expertName,
      Value<DateTime?> expertAppointment,
      Value<int?> responsibility,
      Value<double?> indemnity,
      Value<String?> decisionReason,
      Value<int> rowid,
    });

final class $$ClaimsTableReferences
    extends BaseReferences<_$ClaimsDatabase, $ClaimsTable, ClaimRow> {
  $$ClaimsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClaimTimelineEventsTable, List<TimelineEventRow>>
  _claimTimelineEventsRefsTable(_$ClaimsDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.claimTimelineEvents,
        aliasName: 'claims__id__claim_timeline_events__claim_id',
      );

  $$ClaimTimelineEventsTableProcessedTableManager get claimTimelineEventsRefs {
    final manager = $$ClaimTimelineEventsTableTableManager(
      $_db,
      $_db.claimTimelineEvents,
    ).filter((f) => f.claimId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _claimTimelineEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ClaimDocumentsTable, List<DocumentRow>>
  _claimDocumentsRefsTable(_$ClaimsDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.claimDocuments,
        aliasName: 'claims__id__claim_documents__claim_id',
      );

  $$ClaimDocumentsTableProcessedTableManager get claimDocumentsRefs {
    final manager = $$ClaimDocumentsTableTableManager(
      $_db,
      $_db.claimDocuments,
    ).filter((f) => f.claimId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_claimDocumentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DocumentRequestsTable, List<DocumentRequestRow>>
  _documentRequestsRefsTable(_$ClaimsDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.documentRequests,
        aliasName: 'claims__id__document_requests__claim_id',
      );

  $$DocumentRequestsTableProcessedTableManager get documentRequestsRefs {
    final manager = $$DocumentRequestsTableTableManager(
      $_db,
      $_db.documentRequests,
    ).filter((f) => f.claimId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _documentRequestsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClaimsTableFilterComposer
    extends Composer<_$ClaimsDatabase, $ClaimsTable> {
  $$ClaimsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get circumstances => $composableBuilder(
    column: $table.circumstances,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get impactZones => $composableBuilder(
    column: $table.impactZones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentName => $composableBuilder(
    column: $table.agentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expertName => $composableBuilder(
    column: $table.expertName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expertAppointment => $composableBuilder(
    column: $table.expertAppointment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get responsibility => $composableBuilder(
    column: $table.responsibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get indemnity => $composableBuilder(
    column: $table.indemnity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisionReason => $composableBuilder(
    column: $table.decisionReason,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> claimTimelineEventsRefs(
    Expression<bool> Function($$ClaimTimelineEventsTableFilterComposer f) f,
  ) {
    final $$ClaimTimelineEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.claimTimelineEvents,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimTimelineEventsTableFilterComposer(
            $db: $db,
            $table: $db.claimTimelineEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> claimDocumentsRefs(
    Expression<bool> Function($$ClaimDocumentsTableFilterComposer f) f,
  ) {
    final $$ClaimDocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.claimDocuments,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimDocumentsTableFilterComposer(
            $db: $db,
            $table: $db.claimDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> documentRequestsRefs(
    Expression<bool> Function($$DocumentRequestsTableFilterComposer f) f,
  ) {
    final $$DocumentRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentRequests,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentRequestsTableFilterComposer(
            $db: $db,
            $table: $db.documentRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClaimsTableOrderingComposer
    extends Composer<_$ClaimsDatabase, $ClaimsTable> {
  $$ClaimsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get circumstances => $composableBuilder(
    column: $table.circumstances,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get impactZones => $composableBuilder(
    column: $table.impactZones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentName => $composableBuilder(
    column: $table.agentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expertName => $composableBuilder(
    column: $table.expertName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expertAppointment => $composableBuilder(
    column: $table.expertAppointment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get responsibility => $composableBuilder(
    column: $table.responsibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get indemnity => $composableBuilder(
    column: $table.indemnity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisionReason => $composableBuilder(
    column: $table.decisionReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClaimsTableAnnotationComposer
    extends Composer<_$ClaimsDatabase, $ClaimsTable> {
  $$ClaimsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get place =>
      $composableBuilder(column: $table.place, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get circumstances => $composableBuilder(
    column: $table.circumstances,
    builder: (column) => column,
  );

  GeneratedColumn<String> get impactZones => $composableBuilder(
    column: $table.impactZones,
    builder: (column) => column,
  );

  GeneratedColumn<String> get agentName =>
      $composableBuilder(column: $table.agentName, builder: (column) => column);

  GeneratedColumn<String> get expertName => $composableBuilder(
    column: $table.expertName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expertAppointment => $composableBuilder(
    column: $table.expertAppointment,
    builder: (column) => column,
  );

  GeneratedColumn<int> get responsibility => $composableBuilder(
    column: $table.responsibility,
    builder: (column) => column,
  );

  GeneratedColumn<double> get indemnity =>
      $composableBuilder(column: $table.indemnity, builder: (column) => column);

  GeneratedColumn<String> get decisionReason => $composableBuilder(
    column: $table.decisionReason,
    builder: (column) => column,
  );

  Expression<T> claimTimelineEventsRefs<T extends Object>(
    Expression<T> Function($$ClaimTimelineEventsTableAnnotationComposer a) f,
  ) {
    final $$ClaimTimelineEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.claimTimelineEvents,
          getReferencedColumn: (t) => t.claimId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ClaimTimelineEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.claimTimelineEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> claimDocumentsRefs<T extends Object>(
    Expression<T> Function($$ClaimDocumentsTableAnnotationComposer a) f,
  ) {
    final $$ClaimDocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.claimDocuments,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimDocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.claimDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> documentRequestsRefs<T extends Object>(
    Expression<T> Function($$DocumentRequestsTableAnnotationComposer a) f,
  ) {
    final $$DocumentRequestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentRequests,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentRequestsTableAnnotationComposer(
            $db: $db,
            $table: $db.documentRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClaimsTableTableManager
    extends
        RootTableManager<
          _$ClaimsDatabase,
          $ClaimsTable,
          ClaimRow,
          $$ClaimsTableFilterComposer,
          $$ClaimsTableOrderingComposer,
          $$ClaimsTableAnnotationComposer,
          $$ClaimsTableCreateCompanionBuilder,
          $$ClaimsTableUpdateCompanionBuilder,
          (ClaimRow, $$ClaimsTableReferences),
          ClaimRow,
          PrefetchHooks Function({
            bool claimTimelineEventsRefs,
            bool claimDocumentsRefs,
            bool documentRequestsRefs,
          })
        > {
  $$ClaimsTableTableManager(_$ClaimsDatabase db, $ClaimsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClaimsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClaimsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClaimsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> place = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String> observations = const Value.absent(),
                Value<String> circumstances = const Value.absent(),
                Value<String> impactZones = const Value.absent(),
                Value<String?> agentName = const Value.absent(),
                Value<String?> expertName = const Value.absent(),
                Value<DateTime?> expertAppointment = const Value.absent(),
                Value<int?> responsibility = const Value.absent(),
                Value<double?> indemnity = const Value.absent(),
                Value<String?> decisionReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClaimsCompanion(
                id: id,
                type: type,
                place: place,
                date: date,
                status: status,
                severity: severity,
                observations: observations,
                circumstances: circumstances,
                impactZones: impactZones,
                agentName: agentName,
                expertName: expertName,
                expertAppointment: expertAppointment,
                responsibility: responsibility,
                indemnity: indemnity,
                decisionReason: decisionReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String place,
                required String date,
                required String status,
                required String severity,
                Value<String> observations = const Value.absent(),
                Value<String> circumstances = const Value.absent(),
                Value<String> impactZones = const Value.absent(),
                Value<String?> agentName = const Value.absent(),
                Value<String?> expertName = const Value.absent(),
                Value<DateTime?> expertAppointment = const Value.absent(),
                Value<int?> responsibility = const Value.absent(),
                Value<double?> indemnity = const Value.absent(),
                Value<String?> decisionReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClaimsCompanion.insert(
                id: id,
                type: type,
                place: place,
                date: date,
                status: status,
                severity: severity,
                observations: observations,
                circumstances: circumstances,
                impactZones: impactZones,
                agentName: agentName,
                expertName: expertName,
                expertAppointment: expertAppointment,
                responsibility: responsibility,
                indemnity: indemnity,
                decisionReason: decisionReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClaimsTable, ClaimRow>(table),
                  $$ClaimsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                claimTimelineEventsRefs = false,
                claimDocumentsRefs = false,
                documentRequestsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (claimTimelineEventsRefs) db.claimTimelineEvents,
                    if (claimDocumentsRefs) db.claimDocuments,
                    if (documentRequestsRefs) db.documentRequests,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (claimTimelineEventsRefs)
                        await $_getPrefetchedDataByColumns<
                          ClaimRow,
                          $ClaimsTable,
                          TimelineEventRow,
                          $ClaimTimelineEventsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ClaimsTableReferences
                              ._claimTimelineEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClaimsTableReferences(
                                db,
                                table,
                                p0,
                              ).claimTimelineEventsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'claim_id',
                          typedResults: items,
                        ),
                      if (claimDocumentsRefs)
                        await $_getPrefetchedDataByColumns<
                          ClaimRow,
                          $ClaimsTable,
                          DocumentRow,
                          $ClaimDocumentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ClaimsTableReferences
                              ._claimDocumentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClaimsTableReferences(
                                db,
                                table,
                                p0,
                              ).claimDocumentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'claim_id',
                          typedResults: items,
                        ),
                      if (documentRequestsRefs)
                        await $_getPrefetchedDataByColumns<
                          ClaimRow,
                          $ClaimsTable,
                          DocumentRequestRow,
                          $DocumentRequestsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ClaimsTableReferences
                              ._documentRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClaimsTableReferences(
                                db,
                                table,
                                p0,
                              ).documentRequestsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'claim_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ClaimsTableProcessedTableManager =
    ProcessedTableManager<
      _$ClaimsDatabase,
      $ClaimsTable,
      ClaimRow,
      $$ClaimsTableFilterComposer,
      $$ClaimsTableOrderingComposer,
      $$ClaimsTableAnnotationComposer,
      $$ClaimsTableCreateCompanionBuilder,
      $$ClaimsTableUpdateCompanionBuilder,
      (ClaimRow, $$ClaimsTableReferences),
      ClaimRow,
      PrefetchHooks Function({
        bool claimTimelineEventsRefs,
        bool claimDocumentsRefs,
        bool documentRequestsRefs,
      })
    >;
typedef $$ClaimTimelineEventsTableCreateCompanionBuilder =
    ClaimTimelineEventsCompanion Function({
      Value<int> id,
      required String claimId,
      required String label,
      Value<DateTime> createdAt,
    });
typedef $$ClaimTimelineEventsTableUpdateCompanionBuilder =
    ClaimTimelineEventsCompanion Function({
      Value<int> id,
      Value<String> claimId,
      Value<String> label,
      Value<DateTime> createdAt,
    });

final class $$ClaimTimelineEventsTableReferences
    extends
        BaseReferences<
          _$ClaimsDatabase,
          $ClaimTimelineEventsTable,
          TimelineEventRow
        > {
  $$ClaimTimelineEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ClaimsTable _claimIdTable(_$ClaimsDatabase db) =>
      db.claims.createAlias('claim_timeline_events__claim_id__claims__id');

  $$ClaimsTableProcessedTableManager get claimId {
    final $_column = $_itemColumn<String>('claim_id')!;

    final manager = $$ClaimsTableTableManager(
      $_db,
      $_db.claims,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_claimIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ClaimTimelineEventsTableFilterComposer
    extends Composer<_$ClaimsDatabase, $ClaimTimelineEventsTable> {
  $$ClaimTimelineEventsTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClaimsTableFilterComposer get claimId {
    final $$ClaimsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableFilterComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClaimTimelineEventsTableOrderingComposer
    extends Composer<_$ClaimsDatabase, $ClaimTimelineEventsTable> {
  $$ClaimTimelineEventsTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClaimsTableOrderingComposer get claimId {
    final $$ClaimsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableOrderingComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClaimTimelineEventsTableAnnotationComposer
    extends Composer<_$ClaimsDatabase, $ClaimTimelineEventsTable> {
  $$ClaimTimelineEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ClaimsTableAnnotationComposer get claimId {
    final $$ClaimsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableAnnotationComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClaimTimelineEventsTableTableManager
    extends
        RootTableManager<
          _$ClaimsDatabase,
          $ClaimTimelineEventsTable,
          TimelineEventRow,
          $$ClaimTimelineEventsTableFilterComposer,
          $$ClaimTimelineEventsTableOrderingComposer,
          $$ClaimTimelineEventsTableAnnotationComposer,
          $$ClaimTimelineEventsTableCreateCompanionBuilder,
          $$ClaimTimelineEventsTableUpdateCompanionBuilder,
          (TimelineEventRow, $$ClaimTimelineEventsTableReferences),
          TimelineEventRow,
          PrefetchHooks Function({bool claimId})
        > {
  $$ClaimTimelineEventsTableTableManager(
    _$ClaimsDatabase db,
    $ClaimTimelineEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClaimTimelineEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClaimTimelineEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ClaimTimelineEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> claimId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClaimTimelineEventsCompanion(
                id: id,
                claimId: claimId,
                label: label,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String claimId,
                required String label,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClaimTimelineEventsCompanion.insert(
                id: id,
                claimId: claimId,
                label: label,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClaimTimelineEventsTable, TimelineEventRow>(
                    table,
                  ),
                  $$ClaimTimelineEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({claimId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (claimId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.claimId,
                                referencedTable:
                                    $$ClaimTimelineEventsTableReferences
                                        ._claimIdTable(db),
                                referencedColumn:
                                    $$ClaimTimelineEventsTableReferences
                                        ._claimIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ClaimTimelineEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$ClaimsDatabase,
      $ClaimTimelineEventsTable,
      TimelineEventRow,
      $$ClaimTimelineEventsTableFilterComposer,
      $$ClaimTimelineEventsTableOrderingComposer,
      $$ClaimTimelineEventsTableAnnotationComposer,
      $$ClaimTimelineEventsTableCreateCompanionBuilder,
      $$ClaimTimelineEventsTableUpdateCompanionBuilder,
      (TimelineEventRow, $$ClaimTimelineEventsTableReferences),
      TimelineEventRow,
      PrefetchHooks Function({bool claimId})
    >;
typedef $$ClaimDocumentsTableCreateCompanionBuilder =
    ClaimDocumentsCompanion Function({
      Value<int> id,
      Value<String> uid,
      required String claimId,
      required String name,
      Value<String> kind,
      Value<String?> path,
      Value<String?> requestId,
      Value<DateTime> createdAt,
    });
typedef $$ClaimDocumentsTableUpdateCompanionBuilder =
    ClaimDocumentsCompanion Function({
      Value<int> id,
      Value<String> uid,
      Value<String> claimId,
      Value<String> name,
      Value<String> kind,
      Value<String?> path,
      Value<String?> requestId,
      Value<DateTime> createdAt,
    });

final class $$ClaimDocumentsTableReferences
    extends
        BaseReferences<_$ClaimsDatabase, $ClaimDocumentsTable, DocumentRow> {
  $$ClaimDocumentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ClaimsTable _claimIdTable(_$ClaimsDatabase db) =>
      db.claims.createAlias('claim_documents__claim_id__claims__id');

  $$ClaimsTableProcessedTableManager get claimId {
    final $_column = $_itemColumn<String>('claim_id')!;

    final manager = $$ClaimsTableTableManager(
      $_db,
      $_db.claims,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_claimIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ClaimDocumentsTableFilterComposer
    extends Composer<_$ClaimsDatabase, $ClaimDocumentsTable> {
  $$ClaimDocumentsTableFilterComposer({
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

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClaimsTableFilterComposer get claimId {
    final $$ClaimsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableFilterComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClaimDocumentsTableOrderingComposer
    extends Composer<_$ClaimsDatabase, $ClaimDocumentsTable> {
  $$ClaimDocumentsTableOrderingComposer({
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

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClaimsTableOrderingComposer get claimId {
    final $$ClaimsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableOrderingComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClaimDocumentsTableAnnotationComposer
    extends Composer<_$ClaimsDatabase, $ClaimDocumentsTable> {
  $$ClaimDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ClaimsTableAnnotationComposer get claimId {
    final $$ClaimsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableAnnotationComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClaimDocumentsTableTableManager
    extends
        RootTableManager<
          _$ClaimsDatabase,
          $ClaimDocumentsTable,
          DocumentRow,
          $$ClaimDocumentsTableFilterComposer,
          $$ClaimDocumentsTableOrderingComposer,
          $$ClaimDocumentsTableAnnotationComposer,
          $$ClaimDocumentsTableCreateCompanionBuilder,
          $$ClaimDocumentsTableUpdateCompanionBuilder,
          (DocumentRow, $$ClaimDocumentsTableReferences),
          DocumentRow,
          PrefetchHooks Function({bool claimId})
        > {
  $$ClaimDocumentsTableTableManager(
    _$ClaimsDatabase db,
    $ClaimDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClaimDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClaimDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClaimDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> claimId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> path = const Value.absent(),
                Value<String?> requestId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClaimDocumentsCompanion(
                id: id,
                uid: uid,
                claimId: claimId,
                name: name,
                kind: kind,
                path: path,
                requestId: requestId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                required String claimId,
                required String name,
                Value<String> kind = const Value.absent(),
                Value<String?> path = const Value.absent(),
                Value<String?> requestId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClaimDocumentsCompanion.insert(
                id: id,
                uid: uid,
                claimId: claimId,
                name: name,
                kind: kind,
                path: path,
                requestId: requestId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClaimDocumentsTable, DocumentRow>(table),
                  $$ClaimDocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({claimId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (claimId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.claimId,
                                referencedTable: $$ClaimDocumentsTableReferences
                                    ._claimIdTable(db),
                                referencedColumn:
                                    $$ClaimDocumentsTableReferences
                                        ._claimIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ClaimDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$ClaimsDatabase,
      $ClaimDocumentsTable,
      DocumentRow,
      $$ClaimDocumentsTableFilterComposer,
      $$ClaimDocumentsTableOrderingComposer,
      $$ClaimDocumentsTableAnnotationComposer,
      $$ClaimDocumentsTableCreateCompanionBuilder,
      $$ClaimDocumentsTableUpdateCompanionBuilder,
      (DocumentRow, $$ClaimDocumentsTableReferences),
      DocumentRow,
      PrefetchHooks Function({bool claimId})
    >;
typedef $$DocumentRequestsTableCreateCompanionBuilder =
    DocumentRequestsCompanion Function({
      required String id,
      required String claimId,
      required String label,
      Value<String> note,
      Value<String?> documentId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$DocumentRequestsTableUpdateCompanionBuilder =
    DocumentRequestsCompanion Function({
      Value<String> id,
      Value<String> claimId,
      Value<String> label,
      Value<String> note,
      Value<String?> documentId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$DocumentRequestsTableReferences
    extends
        BaseReferences<
          _$ClaimsDatabase,
          $DocumentRequestsTable,
          DocumentRequestRow
        > {
  $$DocumentRequestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ClaimsTable _claimIdTable(_$ClaimsDatabase db) =>
      db.claims.createAlias('document_requests__claim_id__claims__id');

  $$ClaimsTableProcessedTableManager get claimId {
    final $_column = $_itemColumn<String>('claim_id')!;

    final manager = $$ClaimsTableTableManager(
      $_db,
      $_db.claims,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_claimIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DocumentRequestsTableFilterComposer
    extends Composer<_$ClaimsDatabase, $DocumentRequestsTable> {
  $$DocumentRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClaimsTableFilterComposer get claimId {
    final $$ClaimsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableFilterComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentRequestsTableOrderingComposer
    extends Composer<_$ClaimsDatabase, $DocumentRequestsTable> {
  $$DocumentRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClaimsTableOrderingComposer get claimId {
    final $$ClaimsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableOrderingComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentRequestsTableAnnotationComposer
    extends Composer<_$ClaimsDatabase, $DocumentRequestsTable> {
  $$DocumentRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ClaimsTableAnnotationComposer get claimId {
    final $$ClaimsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableAnnotationComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentRequestsTableTableManager
    extends
        RootTableManager<
          _$ClaimsDatabase,
          $DocumentRequestsTable,
          DocumentRequestRow,
          $$DocumentRequestsTableFilterComposer,
          $$DocumentRequestsTableOrderingComposer,
          $$DocumentRequestsTableAnnotationComposer,
          $$DocumentRequestsTableCreateCompanionBuilder,
          $$DocumentRequestsTableUpdateCompanionBuilder,
          (DocumentRequestRow, $$DocumentRequestsTableReferences),
          DocumentRequestRow,
          PrefetchHooks Function({bool claimId})
        > {
  $$DocumentRequestsTableTableManager(
    _$ClaimsDatabase db,
    $DocumentRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> claimId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String?> documentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentRequestsCompanion(
                id: id,
                claimId: claimId,
                label: label,
                note: note,
                documentId: documentId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String claimId,
                required String label,
                Value<String> note = const Value.absent(),
                Value<String?> documentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentRequestsCompanion.insert(
                id: id,
                claimId: claimId,
                label: label,
                note: note,
                documentId: documentId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentRequestsTable, DocumentRequestRow>(
                    table,
                  ),
                  $$DocumentRequestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({claimId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (claimId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.claimId,
                                referencedTable:
                                    $$DocumentRequestsTableReferences
                                        ._claimIdTable(db),
                                referencedColumn:
                                    $$DocumentRequestsTableReferences
                                        ._claimIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DocumentRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$ClaimsDatabase,
      $DocumentRequestsTable,
      DocumentRequestRow,
      $$DocumentRequestsTableFilterComposer,
      $$DocumentRequestsTableOrderingComposer,
      $$DocumentRequestsTableAnnotationComposer,
      $$DocumentRequestsTableCreateCompanionBuilder,
      $$DocumentRequestsTableUpdateCompanionBuilder,
      (DocumentRequestRow, $$DocumentRequestsTableReferences),
      DocumentRequestRow,
      PrefetchHooks Function({bool claimId})
    >;
typedef $$ClaimNotificationsTableCreateCompanionBuilder =
    ClaimNotificationsCompanion Function({
      Value<int> id,
      Value<String> uid,
      Value<String?> claimId,
      Value<String> audience,
      required String body,
      Value<bool> isRead,
      Value<DateTime> createdAt,
    });
typedef $$ClaimNotificationsTableUpdateCompanionBuilder =
    ClaimNotificationsCompanion Function({
      Value<int> id,
      Value<String> uid,
      Value<String?> claimId,
      Value<String> audience,
      Value<String> body,
      Value<bool> isRead,
      Value<DateTime> createdAt,
    });

class $$ClaimNotificationsTableFilterComposer
    extends Composer<_$ClaimsDatabase, $ClaimNotificationsTable> {
  $$ClaimNotificationsTableFilterComposer({
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

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get claimId => $composableBuilder(
    column: $table.claimId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audience => $composableBuilder(
    column: $table.audience,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClaimNotificationsTableOrderingComposer
    extends Composer<_$ClaimsDatabase, $ClaimNotificationsTable> {
  $$ClaimNotificationsTableOrderingComposer({
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

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get claimId => $composableBuilder(
    column: $table.claimId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audience => $composableBuilder(
    column: $table.audience,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClaimNotificationsTableAnnotationComposer
    extends Composer<_$ClaimsDatabase, $ClaimNotificationsTable> {
  $$ClaimNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get claimId =>
      $composableBuilder(column: $table.claimId, builder: (column) => column);

  GeneratedColumn<String> get audience =>
      $composableBuilder(column: $table.audience, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ClaimNotificationsTableTableManager
    extends
        RootTableManager<
          _$ClaimsDatabase,
          $ClaimNotificationsTable,
          NotificationRow,
          $$ClaimNotificationsTableFilterComposer,
          $$ClaimNotificationsTableOrderingComposer,
          $$ClaimNotificationsTableAnnotationComposer,
          $$ClaimNotificationsTableCreateCompanionBuilder,
          $$ClaimNotificationsTableUpdateCompanionBuilder,
          (
            NotificationRow,
            BaseReferences<
              _$ClaimsDatabase,
              $ClaimNotificationsTable,
              NotificationRow
            >,
          ),
          NotificationRow,
          PrefetchHooks Function()
        > {
  $$ClaimNotificationsTableTableManager(
    _$ClaimsDatabase db,
    $ClaimNotificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClaimNotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClaimNotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClaimNotificationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String?> claimId = const Value.absent(),
                Value<String> audience = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClaimNotificationsCompanion(
                id: id,
                uid: uid,
                claimId: claimId,
                audience: audience,
                body: body,
                isRead: isRead,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String?> claimId = const Value.absent(),
                Value<String> audience = const Value.absent(),
                required String body,
                Value<bool> isRead = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClaimNotificationsCompanion.insert(
                id: id,
                uid: uid,
                claimId: claimId,
                audience: audience,
                body: body,
                isRead: isRead,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClaimNotificationsTable, NotificationRow>(table),
                  BaseReferences<
                    _$ClaimsDatabase,
                    $ClaimNotificationsTable,
                    NotificationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClaimNotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$ClaimsDatabase,
      $ClaimNotificationsTable,
      NotificationRow,
      $$ClaimNotificationsTableFilterComposer,
      $$ClaimNotificationsTableOrderingComposer,
      $$ClaimNotificationsTableAnnotationComposer,
      $$ClaimNotificationsTableCreateCompanionBuilder,
      $$ClaimNotificationsTableUpdateCompanionBuilder,
      (
        NotificationRow,
        BaseReferences<
          _$ClaimsDatabase,
          $ClaimNotificationsTable,
          NotificationRow
        >,
      ),
      NotificationRow,
      PrefetchHooks Function()
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      Value<String> uid,
      Value<String?> claimId,
      required String author,
      Value<String> senderRole,
      required String body,
      Value<String?> attachmentName,
      Value<String?> attachmentPath,
      Value<bool> isRead,
      Value<DateTime> sentAt,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      Value<String> uid,
      Value<String?> claimId,
      Value<String> author,
      Value<String> senderRole,
      Value<String> body,
      Value<String?> attachmentName,
      Value<String?> attachmentPath,
      Value<bool> isRead,
      Value<DateTime> sentAt,
    });

class $$ChatMessagesTableFilterComposer
    extends Composer<_$ClaimsDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
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

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get claimId => $composableBuilder(
    column: $table.claimId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderRole => $composableBuilder(
    column: $table.senderRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentName => $composableBuilder(
    column: $table.attachmentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentPath => $composableBuilder(
    column: $table.attachmentPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$ClaimsDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
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

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get claimId => $composableBuilder(
    column: $table.claimId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderRole => $composableBuilder(
    column: $table.senderRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentName => $composableBuilder(
    column: $table.attachmentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentPath => $composableBuilder(
    column: $table.attachmentPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$ClaimsDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get claimId =>
      $composableBuilder(column: $table.claimId, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get senderRole => $composableBuilder(
    column: $table.senderRole,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get attachmentName => $composableBuilder(
    column: $table.attachmentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attachmentPath => $composableBuilder(
    column: $table.attachmentPath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$ClaimsDatabase,
          $ChatMessagesTable,
          ChatMessageRow,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (
            ChatMessageRow,
            BaseReferences<
              _$ClaimsDatabase,
              $ChatMessagesTable,
              ChatMessageRow
            >,
          ),
          ChatMessageRow,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableManager(_$ClaimsDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String?> claimId = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> senderRole = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> attachmentName = const Value.absent(),
                Value<String?> attachmentPath = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<DateTime> sentAt = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                uid: uid,
                claimId: claimId,
                author: author,
                senderRole: senderRole,
                body: body,
                attachmentName: attachmentName,
                attachmentPath: attachmentPath,
                isRead: isRead,
                sentAt: sentAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String?> claimId = const Value.absent(),
                required String author,
                Value<String> senderRole = const Value.absent(),
                required String body,
                Value<String?> attachmentName = const Value.absent(),
                Value<String?> attachmentPath = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<DateTime> sentAt = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                uid: uid,
                claimId: claimId,
                author: author,
                senderRole: senderRole,
                body: body,
                attachmentName: attachmentName,
                attachmentPath: attachmentPath,
                isRead: isRead,
                sentAt: sentAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChatMessagesTable, ChatMessageRow>(table),
                  BaseReferences<
                    _$ClaimsDatabase,
                    $ChatMessagesTable,
                    ChatMessageRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$ClaimsDatabase,
      $ChatMessagesTable,
      ChatMessageRow,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (
        ChatMessageRow,
        BaseReferences<_$ClaimsDatabase, $ChatMessagesTable, ChatMessageRow>,
      ),
      ChatMessageRow,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<int> seq,
      required String id,
      required String method,
      required String path,
      Value<String> body,
      Value<bool> multipart,
      Value<String?> filePath,
      required String actorId,
      required String actorRole,
      required String actorName,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<int> seq,
      Value<String> id,
      Value<String> method,
      Value<String> path,
      Value<String> body,
      Value<bool> multipart,
      Value<String?> filePath,
      Value<String> actorId,
      Value<String> actorRole,
      Value<String> actorName,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$ClaimsDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get multipart => $composableBuilder(
    column: $table.multipart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorRole => $composableBuilder(
    column: $table.actorRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorName => $composableBuilder(
    column: $table.actorName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$ClaimsDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get multipart => $composableBuilder(
    column: $table.multipart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorRole => $composableBuilder(
    column: $table.actorRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorName => $composableBuilder(
    column: $table.actorName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$ClaimsDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get multipart =>
      $composableBuilder(column: $table.multipart, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get actorRole =>
      $composableBuilder(column: $table.actorRole, builder: (column) => column);

  GeneratedColumn<String> get actorName =>
      $composableBuilder(column: $table.actorName, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$ClaimsDatabase,
          $SyncOutboxTable,
          OutboxRow,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            OutboxRow,
            BaseReferences<_$ClaimsDatabase, $SyncOutboxTable, OutboxRow>,
          ),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$ClaimsDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<bool> multipart = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String> actorId = const Value.absent(),
                Value<String> actorRole = const Value.absent(),
                Value<String> actorName = const Value.absent(),
              }) => SyncOutboxCompanion(
                seq: seq,
                id: id,
                method: method,
                path: path,
                body: body,
                multipart: multipart,
                filePath: filePath,
                actorId: actorId,
                actorRole: actorRole,
                actorName: actorName,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String id,
                required String method,
                required String path,
                Value<String> body = const Value.absent(),
                Value<bool> multipart = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                required String actorId,
                required String actorRole,
                required String actorName,
              }) => SyncOutboxCompanion.insert(
                seq: seq,
                id: id,
                method: method,
                path: path,
                body: body,
                multipart: multipart,
                filePath: filePath,
                actorId: actorId,
                actorRole: actorRole,
                actorName: actorName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncOutboxTable, OutboxRow>(table),
                  BaseReferences<_$ClaimsDatabase, $SyncOutboxTable, OutboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$ClaimsDatabase,
      $SyncOutboxTable,
      OutboxRow,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        OutboxRow,
        BaseReferences<_$ClaimsDatabase, $SyncOutboxTable, OutboxRow>,
      ),
      OutboxRow,
      PrefetchHooks Function()
    >;

class $ClaimsDatabaseManager {
  final _$ClaimsDatabase _db;
  $ClaimsDatabaseManager(this._db);
  $$ClaimsTableTableManager get claims =>
      $$ClaimsTableTableManager(_db, _db.claims);
  $$ClaimTimelineEventsTableTableManager get claimTimelineEvents =>
      $$ClaimTimelineEventsTableTableManager(_db, _db.claimTimelineEvents);
  $$ClaimDocumentsTableTableManager get claimDocuments =>
      $$ClaimDocumentsTableTableManager(_db, _db.claimDocuments);
  $$DocumentRequestsTableTableManager get documentRequests =>
      $$DocumentRequestsTableTableManager(_db, _db.documentRequests);
  $$ClaimNotificationsTableTableManager get claimNotifications =>
      $$ClaimNotificationsTableTableManager(_db, _db.claimNotifications);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
}
