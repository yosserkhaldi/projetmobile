class Constat {
  Constat({
    required this.id,
    this.accidentId,
    required this.userId,
    required this.status,
    required this.sha256Hash,
    required this.pdfUrl,
    required this.driverAName,
    required this.driverAPlate,
    required this.driverAInsurer,
    this.driverAPolicy,
    this.companyAId,
    required this.driverBName,
    this.driverBEmail,
    this.driverBPhone,
    required this.driverBPlate,
    required this.driverBInsurer,
    this.driverBPolicy,
    this.companyBId,
    required this.place,
    required this.occurredAt,
    this.circumstancesA = const [],
    this.circumstancesB = const [],
    this.impactZones = const [],
    this.observations,
    this.sketchData,
    DateTime? driverASignedAt,
    DateTime? driverBSignedAt,
    DateTime? createdAt,
  })  : driverASignedAt = driverASignedAt ?? DateTime.now(),
        driverBSignedAt = driverBSignedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String? accidentId;
  final String userId;
  final String status;
  final String sha256Hash;
  final String pdfUrl;

  final String driverAName;
  final String driverAPlate;
  final String driverAInsurer;
  final String? driverAPolicy;
  final String? companyAId;

  final String driverBName;
  final String? driverBEmail;
  final String? driverBPhone;
  final String driverBPlate;
  final String driverBInsurer;
  final String? driverBPolicy;
  final String? companyBId;

  final String place;
  final DateTime occurredAt;
  final List<String> circumstancesA;
  final List<String> circumstancesB;
  final List<String> impactZones;
  final String? observations;
  final dynamic sketchData;

  final DateTime driverASignedAt;
  final DateTime driverBSignedAt;
  final DateTime createdAt;

  factory Constat.fromJson(Map<String, dynamic> json) => Constat(
        id: json['id'] as String,
        accidentId: json['accidentId'] as String?,
        userId: json['userId'] as String? ?? '',
        status: json['status'] as String? ?? 'SIGNED',
        sha256Hash: json['sha256Hash'] as String,
        pdfUrl: json['pdfUrl'] as String? ?? '',
        driverAName: json['driverAName'] as String? ?? '',
        driverAPlate: json['driverAPlate'] as String? ?? '',
        driverAInsurer: json['driverAInsurer'] as String? ?? '',
        driverAPolicy: json['driverAPolicy'] as String?,
        companyAId: json['companyAId'] as String?,
        driverBName: json['driverBName'] as String? ?? '',
        driverBEmail: json['driverBEmail'] as String?,
        driverBPhone: json['driverBPhone'] as String?,
        driverBPlate: json['driverBPlate'] as String? ?? '',
        driverBInsurer: json['driverBInsurer'] as String? ?? '',
        driverBPolicy: json['driverBPolicy'] as String?,
        companyBId: json['companyBId'] as String?,
        place: json['place'] as String? ?? '',
        occurredAt: json['occurredAt'] != null
            ? DateTime.parse(json['occurredAt'] as String)
            : DateTime.now(),
        circumstancesA: (json['circumstancesA'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        circumstancesB: (json['circumstancesB'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        impactZones: (json['impactZones'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        observations: json['observations'] as String?,
        sketchData: json['sketchData'],
        driverASignedAt: json['driverASignedAt'] != null
            ? DateTime.parse(json['driverASignedAt'] as String)
            : null,
        driverBSignedAt: json['driverBSignedAt'] != null
            ? DateTime.parse(json['driverBSignedAt'] as String)
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'accidentId': accidentId,
        'userId': userId,
        'status': status,
        'sha256Hash': sha256Hash,
        'pdfUrl': pdfUrl,
        'driverAName': driverAName,
        'driverAPlate': driverAPlate,
        'driverAInsurer': driverAInsurer,
        'driverAPolicy': driverAPolicy,
        'companyAId': companyAId,
        'driverBName': driverBName,
        'driverBEmail': driverBEmail,
        'driverBPhone': driverBPhone,
        'driverBPlate': driverBPlate,
        'driverBInsurer': driverBInsurer,
        'driverBPolicy': driverBPolicy,
        'companyBId': companyBId,
        'place': place,
        'occurredAt': occurredAt.toIso8601String(),
        'circumstancesA': circumstancesA,
        'circumstancesB': circumstancesB,
        'impactZones': impactZones,
        'observations': observations,
        'sketchData': sketchData,
        'driverASignedAt': driverASignedAt.toIso8601String(),
        'driverBSignedAt': driverBSignedAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };
}

