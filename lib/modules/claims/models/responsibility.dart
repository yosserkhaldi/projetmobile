/// Pourquoi la proposition a ce partage.
enum ProposalBasis { fault, parked, turn, unknown }

/// Proposition de responsabilité à partir des cases cochées. L'agent décide.
class ResponsibilityProposal {
  const ResponsibilityProposal(this.driverA, this.basis, [this.box]);

  /// Part du conducteur A en pourcentage : 0, 50 ou 100.
  final int driverA;
  final ProposalBasis basis;

  /// La case qui décide, enregistrée en français (« Reculait »).
  final String? box;

  int get driverB => 100 - driverA;

  /// En français, comme le serveur. L'écran utilise `claimProposalReason`.
  String get reason => switch (basis) {
    ProposalBasis.fault => '$box : manœuvre à risque de A.',
    ProposalBasis.parked => 'A était en stationnement.',
    ProposalBasis.turn => '$box : partage par défaut.',
    ProposalBasis.unknown => 'Cases insuffisantes : partage par défaut.',
  };

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
        return ResponsibilityProposal(100, ProposalBasis.fault, box);
      }
    }
    if (boxes.contains('En stationnement')) {
      return const ResponsibilityProposal(0, ProposalBasis.parked);
    }
    for (final box in shared) {
      if (boxes.contains(box)) {
        return ResponsibilityProposal(50, ProposalBasis.turn, box);
      }
    }
    return const ResponsibilityProposal(50, ProposalBasis.unknown);
  }
}
