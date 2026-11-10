/// Types de véhicule reconnus.
enum VehicleType { car, moto, truck, van, other }

/// Carburant du véhicule.
enum FuelType { petrol, diesel, electric, hybrid, other }

/// Un véhicule enregistré par le conducteur.
///
/// Toutes les dates sont stockées en ISO-8601 (AAAA-MM-JJ) pour faciliter
/// les comparaisons. L'affichage se charge de la mise en forme locale.
class Vehicle {
  Vehicle({
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
    this.type = VehicleType.car,
    this.fuel = FuelType.petrol,
    this.photoPath,
    this.claimCount = 0,
    this.archived = false,
    this.createdAt,
    this.companyId,
    this.companyName,
  });

  /// Identifiant local (UUID généré à la création).
  final String id;

  /// Plaque d'immatriculation (peut contenir des caractères arabes).
  String plate;

  String brand;
  String model;

  /// Année de fabrication (ex : "2021").
  String year;

  /// Numéro de police d'assurance.
  String policy;

  /// Nom de la compagnie d'assurance.
  String insurerName;

  /// ID de la compagnie d'assurance (Module 1).
  String? companyId;

  /// Nom de la compagnie d'assurance (Module 1).
  String? companyName;

  /// Date d'expiration du contrat d'assurance (ISO-8601 : "AAAA-MM-JJ").
  String insuranceExpiry;

  /// Date de la prochaine visite technique (ISO-8601). Nullable si inconnue.
  String? technicalExpiry;

  /// Couleur du véhicule (ex : "Blanc", "Rouge").
  String? color;

  /// Kilométrage actuel (facultatif, utile pour le score de risque).
  int? mileage;

  VehicleType type;
  FuelType fuel;

  /// Chemin local de la photo du véhicule (carte grise ou photo directe).
  String? photoPath;

  /// Nombre de sinistres enregistrés pour ce véhicule (calculé localement).
  int claimCount;

  bool archived;

  DateTime? createdAt;

  // ── Sérialisation ──────────────────────────────────────────────────────────

  Map<String, Object?> toMap() => {
    'id': id,
    'plate': plate,
    'brand': brand,
    'model': model,
    'year': year,
    'policy': policy,
    'insurer_name': insurerName,
    'company_id': companyId,
    'company_name': companyName,
    'insurance_expiry': insuranceExpiry,
    'technical_expiry': technicalExpiry,
    'color': color,
    'mileage': mileage,
    'type': type.name,
    'fuel': fuel.name,
    'photo_path': photoPath,
    'claim_count': claimCount,
    'archived': archived ? 1 : 0,
    'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
  };

  factory Vehicle.fromMap(Map<String, Object?> m) => Vehicle(
    id: m['id'] as String,
    plate: m['plate'] as String,
    brand: m['brand'] as String,
    model: m['model'] as String,
    year: m['year'] as String,
    policy: m['policy'] as String,
    insurerName: m['insurer_name'] as String? ?? '',
    companyId: m['company_id'] as String?,
    companyName: m['company_name'] as String?,
    insuranceExpiry: m['insurance_expiry'] as String,
    technicalExpiry: m['technical_expiry'] as String?,
    color: m['color'] as String?,
    mileage: m['mileage'] as int?,
    type: VehicleType.values.firstWhere(
      (e) => e.name == (m['type'] as String? ?? ''),
      orElse: () => VehicleType.car,
    ),
    fuel: FuelType.values.firstWhere(
      (e) => e.name == (m['fuel'] as String? ?? ''),
      orElse: () => FuelType.petrol,
    ),
    photoPath: m['photo_path'] as String?,
    claimCount: m['claim_count'] as int? ?? 0,
    archived: (m['archived'] as int? ?? 0) == 1,
    createdAt: m['created_at'] != null
        ? DateTime.tryParse(m['created_at'] as String)
        : null,
  );

