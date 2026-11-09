import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/admin/console_widgets.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/screens/identity_review_screen.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';

/// File de vérification des CIN : liste à gauche, demande ouverte à droite.
class ConsoleIdentities extends StatefulWidget {
  const ConsoleIdentities({this.initialUserId, super.key});

  /// Demande à ouvrir (depuis « À traiter » du tableau de bord).
  final String? initialUserId;

  @override
  State<ConsoleIdentities> createState() => _ConsoleIdentitiesState();
}

class _ConsoleIdentitiesState extends State<ConsoleIdentities> {
  late String? _selectedId = widget.initialUserId;
  bool _loading = true;
  bool _busy = false;
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
      await admin.loadPendingIdentities();
      final pending = admin.pendingIdentities;
      if (mounted && !pending.any((u) => u.id == _selectedId)) {
        setState(() => _selectedId = pending.firstOrNull?.id);
      }
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(context, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Après une décision, on passe à la demande suivante.
  Future<void> _decide(AppUser user, Future<void> Function() decision) async {
    final admin = AppScope.of(context).admin;
    final messenger = ScaffoldMessenger.of(context);
    String describe(Object error) => errorMessage(context, error);
    final index = admin.pendingIdentities.indexWhere((u) => u.id == user.id);
    setState(() => _busy = true);
    try {
      await decision();
      final rest = admin.pendingIdentities;
      setState(() {
        _selectedId = rest.isEmpty
            ? null
            : rest[index.clamp(0, rest.length - 1)].id;
      });
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describe(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _approve(AppUser user) async {
    final admin = AppScope.of(context).admin;
    final messenger = ScaffoldMessenger.of(context);
    final done = context.t.identityApproved;
    await _decide(user, () => admin.approveIdentity(user));
    messenger.showSnackBar(SnackBar(content: Text(done)));
  }

  Future<void> _reject(AppUser user) async {
    final admin = AppScope.of(context).admin;
    final messenger = ScaffoldMessenger.of(context);
    final done = context.t.identityRejected;
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: RejectReasonSheet(),
          ),
        ),
      ),
    );
    if (reason == null) return;
    await _decide(user, () => admin.rejectIdentity(user, reason));
    messenger.showSnackBar(SnackBar(content: Text(done)));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final pending = AppScope.of(context).admin.pendingIdentities;
    final selected = pending.where((u) => u.id == _selectedId).firstOrNull;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConsoleHeader(
            title: t.reviewTitle,
            subtitle: t.reviewSubtitle,
            actions: [
              StatusChip(
                label: t.pendingCount(pending.length),
                background: pending.isEmpty ? p.successBg : p.warningBg,
                foreground: pending.isEmpty ? p.successText : p.warningText,
              ),
              IconButton(
                tooltip: t.refresh,
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          if (_error != null) ...[
            ErrorBanner(_error!),
            const SizedBox(height: 12),
          ],
          // File vide : un seul message, pas deux panneaux vides.
          if (!_loading && pending.isEmpty && _error == null)
            Expanded(
              child: ConsoleCard(
                expand: true,
                child: ConsoleEmpty(
                  icon: Icons.task_alt_rounded,
                  text: t.noPendingReviews,
                ),
              ),
            )
          else
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 340,
                    child: ConsoleCard(
                      expand: true,
                      padding: const EdgeInsets.all(8),
                      child: _loading && pending.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : pending.isEmpty
                          ? ConsoleEmpty(
                              icon: Icons.task_alt_rounded,
                              text: t.noPendingReviews,
                            )
                          : Column(
                              children: [
                                for (final user in pending)
                                  _QueueItem(
                                    user: user,
                                    selected: user.id == _selectedId,
                                    onTap: () =>
                                        setState(() => _selectedId = user.id),
                                  ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ConsoleCard(
                      expand: true,
                      padding: const EdgeInsets.all(24),
                      child: selected == null
                          ? ConsoleEmpty(
                              icon: Icons.badge_outlined,
                              text: pending.isEmpty
                                  ? t.noPendingReviews
                                  : t.selectRequest,
                            )
                          : _Detail(
                              user: selected,
                              busy: _busy,
                              onApprove: () => _approve(selected),
                              onReject: () => _reject(selected),
                            ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QueueItem extends StatelessWidget {
  const _QueueItem({
    required this.user,
    required this.selected,
    required this.onTap,
  });

  final AppUser user;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final submitted = user.identity.submittedAt;
    return Material(
      color: selected ? p.primaryTint : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              InitialAvatar(user.firstName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: selected ? p.primaryText : p.text,
                      ),
                    ),
                    Text(
                      'CIN ${user.identity.cinNumber ?? ''}',
                      style: TextStyle(
                        color: p.textMuted,
                        fontFamily: AppFonts.mono,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (submitted != null)
                Text(
                  DateFormat.MMMd(context.t.localeName).format(submitted),
                  style: TextStyle(color: p.textMuted, fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({
    required this.user,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  final AppUser user;
  final bool busy;
  final VoidCallback onApprove, onReject;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final submitted = user.identity.submittedAt;
    Widget fact(String label, String value, {bool mono = false}) => Padding(
      padding: const EdgeInsets.only(right: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: p.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textDirection: mono ? TextDirection.ltr : null,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: mono ? 18 : 14,
              letterSpacing: mono ? 2 : 0,
              fontFamily: mono ? AppFonts.mono : null,
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            InitialAvatar(user.firstName, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  Text(user.email, style: TextStyle(color: p.textMuted)),
                ],
              ),
            ),
            identityChip(context, user.identity.status),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          runSpacing: 12,
          children: [
            fact(t.cinNumberLabel, user.identity.cinNumber ?? '—', mono: true),
            fact(t.phoneLabel, ltr(user.phone)),
            if (submitted != null)
              fact(
                t.submittedOn('').trim(),
                DateFormat.yMMMd(t.localeName).add_Hm().format(submitted),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (index, (photo, label)) in [
                (UserPhoto.cinFront, t.cinFront),
                (UserPhoto.cinBack, t.cinBack),
              ].indexed) ...[
                if (index > 0) const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      IdentityPhotoFrame(user: user, photo: photo),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: busy ? null : onReject,
              style: OutlinedButton.styleFrom(
                foregroundColor: p.errorText,
                side: BorderSide(color: p.errorText, width: 1.5),
                minimumSize: const Size(160, 48),
              ),
              icon: const Icon(Icons.close_rounded),
              label: Text(t.reject),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: busy ? null : onApprove,
              style: FilledButton.styleFrom(minimumSize: const Size(180, 48)),
              icon: const Icon(Icons.check_rounded),
              label: Text(t.approve),
            ),
          ],
        ),
      ],
    );
  }
}
