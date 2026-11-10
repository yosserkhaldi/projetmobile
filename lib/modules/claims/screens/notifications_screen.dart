import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/claims/screens/claim_detail_screen.dart';
import 'package:mon_constat_digital/modules/claims/widgets/format.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/shared/navigation.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final stores = AppScope.of(context);
    final store = stores.claims;
    final role = stores.users.role;
    final items = store.notificationsFor(role);
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.claimsNotifications),
        actions: [
          if (store.unreadCount(role) > 0)
            TextButton(
              onPressed: () => store.markAllNotificationsRead(role),
              child: Text(t.claimsMarkAllRead),
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                t.claimsNoNotification,
                style: TextStyle(color: context.palette.textMuted),
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                return ListTile(
                  onTap: () {
                    store.markNotificationRead(item);
                    final claim = store.claimById(item.claimId);
                    if (claim == null) return;
                    open(
                      context,
                      ClaimDetail(claim, agentMode: role == UserRole.agent),
                    );
                  },
                  leading: const CircleAvatar(child: Icon(Icons.notifications)),
                  title: Text(
                    t.claimNotification(item.body),
                    style: TextStyle(
                      fontWeight: item.read ? FontWeight.w400 : FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(formatDateTime(item.createdAt)),
                  trailing: item.read
                      ? null
                      : Icon(
                          Icons.circle,
                          size: 10,
                          color: context.palette.primaryText,
                        ),
                );
              },
            ),
    );
  }
}
