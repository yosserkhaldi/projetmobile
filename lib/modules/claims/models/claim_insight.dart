/// Analyse d'un dossier, calculée par le serveur et gardée pour le hors ligne.
///
/// Le serveur n'envoie au conducteur que [headline], [todo] et [remainingDays] :
/// les autres champs restent alors vides.
class ClaimInsight {
  ClaimInsight.fromJson(this.raw)
    : headline = (raw['driver'] as Map?)?['headline'] as String?,
      todo = _strings((raw['driver'] as Map?)?['todo']),
      remainingDays = (raw['driver'] as Map?)?['remainingDays'] as int?,
      estimateLow = _number(raw['estimate'], 'low'),
      estimateHigh = _number(raw['estimate'], 'high'),
      totalDays = (raw['duration'] as Map?)?['totalDays'] as int?,
      riskLevel = (raw['risk'] as Map?)?['level'] as String?,
      riskFactors = _strings((raw['risk'] as Map?)?['factors']),
      signals = _rows(raw['signals']).map((s) => s['label'] as String).toList(),
      missing = _rows(raw['missingDocuments'])
          .map(
            (d) => (label: d['label'] as String, reason: d['reason'] as String),
          )
          .toList(),
      recommendExpert = raw['recommendExpert'] == true,
      overdueDays = ((raw['service'] as Map?)?['overdueDays'] as int?) ?? 0,
      priority = ((raw['priority'] as Map?)?['score'] as int?) ?? 0,
      reasons = _strings((raw['priority'] as Map?)?['reasons']),
      nextAction = (raw['nextAction'] as Map?)?['label'] as String?,
      similar = _rows(raw['similar']).map(SimilarCase.fromJson).toList();

  final Map<String, dynamic> raw;

  final String? headline;
  final List<String> todo;
  final int? remainingDays;

  final double? estimateLow, estimateHigh;
  final int? totalDays;
  final String? riskLevel;
  final List<String> riskFactors, signals, reasons;
  final List<({String label, String reason})> missing;
  final bool recommendExpert;
  final int overdueDays, priority;
  final String? nextAction;
  final List<SimilarCase> similar;

  bool get isForAgent => nextAction != null;

  static double? _number(Object? map, String key) =>
      ((map as Map?)?[key] as num?)?.toDouble();

  static List<String> _strings(Object? value) =>
      (value as List<dynamic>? ?? const []).cast<String>();

  static List<Map<String, dynamic>> _rows(Object? value) =>
      (value as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
}

class SimilarCase {
  SimilarCase.fromJson(Map<String, dynamic> row)
    : id = row['id'] as String,
      similarity = row['similarity'] as int,
      outcome = row['outcome'] as String,
      responsibility = row['responsibility'] as int?,
      indemnity = (row['indemnity'] as num?)?.toDouble();

  final String id, outcome;
  final int similarity;
  final int? responsibility;
  final double? indemnity;
}

/// Lecture d'une pièce par l'IA. Absente sans modèle de langage.
class DocumentAnalysis {
  DocumentAnalysis.fromJson(Map<String, dynamic> row)
    : type = row['documentType'] as String? ?? 'Autre',
      amount = (row['amount'] as num?)?.toDouble(),
      summary = row['summary'] as String? ?? '',
      matches = row['matchesRequest'] as bool? ?? true;

  final String type, summary;
  final double? amount;
  final bool matches;
}

/// Réponse d'un assistant. [by] nomme le modèle qui a répondu, par exemple
/// « Claude (CLI) · claude-sonnet-5-5 » ; null quand les règles ont répondu.
typedef AiAnswer = ({String text, String? by});
