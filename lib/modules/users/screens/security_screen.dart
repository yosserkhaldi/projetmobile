import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/models/security.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';
import 'package:mon_constat_digital/modules/users/widgets/skeleton.dart';

/// Appareils connectés et historique des connexions.
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  List<DeviceSession>? _sessions;
  List<LoginEvent>? _events;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final users = AppScope.of(context).users;
    setState(() => _error = null);
    try {
      final results = await Future.wait([
        users.loadSessions(),
        users.loadLoginEvents(),
      ]);
      if (!mounted) return;
      setState(() {
        _sessions = results[0] as List<DeviceSession>;
        _events = results[1] as List<LoginEvent>;
      });
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(context, e));
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    String describe(Object error) => errorMessage(context, error);
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) await _load();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describe(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _revoke(DeviceSession session) async {
    final t = context.t;
    final users = AppScope.of(context).users;
    final name = session.deviceName ?? t.unknownDevice;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(t.signOutDeviceConfirm(name)),
        content: Text(t.signOutDeviceBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(t.signOutDevice),
          ),
        ],
      ),
    );
    if (confirmed == true) await _run(() => users.revokeSession(session));
  }

  Future<void> _revokeOthers() async {
    final users = AppScope.of(context).users;
    final messenger = ScaffoldMessenger.of(context);
    final t = context.t;
    await _run(() async {
      final count = await users.revokeOtherSessions();
      messenger.showSnackBar(SnackBar(content: Text(t.signedOutOthers(count))));
    });
  }

  String _date(DateTime date) =>
      DateFormat.yMMMd(context.t.localeName).add_Hm().format(date);

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final sessions = _sessions;
    final events = _events;
    return Scaffold(
      appBar: AppBar(title: Text(t.securityDevicesTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (_error != null) ...[
                ErrorBanner(_error!),
                TextButton(onPressed: _load, child: Text(t.retry)),
              ],
              _Note(text: t.securityAlertNote),
              const SizedBox(height: 18),
              _Title(t.securityDevicesSubtitle),
              if (sessions == null && _error == null)
                const SizedBox(
                  height: 190,
                  child: SkeletonList(count: 3, padding: EdgeInsets.all(8)),
                ),
              if (sessions != null)
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < sessions.length; i += 1) ...[
                        if (i > 0) Divider(height: 1, color: p.surfaceAlt),
                        _SessionTile(
                          session: sessions[i],
                          subtitle: t.lastActive(_date(sessions[i].lastUsedAt)),
                          onRevoke: _busy ? null : () => _revoke(sessions[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              if (sessions != null && sessions.length > 1) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _revokeOthers,
                  icon: const Icon(Icons.phonelink_erase_outlined),
                  label: Text(t.signOutOthers),
                ),
              ],
              const SizedBox(height: 26),
              _Title(t.loginHistoryTitle),
              if (events != null && events.isEmpty)
                Text(t.noHistory, style: TextStyle(color: p.textMuted)),
              if (events != null && events.isNotEmpty)
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < events.length; i += 1) ...[
                        if (i > 0) Divider(height: 1, color: p.surfaceAlt),
                        _EventTile(
                          event: events[i],
                          date: _date(events[i].createdAt),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
        color: context.palette.textMuted,
      ),
    ),
  );
}

class _Note extends StatelessWidget {
  const _Note({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.primaryTint,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active_outlined, color: p.primaryText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: p.primaryText,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _deviceIcon(String? name) {
  final lower = (name ?? '').toLowerCase();
  if (lower.contains('web') ||
      lower.contains('windows') ||
      lower.contains('chrome')) {
    return Icons.laptop_outlined;
  }
  if (lower.contains('ipad') || lower.contains('tab')) {
    return Icons.tablet_android_outlined;
  }
  return Icons.smartphone_outlined;
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.subtitle,
    required this.onRevoke,
  });

  final DeviceSession session;
  final String subtitle;
  final VoidCallback? onRevoke;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: session.current ? p.successBg : p.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          _deviceIcon(session.deviceName),
          color: session.current ? p.successText : p.textMuted,
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              session.deviceName ?? t.unknownDevice,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          if (session.current) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: p.successBg,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                t.thisDevice,
                style: TextStyle(
                  color: p.successText,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(subtitle, style: TextStyle(color: p.textMuted)),
      trailing: session.current
          ? null
          : TextButton(
              onPressed: onRevoke,
              style: TextButton.styleFrom(foregroundColor: p.errorText),
              child: Text(t.signOutDevice),
            ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.date});
  final LoginEvent event;
  final String date;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final method = switch (event.method) {
      'biometric' => t.loginMethodBiometric,
      'register' => t.loginMethodRegister,
      _ => t.loginMethodPassword,
    };
    final title = event.success
        ? '${t.loginSuccess} · $method'
        : switch (event.reason) {
            'locked' => t.loginFailedLocked,
            'suspended' => t.loginFailedSuspended,
            _ => t.loginFailedWrongPassword,
          };
    return ListTile(
      dense: true,
      leading: Icon(
        event.success ? Icons.check_circle_outline : Icons.gpp_bad_outlined,
        color: event.success ? p.successText : p.errorText,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        '${event.deviceName ?? t.unknownDevice} · $date',
        style: TextStyle(color: p.textMuted),
      ),
      trailing: event.success
          ? null
          : const Icon(Icons.warning_amber_rounded, color: AppColors.accent),
    );
  }
}
