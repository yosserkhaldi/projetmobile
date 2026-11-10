/// Issue d'une demande de vérification d'identité.
enum AttemptOutcome {
  autoVerified('AUTO_VERIFIED'),
  pending('PENDING'),
  verified('VERIFIED'),
  rejected('REJECTED');

  const AttemptOutcome(this.apiValue);
  final String apiValue;

  static AttemptOutcome fromApi(String value) => values.firstWhere(
    (outcome) => outcome.apiValue == value,
    orElse: () => pending,
  );
}

/// Une demande passée, dans l'historique vu par l'administrateur.
class IdentityAttempt {
  const IdentityAttempt({
    required this.id,
    required this.documentType,
    required this.number,
    required this.outcome,
    required this.createdAt,
    this.faceMatch,
    this.reason,
    this.severe = false,
  });

  factory IdentityAttempt.fromJson(Map<String, dynamic> json) =>
      IdentityAttempt(
        id: json['id'] as String,
        documentType: json['documentType'] as String,
        number: json['number'] as String,
        outcome: AttemptOutcome.fromApi(json['outcome'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        faceMatch: (json['faceMatch'] as num?)?.toDouble(),
        reason: json['reason'] as String?,
        severe: json['severe'] as bool? ?? false,
      );

  final String id, documentType, number;
  final AttemptOutcome outcome;
  final DateTime createdAt;
  final double? faceMatch;
  final String? reason;
  final bool severe;
}

/// Motif d'un refus, et s'il bloque toute nouvelle demande.
typedef IdentityRejection = ({String reason, bool severe});