  Vehicle copyWith({
    String? plate,
    String? brand,
    String? model,
    String? year,
    String? policy,
    String? insurerName,
    String? companyId,
    String? companyName,
    String? insuranceExpiry,
    String? technicalExpiry,
    String? color,
    int? mileage,
    VehicleType? type,
    FuelType? fuel,
    String? photoPath,
    int? claimCount,
    bool? archived,
  }) => Vehicle(
    id: id,
    plate: plate ?? this.plate,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    year: year ?? this.year,
    policy: policy ?? this.policy,
    insurerName: insurerName ?? this.insurerName,
    companyId: companyId ?? this.companyId,
    companyName: companyName ?? this.companyName,
    insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
    technicalExpiry: technicalExpiry ?? this.technicalExpiry,
    color: color ?? this.color,
    mileage: mileage ?? this.mileage,
    type: type ?? this.type,
    fuel: fuel ?? this.fuel,
    photoPath: photoPath ?? this.photoPath,
    claimCount: claimCount ?? this.claimCount,
    archived: archived ?? this.archived,
    createdAt: createdAt,
  );

  // ── API (/api/vehicles) ────────────────────────────────────────────────────

  /// Identifiant au format UUID : le serveur garde le même. Les véhicules
  /// créés par une ancienne version ont un autre format.
  bool get hasServerId => RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  ).hasMatch(id);

  /// Corps envoyé à l'API. [withId] : création (l'identifiant du téléphone).
  Map<String, Object?> toApi({bool withId = false}) => {
    if (withId && hasServerId) 'id': id,
    'plate': plate,
    'brand': brand,
    'model': model,
    'year': int.tryParse(year) ?? DateTime.now().year,
    'policy': policy,
    'insurerName': companyName ?? insurerName,
    'companyId': companyId,
    'insuranceExpiry': insuranceExpiry,
    'technicalExpiry': technicalExpiry,
    'color': color,
    'mileage': mileage,
    'type': type.name.toUpperCase(),
    'fuel': fuel.name.toUpperCase(),
    'archived': archived,
  };

  /// Véhicule renvoyé par l'API. [local] garde ce que seul le téléphone a
  /// (photo, nombre de sinistres compté sur place).
  factory Vehicle.fromApi(Map<String, dynamic> json, {Vehicle? local}) =>
      Vehicle(
        id: json['id'] as String,
        plate: json['plate'] as String,
        brand: json['brand'] as String,
        model: json['model'] as String,
        year: '${json['year']}',
        policy: json['policy'] as String,
        insurerName: json['insurerName'] as String? ?? '',
        companyId: json['companyId'] as String?,
        companyName: json['companyId'] == null
            ? null
            : json['insurerName'] as String?,
        insuranceExpiry: json['insuranceExpiry'] as String,
        technicalExpiry: json['technicalExpiry'] as String?,
        color: json['color'] as String?,
        mileage: json['mileage'] as int?,
        type: VehicleType.values.firstWhere(
          (e) => e.name.toUpperCase() == json['type'],
          orElse: () => VehicleType.car,
        ),
        fuel: FuelType.values.firstWhere(
          (e) => e.name.toUpperCase() == json['fuel'],
          orElse: () => FuelType.petrol,
        ),
        photoPath: local?.photoPath,
        claimCount: local?.claimCount ?? json['claimCount'] as int? ?? 0,
        archived: json['archived'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      );

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Nombre de jours avant l'expiration du contrat d'assurance.
  /// Négatif si déjà expiré.
  int get daysUntilInsuranceExpiry {
    final expiry = DateTime.tryParse(insuranceExpiry);
    if (expiry == null) return 9999;
    return expiry.difference(DateTime.now()).inDays;
  }

  /// Nombre de jours avant la visite technique.
  int? get daysUntilTechnicalExpiry {
    if (technicalExpiry == null) return null;
    final expiry = DateTime.tryParse(technicalExpiry!);
    if (expiry == null) return null;
    return expiry.difference(DateTime.now()).inDays;
  }

  bool get isInsuranceExpired => daysUntilInsuranceExpiry < 0;
  bool get isInsuranceUrgent =>
      !isInsuranceExpired && daysUntilInsuranceExpiry <= 30;

  bool get isTechnicalExpired =>
      daysUntilTechnicalExpiry != null && daysUntilTechnicalExpiry! < 0;
  bool get isTechnicalUrgent =>
      daysUntilTechnicalExpiry != null &&
      !isTechnicalExpired &&
      daysUntilTechnicalExpiry! <= 30;

  /// Vrai si au moins une alerte active.
  bool get hasAlert =>
      isInsuranceExpired ||
      isInsuranceUrgent ||
      isTechnicalExpired ||
      isTechnicalUrgent;

  int get vehicleAge => DateTime.now().year - (int.tryParse(year) ?? 2000);

  @override
  String toString() => '$brand $model ($plate)';
}
