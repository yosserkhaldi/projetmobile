class Claim {
  Claim({
    required this.id,
    required this.type,
    required this.place,
    required this.date,
    this.status = 'Brouillon',
    this.severity = 'Matériel',
  });
  final String id;
  String type, place, date, status, severity;
  final List<String> timeline = ['Brouillon créé'];
  final List<String> documents = [];

  /// Copie figée, pour écrire en base l'état du dossier à un instant donné.
  Claim snapshot() =>
      Claim(
          id: id,
          type: type,
          place: place,
          date: date,
          status: status,
          severity: severity,
        )
        ..timeline.clear()
        ..timeline.addAll(timeline)
        ..documents.addAll(documents);
}
