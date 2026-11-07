// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_database.dart';

// ignore_for_file: type=lint
class $VehiclesTable extends Vehicles
    with TableInfo<$VehiclesTable, VehicleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plateMeta = const VerificationMeta('plate');
  @override
  late final GeneratedColumn<String> plate = GeneratedColumn<String>(
    'plate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<String> year = GeneratedColumn<String>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _policyMeta = const VerificationMeta('policy');
  @override
  late final GeneratedColumn<String> policy = GeneratedColumn<String>(
    'policy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _insurerNameMeta = const VerificationMeta(
    'insurerName',
  );
  @override
  late final GeneratedColumn<String> insurerName = GeneratedColumn<String>(
    'insurer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _insuranceExpiryMeta = const VerificationMeta(
    'insuranceExpiry',
  );
  @override
  late final GeneratedColumn<String> insuranceExpiry = GeneratedColumn<String>(
    'insurance_expiry',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _technicalExpiryMeta = const VerificationMeta(
    'technicalExpiry',
  );
  @override
  late final GeneratedColumn<String> technicalExpiry = GeneratedColumn<String>(
    'technical_expiry',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mileageMeta = const VerificationMeta(
    'mileage',
  );
  @override
  late final GeneratedColumn<int> mileage = GeneratedColumn<int>(
    'mileage',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('car'),
  );
  static const VerificationMeta _fuelMeta = const VerificationMeta('fuel');
  @override
  late final GeneratedColumn<String> fuel = GeneratedColumn<String>(
    'fuel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('petrol'),
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _claimCountMeta = const VerificationMeta(
    'claimCount',
  );
  @override
  late final GeneratedColumn<int> claimCount = GeneratedColumn<int>(
    'claim_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    plate,
    brand,
    model,
    year,
    policy,
    insurerName,
    insuranceExpiry,
    technicalExpiry,
    color,
    mileage,
    type,
    fuel,
    photoPath,
    claimCount,
    archived,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plate')) {
      context.handle(
        _plateMeta,
        plate.isAcceptableOrUnknown(data['plate']!, _plateMeta),
      );
    } else if (isInserting) {
      context.missing(_plateMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('policy')) {
      context.handle(
        _policyMeta,
        policy.isAcceptableOrUnknown(data['policy']!, _policyMeta),
      );
    } else if (isInserting) {
      context.missing(_policyMeta);
    }
    if (data.containsKey('insurer_name')) {
      context.handle(
        _insurerNameMeta,
        insurerName.isAcceptableOrUnknown(
          data['insurer_name']!,
          _insurerNameMeta,
        ),
      );
    }
    if (data.containsKey('insurance_expiry')) {
      context.handle(
        _insuranceExpiryMeta,
        insuranceExpiry.isAcceptableOrUnknown(
          data['insurance_expiry']!,
          _insuranceExpiryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_insuranceExpiryMeta);
    }
    if (data.containsKey('technical_expiry')) {
      context.handle(
        _technicalExpiryMeta,
        technicalExpiry.isAcceptableOrUnknown(
          data['technical_expiry']!,
          _technicalExpiryMeta,
        ),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('mileage')) {
      context.handle(
        _mileageMeta,
        mileage.isAcceptableOrUnknown(data['mileage']!, _mileageMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('fuel')) {
      context.handle(
        _fuelMeta,
        fuel.isAcceptableOrUnknown(data['fuel']!, _fuelMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('claim_count')) {
      context.handle(
        _claimCountMeta,
        claimCount.isAcceptableOrUnknown(data['claim_count']!, _claimCountMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      plate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plate'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year'],
      )!,
      policy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}policy'],
      )!,
      insurerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insurer_name'],
      )!,
      insuranceExpiry: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insurance_expiry'],
      )!,
      technicalExpiry: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}technical_expiry'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      mileage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mileage'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      fuel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuel'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      claimCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}claim_count'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class VehicleRow extends DataClass implements Insertable<VehicleRow> {
  final String id;
  final String plate;
  final String brand;
  final String model;
  final String year;
  final String policy;
  final String insurerName;
  final String insuranceExpiry;
  final String? technicalExpiry;
  final String? color;
  final int? mileage;
  final String type;
  final String fuel;
  final String? photoPath;
  final int claimCount;
  final bool archived;
  final String createdAt;
  const VehicleRow({
    required this.id,
    required this.plate,
    required this.brand,
    required this.model,
    required this.year,
    required this.policy,
    required this.insurerName,
    required this.insuranceExpiry,
    this.technicalExpiry,
    this.color,
    this.mileage,
    required this.type,
    required this.fuel,
    this.photoPath,
    required this.claimCount,
    required this.archived,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plate'] = Variable<String>(plate);
    map['brand'] = Variable<String>(brand);
    map['model'] = Variable<String>(model);
    map['year'] = Variable<String>(year);
    map['policy'] = Variable<String>(policy);
    map['insurer_name'] = Variable<String>(insurerName);
    map['insurance_expiry'] = Variable<String>(insuranceExpiry);
    if (!nullToAbsent || technicalExpiry != null) {
      map['technical_expiry'] = Variable<String>(technicalExpiry);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || mileage != null) {
      map['mileage'] = Variable<int>(mileage);
    }
    map['type'] = Variable<String>(type);
    map['fuel'] = Variable<String>(fuel);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['claim_count'] = Variable<int>(claimCount);
    map['archived'] = Variable<bool>(archived);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      plate: Value(plate),
      brand: Value(brand),
      model: Value(model),
      year: Value(year),
      policy: Value(policy),
      insurerName: Value(insurerName),
      insuranceExpiry: Value(insuranceExpiry),
      technicalExpiry: technicalExpiry == null && nullToAbsent
          ? const Value.absent()
          : Value(technicalExpiry),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      mileage: mileage == null && nullToAbsent
          ? const Value.absent()
          : Value(mileage),
      type: Value(type),
      fuel: Value(fuel),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      claimCount: Value(claimCount),
      archived: Value(archived),
      createdAt: Value(createdAt),
    );
  }

  factory VehicleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleRow(
      id: serializer.fromJson<String>(json['id']),
      plate: serializer.fromJson<String>(json['plate']),
      brand: serializer.fromJson<String>(json['brand']),
      model: serializer.fromJson<String>(json['model']),
      year: serializer.fromJson<String>(json['year']),
      policy: serializer.fromJson<String>(json['policy']),
      insurerName: serializer.fromJson<String>(json['insurerName']),
      insuranceExpiry: serializer.fromJson<String>(json['insuranceExpiry']),
      technicalExpiry: serializer.fromJson<String?>(json['technicalExpiry']),
      color: serializer.fromJson<String?>(json['color']),
      mileage: serializer.fromJson<int?>(json['mileage']),
      type: serializer.fromJson<String>(json['type']),
      fuel: serializer.fromJson<String>(json['fuel']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      claimCount: serializer.fromJson<int>(json['claimCount']),
      archived: serializer.fromJson<bool>(json['archived']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plate': serializer.toJson<String>(plate),
      'brand': serializer.toJson<String>(brand),
      'model': serializer.toJson<String>(model),
      'year': serializer.toJson<String>(year),
      'policy': serializer.toJson<String>(policy),
      'insurerName': serializer.toJson<String>(insurerName),
      'insuranceExpiry': serializer.toJson<String>(insuranceExpiry),
      'technicalExpiry': serializer.toJson<String?>(technicalExpiry),
      'color': serializer.toJson<String?>(color),
      'mileage': serializer.toJson<int?>(mileage),
      'type': serializer.toJson<String>(type),
      'fuel': serializer.toJson<String>(fuel),
      'photoPath': serializer.toJson<String?>(photoPath),
      'claimCount': serializer.toJson<int>(claimCount),
      'archived': serializer.toJson<bool>(archived),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  VehicleRow copyWith({
    String? id,
    String? plate,
    String? brand,
    String? model,
    String? year,
    String? policy,
    String? insurerName,
    String? insuranceExpiry,
    Value<String?> technicalExpiry = const Value.absent(),
    Value<String?> color = const Value.absent(),
    Value<int?> mileage = const Value.absent(),
    String? type,
    String? fuel,
    Value<String?> photoPath = const Value.absent(),
    int? claimCount,
    bool? archived,
    String? createdAt,
  }) => VehicleRow(
    id: id ?? this.id,
    plate: plate ?? this.plate,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    year: year ?? this.year,
    policy: policy ?? this.policy,
    insurerName: insurerName ?? this.insurerName,
    insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
    technicalExpiry: technicalExpiry.present
        ? technicalExpiry.value
        : this.technicalExpiry,
    color: color.present ? color.value : this.color,
    mileage: mileage.present ? mileage.value : this.mileage,
    type: type ?? this.type,
    fuel: fuel ?? this.fuel,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    claimCount: claimCount ?? this.claimCount,
    archived: archived ?? this.archived,
    createdAt: createdAt ?? this.createdAt,
  );
  VehicleRow copyWithCompanion(VehiclesCompanion data) {
    return VehicleRow(
      id: data.id.present ? data.id.value : this.id,
      plate: data.plate.present ? data.plate.value : this.plate,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      year: data.year.present ? data.year.value : this.year,
      policy: data.policy.present ? data.policy.value : this.policy,
      insurerName: data.insurerName.present
          ? data.insurerName.value
          : this.insurerName,
      insuranceExpiry: data.insuranceExpiry.present
          ? data.insuranceExpiry.value
          : this.insuranceExpiry,
      technicalExpiry: data.technicalExpiry.present
          ? data.technicalExpiry.value
          : this.technicalExpiry,
      color: data.color.present ? data.color.value : this.color,
      mileage: data.mileage.present ? data.mileage.value : this.mileage,
      type: data.type.present ? data.type.value : this.type,
      fuel: data.fuel.present ? data.fuel.value : this.fuel,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      claimCount: data.claimCount.present
          ? data.claimCount.value
          : this.claimCount,
      archived: data.archived.present ? data.archived.value : this.archived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleRow(')
          ..write('id: $id, ')
          ..write('plate: $plate, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('policy: $policy, ')
          ..write('insurerName: $insurerName, ')
          ..write('insuranceExpiry: $insuranceExpiry, ')
          ..write('technicalExpiry: $technicalExpiry, ')
          ..write('color: $color, ')
          ..write('mileage: $mileage, ')
          ..write('type: $type, ')
          ..write('fuel: $fuel, ')
          ..write('photoPath: $photoPath, ')
          ..write('claimCount: $claimCount, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    plate,
    brand,
    model,
    year,
    policy,
    insurerName,
    insuranceExpiry,
    technicalExpiry,
    color,
    mileage,
    type,
    fuel,
    photoPath,
    claimCount,
    archived,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleRow &&
          other.id == this.id &&
          other.plate == this.plate &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.year == this.year &&
          other.policy == this.policy &&
          other.insurerName == this.insurerName &&
          other.insuranceExpiry == this.insuranceExpiry &&
          other.technicalExpiry == this.technicalExpiry &&
          other.color == this.color &&
          other.mileage == this.mileage &&
          other.type == this.type &&
          other.fuel == this.fuel &&
          other.photoPath == this.photoPath &&
          other.claimCount == this.claimCount &&
          other.archived == this.archived &&
          other.createdAt == this.createdAt);
}

class VehiclesCompanion extends UpdateCompanion<VehicleRow> {
  final Value<String> id;
  final Value<String> plate;
  final Value<String> brand;
  final Value<String> model;
  final Value<String> year;
  final Value<String> policy;
  final Value<String> insurerName;
  final Value<String> insuranceExpiry;
  final Value<String?> technicalExpiry;
  final Value<String?> color;
  final Value<int?> mileage;
  final Value<String> type;
  final Value<String> fuel;
  final Value<String?> photoPath;
  final Value<int> claimCount;
  final Value<bool> archived;
  final Value<String> createdAt;
  final Value<int> rowid;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.plate = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.policy = const Value.absent(),
    this.insurerName = const Value.absent(),
    this.insuranceExpiry = const Value.absent(),
    this.technicalExpiry = const Value.absent(),
    this.color = const Value.absent(),
    this.mileage = const Value.absent(),
    this.type = const Value.absent(),
    this.fuel = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.claimCount = const Value.absent(),
    this.archived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiclesCompanion.insert({
    required String id,
    required String plate,
    required String brand,
    required String model,
    required String year,
    required String policy,
    this.insurerName = const Value.absent(),
    required String insuranceExpiry,
    this.technicalExpiry = const Value.absent(),
    this.color = const Value.absent(),
    this.mileage = const Value.absent(),
    this.type = const Value.absent(),
    this.fuel = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.claimCount = const Value.absent(),
    this.archived = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       plate = Value(plate),
       brand = Value(brand),
       model = Value(model),
       year = Value(year),
       policy = Value(policy),
       insuranceExpiry = Value(insuranceExpiry),
       createdAt = Value(createdAt);
  static Insertable<VehicleRow> custom({
    Expression<String>? id,
    Expression<String>? plate,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<String>? year,
    Expression<String>? policy,
    Expression<String>? insurerName,
    Expression<String>? insuranceExpiry,
    Expression<String>? technicalExpiry,
    Expression<String>? color,
    Expression<int>? mileage,
    Expression<String>? type,
    Expression<String>? fuel,
    Expression<String>? photoPath,
    Expression<int>? claimCount,
    Expression<bool>? archived,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plate != null) 'plate': plate,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (policy != null) 'policy': policy,
      if (insurerName != null) 'insurer_name': insurerName,
      if (insuranceExpiry != null) 'insurance_expiry': insuranceExpiry,
      if (technicalExpiry != null) 'technical_expiry': technicalExpiry,
      if (color != null) 'color': color,
      if (mileage != null) 'mileage': mileage,
      if (type != null) 'type': type,
      if (fuel != null) 'fuel': fuel,
      if (photoPath != null) 'photo_path': photoPath,
      if (claimCount != null) 'claim_count': claimCount,
      if (archived != null) 'archived': archived,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiclesCompanion copyWith({
    Value<String>? id,
    Value<String>? plate,
    Value<String>? brand,
    Value<String>? model,
    Value<String>? year,
    Value<String>? policy,
    Value<String>? insurerName,
    Value<String>? insuranceExpiry,
    Value<String?>? technicalExpiry,
    Value<String?>? color,
    Value<int?>? mileage,
    Value<String>? type,
    Value<String>? fuel,
    Value<String?>? photoPath,
    Value<int>? claimCount,
    Value<bool>? archived,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      plate: plate ?? this.plate,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      policy: policy ?? this.policy,
      insurerName: insurerName ?? this.insurerName,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      technicalExpiry: technicalExpiry ?? this.technicalExpiry,
      color: color ?? this.color,
      mileage: mileage ?? this.mileage,
      type: type ?? this.type,
      fuel: fuel ?? this.fuel,
      photoPath: photoPath ?? this.photoPath,
      claimCount: claimCount ?? this.claimCount,
      archived: archived ?? this.archived,
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
    if (plate.present) {
      map['plate'] = Variable<String>(plate.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (year.present) {
      map['year'] = Variable<String>(year.value);
    }
    if (policy.present) {
      map['policy'] = Variable<String>(policy.value);
    }
    if (insurerName.present) {
      map['insurer_name'] = Variable<String>(insurerName.value);
    }
    if (insuranceExpiry.present) {
      map['insurance_expiry'] = Variable<String>(insuranceExpiry.value);
    }
    if (technicalExpiry.present) {
      map['technical_expiry'] = Variable<String>(technicalExpiry.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (mileage.present) {
      map['mileage'] = Variable<int>(mileage.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (fuel.present) {
      map['fuel'] = Variable<String>(fuel.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (claimCount.present) {
      map['claim_count'] = Variable<int>(claimCount.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('plate: $plate, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('policy: $policy, ')
          ..write('insurerName: $insurerName, ')
          ..write('insuranceExpiry: $insuranceExpiry, ')
          ..write('technicalExpiry: $technicalExpiry, ')
          ..write('color: $color, ')
          ..write('mileage: $mileage, ')
          ..write('type: $type, ')
          ..write('fuel: $fuel, ')
          ..write('photoPath: $photoPath, ')
          ..write('claimCount: $claimCount, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$VehicleDatabase extends GeneratedDatabase {
  _$VehicleDatabase(QueryExecutor e) : super(e);
  $VehicleDatabaseManager get managers => $VehicleDatabaseManager(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [vehicles];
}

typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      required String id,
      required String plate,
      required String brand,
      required String model,
      required String year,
      required String policy,
      Value<String> insurerName,
      required String insuranceExpiry,
      Value<String?> technicalExpiry,
      Value<String?> color,
      Value<int?> mileage,
      Value<String> type,
      Value<String> fuel,
      Value<String?> photoPath,
      Value<int> claimCount,
      Value<bool> archived,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<String> id,
      Value<String> plate,
      Value<String> brand,
      Value<String> model,
      Value<String> year,
      Value<String> policy,
      Value<String> insurerName,
      Value<String> insuranceExpiry,
      Value<String?> technicalExpiry,
      Value<String?> color,
      Value<int?> mileage,
      Value<String> type,
      Value<String> fuel,
      Value<String?> photoPath,
      Value<int> claimCount,
      Value<bool> archived,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$VehiclesTableFilterComposer
    extends Composer<_$VehicleDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
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

  ColumnFilters<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get policy => $composableBuilder(
    column: $table.policy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insurerName => $composableBuilder(
    column: $table.insurerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insuranceExpiry => $composableBuilder(
    column: $table.insuranceExpiry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get technicalExpiry => $composableBuilder(
    column: $table.technicalExpiry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mileage => $composableBuilder(
    column: $table.mileage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuel => $composableBuilder(
    column: $table.fuel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get claimCount => $composableBuilder(
    column: $table.claimCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$VehicleDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
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

  ColumnOrderings<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get policy => $composableBuilder(
    column: $table.policy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insurerName => $composableBuilder(
    column: $table.insurerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insuranceExpiry => $composableBuilder(
    column: $table.insuranceExpiry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get technicalExpiry => $composableBuilder(
    column: $table.technicalExpiry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mileage => $composableBuilder(
    column: $table.mileage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuel => $composableBuilder(
    column: $table.fuel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get claimCount => $composableBuilder(
    column: $table.claimCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$VehicleDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plate =>
      $composableBuilder(column: $table.plate, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get policy =>
      $composableBuilder(column: $table.policy, builder: (column) => column);

  GeneratedColumn<String> get insurerName => $composableBuilder(
    column: $table.insurerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get insuranceExpiry => $composableBuilder(
    column: $table.insuranceExpiry,
    builder: (column) => column,
  );

  GeneratedColumn<String> get technicalExpiry => $composableBuilder(
    column: $table.technicalExpiry,
    builder: (column) => column,
  );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get mileage =>
      $composableBuilder(column: $table.mileage, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get fuel =>
      $composableBuilder(column: $table.fuel, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<int> get claimCount => $composableBuilder(
    column: $table.claimCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$VehicleDatabase,
          $VehiclesTable,
          VehicleRow,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (
            VehicleRow,
            BaseReferences<_$VehicleDatabase, $VehiclesTable, VehicleRow>,
          ),
          VehicleRow,
          PrefetchHooks Function()
        > {
  $$VehiclesTableTableManager(_$VehicleDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> plate = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String> year = const Value.absent(),
                Value<String> policy = const Value.absent(),
                Value<String> insurerName = const Value.absent(),
                Value<String> insuranceExpiry = const Value.absent(),
                Value<String?> technicalExpiry = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int?> mileage = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> fuel = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> claimCount = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                plate: plate,
                brand: brand,
                model: model,
                year: year,
                policy: policy,
                insurerName: insurerName,
                insuranceExpiry: insuranceExpiry,
                technicalExpiry: technicalExpiry,
                color: color,
                mileage: mileage,
                type: type,
                fuel: fuel,
                photoPath: photoPath,
                claimCount: claimCount,
                archived: archived,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String plate,
                required String brand,
                required String model,
                required String year,
                required String policy,
                Value<String> insurerName = const Value.absent(),
                required String insuranceExpiry,
                Value<String?> technicalExpiry = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int?> mileage = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> fuel = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> claimCount = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                plate: plate,
                brand: brand,
                model: model,
                year: year,
                policy: policy,
                insurerName: insurerName,
                insuranceExpiry: insuranceExpiry,
                technicalExpiry: technicalExpiry,
                color: color,
                mileage: mileage,
                type: type,
                fuel: fuel,
                photoPath: photoPath,
                claimCount: claimCount,
                archived: archived,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VehiclesTable, VehicleRow>(table),
                  BaseReferences<_$VehicleDatabase, $VehiclesTable, VehicleRow>(
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

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$VehicleDatabase,
      $VehiclesTable,
      VehicleRow,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (
        VehicleRow,
        BaseReferences<_$VehicleDatabase, $VehiclesTable, VehicleRow>,
      ),
      VehicleRow,
      PrefetchHooks Function()
    >;

class $VehicleDatabaseManager {
  final _$VehicleDatabase _db;
  $VehicleDatabaseManager(this._db);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
}
