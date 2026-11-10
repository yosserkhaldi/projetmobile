import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/admin/console_widgets.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/screens/identity_review_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/identity_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/profile_screen.dart'
    show formatDate, licenseCategories;
import 'package:mon_constat_digital/modules/users/screens/users_screen.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';

/// Dossier complet d'un compte pour l'administrateur : identité et permis
/// avec leurs photos, même quand l'IA les a validés seule, et toutes les
/// actions (valider, refuser, corriger, supprimer, annuler une vérification).
class AccountDetailScreen extends StatefulWidget {
  const AccountDetailScreen({required this.user, super.key});
  final AppUser user;

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen>
    with FormActions {
  late AppUser _user = widget.user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  /// La liste des comptes peut dater : on relit le dossier à l'ouverture.
  Future<void> _reload() async {
    final admin = AppScope.of(context).admin;
    try {
      final user = await admin.fetchUser(_user.id);
      if (mounted) setState(() => _user = user);
    } catch (e) {
      if (mounted) setState(() => error = errorMessage(context, e));
    }
  }

  /// Lance une action, garde le compte renvoyé et confirme par [done].
  Future<void> _act(Future<AppUser> Function() action, String done) {
    final messenger = ScaffoldMessenger.of(context);
    return submit(() async {
      final user = await action();
      if (!mounted) return;
      setState(() => _user = user);
      messenger.showSnackBar(SnackBar(content: Text(done)));
    }, validate: false);
  }

  Future<void> _changeRole() async {
    final admin = AppScope.of(context).admin;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RoleSheet(
        user: _user,
        onSave: (role, companyId) =>
            admin.setRole(_user, role, companyId: companyId),
      ),
    );
    if (mounted) await _reload();
  }

