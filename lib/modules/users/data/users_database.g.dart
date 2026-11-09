// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_database.dart';

// ignore_for_file: type=lint
class $CachedProfilesTable extends CachedProfiles
    with TableInfo<$CachedProfilesTable, CachedProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licenseNumberMeta = const VerificationMeta(
    'licenseNumber',
  );
  @override
  late final GeneratedColumn<String> licenseNumber = GeneratedColumn<String>(
    'license_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _licenseCategoryMeta = const VerificationMeta(
    'licenseCategory',
  );
  @override
  late final GeneratedColumn<String> licenseCategory = GeneratedColumn<String>(
    'license_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _licenseIssuedAtMeta = const VerificationMeta(
    'licenseIssuedAt',
  );
  @override
  late final GeneratedColumn<String> licenseIssuedAt = GeneratedColumn<String>(
    'license_issued_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _identityStatusMeta = const VerificationMeta(
    'identityStatus',
  );
  @override
  late final GeneratedColumn<String> identityStatus = GeneratedColumn<String>(
    'identity_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    firstName,
    lastName,
    phone,
    licenseNumber,
    licenseCategory,
    licenseIssuedAt,
    identityStatus,
    json,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('license_number')) {
      context.handle(
        _licenseNumberMeta,
        licenseNumber.isAcceptableOrUnknown(
          data['license_number']!,
          _licenseNumberMeta,
        ),
      );
    }
    if (data.containsKey('license_category')) {
      context.handle(
        _licenseCategoryMeta,
        licenseCategory.isAcceptableOrUnknown(
          data['license_category']!,
          _licenseCategoryMeta,
        ),
      );
    }
    if (data.containsKey('license_issued_at')) {
      context.handle(
        _licenseIssuedAtMeta,
        licenseIssuedAt.isAcceptableOrUnknown(
          data['license_issued_at']!,
          _licenseIssuedAtMeta,
        ),
      );
    }
    if (data.containsKey('identity_status')) {
      context.handle(
        _identityStatusMeta,
        identityStatus.isAcceptableOrUnknown(
          data['identity_status']!,
          _identityStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_identityStatusMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  CachedProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedProfileRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      licenseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_number'],
      ),
      licenseCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_category'],
      ),
      licenseIssuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_issued_at'],
      ),
      identityStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identity_status'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedProfilesTable createAlias(String alias) {
    return $CachedProfilesTable(attachedDatabase, alias);
  }
}

