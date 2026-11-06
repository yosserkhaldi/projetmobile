class AccidentDraft {
  String place = 'Position GPS détectée — Tunis';
  DateTime occurredAt = DateTime.now();
  String weather = 'Ensoleillé';
  String road = 'Sèche';
  String light = 'Jour';
  String type = 'Collision';
  String severity = 'Matériel';
  int vehicleCount = 2;
  int injuredCount = 0;
  String witnessName = '';
  String witnessPhone = '';
  final Map<String, bool> evidence = {
    'Vue d’ensemble': false,
    'Dégâts véhicule A': false,
    'Dégâts véhicule B': false,
    'Plaques': false,
  };
  bool videoAdded = false;
  bool voiceNoteAdded = false;
  DateTime lastSavedAt = DateTime.now();

  bool get hasInjured => injuredCount > 0;
  int get evidenceCount => evidence.values.where((value) => value).length;

  void touch() => lastSavedAt = DateTime.now();
}
