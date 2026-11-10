import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/modules/claims/data/claims_dao.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_database.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_seed.dart';
import 'package:mon_constat_digital/modules/claims/data/ids.dart';
import 'package:mon_constat_digital/modules/claims/models/chat_message.dart';
import 'package:mon_constat_digital/modules/claims/state/claims_sync.dart';
import 'package:mon_constat_digital/modules/claims/state/persisted_store.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

class MessageStore extends ChangeNotifier with PersistedStore {
  MessageStore({ClaimsDao? dao})
    : _dao = dao ?? ClaimsDatabase.shared.claimsDao {
    loadFromDatabase(_load);
  }

  final ClaimsDao _dao;

  /// Absent quand l'application reste locale.
  ClaimsSync? sync;
  final messages = seedMessages();

  Future<void> _load() async {
    final savedMessages = await _dao.loadMessages();
    if (savedMessages.isEmpty) {
      await _dao.transaction(() async {
        for (final message in messages) {
          await _dao.insertMessage(message);
        }
      });
      return;
    }
    messages
      ..clear()
      ..addAll(savedMessages);
  }

  /// Recharge depuis SQLite après une synchronisation.
  Future<void> reload() async {
    final fresh = await _dao.loadMessages();
    messages
      ..clear()
      ..addAll(fresh);
    notifyListeners();
  }

  List<ChatMessage> messagesFor(String claimId) =>
      messages.where((m) => m.claimId == claimId).toList();

  int unreadCount(UserRole reader, {String? claimId}) => messages
      .where(
        (m) =>
            !m.read &&
            m.senderRole != reader &&
            (claimId == null || m.claimId == claimId),
      )
      .length;

  void sendMessage(
    String claimId,
    String author,
    UserRole role,
    String text, {
    String? attachmentName,
    String? attachmentPath,
    Uint8List? attachmentBytes,
  }) {
    if (text.trim().isEmpty && attachmentName == null) return;
    final message = ChatMessage(
      id: newId(),
      claimId: claimId,
      author: author,
      senderRole: role,
      text: text.trim(),
      sentAt: DateTime.now(),
      attachmentName: attachmentName,
      attachmentPath: attachmentPath,
    );
    messages.add(message);
    notifyListeners();
    persist(() => _dao.insertMessage(message));
    final queue = sync;
    if (queue != null) {
      persist(
        () => queue.enqueue(
          '/$claimId/messages',
          multipart: true,
          filePath: attachmentPath,
          fileBytes: attachmentBytes,
          fileName: attachmentName,
          body: {
            'id': message.id,
            'body': message.text,
            'attachmentName': attachmentName,
          },
        ),
      );
    }
  }

  /// Accusé de lecture : marque les messages reçus par [reader] sur ce dossier.
  void markRead(String claimId, UserRole reader) {
    final unread = messages
        .where((m) => m.claimId == claimId && m.senderRole != reader && !m.read)
        .toList();
    if (unread.isEmpty) return;
    for (final message in unread) {
      message.read = true;
    }
    notifyListeners();
    final ids = unread.map((m) => m.id).toList();
    persist(() => _dao.markMessagesRead(ids));
    final queue = sync;
    if (queue != null) {
      persist(() => queue.enqueue('/$claimId/messages/read'));
    }
  }
}
