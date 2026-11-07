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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    place,
    date,
    status,
    severity,
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
  const ClaimRow({
    required this.id,
    required this.type,
    required this.place,
    required this.date,
    required this.status,
    required this.severity,
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
    };
  }

  ClaimRow copyWith({
    String? id,
    String? type,
    String? place,
    String? date,
    String? status,
    String? severity,
  }) => ClaimRow(
    id: id ?? this.id,
    type: type ?? this.type,
    place: place ?? this.place,
    date: date ?? this.date,
    status: status ?? this.status,
    severity: severity ?? this.severity,
  );
  ClaimRow copyWithCompanion(ClaimsCompanion data) {
    return ClaimRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      place: data.place.present ? data.place.value : this.place,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      severity: data.severity.present ? data.severity.value : this.severity,
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
          ..write('severity: $severity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, place, date, status, severity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClaimRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.place == this.place &&
          other.date == this.date &&
          other.status == this.status &&
          other.severity == this.severity);
}

class ClaimsCompanion extends UpdateCompanion<ClaimRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> place;
  final Value<String> date;
  final Value<String> status;
  final Value<String> severity;
  final Value<int> rowid;
  const ClaimsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.place = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.severity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClaimsCompanion.insert({
    required String id,
    required String type,
    required String place,
    required String date,
    required String status,
    required String severity,
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
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (place != null) 'place': place,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (severity != null) 'severity': severity,
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
    Value<int>? rowid,
  }) {
    return ClaimsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      place: place ?? this.place,
      date: date ?? this.date,
      status: status ?? this.status,
      severity: severity ?? this.severity,
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
  List<GeneratedColumn> get $columns => [id, claimId, name, createdAt];
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
      claimId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
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
  final String claimId;
  final String name;
  final DateTime createdAt;
  const DocumentRow({
    required this.id,
    required this.claimId,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['claim_id'] = Variable<String>(claimId);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClaimDocumentsCompanion toCompanion(bool nullToAbsent) {
    return ClaimDocumentsCompanion(
      id: Value(id),
      claimId: Value(claimId),
      name: Value(name),
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
      claimId: serializer.fromJson<String>(json['claimId']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'claimId': serializer.toJson<String>(claimId),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DocumentRow copyWith({
    int? id,
    String? claimId,
    String? name,
    DateTime? createdAt,
  }) => DocumentRow(
    id: id ?? this.id,
    claimId: claimId ?? this.claimId,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  DocumentRow copyWithCompanion(ClaimDocumentsCompanion data) {
    return DocumentRow(
      id: data.id.present ? data.id.value : this.id,
      claimId: data.claimId.present ? data.claimId.value : this.claimId,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRow(')
          ..write('id: $id, ')
          ..write('claimId: $claimId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, claimId, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentRow &&
          other.id == this.id &&
          other.claimId == this.claimId &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class ClaimDocumentsCompanion extends UpdateCompanion<DocumentRow> {
  final Value<int> id;
  final Value<String> claimId;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const ClaimDocumentsCompanion({
    this.id = const Value.absent(),
    this.claimId = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClaimDocumentsCompanion.insert({
    this.id = const Value.absent(),
    required String claimId,
    required String name,
    this.createdAt = const Value.absent(),
  }) : claimId = Value(claimId),
       name = Value(name);
  static Insertable<DocumentRow> custom({
    Expression<int>? id,
    Expression<String>? claimId,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (claimId != null) 'claim_id': claimId,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClaimDocumentsCompanion copyWith({
    Value<int>? id,
    Value<String>? claimId,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return ClaimDocumentsCompanion(
      id: id ?? this.id,
      claimId: claimId ?? this.claimId,
      name: name ?? this.name,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
          ..write('claimId: $claimId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
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
  List<GeneratedColumn> get $columns => [id, claimId, body, isRead, createdAt];
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
    if (data.containsKey('claim_id')) {
      context.handle(
        _claimIdMeta,
        claimId.isAcceptableOrUnknown(data['claim_id']!, _claimIdMeta),
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
      claimId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_id'],
      ),
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
  final String? claimId;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  const NotificationRow({
    required this.id,
    this.claimId,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || claimId != null) {
      map['claim_id'] = Variable<String>(claimId);
    }
    map['body'] = Variable<String>(body);
    map['is_read'] = Variable<bool>(isRead);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClaimNotificationsCompanion toCompanion(bool nullToAbsent) {
    return ClaimNotificationsCompanion(
      id: Value(id),
      claimId: claimId == null && nullToAbsent
          ? const Value.absent()
          : Value(claimId),
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
      claimId: serializer.fromJson<String?>(json['claimId']),
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
      'claimId': serializer.toJson<String?>(claimId),
      'body': serializer.toJson<String>(body),
      'isRead': serializer.toJson<bool>(isRead),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NotificationRow copyWith({
    int? id,
    Value<String?> claimId = const Value.absent(),
    String? body,
    bool? isRead,
    DateTime? createdAt,
  }) => NotificationRow(
    id: id ?? this.id,
    claimId: claimId.present ? claimId.value : this.claimId,
    body: body ?? this.body,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt ?? this.createdAt,
  );
  NotificationRow copyWithCompanion(ClaimNotificationsCompanion data) {
    return NotificationRow(
      id: data.id.present ? data.id.value : this.id,
      claimId: data.claimId.present ? data.claimId.value : this.claimId,
      body: data.body.present ? data.body.value : this.body,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRow(')
          ..write('id: $id, ')
          ..write('claimId: $claimId, ')
          ..write('body: $body, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, claimId, body, isRead, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationRow &&
          other.id == this.id &&
          other.claimId == this.claimId &&
          other.body == this.body &&
          other.isRead == this.isRead &&
          other.createdAt == this.createdAt);
}

class ClaimNotificationsCompanion extends UpdateCompanion<NotificationRow> {
  final Value<int> id;
  final Value<String?> claimId;
  final Value<String> body;
  final Value<bool> isRead;
  final Value<DateTime> createdAt;
  const ClaimNotificationsCompanion({
    this.id = const Value.absent(),
    this.claimId = const Value.absent(),
    this.body = const Value.absent(),
    this.isRead = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClaimNotificationsCompanion.insert({
    this.id = const Value.absent(),
    this.claimId = const Value.absent(),
    required String body,
    this.isRead = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : body = Value(body);
  static Insertable<NotificationRow> custom({
    Expression<int>? id,
    Expression<String>? claimId,
    Expression<String>? body,
    Expression<bool>? isRead,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (claimId != null) 'claim_id': claimId,
      if (body != null) 'body': body,
      if (isRead != null) 'is_read': isRead,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClaimNotificationsCompanion copyWith({
    Value<int>? id,
    Value<String?>? claimId,
    Value<String>? body,
    Value<bool>? isRead,
    Value<DateTime>? createdAt,
  }) {
    return ClaimNotificationsCompanion(
      id: id ?? this.id,
      claimId: claimId ?? this.claimId,
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
    if (claimId.present) {
      map['claim_id'] = Variable<String>(claimId.value);
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
          ..write('claimId: $claimId, ')
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
    claimId,
    author,
    body,
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
      claimId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_id'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
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
  final String? claimId;
  final String author;
  final String body;
  final bool isRead;
  final DateTime sentAt;
  const ChatMessageRow({
    required this.id,
    this.claimId,
    required this.author,
    required this.body,
    required this.isRead,
    required this.sentAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || claimId != null) {
      map['claim_id'] = Variable<String>(claimId);
    }
    map['author'] = Variable<String>(author);
    map['body'] = Variable<String>(body);
    map['is_read'] = Variable<bool>(isRead);
    map['sent_at'] = Variable<DateTime>(sentAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      claimId: claimId == null && nullToAbsent
          ? const Value.absent()
          : Value(claimId),
      author: Value(author),
      body: Value(body),
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
      claimId: serializer.fromJson<String?>(json['claimId']),
      author: serializer.fromJson<String>(json['author']),
      body: serializer.fromJson<String>(json['body']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'claimId': serializer.toJson<String?>(claimId),
      'author': serializer.toJson<String>(author),
      'body': serializer.toJson<String>(body),
      'isRead': serializer.toJson<bool>(isRead),
      'sentAt': serializer.toJson<DateTime>(sentAt),
    };
  }

  ChatMessageRow copyWith({
    int? id,
    Value<String?> claimId = const Value.absent(),
    String? author,
    String? body,
    bool? isRead,
    DateTime? sentAt,
  }) => ChatMessageRow(
    id: id ?? this.id,
    claimId: claimId.present ? claimId.value : this.claimId,
    author: author ?? this.author,
    body: body ?? this.body,
    isRead: isRead ?? this.isRead,
    sentAt: sentAt ?? this.sentAt,
  );
  ChatMessageRow copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessageRow(
      id: data.id.present ? data.id.value : this.id,
      claimId: data.claimId.present ? data.claimId.value : this.claimId,
      author: data.author.present ? data.author.value : this.author,
      body: data.body.present ? data.body.value : this.body,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageRow(')
          ..write('id: $id, ')
          ..write('claimId: $claimId, ')
          ..write('author: $author, ')
          ..write('body: $body, ')
          ..write('isRead: $isRead, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, claimId, author, body, isRead, sentAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageRow &&
          other.id == this.id &&
          other.claimId == this.claimId &&
          other.author == this.author &&
          other.body == this.body &&
          other.isRead == this.isRead &&
          other.sentAt == this.sentAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessageRow> {
  final Value<int> id;
  final Value<String?> claimId;
  final Value<String> author;
  final Value<String> body;
  final Value<bool> isRead;
  final Value<DateTime> sentAt;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.claimId = const Value.absent(),
    this.author = const Value.absent(),
    this.body = const Value.absent(),
    this.isRead = const Value.absent(),
    this.sentAt = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    this.claimId = const Value.absent(),
    required String author,
    required String body,
    this.isRead = const Value.absent(),
    this.sentAt = const Value.absent(),
  }) : author = Value(author),
       body = Value(body);
  static Insertable<ChatMessageRow> custom({
    Expression<int>? id,
    Expression<String>? claimId,
    Expression<String>? author,
    Expression<String>? body,
    Expression<bool>? isRead,
    Expression<DateTime>? sentAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (claimId != null) 'claim_id': claimId,
      if (author != null) 'author': author,
      if (body != null) 'body': body,
      if (isRead != null) 'is_read': isRead,
      if (sentAt != null) 'sent_at': sentAt,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<int>? id,
    Value<String?>? claimId,
    Value<String>? author,
    Value<String>? body,
    Value<bool>? isRead,
    Value<DateTime>? sentAt,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      claimId: claimId ?? this.claimId,
      author: author ?? this.author,
      body: body ?? this.body,
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
    if (claimId.present) {
      map['claim_id'] = Variable<String>(claimId.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
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
          ..write('claimId: $claimId, ')
          ..write('author: $author, ')
          ..write('body: $body, ')
          ..write('isRead: $isRead, ')
          ..write('sentAt: $sentAt')
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
  late final $ClaimNotificationsTable claimNotifications =
      $ClaimNotificationsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final ClaimsDao claimsDao = ClaimsDao(this as ClaimsDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    claims,
    claimTimelineEvents,
    claimDocuments,
    claimNotifications,
    chatMessages,
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
                Value<int> rowid = const Value.absent(),
              }) => ClaimsCompanion(
                id: id,
                type: type,
                place: place,
                date: date,
                status: status,
                severity: severity,
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
                Value<int> rowid = const Value.absent(),
              }) => ClaimsCompanion.insert(
                id: id,
                type: type,
                place: place,
                date: date,
                status: status,
                severity: severity,
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
              ({claimTimelineEventsRefs = false, claimDocumentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (claimTimelineEventsRefs) db.claimTimelineEvents,
                    if (claimDocumentsRefs) db.claimDocuments,
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
      required String claimId,
      required String name,
      Value<DateTime> createdAt,
    });
typedef $$ClaimDocumentsTableUpdateCompanionBuilder =
    ClaimDocumentsCompanion Function({
      Value<int> id,
      Value<String> claimId,
      Value<String> name,
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

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
                Value<String> claimId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClaimDocumentsCompanion(
                id: id,
                claimId: claimId,
                name: name,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String claimId,
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClaimDocumentsCompanion.insert(
                id: id,
                claimId: claimId,
                name: name,
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
typedef $$ClaimNotificationsTableCreateCompanionBuilder =
    ClaimNotificationsCompanion Function({
      Value<int> id,
      Value<String?> claimId,
      required String body,
      Value<bool> isRead,
      Value<DateTime> createdAt,
    });
typedef $$ClaimNotificationsTableUpdateCompanionBuilder =
    ClaimNotificationsCompanion Function({
      Value<int> id,
      Value<String?> claimId,
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

  ColumnFilters<String> get claimId => $composableBuilder(
    column: $table.claimId,
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

  ColumnOrderings<String> get claimId => $composableBuilder(
    column: $table.claimId,
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

  GeneratedColumn<String> get claimId =>
      $composableBuilder(column: $table.claimId, builder: (column) => column);

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
                Value<String?> claimId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClaimNotificationsCompanion(
                id: id,
                claimId: claimId,
                body: body,
                isRead: isRead,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> claimId = const Value.absent(),
                required String body,
                Value<bool> isRead = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClaimNotificationsCompanion.insert(
                id: id,
                claimId: claimId,
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
      Value<String?> claimId,
      required String author,
      required String body,
      Value<bool> isRead,
      Value<DateTime> sentAt,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      Value<String?> claimId,
      Value<String> author,
      Value<String> body,
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

  ColumnFilters<String> get claimId => $composableBuilder(
    column: $table.claimId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
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

  ColumnOrderings<String> get claimId => $composableBuilder(
    column: $table.claimId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
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

  GeneratedColumn<String> get claimId =>
      $composableBuilder(column: $table.claimId, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

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
                Value<String?> claimId = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<DateTime> sentAt = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                claimId: claimId,
                author: author,
                body: body,
                isRead: isRead,
                sentAt: sentAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> claimId = const Value.absent(),
                required String author,
                required String body,
                Value<bool> isRead = const Value.absent(),
                Value<DateTime> sentAt = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                claimId: claimId,
                author: author,
                body: body,
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

class $ClaimsDatabaseManager {
  final _$ClaimsDatabase _db;
  $ClaimsDatabaseManager(this._db);
  $$ClaimsTableTableManager get claims =>
      $$ClaimsTableTableManager(_db, _db.claims);
  $$ClaimTimelineEventsTableTableManager get claimTimelineEvents =>
      $$ClaimTimelineEventsTableTableManager(_db, _db.claimTimelineEvents);
  $$ClaimDocumentsTableTableManager get claimDocuments =>
      $$ClaimDocumentsTableTableManager(_db, _db.claimDocuments);
  $$ClaimNotificationsTableTableManager get claimNotifications =>
      $$ClaimNotificationsTableTableManager(_db, _db.claimNotifications);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
}
