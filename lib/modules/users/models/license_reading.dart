/// Ce que l'IA a lu sur la photo du permis, pour pré-remplir le formulaire.
class LicenseReading {
  const LicenseReading({
    this.number,
    this.categories = const [],
    this.issuedAt,
    this.expiresAt,
    this.birthDateMatchesIdentity,
  });

  factory LicenseReading.fromJson(Map<String, dynamic> json) => LicenseReading(
    number: json['number'] as String?,
    categories: [
      for (final c in json['categories'] as List? ?? const []) c as String,
    ],
    issuedAt: json['issuedAt'] as String?,
    expiresAt: json['expiresAt'] as String?,
    birthDateMatchesIdentity: json['birthDateMatchesIdentity'] as bool?,
  );

  final String? number;

  /// Codes officiels : A1, A, B, B+E, C, C+E, D, D1, D+E, H.
  final List<String> categories;

  /// Dates au format AAAA-MM-JJ.
  final String? issuedAt, expiresAt;

  /// Contrôle croisé avec la pièce d'identité : false si la date de
  /// naissance diffère, null si elle n'a pas pu être comparée.
  final bool? birthDateMatchesIdentity;

  bool get isEmpty => number == null && categories.isEmpty && issuedAt == null;
}
