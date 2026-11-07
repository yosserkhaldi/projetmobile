/// Proposition de responsabilité à partir des cases cochées. L'agent décide.
class ResponsibilityProposal {
  const ResponsibilityProposal(this.driverA, this.reason);

  /// Part du conducteur A en pourcentage : 0, 50 ou 100.
  final int driverA;
  final String reason;

  int get driverB => 100 - driverA;

  /// Le constat ne porte aujourd'hui que les cases du conducteur A.
  static ResponsibilityProposal fromCircumstances(List<String> boxes) {
    const atFault = [
      'Reculait',
      'Quittait un stationnement',
      'Changeait de file',
      'Doublait',
    ];
    const shared = ['Virait à droite', 'Virait à gauche'];

    for (final box in atFault) {
      if (boxes.contains(box)) {
        return ResponsibilityProposal(100, '$box : manœuvre à risque de A.');
      }
    }
    if (boxes.contains('En stationnement')) {
      return const ResponsibilityProposal(0, 'A était en stationnement.');
    }
    for (final box in shared) {
      if (boxes.contains(box)) {
        return ResponsibilityProposal(50, '$box : partage par défaut.');
      }
    }
    return const ResponsibilityProposal(
      50,
      'Cases insuffisantes : partage par défaut.',
    );
  }
}
