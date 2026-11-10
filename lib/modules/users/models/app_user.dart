import 'package:mon_constat_digital/modules/users/models/license_reading.dart';

/// Libellés traduits : `role.labelIn(context.t)` (lib/l10n/l10n.dart).
enum UserRole {
  driver('DRIVER'),
  agent('AGENT'),
  admin('ADMIN');

  const UserRole(this.apiValue);
  final String apiValue;

  static UserRole fromApi(String value) =>
      values.firstWhere((role) => role.apiValue == value);
}

enum AppLanguage {
  fr('FR', 'Français'),
  ar('AR', 'العربية'),
  en('EN', 'English');

  const AppLanguage(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static AppLanguage fromApi(String value) =>
      values.firstWhere((language) => language.apiValue == value);

  String get code => apiValue.toLowerCase();
}

enum IdentityStatus {
  unverified('UNVERIFIED'),
  pending('PENDING'),
  verified('VERIFIED'),
  rejected('REJECTED');

  const IdentityStatus(this.apiValue);
  final String apiValue;

  static IdentityStatus fromApi(String value) =>
      values.firstWhere((status) => status.apiValue == value);
}

/// Permis du profil : validé (par l'IA ou un administrateur), à vérifier par
/// un administrateur (un contrôle croisé a échoué), ou refusé.
enum LicenseStatus {
  verified('VERIFIED'),
  toReview('TO_REVIEW'),
  rejected('REJECTED');

  const LicenseStatus(this.apiValue);
  final String apiValue;

  static LicenseStatus? fromApi(String? value) => value == null
      ? null
      : values.firstWhere((status) => status.apiValue == value);
}

/// Contrôle du permis : ce que l'IA a lu, contrôles croisés avec le compte
/// et décision.
class LicenseReview {
  const LicenseReview({
    this.status,
    this.reading,
    this.rejectionReason,
    this.reviewedAt,
  });

  factory LicenseReview.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LicenseReview();
    final reading = json['reading'] as Map<String, dynamic>?;
    final checks = json['checks'] as Map<String, dynamic>?;
    return LicenseReview(
      status: LicenseStatus.fromApi(json['status'] as String?),
      // Lecture et contrôles réunis : même forme que la réponse au scan.
      reading: reading == null && checks == null
          ? null
          : LicenseReading.fromJson({...?reading, ...?checks}),
      rejectionReason: json['rejectionReason'] as String?,
      reviewedAt: DateTime.tryParse(
        json['reviewedAt'] as String? ?? '',
      )?.toLocal(),
    );
  }

  /// null : aucun permis contrôlé.
  final LicenseStatus? status;
  final LicenseReading? reading;
  final String? rejectionReason;
  final DateTime? reviewedAt;

  Map<String, dynamic> toJson() {
    final json = reading?.toJson();
    return {
      'status': status?.apiValue,
      'reading': json,
      'checks': json == null
          ? null
          : {
              for (final key in const [
                'nameMatchesAccount',
                'birthDateMatchesIdentity',
                'cinMatchesIdentity',
                'numberMatchesReading',
              ])
                key: json[key],
            },
      'rejectionReason': rejectionReason,
      'reviewedAt': reviewedAt?.toUtc().toIso8601String(),
    };
  }
}

/// Pièce présentée pour la vérification d'identité.
enum IdentityDocument {
  cin('CIN'),
  license('LICENSE'),
  passport('PASSPORT');

  const IdentityDocument(this.apiValue);
  final String apiValue;

  static IdentityDocument fromApi(String? value) => values.firstWhere(
    (document) => document.apiValue == value,
    orElse: () => cin,
  );

  /// Le passeport n'a qu'une page utile : la page photo.
  bool get hasBack => this != passport;

  /// Format du numéro, comme le vérifie l'API.
  RegExp get numberPattern => switch (this) {
    cin => RegExp(r'^\d{8}$'),
    license => RegExp(r'^\d{2}/?\d{5,8}$'),
    passport => RegExp(r'^[A-Z]\d{6,7}$'),
  };

  String normalize(String number) =>
      number.toUpperCase().replaceAll(' ', '').trim();
}

/// Ce que l'IA a lu sur le recto de la pièce (OCR). Un champ illisible est
/// null. Champs en arabe pour la CIN, en lettres latines pour le passeport.
class DocumentReading {
  const DocumentReading({
    this.type,
    this.number,
    this.lastName,
    this.firstName,
    this.lastNameAr,
    this.firstNameAr,
    this.parentsAr,
    this.birthPlaceAr,
    this.birthDate,
    this.expiresAt,
  });

