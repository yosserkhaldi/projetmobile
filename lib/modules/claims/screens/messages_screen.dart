import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/claims/screens/chat_screen.dart';
import 'package:mon_constat_digital/shared/navigation.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';

/// Une conversation par dossier.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final stores = AppScope.of(context);
    final role = stores.users.role;
    final claims = stores.claims.claims;
    final t = context.t;
    return SafeArea(
      child: Column(
        children: [
          PageHead(t.claimsMessaging, subtitle: t.claimsOneConversation),
          Expanded(
            child: claims.isEmpty
                ? Center(
                    child: Text(
                      t.claimsNoClaims,
                      style: TextStyle(color: context.palette.textMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: claims.length,
                    itemBuilder: (_, i) {
                      final claim = claims[i];
                      final messages = stores.messages.messagesFor(claim.id);
                      final unread = stores.messages.unreadCount(
                        role,
                        claimId: claim.id,
                      );
                      return ListTile(
                        onTap: () => open(context, ChatScreen(claim)),
                        leading: const CircleAvatar(child: Icon(Icons.chat)),
                        title: Text(
                          claim.id,
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          messages.isEmpty
                              ? t.claimsNoMessage
                              : messages.last.attachmentName ??
                                    messages.last.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: unread == 0
                            ? null
                            : Badge(label: Text('$unread')),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
