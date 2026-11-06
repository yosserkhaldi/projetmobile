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
}
