import 'package:mon_constat_digital/modules/users/models/app_user.dart';

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.claimId,
    required this.author,
    required this.senderRole,
    required this.text,
    required this.sentAt,
    this.attachmentName,
    this.attachmentPath,
    this.read = false,
  });

  final String id, claimId, author, text;
  final UserRole senderRole;
  final DateTime sentAt;
  final String? attachmentName, attachmentPath;

  /// Lu par le destinataire.
  bool read;
}