  factory DocumentReading.fromJson(Map<String, dynamic> json) =>
      DocumentReading(
        type: json['type'] as String?,
        number: json['number'] as String?,
        lastName: json['lastName'] as String?,
        firstName: json['firstName'] as String?,
        lastNameAr: json['lastNameAr'] as String?,
        firstNameAr: json['firstNameAr'] as String?,
        parentsAr: json['parentsAr'] as String?,
        birthPlaceAr: json['birthPlaceAr'] as String?,
        birthDate: json['birthDate'] as String?,
        expiresAt: json['expiresAt'] as String?,
      );

  final String? type, number, lastName, firstName;
  final String? lastNameAr, firstNameAr, parentsAr, birthPlaceAr;

  /// Dates au format AAAA-MM-JJ.
  final String? birthDate, expiresAt;

  /// Nom lu, en arabe (CIN) ou en lettres latines (passeport).
  String? get fullName {
    final parts = [
      firstNameAr ?? firstName,
      lastNameAr ?? lastName,
    ].whereType<String>();
    return parts.isEmpty ? null : parts.join(' ');
  }

  bool get isEmpty => number == null && fullName == null && birthDate == null;

  Map<String, dynamic> toJson() => {
    'type': type,
    'number': number,
    'lastName': lastName,
    'firstName': firstName,
    'lastNameAr': lastNameAr,
    'firstNameAr': firstNameAr,
    'parentsAr': parentsAr,
    'birthPlaceAr': birthPlaceAr,
    'birthDate': birthDate,
    'expiresAt': expiresAt,
  };
}

/// Contrôles faits par l'IA à l'envoi. null : n'a pas pu être vérifié.
class IdentityChecks {
  const IdentityChecks({
    this.numberRead,
    this.numberMatches,
    this.nameMatches,
    this.notExpired,
    this.backRecognized,
    this.birthDateMatches,
  });

  factory IdentityChecks.fromJson(Map<String, dynamic> json) => IdentityChecks(
    numberRead: json['numberRead'] as String?,
    numberMatches: json['numberMatches'] as bool?,
    nameMatches: json['nameMatches'] as bool?,
    notExpired: json['notExpired'] as bool?,
    backRecognized: json['backRecognized'] as bool?,
    birthDateMatches: json['birthDateMatches'] as bool?,
  );

  final String? numberRead;
  final bool? numberMatches, nameMatches, notExpired;

  /// Verso reconnu (code-barres de la CIN, catégories du permis).
  final bool? backRecognized;

  /// Contrôle croisé : même date de naissance que sur le permis du profil.
  final bool? birthDateMatches;

  Map<String, dynamic> toJson() => {
    'numberRead': numberRead,
    'numberMatches': numberMatches,
    'nameMatches': nameMatches,
    'notExpired': notExpired,
    'backRecognized': backRecognized,
    'birthDateMatches': birthDateMatches,
  };
}

/// Vérification d'identité : pièce, visage comparé par l'IA, et au besoin
/// décision d'un administrateur.
class Identity {
  const Identity({
    this.status = IdentityStatus.unverified,
    this.documentType = IdentityDocument.cin,
    this.cinNumber,
    this.frontId,
    this.backId,
    this.selfieId,
    this.livenessAt,
    this.faceMatch,
    this.autoVerified = false,
    this.extracted,
    this.checks,
    this.refusals = 0,
    this.retryAt,
    this.blocked = false,
    this.rejectionReason,
    this.submittedAt,
  });

  /// Durée de validité de la vérification du visage, comme côté API.
  static const livenessValidity = Duration(minutes: 30);

  /// Refus permis avant blocage, comme côté API.
  static const maxRefusals = 3;

  factory Identity.fromJson(Map<String, dynamic>? json) => json == null
      ? const Identity()
      : Identity(
          status: IdentityStatus.fromApi(json['status'] as String),
          documentType: IdentityDocument.fromApi(
            json['documentType'] as String?,
          ),
          cinNumber: json['cinNumber'] as String?,
          frontId: json['frontId'] as String?,
          backId: json['backId'] as String?,
          selfieId: json['selfieId'] as String?,
          livenessAt: DateTime.tryParse(
            json['livenessAt'] as String? ?? '',
          )?.toLocal(),
          faceMatch: (json['faceMatch'] as num?)?.toDouble(),
          autoVerified: json['autoVerified'] as bool? ?? false,
          extracted: json['extracted'] == null
              ? null
              : DocumentReading.fromJson(
                  json['extracted'] as Map<String, dynamic>,
                ),
          checks: json['checks'] == null
              ? null
              : IdentityChecks.fromJson(json['checks'] as Map<String, dynamic>),
          refusals: json['refusals'] as int? ?? 0,
          retryAt: DateTime.tryParse(
            json['retryAt'] as String? ?? '',
          )?.toLocal(),
          blocked: json['blocked'] as bool? ?? false,
          rejectionReason: json['rejectionReason'] as String?,
          submittedAt: DateTime.tryParse(
            json['submittedAt'] as String? ?? '',
          )?.toLocal(),
        );

