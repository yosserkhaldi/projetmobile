import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/modules/claims/models/chat_message.dart';

class MessageStore extends ChangeNotifier {
  final messages = <ChatMessage>[
    ChatMessage(
      "Agent Leïla",
      'Bonjour, merci de joindre le devis de réparation.',
    ),
    ChatMessage('Sami', 'Je vous le transmets aujourd’hui.'),
  ];

  void sendMessage(String author, String text) {
    if (text.trim().isEmpty) return;
    messages.add(ChatMessage(author, text.trim()));
    notifyListeners();
  }
}
