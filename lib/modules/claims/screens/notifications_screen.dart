import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/claims/screens/claim_detail_screen.dart';
import 'package:mon_constat_digital/modules/claims/widgets/format.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/shared/navigation.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final stores = AppScope.of(context);
    final store = stores.claims;
    final role = stores.users.role;
    final items = store.notificationsFor(role);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (store.unreadCount(role) > 0)
            TextButton(
              onPressed: () => store.markAllNotificationsRead(role),
              child: const Text('Tout marquer lu'),
            ),
        ],
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Aucune notification.',
                style: TextStyle(color: AppColors.textMuted),
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
                    item.body,
                    style: TextStyle(
                      fontWeight: item.read ? FontWeight.w500 : FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(formatDateTime(item.createdAt)),
                  trailing: item.read
                      ? null
                      : const Icon(
                          Icons.circle,
                          size: 10,
                          color: AppColors.primary,
                        ),
                );
              },
            ),
    );
  }
}
