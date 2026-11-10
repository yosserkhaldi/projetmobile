import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/admin/admin_console.dart'
    show adminConsoleMinWidth;
import 'package:mon_constat_digital/modules/users/admin/console_widgets.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/screens/account_detail_screen.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';
import 'package:mon_constat_digital/modules/users/widgets/skeleton.dart';

/// Ouvre un écran : page sur téléphone, fenêtre dans la console.
Future<void> openAdminPage(BuildContext context, Widget page) {
  final wide = MediaQuery.sizeOf(context).width >= adminConsoleMinWidth;
  if (!wide) {
    return Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 820),
        child: page,
      ),
    ),
  );
}

/// Dossier d'un compte, depuis n'importe quelle liste de l'administration.
Future<void> openAccountFile(BuildContext context, AppUser user) =>
    openAdminPage(context, AccountDetailScreen(user: user));

/// Permis signalés par l'IA : un contrôle croisé a échoué, ou la photo
/// était illisible. Un administrateur tranche depuis le dossier du compte.
class LicenseReviewScreen extends StatefulWidget {
  const LicenseReviewScreen({super.key});

  @override
  State<LicenseReviewScreen> createState() => _LicenseReviewScreenState();
}

class _LicenseReviewScreenState extends State<LicenseReviewScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final admin = AppScope.of(context).admin;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await admin.loadLicenseReviews();
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(context, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final items = AppScope.of(context).admin.licenseReviews;
    return Scaffold(
      appBar: AppBar(title: Text(t.licenseReviewTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                t.licenseReviewSubtitle,
                style: TextStyle(color: p.textMuted),
              ),
              const SizedBox(height: 12),
              if (_loading && items.isEmpty)
                const SizedBox(
                  height: 300,
                  child: SkeletonList(count: 3, padding: EdgeInsets.zero),
                ),
              if (_error != null) ...[
                ErrorBanner(_error!),
                TextButton(onPressed: _load, child: Text(t.retry)),
              ],
              if (!_loading && _error == null && items.isEmpty)
                ConsoleEmpty(
                  icon: Icons.task_alt_rounded,
                  text: t.noLicenseReviews,
                ),
              for (final user in items)
                Card(
                  child: ListTile(
                    leading: InitialAvatar(user.firstName),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      [
                        ?user.licenseNumber,
                        if (user.license.reading case final reading?)
                          if (reading.failedChecks > 0)
                            '${reading.failedChecks} ✗',
                      ].join(' · '),
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: p.textMuted,
                        fontFamily: AppFonts.mono,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await openAccountFile(context, user);
                      if (context.mounted) await _load();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alerte du tableau de bord : des permis attendent un administrateur.
class LicenseReviewAlert extends StatelessWidget {
  const LicenseReviewAlert({required this.count, super.key});
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    final t = context.t;
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: p.warningBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          key: const Key('license-review-alert'),
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: () async {
            final admin = AppScope.of(context).admin;
            await openAdminPage(context, const LicenseReviewScreen());
            await admin.loadStats().catchError((Object _) {});
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.report_problem_outlined, color: p.warningText),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.licensesToReviewCount(count),
                        style: TextStyle(
                          color: p.warningText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        t.licenseReviewSubtitle,
                        style: TextStyle(color: p.warningText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: p.warningText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