  final IdentityStatus status;
  final IdentityDocument documentType;

  /// Numéro de la pièce présentée (CIN, permis ou passeport).
  final String? cinNumber;
  final String? frontId, backId, selfieId, rejectionReason;
  final DateTime? submittedAt, livenessAt;

  /// Ressemblance pièce / visage calculée par l'IA, de 0 à 1.
  final double? faceMatch;

  /// Validée par la reconnaissance faciale, sans administrateur.
  final bool autoVerified;

  /// Lu sur la pièce par l'IA, et contrôles faits à l'envoi.
  final DocumentReading? extracted;
  final IdentityChecks? checks;

  /// Refus reçus, date avant laquelle aucune demande n'est possible, et
  /// blocage (refus grave ou 3e refus) que seul un administrateur lève.
  final int refusals;
  final DateTime? retryAt;
  final bool blocked;

  /// Délai de 24 h après un refus encore en cours.
  bool get waiting => retryAt != null && retryAt!.isAfter(DateTime.now());

  /// Demande possible : ni en attente, ni vérifiée, ni bloquée, ni en délai.
  bool get editable =>
      (status == IdentityStatus.unverified ||
          status == IdentityStatus.rejected) &&
      !blocked &&
      !waiting;

  /// Vérification du visage faite et encore valable pour envoyer la demande.
  bool get livenessValid =>
      selfieId != null &&
      livenessAt != null &&
      DateTime.now().difference(livenessAt!) < livenessValidity;

  Map<String, dynamic> toJson() => {
    'status': status.apiValue,
    'documentType': documentType.apiValue,
    'cinNumber': cinNumber,
    'frontId': frontId,
    'backId': backId,
    'selfieId': selfieId,
    'livenessAt': livenessAt?.toUtc().toIso8601String(),
    'faceMatch': faceMatch,
    'autoVerified': autoVerified,
    'extracted': extracted?.toJson(),
    'checks': checks?.toJson(),
    'refusals': refusals,
    'retryAt': retryAt?.toUtc().toIso8601String(),
    'blocked': blocked,
    'rejectionReason': rejectionReason,
    'submittedAt': submittedAt?.toUtc().toIso8601String(),
  };
}

class AppUser {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.phoneVerified,
    required this.role,
    required this.active,
    required this.language,
    this.licenseNumber,
    this.licenseCategory,
    this.licenseIssuedAt,
    this.companyId,
    this.companyName,
    this.photoId,
    this.licensePhotoId,
    this.identity = const Identity(),
    this.license = const LicenseReview(),
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final company = json['company'] as Map<String, dynamic>?;
    return AppUser(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      phoneVerified: json['phoneVerified'] as bool,
      role: UserRole.fromApi(json['role'] as String),
      active: json['active'] as bool,
      language: AppLanguage.fromApi(json['language'] as String),
      licenseNumber: json['licenseNumber'] as String?,
      licenseCategory: json['licenseCategory'] as String?,
      licenseIssuedAt: json['licenseIssuedAt'] as String?,
      companyId: company?['id'] as String?,
      companyName: company?['name'] as String?,
      photoId: json['photoId'] as String?,
      licensePhotoId: json['licensePhotoId'] as String?,
      identity: Identity.fromJson(json['identity'] as Map<String, dynamic>?),
      license: LicenseReview.fromJson(json['license'] as Map<String, dynamic>?),
    );
  }

  final String id, firstName, lastName, email, phone;
  final bool phoneVerified, active;
  final UserRole role;
  final AppLanguage language;
  final String? licenseNumber, licenseCategory;

  /// Date au format AAAA-MM-JJ.
  final String? licenseIssuedAt;
  final String? companyId, companyName;

  /// Changent à chaque nouvelle photo. `null` : pas de photo.
  final String? photoId, licensePhotoId;
  final Identity identity;
  final LicenseReview license;

  String get name => '$firstName $lastName';

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'phoneVerified': phoneVerified,
    'role': role.apiValue,
    'active': active,
    'language': language.apiValue,
    'licenseNumber': licenseNumber,
    'licenseCategory': licenseCategory,
    'licenseIssuedAt': licenseIssuedAt,
    'company': companyId == null
        ? null
        : {'id': companyId, 'name': companyName},
    'photoId': photoId,
    'licensePhotoId': licensePhotoId,
    'identity': identity.toJson(),
    'license': license.toJson(),
  };
}
