/// Pourquoi la proposition a ce partage. Mêmes codes que le serveur
/// (`basis` : fault-a, fault-b, both, parked-a, parked-b, turn, unknown).
enum ProposalBasis { fault, faultB, both, parked, parkedB, turn, unknown }

/// Proposition de responsabilité à partir des cases cochées par A et par B.
/// L'agent décide.
class ResponsibilityProposal {
  const ResponsibilityProposal(this.driverA, this.basis, [this.box, this.boxB]);

  /// Part du conducteur A en pourcentage : 0, 50 ou 100.
  final int driverA;
  final ProposalBasis basis;

  /// La case qui décide, enregistrée en français (« Reculait ») : celle de A,
  /// ou celle d'un virage. [boxB] : celle de B.
  final String? box, boxB;

  int get driverB => 100 - driverA;

  /// En français, comme le serveur. L'écran utilise `claimProposalReason`.
  String get reason => switch (basis) {
    ProposalBasis.fault => '$box : manœuvre à risque de A.',
    ProposalBasis.faultB => '$boxB : manœuvre à risque de B.',
    ProposalBasis.both =>
      'A : $box, B : $boxB. Manœuvres à risque des deux côtés : partage.',
    ProposalBasis.parked => 'A était en stationnement.',
    ProposalBasis.parkedB => 'B était en stationnement.',
    ProposalBasis.turn => '$box : partage par défaut.',
    ProposalBasis.unknown => 'Cases insuffisantes : partage par défaut.',
  };

  static const _atFault = [
    'Reculait',
    'Quittait un stationnement',
    'Changeait de file',
    'Doublait',
  ];
  static const _shared = ['Virait à droite', 'Virait à gauche'];
  static const _parked = 'En stationnement';

  static String _canonical(String raw) {
    final stripped = raw
        .replaceFirst(RegExp(r'^\d{1,2}\s*[-–.)]\s*'), '')
        .trim();
    if (stripped.startsWith('En stationnement')) return 'En stationnement';
    if (stripped.startsWith('Quittait un stationnement')) {
      return 'Quittait un stationnement';
    }
    return stripped;
  }

  /// Le barème, identique à `responsibilityProposal` côté serveur :
  /// - une manœuvre à risque d'un seul côté : ce conducteur à 100 % ;
  /// - des deux côtés : partage ;
  /// - un véhicule en stationnement face à un véhicule qui roulait : 0 % ;
  /// - sinon, partage par défaut.
  static ResponsibilityProposal fromBoxes(
    List<String> boxesA, [
    List<String> boxesB = const [],
  ]) {
    final normA = boxesA.map(_canonical).toList(growable: false);
    final normB = boxesB.map(_canonical).toList(growable: false);

    String? first(List<String> boxes, List<String> among) {
      for (final box in among) {
        if (boxes.contains(box)) return box;
      }
      return null;
    }

    final riskyA = first(normA, _atFault);
    final riskyB = first(normB, _atFault);
    final parkedA = normA.contains(_parked);
    final parkedB = normB.contains(_parked);
    if (riskyA != null && riskyB != null) {
      return ResponsibilityProposal(50, ProposalBasis.both, riskyA, riskyB);
    }
    if (riskyA != null) {
      return ResponsibilityProposal(100, ProposalBasis.fault, riskyA);
    }
    if (riskyB != null) {
      return ResponsibilityProposal(0, ProposalBasis.faultB, null, riskyB);
    }
    if (parkedA && !parkedB) {
      return const ResponsibilityProposal(0, ProposalBasis.parked);
    }
    if (parkedB && !parkedA) {
      return const ResponsibilityProposal(100, ProposalBasis.parkedB);
    }
    final turn = first(normA, _shared) ?? first(normB, _shared);
    if (turn != null) {
      return ResponsibilityProposal(50, ProposalBasis.turn, turn);
    }
    return const ResponsibilityProposal(50, ProposalBasis.unknown);
  }

  /// Ancien nom : les cases de A seules.
  static ResponsibilityProposal fromCircumstances(List<String> boxes) =>
      fromBoxes(boxes);
}
