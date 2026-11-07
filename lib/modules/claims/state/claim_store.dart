import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/modules/claims/data/claims_dao.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_database.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_seed.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/state/persisted_store.dart';

class ClaimStore extends ChangeNotifier with PersistedStore {
  ClaimStore({ClaimsDao? dao}) : _dao = dao ?? ClaimsDatabase.shared.claimsDao {
    loadFromDatabase(_load);
  }

  final ClaimsDao _dao;
  final claims = seedClaims();
  final notifications = seedNotifications();

  Future<void> _load() async {
    final savedClaims = await _dao.loadClaims();
    if (savedClaims.isEmpty) {
      await _dao.transaction(() async {
        for (final claim in seedClaims().reversed) {
          await _dao.insertClaim(claim);
        }
        for (final body in seedNotifications().reversed) {
          await _dao.insertNotification(body);
        }
      });
      return;
    }
    final savedNotifications = await _dao.loadNotifications();
    claims
      ..clear()
      ..addAll(savedClaims);
    notifications
      ..clear()
      ..addAll(savedNotifications);
  }

  void addClaim(Claim value) {
    claims.insert(0, value);
    notifyListeners();
    final snapshot = value.snapshot();
    persist(() => _dao.insertClaim(snapshot));
  }

  void updateClaim(Claim claim, String status) {
    final notification = '${claim.id} : $status';
    claim.status = status;
    claim.timeline.add(status);
    notifications.insert(0, notification);
    notifyListeners();
    persist(() => _dao.recordStatusChange(claim.id, status, notification));
  }

  void addDocument(Claim claim) {
    final name = 'Document-${claim.documents.length + 1}.pdf';
    claim.documents.add(name);
    notifyListeners();
    persist(() => _dao.insertDocument(claim.id, name));
  }
}
