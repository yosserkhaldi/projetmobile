import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:mon_constat_digital/app/help_screen.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/accident/screens/accident_wizard.dart';
import 'package:mon_constat_digital/modules/accident/screens/declarations_screen.dart';
import 'package:mon_constat_digital/modules/accident/screens/emergency_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/notifications_screen.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_card.dart';
import 'package:mon_constat_digital/modules/users/screens/profile_screen.dart';
import 'package:mon_constat_digital/modules/vehicles/screens/alerts_screen.dart';
import 'package:mon_constat_digital/shared/navigation.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class DriverHome extends StatelessWidget {
  const DriverHome({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          PageHead(
            'Bonjour, ${s.users.userName.split(' ').first}',
            subtitle: 'Prêt à prendre la route ?',
            actions: [
              IconButton(
                onPressed: () => open(context, const NotificationsScreen()),
                icon: Badge(
                  label: Text('${s.claims.notifications.length}'),
                  child: const Icon(Icons.notifications_outlined),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: context.palette.hero,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UN ACCIDENT ?',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Déclarez-le en moins de 10 minutes, même hors ligne.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        final draft = s.accidents.startNew();
                        open(context, AccidentWizard(initialDraft: draft));
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Commencer une déclaration'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'Accès rapides',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.05,
              children: [
                _quick(
                  context,
                  Icons.badge_outlined,
                  'Mon permis',
                  const ProfileScreen(),
                ),
                _quick(
                  context,
                  Icons.warning_amber,
                  'Alertes',
                  const AlertsScreen(),
                ),
                _quick(
                  context,
                  Icons.description,
                  'Constat',
                  const DeclarationsScreen(),
                ),
                _quick(
                  context,
                  Icons.phone,
                  'Urgences',
                  const EmergencyScreen(),
                ),
                _quick(
                  context,
                  Icons.notifications,
                  'Notifications',
                  const NotificationsScreen(),
                ),
                _quick(
                  context,
                  Icons.help_outline,
                  'Assistance',
                  const HelpScreen(),
                ),
              ],
            ),
          ),
          if (s.claims.claims.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClaimCard(s.claims.claims.first),
            ),
        ],
      ),
    );
  }

  Widget _quick(BuildContext c, IconData i, String t, Widget p) => InkWell(
    onTap: () => open(c, p),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, color: c.palette.primaryText),
            const SizedBox(height: 8),
            Text(
              t,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}
