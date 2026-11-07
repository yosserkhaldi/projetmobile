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

/// Vérification de la CIN par un administrateur.
class Identity {
  const Identity({
    this.status = IdentityStatus.unverified,
    this.cinNumber,
    this.frontId,
    this.backId,
    this.rejectionReason,
    this.submittedAt,
  });

  factory Identity.fromJson(Map<String, dynamic>? json) => json == null
      ? const Identity()
      : Identity(
          status: IdentityStatus.fromApi(json['status'] as String),
          cinNumber: json['cinNumber'] as String?,
          frontId: json['frontId'] as String?,
          backId: json['backId'] as String?,
          rejectionReason: json['rejectionReason'] as String?,
          submittedAt: DateTime.tryParse(
            json['submittedAt'] as String? ?? '',
          )?.toLocal(),
        );

  final IdentityStatus status;
  final String? cinNumber, frontId, backId, rejectionReason;
  final DateTime? submittedAt;

  /// Photos modifiables : ni en attente, ni déjà vérifiée.
  bool get editable =>
      status == IdentityStatus.unverified || status == IdentityStatus.rejected;

  Map<String, dynamic> toJson() => {
    'status': status.apiValue,
    'cinNumber': cinNumber,
    'frontId': frontId,
    'backId': backId,
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
  };
}
