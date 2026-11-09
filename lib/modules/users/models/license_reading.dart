/// Ce que l'IA a lu sur la photo du permis, pour pré-remplir le formulaire.
class LicenseReading {
  const LicenseReading({
    this.number,
    this.categories = const [],
    this.issuedAt,
    this.expiresAt,
  });

  factory LicenseReading.fromJson(Map<String, dynamic> json) => LicenseReading(
    number: json['number'] as String?,
    categories: [
      for (final c in json['categories'] as List? ?? const []) c as String,
    ],
    issuedAt: json['issuedAt'] as String?,
    expiresAt: json['expiresAt'] as String?,
  );

  final String? number;

  /// Codes officiels : A1, A, B, B+E, C, C+E, D, D1, D+E, H.
  final List<String> categories;

  /// Dates au format AAAA-MM-JJ.
  final String? issuedAt, expiresAt;

  bool get isEmpty => number == null && categories.isEmpty && issuedAt == null;
}
