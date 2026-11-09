/// Cycle de vie d'un dossier : les 9 statuts du cahier des charges.
abstract final class ClaimStatus {
  static const draft = 'Brouillon';
  static const declared = 'Déclaré';
  static const signed = 'Constat signé';
  static const transmitted = 'Transmis';
  static const inReview = 'En instruction';
  static const documentRequested = 'Pièce demandée';
  static const expertise = 'Expertise';
  static const closed = 'Clôturé';
  static const rejected = 'Rejeté';

  static const all = [
    draft,
    declared,
    signed,
    transmitted,
    inReview,
    documentRequested,
    expertise,
    closed,
    rejected,
  ];

  /// Le conducteur avance jusqu'à Transmis, l'agent prend ensuite la main.
  static const _next = <String, List<String>>{
    draft: [declared],
    declared: [signed],
    signed: [transmitted],
    transmitted: [inReview],
    inReview: [documentRequested, expertise, closed, rejected],
    documentRequested: [inReview, rejected],
    expertise: [closed, rejected],
  };

  static List<String> nextOf(String status) => _next[status] ?? const [];

  static bool canMove(String from, String to) => nextOf(from).contains(to);

  static bool isFinal(String status) => status == closed || status == rejected;

  /// Dossiers qui attendent une action de l'agent.
  static bool isOpenForAgent(String status) =>
      status == transmitted ||
      status == inReview ||
      status == documentRequested ||
      status == expertise;
}
