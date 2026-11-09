/// Consigne de la vérification du visage.
enum LivenessStep {
  center('center'),
  left('left'),
  right('right');

  const LivenessStep(this.apiValue);
  final String apiValue;

  static LivenessStep fromApi(String value) =>
      values.firstWhere((step) => step.apiValue == value);
}

/// Défi tiré par l'API : l'ordre des consignes change à chaque fois.
class LivenessChallenge {
  const LivenessChallenge({required this.token, required this.steps});
  final String token;
  final List<LivenessStep> steps;
}