class CachedProfileRow extends DataClass
    implements Insertable<CachedProfileRow> {
  final String userId;
  final String firstName;
  final String lastName;
  final String phone;
  final String? licenseNumber;
  final String? licenseCategory;
  final String? licenseIssuedAt;
  final String identityStatus;

  /// Profil complet (AppUser.toJson), pour le reconstruire tel quel.
  final String json;
  final DateTime syncedAt;
  const CachedProfileRow({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.licenseNumber,
    this.licenseCategory,
    this.licenseIssuedAt,
    required this.identityStatus,
    required this.json,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || licenseNumber != null) {
      map['license_number'] = Variable<String>(licenseNumber);
    }
    if (!nullToAbsent || licenseCategory != null) {
      map['license_category'] = Variable<String>(licenseCategory);
    }
    if (!nullToAbsent || licenseIssuedAt != null) {
      map['license_issued_at'] = Variable<String>(licenseIssuedAt);
    }
    map['identity_status'] = Variable<String>(identityStatus);
    map['json'] = Variable<String>(json);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedProfilesCompanion toCompanion(bool nullToAbsent) {
    return CachedProfilesCompanion(
      userId: Value(userId),
      firstName: Value(firstName),
      lastName: Value(lastName),
      phone: Value(phone),
      licenseNumber: licenseNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(licenseNumber),
      licenseCategory: licenseCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(licenseCategory),
      licenseIssuedAt: licenseIssuedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(licenseIssuedAt),
      identityStatus: Value(identityStatus),
      json: Value(json),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedProfileRow(
      userId: serializer.fromJson<String>(json['userId']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      phone: serializer.fromJson<String>(json['phone']),
      licenseNumber: serializer.fromJson<String?>(json['licenseNumber']),
      licenseCategory: serializer.fromJson<String?>(json['licenseCategory']),
      licenseIssuedAt: serializer.fromJson<String?>(json['licenseIssuedAt']),
      identityStatus: serializer.fromJson<String>(json['identityStatus']),
      json: serializer.fromJson<String>(json['json']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'phone': serializer.toJson<String>(phone),
      'licenseNumber': serializer.toJson<String?>(licenseNumber),
      'licenseCategory': serializer.toJson<String?>(licenseCategory),
      'licenseIssuedAt': serializer.toJson<String?>(licenseIssuedAt),
      'identityStatus': serializer.toJson<String>(identityStatus),
      'json': serializer.toJson<String>(json),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedProfileRow copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? phone,
    Value<String?> licenseNumber = const Value.absent(),
    Value<String?> licenseCategory = const Value.absent(),
    Value<String?> licenseIssuedAt = const Value.absent(),
    String? identityStatus,
    String? json,
    DateTime? syncedAt,
  }) => CachedProfileRow(
    userId: userId ?? this.userId,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    phone: phone ?? this.phone,
    licenseNumber: licenseNumber.present
        ? licenseNumber.value
        : this.licenseNumber,
    licenseCategory: licenseCategory.present
        ? licenseCategory.value
        : this.licenseCategory,
    licenseIssuedAt: licenseIssuedAt.present
        ? licenseIssuedAt.value
        : this.licenseIssuedAt,
    identityStatus: identityStatus ?? this.identityStatus,
    json: json ?? this.json,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedProfileRow copyWithCompanion(CachedProfilesCompanion data) {
    return CachedProfileRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      phone: data.phone.present ? data.phone.value : this.phone,
      licenseNumber: data.licenseNumber.present
          ? data.licenseNumber.value
          : this.licenseNumber,
      licenseCategory: data.licenseCategory.present
          ? data.licenseCategory.value
          : this.licenseCategory,
      licenseIssuedAt: data.licenseIssuedAt.present
          ? data.licenseIssuedAt.value
          : this.licenseIssuedAt,
      identityStatus: data.identityStatus.present
          ? data.identityStatus.value
          : this.identityStatus,
      json: data.json.present ? data.json.value : this.json,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedProfileRow(')
          ..write('userId: $userId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('phone: $phone, ')
          ..write('licenseNumber: $licenseNumber, ')
          ..write('licenseCategory: $licenseCategory, ')
          ..write('licenseIssuedAt: $licenseIssuedAt, ')
          ..write('identityStatus: $identityStatus, ')
          ..write('json: $json, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    firstName,
    lastName,
    phone,
    licenseNumber,
    licenseCategory,
    licenseIssuedAt,
    identityStatus,
    json,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedProfileRow &&
          other.userId == this.userId &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.phone == this.phone &&
          other.licenseNumber == this.licenseNumber &&
          other.licenseCategory == this.licenseCategory &&
          other.licenseIssuedAt == this.licenseIssuedAt &&
          other.identityStatus == this.identityStatus &&
          other.json == this.json &&
          other.syncedAt == this.syncedAt);
}

class CachedProfilesCompanion extends UpdateCompanion<CachedProfileRow> {
  final Value<String> userId;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String> phone;
  final Value<String?> licenseNumber;
  final Value<String?> licenseCategory;
  final Value<String?> licenseIssuedAt;
  final Value<String> identityStatus;
  final Value<String> json;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedProfilesCompanion({
    this.userId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.phone = const Value.absent(),
    this.licenseNumber = const Value.absent(),
    this.licenseCategory = const Value.absent(),
    this.licenseIssuedAt = const Value.absent(),
    this.identityStatus = const Value.absent(),
    this.json = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedProfilesCompanion.insert({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    this.licenseNumber = const Value.absent(),
    this.licenseCategory = const Value.absent(),
    this.licenseIssuedAt = const Value.absent(),
    required String identityStatus,
    required String json,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       firstName = Value(firstName),
       lastName = Value(lastName),
       phone = Value(phone),
       identityStatus = Value(identityStatus),
       json = Value(json),
       syncedAt = Value(syncedAt);
  static Insertable<CachedProfileRow> custom({
    Expression<String>? userId,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? phone,
    Expression<String>? licenseNumber,
    Expression<String>? licenseCategory,
    Expression<String>? licenseIssuedAt,
    Expression<String>? identityStatus,
    Expression<String>? json,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phone != null) 'phone': phone,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (licenseCategory != null) 'license_category': licenseCategory,
      if (licenseIssuedAt != null) 'license_issued_at': licenseIssuedAt,
      if (identityStatus != null) 'identity_status': identityStatus,
      if (json != null) 'json': json,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedProfilesCompanion copyWith({
    Value<String>? userId,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String>? phone,
    Value<String?>? licenseNumber,
    Value<String?>? licenseCategory,
    Value<String?>? licenseIssuedAt,
    Value<String>? identityStatus,
    Value<String>? json,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedProfilesCompanion(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseCategory: licenseCategory ?? this.licenseCategory,
      licenseIssuedAt: licenseIssuedAt ?? this.licenseIssuedAt,
      identityStatus: identityStatus ?? this.identityStatus,
      json: json ?? this.json,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (licenseNumber.present) {
      map['license_number'] = Variable<String>(licenseNumber.value);
    }
    if (licenseCategory.present) {
      map['license_category'] = Variable<String>(licenseCategory.value);
    }
    if (licenseIssuedAt.present) {
      map['license_issued_at'] = Variable<String>(licenseIssuedAt.value);
    }
    if (identityStatus.present) {
      map['identity_status'] = Variable<String>(identityStatus.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('phone: $phone, ')
          ..write('licenseNumber: $licenseNumber, ')
          ..write('licenseCategory: $licenseCategory, ')
          ..write('licenseIssuedAt: $licenseIssuedAt, ')
          ..write('identityStatus: $identityStatus, ')
          ..write('json: $json, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompaniesTable extends Companies
    with TableInfo<$CompaniesTable, CompanyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompaniesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, syncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompanyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompanyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompanyRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CompaniesTable createAlias(String alias) {
    return $CompaniesTable(attachedDatabase, alias);
  }
}

class CompanyRow extends DataClass implements Insertable<CompanyRow> {
  final String id;
  final String name;
  final DateTime syncedAt;
  const CompanyRow({
    required this.id,
    required this.name,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CompaniesCompanion toCompanion(bool nullToAbsent) {
    return CompaniesCompanion(
      id: Value(id),
      name: Value(name),
      syncedAt: Value(syncedAt),
    );
  }

  factory CompanyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompanyRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CompanyRow copyWith({String? id, String? name, DateTime? syncedAt}) =>
      CompanyRow(
        id: id ?? this.id,
        name: name ?? this.name,
        syncedAt: syncedAt ?? this.syncedAt,
      );
  CompanyRow copyWithCompanion(CompaniesCompanion data) {
    return CompanyRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompanyRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompanyRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.syncedAt == this.syncedAt);
}

class CompaniesCompanion extends UpdateCompanion<CompanyRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CompaniesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompaniesCompanion.insert({
    required String id,
    required String name,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       syncedAt = Value(syncedAt);
  static Insertable<CompanyRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompaniesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CompaniesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AgenciesTable extends Agencies
    with TableInfo<$AgenciesTable, AgencyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
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
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, companyId, name, city];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agencies';
  @override
  VerificationContext validateIntegrity(
    Insertable<AgencyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    } else if (isInserting) {
      context.missing(_cityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AgencyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgencyRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
    );
  }

  @override
  $AgenciesTable createAlias(String alias) {
    return $AgenciesTable(attachedDatabase, alias);
  }
}

class AgencyRow extends DataClass implements Insertable<AgencyRow> {
  final String id;
  final String companyId;
  final String name;
  final String city;
  const AgencyRow({
    required this.id,
    required this.companyId,
    required this.name,
    required this.city,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['name'] = Variable<String>(name);
    map['city'] = Variable<String>(city);
    return map;
  }

  AgenciesCompanion toCompanion(bool nullToAbsent) {
    return AgenciesCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      city: Value(city),
    );
  }

  factory AgencyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgencyRow(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      city: serializer.fromJson<String>(json['city']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'name': serializer.toJson<String>(name),
      'city': serializer.toJson<String>(city),
    };
  }

  AgencyRow copyWith({
    String? id,
    String? companyId,
    String? name,
    String? city,
  }) => AgencyRow(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    city: city ?? this.city,
  );
  AgencyRow copyWithCompanion(AgenciesCompanion data) {
    return AgencyRow(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      city: data.city.present ? data.city.value : this.city,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgencyRow(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('city: $city')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, companyId, name, city);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgencyRow &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.city == this.city);
}

class AgenciesCompanion extends UpdateCompanion<AgencyRow> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> name;
  final Value<String> city;
  final Value<int> rowid;
  const AgenciesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.city = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgenciesCompanion.insert({
    required String id,
    required String companyId,
    required String name,
    required String city,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       name = Value(name),
       city = Value(city);
  static Insertable<AgencyRow> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? name,
    Expression<String>? city,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (city != null) 'city': city,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgenciesCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? name,
    Value<String>? city,
    Value<int>? rowid,
  }) {
    return AgenciesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      city: city ?? this.city,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgenciesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('city: $city, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingChangesTable extends PendingChanges
    with TableInfo<$PendingChangesTable, PendingChangeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingChangesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    payload,
    createdAt,
    updatedAt,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingChangeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingChangeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingChangeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $PendingChangesTable createAlias(String alias) {
    return $PendingChangesTable(attachedDatabase, alias);
  }
}

class PendingChangeRow extends DataClass
    implements Insertable<PendingChangeRow> {
  final int id;

  /// Type de modification : `profile` (PATCH /users/me).
  final String kind;

  /// Champs modifiés, en JSON. Plusieurs modifications hors ligne du même
  /// type sont fusionnées dans une seule ligne.
  final String payload;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int attempts;

  /// Motif du dernier refus du serveur. La ligne n'est plus renvoyée
  /// automatiquement tant que l'utilisateur ne réessaie pas.
  final String? lastError;
  const PendingChangeRow({
    required this.id,
    required this.kind,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  PendingChangesCompanion toCompanion(bool nullToAbsent) {
    return PendingChangesCompanion(
      id: Value(id),
      kind: Value(kind),
      payload: Value(payload),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory PendingChangeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingChangeRow(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  PendingChangeRow copyWith({
    int? id,
    String? kind,
    String? payload,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => PendingChangeRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  PendingChangeRow copyWithCompanion(PendingChangesCompanion data) {
    return PendingChangeRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingChangeRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, payload, createdAt, updatedAt, attempts, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingChangeRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class PendingChangesCompanion extends UpdateCompanion<PendingChangeRow> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  const PendingChangesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  PendingChangesCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String payload,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : kind = Value(kind),
       payload = Value(payload),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PendingChangeRow> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
    });
  }

  PendingChangesCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? attempts,
    Value<String?>? lastError,
  }) {
    return PendingChangesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingChangesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

abstract class _$UsersDatabase extends GeneratedDatabase {
  _$UsersDatabase(QueryExecutor e) : super(e);
  $UsersDatabaseManager get managers => $UsersDatabaseManager(this);
  late final $CachedProfilesTable cachedProfiles = $CachedProfilesTable(this);
  late final $CompaniesTable companies = $CompaniesTable(this);
  late final $AgenciesTable agencies = $AgenciesTable(this);
  late final $PendingChangesTable pendingChanges = $PendingChangesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedProfiles,
    companies,
    agencies,
    pendingChanges,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('agencies', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CachedProfilesTableCreateCompanionBuilder =
    CachedProfilesCompanion Function({
      required String userId,
      required String firstName,
      required String lastName,
      required String phone,
      Value<String?> licenseNumber,
      Value<String?> licenseCategory,
      Value<String?> licenseIssuedAt,
      required String identityStatus,
      required String json,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedProfilesTableUpdateCompanionBuilder =
    CachedProfilesCompanion Function({
      Value<String> userId,
      Value<String> firstName,
      Value<String> lastName,
      Value<String> phone,
      Value<String?> licenseNumber,
      Value<String?> licenseCategory,
      Value<String?> licenseIssuedAt,
      Value<String> identityStatus,
      Value<String> json,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedProfilesTableFilterComposer
    extends Composer<_$UsersDatabase, $CachedProfilesTable> {
  $$CachedProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseNumber => $composableBuilder(
    column: $table.licenseNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseCategory => $composableBuilder(
    column: $table.licenseCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseIssuedAt => $composableBuilder(
    column: $table.licenseIssuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identityStatus => $composableBuilder(
    column: $table.identityStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedProfilesTableOrderingComposer
    extends Composer<_$UsersDatabase, $CachedProfilesTable> {
  $$CachedProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseNumber => $composableBuilder(
    column: $table.licenseNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseCategory => $composableBuilder(
    column: $table.licenseCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseIssuedAt => $composableBuilder(
    column: $table.licenseIssuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identityStatus => $composableBuilder(
    column: $table.identityStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedProfilesTableAnnotationComposer
    extends Composer<_$UsersDatabase, $CachedProfilesTable> {
  $$CachedProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get licenseNumber => $composableBuilder(
    column: $table.licenseNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get licenseCategory => $composableBuilder(
    column: $table.licenseCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get licenseIssuedAt => $composableBuilder(
    column: $table.licenseIssuedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get identityStatus => $composableBuilder(
    column: $table.identityStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$CachedProfilesTableTableManager
    extends
        RootTableManager<
          _$UsersDatabase,
          $CachedProfilesTable,
          CachedProfileRow,
          $$CachedProfilesTableFilterComposer,
          $$CachedProfilesTableOrderingComposer,
          $$CachedProfilesTableAnnotationComposer,
          $$CachedProfilesTableCreateCompanionBuilder,
          $$CachedProfilesTableUpdateCompanionBuilder,
          (
            CachedProfileRow,
            BaseReferences<
              _$UsersDatabase,
              $CachedProfilesTable,
              CachedProfileRow
            >,
          ),
          CachedProfileRow,
          PrefetchHooks Function()
        > {
  $$CachedProfilesTableTableManager(
    _$UsersDatabase db,
    $CachedProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> licenseNumber = const Value.absent(),
                Value<String?> licenseCategory = const Value.absent(),
                Value<String?> licenseIssuedAt = const Value.absent(),
                Value<String> identityStatus = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedProfilesCompanion(
                userId: userId,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                licenseNumber: licenseNumber,
                licenseCategory: licenseCategory,
                licenseIssuedAt: licenseIssuedAt,
                identityStatus: identityStatus,
                json: json,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String firstName,
                required String lastName,
                required String phone,
                Value<String?> licenseNumber = const Value.absent(),
                Value<String?> licenseCategory = const Value.absent(),
                Value<String?> licenseIssuedAt = const Value.absent(),
                required String identityStatus,
                required String json,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedProfilesCompanion.insert(
                userId: userId,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                licenseNumber: licenseNumber,
                licenseCategory: licenseCategory,
                licenseIssuedAt: licenseIssuedAt,
                identityStatus: identityStatus,
                json: json,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedProfilesTable, CachedProfileRow>(table),
                  BaseReferences<
                    _$UsersDatabase,
                    $CachedProfilesTable,
                    CachedProfileRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$UsersDatabase,
      $CachedProfilesTable,
      CachedProfileRow,
      $$CachedProfilesTableFilterComposer,
      $$CachedProfilesTableOrderingComposer,
      $$CachedProfilesTableAnnotationComposer,
      $$CachedProfilesTableCreateCompanionBuilder,
      $$CachedProfilesTableUpdateCompanionBuilder,
      (
        CachedProfileRow,
        BaseReferences<_$UsersDatabase, $CachedProfilesTable, CachedProfileRow>,
      ),
      CachedProfileRow,
      PrefetchHooks Function()
    >;
typedef $$CompaniesTableCreateCompanionBuilder =
    CompaniesCompanion Function({
      required String id,
      required String name,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CompaniesTableUpdateCompanionBuilder =
    CompaniesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

final class $$CompaniesTableReferences
    extends BaseReferences<_$UsersDatabase, $CompaniesTable, CompanyRow> {
  $$CompaniesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AgenciesTable, List<AgencyRow>>
  _agenciesRefsTable(_$UsersDatabase db) => MultiTypedResultKey.fromTable(
    db.agencies,
    aliasName: 'companies__id__agencies__company_id',
  );

  $$AgenciesTableProcessedTableManager get agenciesRefs {
    final manager = $$AgenciesTableTableManager(
      $_db,
      $_db.agencies,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_agenciesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompaniesTableFilterComposer
    extends Composer<_$UsersDatabase, $CompaniesTable> {
  $$CompaniesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> agenciesRefs(
    Expression<bool> Function($$AgenciesTableFilterComposer f) f,
  ) {
    final $$AgenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.agencies,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgenciesTableFilterComposer(
            $db: $db,
            $table: $db.agencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableOrderingComposer
    extends Composer<_$UsersDatabase, $CompaniesTable> {
  $$CompaniesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompaniesTableAnnotationComposer
    extends Composer<_$UsersDatabase, $CompaniesTable> {
  $$CompaniesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  Expression<T> agenciesRefs<T extends Object>(
    Expression<T> Function($$AgenciesTableAnnotationComposer a) f,
  ) {
    final $$AgenciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.agencies,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgenciesTableAnnotationComposer(
            $db: $db,
            $table: $db.agencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableTableManager
    extends
        RootTableManager<
          _$UsersDatabase,
          $CompaniesTable,
          CompanyRow,
          $$CompaniesTableFilterComposer,
          $$CompaniesTableOrderingComposer,
          $$CompaniesTableAnnotationComposer,
          $$CompaniesTableCreateCompanionBuilder,
          $$CompaniesTableUpdateCompanionBuilder,
          (CompanyRow, $$CompaniesTableReferences),
          CompanyRow,
          PrefetchHooks Function({bool agenciesRefs})
        > {
  $$CompaniesTableTableManager(_$UsersDatabase db, $CompaniesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompaniesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompaniesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompaniesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompaniesCompanion(
                id: id,
                name: name,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CompaniesCompanion.insert(
                id: id,
                name: name,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompaniesTable, CompanyRow>(table),
                  $$CompaniesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({agenciesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (agenciesRefs) db.agencies],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (agenciesRefs)
                    await $_getPrefetchedDataByColumns<
                      CompanyRow,
                      $CompaniesTable,
                      AgencyRow,
                      $AgenciesTable
                    >(
                      currentTable: table,
                      referencedTable: $$CompaniesTableReferences
                          ._agenciesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CompaniesTableReferences(
                            db,
                            table,
                            p0,
                          ).agenciesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'company_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CompaniesTableProcessedTableManager =
    ProcessedTableManager<
      _$UsersDatabase,
      $CompaniesTable,
      CompanyRow,
      $$CompaniesTableFilterComposer,
      $$CompaniesTableOrderingComposer,
      $$CompaniesTableAnnotationComposer,
      $$CompaniesTableCreateCompanionBuilder,
      $$CompaniesTableUpdateCompanionBuilder,
      (CompanyRow, $$CompaniesTableReferences),
      CompanyRow,
      PrefetchHooks Function({bool agenciesRefs})
    >;
typedef $$AgenciesTableCreateCompanionBuilder =
    AgenciesCompanion Function({
      required String id,
      required String companyId,
      required String name,
      required String city,
      Value<int> rowid,
    });
typedef $$AgenciesTableUpdateCompanionBuilder =
    AgenciesCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> name,
      Value<String> city,
      Value<int> rowid,
    });

final class $$AgenciesTableReferences
    extends BaseReferences<_$UsersDatabase, $AgenciesTable, AgencyRow> {
  $$AgenciesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$UsersDatabase db) =>
      db.companies.createAlias('agencies__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AgenciesTableFilterComposer
    extends Composer<_$UsersDatabase, $AgenciesTable> {
  $$AgenciesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AgenciesTableOrderingComposer
    extends Composer<_$UsersDatabase, $AgenciesTable> {
  $$AgenciesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AgenciesTableAnnotationComposer
    extends Composer<_$UsersDatabase, $AgenciesTable> {
  $$AgenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AgenciesTableTableManager
    extends
        RootTableManager<
          _$UsersDatabase,
          $AgenciesTable,
          AgencyRow,
          $$AgenciesTableFilterComposer,
          $$AgenciesTableOrderingComposer,
          $$AgenciesTableAnnotationComposer,
          $$AgenciesTableCreateCompanionBuilder,
          $$AgenciesTableUpdateCompanionBuilder,
          (AgencyRow, $$AgenciesTableReferences),
          AgencyRow,
          PrefetchHooks Function({bool companyId})
        > {
  $$AgenciesTableTableManager(_$UsersDatabase db, $AgenciesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgenciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgenciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgenciesCompanion(
                id: id,
                companyId: companyId,
                name: name,
                city: city,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String name,
                required String city,
                Value<int> rowid = const Value.absent(),
              }) => AgenciesCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                city: city,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AgenciesTable, AgencyRow>(table),
                  $$AgenciesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false}) {
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
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable: $$AgenciesTableReferences
                                    ._companyIdTable(db),
                                referencedColumn: $$AgenciesTableReferences
                                    ._companyIdTable(db)
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

typedef $$AgenciesTableProcessedTableManager =
    ProcessedTableManager<
      _$UsersDatabase,
      $AgenciesTable,
      AgencyRow,
      $$AgenciesTableFilterComposer,
      $$AgenciesTableOrderingComposer,
      $$AgenciesTableAnnotationComposer,
      $$AgenciesTableCreateCompanionBuilder,
      $$AgenciesTableUpdateCompanionBuilder,
      (AgencyRow, $$AgenciesTableReferences),
      AgencyRow,
      PrefetchHooks Function({bool companyId})
    >;
typedef $$PendingChangesTableCreateCompanionBuilder =
    PendingChangesCompanion Function({
      Value<int> id,
      required String kind,
      required String payload,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> attempts,
      Value<String?> lastError,
    });
typedef $$PendingChangesTableUpdateCompanionBuilder =
    PendingChangesCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> attempts,
      Value<String?> lastError,
    });

class $$PendingChangesTableFilterComposer
    extends Composer<_$UsersDatabase, $PendingChangesTable> {
  $$PendingChangesTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingChangesTableOrderingComposer
    extends Composer<_$UsersDatabase, $PendingChangesTable> {
  $$PendingChangesTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingChangesTableAnnotationComposer
    extends Composer<_$UsersDatabase, $PendingChangesTable> {
  $$PendingChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$PendingChangesTableTableManager
    extends
        RootTableManager<
          _$UsersDatabase,
          $PendingChangesTable,
          PendingChangeRow,
          $$PendingChangesTableFilterComposer,
          $$PendingChangesTableOrderingComposer,
          $$PendingChangesTableAnnotationComposer,
          $$PendingChangesTableCreateCompanionBuilder,
          $$PendingChangesTableUpdateCompanionBuilder,
          (
            PendingChangeRow,
            BaseReferences<
              _$UsersDatabase,
              $PendingChangesTable,
              PendingChangeRow
            >,
          ),
          PendingChangeRow,
          PrefetchHooks Function()
        > {
  $$PendingChangesTableTableManager(
    _$UsersDatabase db,
    $PendingChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => PendingChangesCompanion(
                id: id,
                kind: kind,
                payload: payload,
                createdAt: createdAt,
                updatedAt: updatedAt,
                attempts: attempts,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required String payload,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => PendingChangesCompanion.insert(
                id: id,
                kind: kind,
                payload: payload,
                createdAt: createdAt,
                updatedAt: updatedAt,
                attempts: attempts,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PendingChangesTable, PendingChangeRow>(table),
                  BaseReferences<
                    _$UsersDatabase,
                    $PendingChangesTable,
                    PendingChangeRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$UsersDatabase,
      $PendingChangesTable,
      PendingChangeRow,
      $$PendingChangesTableFilterComposer,
      $$PendingChangesTableOrderingComposer,
      $$PendingChangesTableAnnotationComposer,
      $$PendingChangesTableCreateCompanionBuilder,
      $$PendingChangesTableUpdateCompanionBuilder,
      (
        PendingChangeRow,
        BaseReferences<_$UsersDatabase, $PendingChangesTable, PendingChangeRow>,
      ),
      PendingChangeRow,
      PrefetchHooks Function()
    >;

class $UsersDatabaseManager {
  final _$UsersDatabase _db;
  $UsersDatabaseManager(this._db);
  $$CachedProfilesTableTableManager get cachedProfiles =>
      $$CachedProfilesTableTableManager(_db, _db.cachedProfiles);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db, _db.companies);
  $$AgenciesTableTableManager get agencies =>
      $$AgenciesTableTableManager(_db, _db.agencies);
  $$PendingChangesTableTableManager get pendingChanges =>
      $$PendingChangesTableTableManager(_db, _db.pendingChanges);
}
