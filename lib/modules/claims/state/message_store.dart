import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/modules/claims/data/claims_dao.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_database.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_seed.dart';
import 'package:mon_constat_digital/modules/claims/models/chat_message.dart';
import 'package:mon_constat_digital/modules/claims/state/persisted_store.dart';

class MessageStore extends ChangeNotifier with PersistedStore {
  MessageStore({ClaimsDao? dao})
    : _dao = dao ?? ClaimsDatabase.shared.claimsDao {
    loadFromDatabase(_load);
  }

  final ClaimsDao _dao;
  final messages = seedMessages();

  Future<void> _load() async {
    final savedMessages = await _dao.loadMessages();
    if (savedMessages.isEmpty) {
      await _dao.transaction(() async {
        for (final message in seedMessages()) {
          await _dao.insertMessage(message, claimId: demoClaimId);
        }
      });
      return;
    }
    messages
      ..clear()
      ..addAll(savedMessages);
  }

  void sendMessage(String author, String text) {
    if (text.trim().isEmpty) return;
    final message = ChatMessage(author, text.trim());
    messages.add(message);
    notifyListeners();
    persist(() => _dao.insertMessage(message, claimId: demoClaimId));
  }
}
