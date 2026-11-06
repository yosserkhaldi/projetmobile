import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).claims;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: s.notifications.length,
        itemBuilder: (_, i) => ListTile(
          leading: const CircleAvatar(child: Icon(Icons.notifications)),
          title: Text(s.notifications[i]),
          subtitle: const Text('Maintenant'),
          trailing: const Icon(
            Icons.circle,
            size: 10,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
