/// Ce que l'IA a lu sur la photo du permis, pour pré-remplir le formulaire.
class LicenseReading {
  const LicenseReading({
    this.number,
    this.categories = const [],
    this.issuedAt,
    this.expiresAt,
    this.birthDateMatchesIdentity,
    this.nameMatchesAccount,
    this.cinMatchesIdentity,
  });

  factory LicenseReading.fromJson(Map<String, dynamic> json) => LicenseReading(
    number: json['number'] as String?,
    categories: [
      for (final c in json['categories'] as List? ?? const []) c as String,
    ],
    issuedAt: json['issuedAt'] as String?,
    expiresAt: json['expiresAt'] as String?,
    birthDateMatchesIdentity: json['birthDateMatchesIdentity'] as bool?,
    nameMatchesAccount: json['nameMatchesAccount'] as bool?,
    cinMatchesIdentity: json['cinMatchesIdentity'] as bool?,
  );

  final String? number;

  /// Codes officiels : A1, A, B, B+E, C, C+E, D, D1, D+E, H.
  final List<String> categories;

  /// Dates au format AAAA-MM-JJ.
  final String? issuedAt, expiresAt;

  /// Contrôle croisé avec la pièce d'identité : false si la date de
  /// naissance diffère, null si elle n'a pas pu être comparée.
  final bool? birthDateMatchesIdentity;

  /// Nom du titulaire lu sur le permis = nom du compte (false : le permis
  /// d'un proche, par exemple).
  final bool? nameMatchesAccount;

  /// Numéro de CIN imprimé sur le permis (carte de 2017) = celui de la pièce
  /// d'identité du compte.
  final bool? cinMatchesIdentity;

  bool get isEmpty => number == null && categories.isEmpty && issuedAt == null;
}
