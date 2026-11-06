import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/modules/claims/models/claim.dart';

class ClaimStore extends ChangeNotifier {
  final claims = <Claim>[
    Claim(
      id: 'SIN-2026-0418',
      type: 'Collision',
      place: 'Avenue Habib Bourguiba, Tunis',
      date: '12/10/2026 18:40',
      status: 'En instruction',
    ),
  ];
  final notifications = <String>[
    'Votre dossier SIN-2026-0418 est en instruction.',
    'Votre contrat expire dans 7 jours.',
  ];

  void addClaim(Claim value) {
    claims.insert(0, value);
    notifyListeners();
  }

  void updateClaim(Claim claim, String status) {
    claim.status = status;
    claim.timeline.add(status);
    notifications.insert(0, '${claim.id} : $status');
    notifyListeners();
  }

  void addDocument(Claim claim) {
    claim.documents.add('Document-${claim.documents.length + 1}.pdf');
    notifyListeners();
  }
}
