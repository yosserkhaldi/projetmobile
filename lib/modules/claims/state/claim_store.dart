import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/modules/claims/data/claims_dao.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_database.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_seed.dart';
import 'package:mon_constat_digital/modules/claims/data/ids.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_notification.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/state/persisted_store.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

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
        for (final claim in claims.reversed) {
          await _dao.insertClaim(claim);
        }
        for (final notification in notifications.reversed) {
          await _dao.insertNotification(notification);
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

  Claim? claimById(String? id) {
    for (final claim in claims) {
      if (claim.id == id) return claim;
    }
    return null;
  }

  List<ClaimNotification> notificationsFor(UserRole role) =>
      notifications.where((n) => n.audience == role).toList();

  int unreadCount(UserRole role) =>
      notifications.where((n) => n.audience == role && !n.read).length;

  int countByStatus(bool Function(String status) test) =>
      claims.where((claim) => test(claim.status)).length;

  void addClaim(Claim value) {
    claims.insert(0, value);
    final notification = _notify(
      UserRole.agent,
      'Nouveau sinistre reçu : ${value.id}',
      value.id,
    );
    notifyListeners();
    final snapshot = value.snapshot();
    persist(() async {
      await _dao.insertClaim(snapshot);
      await _dao.insertNotification(notification);
    });
  }

  /// Applique un changement du cycle de vie. Refuse un passage non prévu.
  bool updateClaim(Claim claim, String status) {
    if (!ClaimStatus.canMove(claim.status, status)) return false;
    _applyStatus(claim, status);
    return true;
  }

  /// L'agent prend le dossier et ouvre l'instruction.
  void takeCharge(Claim claim, String agentName) {
    if (!ClaimStatus.canMove(claim.status, ClaimStatus.inReview)) return;
    claim.agentName = agentName;
    updateClaim(claim, ClaimStatus.inReview);
  }

  void requestDocument(Claim claim, String label, {String note = ''}) {
    final request = DocumentRequest(
      id: newId(),
      label: label,
      note: note.trim(),
    );
    claim.requests.add(request);
    persist(() => _dao.insertRequest(claim.id, request));
    if (claim.status == ClaimStatus.documentRequested) {
      _saveEvent(claim, 'Pièce demandée : $label');
      _sendNotification(
        UserRole.driver,
        '${claim.id} : pièce demandée ($label)',
        claim.id,
      );
    } else {
      _applyStatus(claim, ClaimStatus.documentRequested, event: label);
    }
  }

  /// Dépôt d'une pièce. La dernière pièce attendue relance l'instruction.
  void addDocument(
    Claim claim,
    String name, {
    String? path,
    DocumentRequest? request,
  }) {
    final document = ClaimDocument(
      id: newId(),
      name: name,
      path: path,
      requestId: request?.id,
    );
    claim.documents.add(document);
    persist(() => _dao.insertDocument(claim.id, document));

    if (request != null) {
      final index = claim.requests.indexWhere((r) => r.id == request.id);
      if (index >= 0) {
        claim.requests[index] = request.fulfilledBy(document.id);
        persist(() => _dao.fulfillRequest(request.id, document.id));
      }
    }
    _sendNotification(
      UserRole.agent,
      '${claim.id} : pièce déposée ($name)',
      claim.id,
    );
    if (claim.status == ClaimStatus.documentRequested &&
        claim.openRequests.isEmpty) {
      _applyStatus(claim, ClaimStatus.inReview);
    } else {
      notifyListeners();
    }
  }

  void scheduleExpertise(Claim claim, String expert, DateTime appointment) {
    claim
      ..expertName = expert.trim()
      ..expertAppointment = appointment;
    if (claim.status == ClaimStatus.expertise) {
      _saveEvent(claim, 'Rendez-vous déplacé');
      _sendNotification(
        UserRole.driver,
        '${claim.id} : rendez-vous d’expertise déplacé',
        claim.id,
      );
    } else {
      _applyStatus(claim, ClaimStatus.expertise);
    }
  }

  void addExpertReport(Claim claim, String name, {String? path}) {
    final document = ClaimDocument(
      id: newId(),
      name: name,
      path: path,
      kind: ClaimDocument.expertReport,
    );
    claim.documents.add(document);
    persist(() => _dao.insertDocument(claim.id, document));
    _saveEvent(claim, 'Rapport d’expertise joint');
  }

  /// Clôture avec responsabilité et montant.
  void closeClaim(Claim claim, int responsibility, double indemnity) {
    if (!ClaimStatus.canMove(claim.status, ClaimStatus.closed)) return;
    claim
      ..responsibility = responsibility
      ..indemnity = indemnity;
    updateClaim(claim, ClaimStatus.closed);
  }

  void rejectClaim(Claim claim, String reason) {
    if (!ClaimStatus.canMove(claim.status, ClaimStatus.rejected)) return;
    claim.decisionReason = reason.trim();
    updateClaim(claim, ClaimStatus.rejected);
  }

  void markNotificationRead(ClaimNotification notification) {
    if (notification.read) return;
    notification.read = true;
    notifyListeners();
    persist(() => _dao.markNotificationsRead([notification.id]));
  }

  void markAllNotificationsRead(UserRole role) {
    final unread = notifications.where((n) => n.audience == role && !n.read);
    final ids = unread.map((n) => n.id).toList();
    if (ids.isEmpty) return;
    for (final notification in unread) {
      notification.read = true;
    }
    notifyListeners();
    persist(() => _dao.markNotificationsRead(ids));
  }

  void _applyStatus(Claim claim, String status, {String? event}) {
    claim.status = status;
    final label = event == null ? status : '$status : $event';
    _saveEvent(claim, label);
    _sendNotification(UserRole.driver, '${claim.id} : $label', claim.id);
  }

  void _saveEvent(Claim claim, String label) {
    claim.timeline.add(label);
    claim.timelineDates[claim.timeline.length - 1] = DateTime.now();
    notifyListeners();
    final snapshot = claim.snapshot();
    persist(() => _dao.saveClaim(snapshot, event: label));
  }

  void _sendNotification(UserRole audience, String body, String claimId) {
    final notification = _notify(audience, body, claimId);
    notifyListeners();
    persist(() => _dao.insertNotification(notification));
  }

  ClaimNotification _notify(UserRole audience, String body, String claimId) {
    final notification = ClaimNotification(
      id: newId(),
      body: body,
      audience: audience,
      claimId: claimId,
      createdAt: DateTime.now(),
    );
    notifications.insert(0, notification);
    return notification;
  }
}
