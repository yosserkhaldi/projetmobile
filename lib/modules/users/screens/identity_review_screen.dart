import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';
import 'package:mon_constat_digital/modules/users/widgets/user_photo.dart';
import 'package:mon_constat_digital/shared/navigation.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

/// File des identités à vérifier (administrateurs).
class IdentityReviewScreen extends StatefulWidget {
  const IdentityReviewScreen({super.key});

  @override
  State<IdentityReviewScreen> createState() => _IdentityReviewScreenState();
}

class _IdentityReviewScreenState extends State<IdentityReviewScreen> {
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
      await admin.loadPendingIdentities();
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
    final pending = AppScope.of(context).admin.pendingIdentities;
    return SafeArea(
      child: Column(
        children: [
          PageHead(t.reviewTitle, subtitle: t.reviewSubtitle),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_loading && pending.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (_error != null) ...[
                    ErrorBanner(_error!),
                    TextButton(onPressed: _load, child: Text(t.retry)),
                  ],
                  if (!_loading && _error == null && pending.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.task_alt_rounded,
                            size: 48,
                            color: p.successText,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            t.noPendingReviews,
                            style: TextStyle(color: p.textMuted),
                          ),
                        ],
                      ),
                    ),
                  for (final user in pending)
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: p.primaryTint,
                          foregroundColor: p.primaryText,
                          child: Text(
                            user.firstName.characters.first.toUpperCase(),
                          ),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          'CIN ${user.identity.cinNumber ?? ''} · ${user.email}',
                          style: TextStyle(color: p.textMuted),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => open(context, _ReviewDetail(user: user)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewDetail extends StatefulWidget {
  const _ReviewDetail({required this.user});
  final AppUser user;

  @override
  State<_ReviewDetail> createState() => _ReviewDetailState();
}

class _ReviewDetailState extends State<_ReviewDetail> with FormActions {
  void _approve() {
    final admin = AppScope.of(context).admin;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final done = context.t.identityApproved;
    submit(() async {
      await admin.approveIdentity(widget.user);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(done)));
    }, validate: false);
  }

  Future<void> _reject() async {
    final admin = AppScope.of(context).admin;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final done = context.t.identityRejected;
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _RejectSheet(),
    );
    if (reason == null) return;
    await submit(() async {
      await admin.rejectIdentity(widget.user, reason);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(done)));
    }, validate: false);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final user = widget.user;
    final submitted = user.identity.submittedAt;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (error != null) ...[
              ErrorBanner(error!),
              const SizedBox(height: 14),
            ],
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.cinNumberLabel,
                      style: TextStyle(
                        color: p.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      user.identity.cinNumber ?? '',
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontFamily: AppFonts.mono,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${user.name} · ${ltr(user.phone)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (submitted != null)
                      Text(
                        t.submittedOn(
                          DateFormat.yMMMd(
                            t.localeName,
                          ).add_Hm().format(submitted),
                        ),
                        style: TextStyle(color: p.textMuted, fontSize: 13),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.cinFront,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            _Photo(user: user, photo: UserPhoto.cinFront),
            const SizedBox(height: 16),
            Text(
              t.cinBack,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            _Photo(user: user, photo: UserPhoto.cinBack),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : _reject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: p.errorText,
                      side: BorderSide(color: p.errorText, width: 1.5),
                    ),
                    icon: const Icon(Icons.close),
                    label: Text(t.reject),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: busy ? null : _approve,
                    icon: const Icon(Icons.check),
                    label: Text(t.approve),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RejectSheet extends StatefulWidget {
  const _RejectSheet();

  @override
  State<_RejectSheet> createState() => _RejectSheetState();
}

class _RejectSheetState extends State<_RejectSheet> {
  final _other = TextEditingController();
  String? _choice;

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final reasons = [
      t.rejectReasonBlurry,
      t.rejectReasonUnreadable,
      t.rejectReasonNameMismatch,
      t.rejectReasonNotCin,
    ];
    final reason = _choice == t.otherReason ? _other.text.trim() : _choice;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.rejectTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in [...reasons, t.otherReason])
                ChoiceChip(
                  label: Text(option),
                  selected: _choice == option,
                  onSelected: (_) => setState(() => _choice = option),
                ),
            ],
          ),
          if (_choice == t.otherReason) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _other,
              autofocus: true,
              maxLength: 300,
              onChanged: (_) => setState(() {}),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: reason == null || reason.length < 3
                ? null
                : () => Navigator.pop(context, reason),
            child: Text(t.reject),
          ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.user, required this.photo});
  final AppUser user;
  final UserPhoto photo;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1.58,
    child: Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: context.palette.border),
      ),
      // Agrandissable pour lire les détails de la carte.
      child: InteractiveViewer(
        maxScale: 4,
        child: UserPhotoView(
          user: user,
          photo: photo,
          fit: BoxFit.contain,
          placeholder: const Icon(Icons.image_not_supported_outlined),
        ),
      ),
    ),
  );
}