  Future<void> _toggleActive() async {
    final admin = AppScope.of(context).admin;
    final t = context.t;
    final active = !_user.active;
    await submit(() async {
      await admin.setActive(_user, active);
      await _reload();
    }, validate: false);
    if (mounted && error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(active ? t.statusActive : t.statusSuspended)),
      );
    }
  }

  Future<void> _rejectLicense() async {
    final t = context.t;
    final admin = AppScope.of(context).admin;
    final reason = await _askReason(context, t.rejectLicense, [
      t.licenseRejectReasonNotOwner,
      t.rejectReasonBlurry,
      t.rejectReasonUnreadable,
      t.licenseRejectReasonExpired,
    ]);
    if (reason == null || !mounted) return;
    await _act(() => admin.rejectLicense(_user, reason), t.licenseRejected);
  }

  Future<void> _deleteLicense() async {
    final t = context.t;
    final admin = AppScope.of(context).admin;
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.deleteLicense),
        content: Text(t.deleteLicenseBody(_user.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            key: const Key('confirm-delete-license'),
            style: FilledButton.styleFrom(
              backgroundColor: context.palette.errorText,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    await _act(() => admin.deleteLicense(_user), t.licenseDeleted);
  }

  Future<void> _editLicense() async {
    final t = context.t;
    final fields = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _LicenseEditSheet(user: _user),
    );
    if (fields == null || !mounted) return;
    final admin = AppScope.of(context).admin;
    await _act(() => admin.updateLicense(_user, fields), t.licenseUpdated);
  }

  Future<void> _revokeIdentity() async {
    final t = context.t;
    final admin = AppScope.of(context).admin;
    final reason = await _askReason(
      context,
      t.revokeIdentityTitle,
      [
        t.rejectReasonBlurry,
        t.rejectReasonUnreadable,
        t.rejectReasonNameMismatch,
        t.rejectReasonNotCin,
        t.rejectReasonFaceMismatch,
      ],
      hint: t.revokeIdentityBody,
      confirm: t.revokeIdentity,
    );
    if (reason == null || !mounted) return;
    await _act(() => admin.revokeIdentity(_user, reason), t.identityRevoked);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final isMe = AppScope.of(context).users.currentUser?.id == _user.id;
    return Scaffold(
      key: const Key('account-file'),
      appBar: AppBar(title: Text(t.accountFileTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (error != null) ...[
                ErrorBanner(error!),
                const SizedBox(height: 12),
              ],
              _accountPanel(context, isMe),
              if (_user.role == UserRole.driver) ...[
                _licensePanel(context),
                _identityPanel(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountPanel(BuildContext context, bool isMe) {
    final t = context.t;
    final p = context.palette;
    return _Panel(
      title: t.sectionAccount,
      children: [
        Row(
          children: [
            InitialAvatar(_user.firstName, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  Text(_user.email, style: TextStyle(color: p.textMuted)),
                  Text(
                    ltr(_user.phone),
                    style: TextStyle(
                      color: p.textMuted,
                      fontFamily: AppFonts.mono,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            roleChip(context, _user.role),
            StatusChip(
              label: _user.active ? t.statusActive : t.statusSuspended,
              background: _user.active ? p.successBg : p.errorBg,
              foreground: _user.active ? p.successText : p.errorText,
            ),
            if (_user.companyName != null)
              StatusChip(
                label: _user.companyName!,
                background: p.surfaceAlt,
                foreground: p.text,
                icon: Icons.apartment_outlined,
              ),
          ],
        ),
        // Un administrateur ne modifie pas son propre compte.
        if (!isMe) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: busy ? null : _changeRole,
                icon: const Icon(Icons.badge_outlined, size: 18),
                label: Text(t.changeRole),
              ),
              OutlinedButton.icon(
                key: const Key('toggle-active'),
                onPressed: busy ? null : _toggleActive,
                style: _user.active
                    ? OutlinedButton.styleFrom(foregroundColor: p.errorText)
                    : null,
                icon: Icon(
                  _user.active
                      ? Icons.block_outlined
                      : Icons.check_circle_outline,
                  size: 18,
                ),
                label: Text(
                  _user.active ? t.suspendAccount : t.reactivateAccount,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _licensePanel(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final admin = AppScope.of(context).admin;
    final license = _user.license;
    final reading = license.reading;
    final hasLicense =
        _user.licensePhotoId != null || _user.licenseNumber != null;
    final details = [
      ?_user.licenseNumber,
      ?_user.licenseCategory,
      if (_user.licenseIssuedAt != null)
        t.licenseIssuedOn(formatDate(context, _user.licenseIssuedAt!)),
    ];
    return _Panel(
      key: const Key('license-panel'),
      title: t.sectionLicense,
      chip: licenseChip(context, license.status),
      children: [
        if (license.status == LicenseStatus.rejected &&
            license.rejectionReason != null)
          _Note(
            text: t.identityRejectedReason(license.rejectionReason!),
            color: p.errorText,
            background: p.errorBg,
          ),
        if (!hasLicense)
          Text(t.noLicense, style: TextStyle(color: p.textMuted))
        else ...[
          if (details.isNotEmpty)
            Text(
              details.join(' · '),
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontFamily: AppFonts.mono,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (_user.licensePhotoId != null) ...[
            const SizedBox(height: 10),
            IdentityPhotoFrame(user: _user, photo: UserPhoto.license),
          ],
          if (reading != null) ...[
            const SizedBox(height: 14),
            LicenseChecklist(reading: reading),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (license.status != LicenseStatus.verified)
                FilledButton.icon(
                  key: const Key('approve-license'),
                  onPressed: busy
                      ? null
                      : () => _act(
                          () => admin.approveLicense(_user),
                          t.licenseApproved,
                        ),
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(t.approveLicense),
                ),
              OutlinedButton.icon(
                key: const Key('reject-license'),
                onPressed: busy ? null : _rejectLicense,
                style: OutlinedButton.styleFrom(foregroundColor: p.errorText),
                icon: const Icon(Icons.close, size: 18),
                label: Text(t.rejectLicense),
              ),
              OutlinedButton.icon(
                key: const Key('admin-edit-license'),
                onPressed: busy ? null : _editLicense,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(t.edit),
              ),
              TextButton.icon(
                key: const Key('delete-license'),
                onPressed: busy ? null : _deleteLicense,
                style: TextButton.styleFrom(foregroundColor: p.errorText),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(t.deleteLicense),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _identityPanel(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final admin = AppScope.of(context).admin;
    final identity = _user.identity;
    final document = identity.documentType;
    final hasDocuments = identity.frontId != null || identity.backId != null;
    final canRevoke =
        identity.status == IdentityStatus.verified ||
        identity.status == IdentityStatus.pending;
    return _Panel(
      key: const Key('identity-panel'),
      title: t.sectionIdentity,
      chip: identity.blocked
          ? StatusChip(
              label: t.identityBlockedChip,
              background: p.errorBg,
              foreground: p.errorText,
              icon: Icons.block,
            )
          : identityChip(context, identity.status),
      children: [
        if (identity.status == IdentityStatus.rejected &&
            identity.rejectionReason != null)
          _Note(
            text: t.identityRejectedReason(identity.rejectionReason!),
            color: p.errorText,
            background: p.errorBg,
          ),
        if (identity.status != IdentityStatus.unverified &&
            identity.cinNumber != null)
          Text(
            '${document.labelIn(t)} · ${identity.cinNumber}',
            style: const TextStyle(
              fontFamily: AppFonts.mono,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (identity.faceMatch != null || identity.autoVerified) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (identity.autoVerified &&
                  identity.status == IdentityStatus.verified)
                StatusChip(
                  label: t.identityVerifiedByAi,
                  background: p.primaryTint,
                  foreground: p.primaryText,
                  icon: Icons.auto_awesome,
                ),
              if (identity.faceMatch != null) aiMatchChip(context, identity),
            ],
          ),
        ],
        if (identity.checks != null) ...[
          const SizedBox(height: 12),
          IdentityChecklist(identity: identity),
        ],
        if (!hasDocuments)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              t.noIdentityDocuments,
              style: TextStyle(color: p.textMuted),
            ),
          )
        else
          for (final (photo, label) in [
            if (identity.frontId != null)
              (UserPhoto.cinFront, document.frontLabel(t)),
            if (identity.selfieId != null) (UserPhoto.selfie, t.selfieLabel),
            if (identity.backId != null)
              (UserPhoto.cinBack, document.backLabel(t)),
          ]) ...[
            const SizedBox(height: 14),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            IdentityPhotoFrame(user: _user, photo: photo),
          ],
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (canRevoke)
              OutlinedButton.icon(
                key: const Key('revoke-identity'),
                onPressed: busy ? null : _revokeIdentity,
                style: OutlinedButton.styleFrom(foregroundColor: p.errorText),
                icon: const Icon(Icons.gpp_bad_outlined, size: 18),
                label: Text(t.revokeIdentity),
              ),
            if (identity.blocked || identity.waiting)
              OutlinedButton.icon(
                onPressed: busy
                    ? null
                    : () => _act(() async {
                        await admin.unblockIdentity(_user);
                        return admin.fetchUser(_user.id);
                      }, t.identityUnblocked),
                icon: const Icon(Icons.lock_open, size: 18),
                label: Text(t.unblockIdentity),
              ),
          ],
        ),
        AttemptHistoryButton(user: _user),
      ],
    );
  }
}

/// Bloc du dossier : titre, pastille d'état, contenu.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.children,
    this.chip,
    super.key,
  });

  final String title;
  final Widget? chip;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titre et état sur une ligne, l'état passe dessous si la place
          // manque.
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: context.palette.textMuted,
                ),
              ),
              ?chip,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );
}

class _Note extends StatelessWidget {
  const _Note({
    required this.text,
    required this.color,
    required this.background,
  });

  final String text;
  final Color color, background;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.input),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w600),
    ),
  );
}

/// Motif d'une décision : motifs courants, ou texte libre.
Future<String?> _askReason(
  BuildContext context,
  String title,
  List<String> reasons, {
  String? hint,
  String? confirm,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _ReasonSheet(
    title: title,
    reasons: reasons,
    hint: hint,
    confirm: confirm,
  ),
);

class _ReasonSheet extends StatefulWidget {
  const _ReasonSheet({
    required this.title,
    required this.reasons,
    this.hint,
    this.confirm,
  });

  final String title;
  final List<String> reasons;
  final String? hint, confirm;

  @override
  State<_ReasonSheet> createState() => _ReasonSheetState();
}

class _ReasonSheetState extends State<_ReasonSheet> {
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
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
          if (widget.hint != null) ...[
            const SizedBox(height: 6),
            Text(
              widget.hint!,
              style: TextStyle(color: context.palette.textMuted, height: 1.4),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            t.reasonLabel,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in [...widget.reasons, t.otherReason])
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
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('confirm-reason'),
            style: FilledButton.styleFrom(
              backgroundColor: context.palette.errorText,
            ),
            onPressed: reason == null || reason.length < 3
                ? null
                : () => Navigator.pop(context, reason),
            child: Text(widget.confirm ?? t.reject),
          ),
        ],
      ),
    );
  }
}

/// Correction du permis par l'administrateur : numéro, catégories, date.
class _LicenseEditSheet extends StatefulWidget {
  const _LicenseEditSheet({required this.user});
  final AppUser user;

  @override
  State<_LicenseEditSheet> createState() => _LicenseEditSheetState();
}

class _LicenseEditSheetState extends State<_LicenseEditSheet> {
  late final _number = TextEditingController(
    text: widget.user.licenseNumber ?? '',
  );
  late final _categories = {
    for (final c in (widget.user.licenseCategory ?? '').split(','))
      if (c.trim().isNotEmpty) c.trim(),
  };
  late String? _issuedAt = widget.user.licenseIssuedAt;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: now,
      initialDate: DateTime.tryParse(_issuedAt ?? '') ?? now,
    );
    if (picked != null) {
      setState(() => _issuedAt = picked.toIso8601String().substring(0, 10));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.editLicenseTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: t.licenseNumberLabel,
              controller: _number,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 14),
            Text(
              t.licenseCategoryLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: p.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in licenseCategories)
                  FilterChip(
                    label: Text(category),
                    selected: _categories.contains(category),
                    onSelected: (on) => setState(
                      () => on
                          ? _categories.add(category)
                          : _categories.remove(category),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                _issuedAt == null
                    ? t.licenseIssuedLabel
                    : t.licenseIssuedOn(formatDate(context, _issuedAt!)),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              key: const Key('save-admin-license'),
              onPressed: () => Navigator.pop(context, {
                'licenseNumber': _number.text.trim(),
                'licenseCategory': licenseCategories
                    .where(_categories.contains)
                    .join(', '),
                'licenseIssuedAt': _issuedAt ?? '',
              }),
              child: Text(t.save),
            ),
          ],
        ),
      ),
    );
  }
}
