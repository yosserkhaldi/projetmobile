import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).users;
    return SafeArea(
      child: Column(
        children: [
          const PageHead(
            'Gestion des comptes',
            subtitle: 'Rôles, agents et suspensions',
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: s.users.length,
              itemBuilder: (_, i) {
                final u = s.users[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(u.name[0])),
                    title: Text(u.name),
                    subtitle: Text('${u.email}\n${u.role.label}'),
                    isThreeLine: true,
                    trailing: Switch(
                      value: u.active,
                      onChanged: (_) => s.toggleUser(u),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
