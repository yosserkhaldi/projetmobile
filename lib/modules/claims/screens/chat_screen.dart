import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/claims/models/chat_message.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/widgets/document_picker.dart';
import 'package:mon_constat_digital/modules/claims/widgets/format.dart';
import 'package:mon_constat_digital/modules/claims/widgets/offline_banner.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(this.claim, {this.suggest, super.key});
  final Claim claim;

  /// Remplace l'appel au serveur dans les tests.
  final Future<List<String>> Function()? suggest;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final input = TextEditingController();
  List<String> suggestions = const [];
  bool suggesting = false;

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  /// Sur demande seulement : chaque suggestion peut coûter un appel au modèle.
  Future<void> _suggest() async {
    final sync = AppScope.of(context).claimsSync;
    final messenger = ScaffoldMessenger.of(context);
    final unavailable = context.t.claimsSuggestionsUnavailable;
    setState(() => suggesting = true);
    try {
      final replies =
          await widget.suggest?.call() ??
          await sync!.api.suggestReplies(widget.claim.id);
      if (mounted) setState(() => suggestions = replies);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(unavailable)));
    } finally {
      if (mounted) setState(() => suggesting = false);
    }
  }

  void _send({
    String? attachmentName,
    String? attachmentPath,
    Uint8List? attachmentBytes,
  }) {
    final stores = AppScope.of(context);
    stores.messages.sendMessage(
      widget.claim.id,
      stores.users.userName,
      stores.users.role,
      input.text,
      attachmentName: attachmentName,
      attachmentPath: attachmentPath,
      attachmentBytes: attachmentBytes,
    );
    input.clear();
    if (suggestions.isNotEmpty) setState(() => suggestions = const []);
  }

  Future<void> _attach() async {
    final file = await pickDocument();
    if (file == null || !mounted) return;
    _send(
      attachmentName: file.name,
      attachmentPath: file.path,
      attachmentBytes: file.bytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final stores = AppScope.of(context);
    final role = stores.users.role;
    final messages = stores.messages.messagesFor(widget.claim.id);
    // Les messages affichés sont lus : l'accusé part après ce rendu.
    if (stores.messages.unreadCount(role, claimId: widget.claim.id) > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) stores.messages.markRead(widget.claim.id, role);
      });
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.claim.id)),
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        t.claimsNoMessages,
                        style: TextStyle(color: context.palette.textMuted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (_, i) => _Bubble(
                        messages[i],
                        mine: messages[i].senderRole == role,
                      ),
                    ),
            ),
            if (suggestions.isNotEmpty)
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final reply in suggestions)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ActionChip(
                          label: Text(reply),
                          onPressed: () => input.text = reply,
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (role == UserRole.agent &&
                      (stores.claimsSync != null ||
                          widget.suggest != null)) ...[
                    IconButton.outlined(
                      tooltip: t.claimsSuggestReply,
                      onPressed: suggesting ? null : _suggest,
                      icon: const Icon(Icons.lightbulb_outline),
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton.outlined(
                    tooltip: t.claimsAttachFile,
                    onPressed: _attach,
                    icon: const Icon(Icons.attach_file),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: input,
                      decoration: InputDecoration(
                        hintText: t.claimsYourMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: t.claimsSend,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _send,
                    icon: const Icon(Icons.arrow_upward, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.message, {required this.mine});
  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final foreground = mine ? Colors.white : context.palette.text;
    final muted = mine ? AppColors.onPrimaryMuted : context.palette.textMuted;
    // Directionnel : en arabe, mes messages passent à gauche.
    final side = mine
        ? AlignmentDirectional.centerEnd
        : AlignmentDirectional.centerStart;
    return Align(
      alignment: side,
      child: FractionallySizedBox(
        widthFactor: .82,
        alignment: side,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: mine ? AppColors.primary : context.palette.surface,
            border: mine ? null : Border.all(color: context.palette.border),
            borderRadius: BorderRadiusDirectional.only(
              topStart: const Radius.circular(18),
              topEnd: const Radius.circular(18),
              bottomStart: Radius.circular(mine ? 18 : 6),
              bottomEnd: Radius.circular(mine ? 6 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.author,
                style: TextStyle(fontSize: 11, color: muted),
              ),
              if (message.text.isNotEmpty)
                Text(message.text, style: TextStyle(color: foreground)),
              if (message.attachmentName != null)
                InkWell(
                  onTap: () => saveFromServer(
                    context,
                    kind: 'message',
                    id: message.id,
                    name: message.attachmentName!,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.attach_file, size: 16, color: foreground),
                      Expanded(
                        child: Text(
                          message.attachmentName!,
                          style: TextStyle(color: foreground),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    formatDateTime(message.sentAt),
                    style: TextStyle(fontSize: 10, color: muted),
                  ),
                  if (mine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.read ? Icons.done_all : Icons.done,
                      size: 14,
                      color: muted,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
