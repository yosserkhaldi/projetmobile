import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/widgets/dashboard_widgets.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

/// Tableau de bord administrateur (1.4), sur les données réelles des comptes.
/// Les indicateurs d'accidents arrivent avec les modules 3 et 5.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final admin = AppScope.of(context).admin;
    setState(() => _error = null);
    try {
      await admin.loadStats();
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final stats = AppScope.of(context).admin.stats;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            PageHead(t.adminTitle, subtitle: t.adminSubtitle),
            if (_error != null) ...[
              ErrorBanner(_error!),
              TextButton(onPressed: _load, child: Text(t.retry)),
            ],
            if (stats == null && _error == null)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (stats != null) ...dashboardSections(context, stats).phone,
          ],
        ),
      ),
    );
  }
}
