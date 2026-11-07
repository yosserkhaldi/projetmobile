import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:printing/printing.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/screens/identity_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/otp_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/security_screen.dart';
import 'package:mon_constat_digital/modules/users/services/data_export_pdf.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';
import 'package:mon_constat_digital/modules/users/widgets/user_photo.dart';
import 'package:mon_constat_digital/shared/navigation.dart';

/// Catégories du permis tunisien.
const licenseCategories = [
  'A1',
  'A',
  'B',
  'B+E',
  'C',
  'C+E',
  'D',
  'D1',
  'D+E',
  'H',
];

/// Profil en sections. Chaque section se modifie dans sa propre feuille.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final users = AppScope.of(context).users;
    final user = users.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                if (Navigator.canPop(context)) const BackButton(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 4),
                    child: Text(
                      t.profileTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ProfileHeader(user: user),
            const SizedBox(height: 22),
            _Section(
              title: t.sectionIdentity,
              editKey: const Key('edit-identity'),
              onEdit: () => _showSheet(context, _IdentitySheet(user: user)),
              children: [
                _InfoRow(
                  icon: Icons.person_outline,
                  label: t.fullNameLabel,
                  value: user.name,
                ),
                _InfoRow(
                  icon: Icons.mail_outline,
                  label: t.emailLabel,
                  value: ltr(user.email),
                  trailing: Tooltip(
                    message: t.emailNotEditable,
                    child: Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: context.palette.textMuted,
                    ),
                  ),
                ),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: t.phoneLabel,
                  value: ltr(user.phone),
                  mono: true,
                ),
              ],
            ),
            _Section(
              title: t.sectionLicense,
              editKey: const Key('edit-license'),
              onEdit: () => _showSheet(context, _LicenseSheet(user: user)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LicenseCard(user: user),
                      const SizedBox(height: 12),
                      _LicensePhoto(user: user),
                    ],
                  ),
                ),
              ],
            ),
            if (user.role == UserRole.driver)
              _Section(
                title: t.identityTitle,
                children: [
                  InkWell(
                    key: const Key('open-identity'),
                    onTap: () => open(context, const IdentityScreen()),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: IdentityStatusBanner(identity: user.identity),
                    ),
                  ),
                ],
              ),
            _Section(
              title: t.sectionSecurity,
              children: [
                _PhoneVerification(verified: user.phoneVerified),
                if (users.biometricAvailable) const _BiometricSwitch(),
                ListTile(
                  leading: Icon(
                    Icons.devices_outlined,
                    color: context.palette.primaryText,
                  ),
                  title: Text(
                    t.securityDevicesTitle,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(t.loginHistoryTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => open(context, const SecurityScreen()),
                ),
              ],
            ),
            _Section(
              title: t.sectionPreferences,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.translate,
                    color: context.palette.primaryText,
                  ),
                  title: Text(
                    t.languageLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        users.language.label,
                        style: TextStyle(color: context.palette.textMuted),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => _showSheet(context, const _LanguageSheet()),
                ),
                ListTile(
                  leading: Icon(
                    Icons.contrast,
                    color: context.palette.primaryText,
                  ),
                  title: Text(
                    t.appearanceLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _themeLabel(t, users.themeMode),
                        style: TextStyle(color: context.palette.textMuted),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => _showSheet(context, const _ThemeSheet()),
                ),
              ],
            ),
            _Section(
              title: t.sectionPrivacy,
              children: [
                const _ExportDataTile(),
                if (user.role != UserRole.admin)
                  ListTile(
                    key: const Key('delete-account'),
                    leading: Icon(
                      Icons.delete_forever_outlined,
                      color: context.palette.errorText,
                    ),
                    title: Text(
                      t.deleteAccount,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.palette.errorText,
                      ),
                    ),
                    subtitle: Text(t.deleteAccountSubtitle),
                    onTap: () =>
                        _showSheet(context, const _DeleteAccountSheet()),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: users.logout,
              style: TextButton.styleFrom(
                foregroundColor: context.palette.errorText,
                minimumSize: const Size.fromHeight(52),
              ),
              icon: const Icon(Icons.logout),
              label: Text(
                t.logout,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showSheet(BuildContext context, Widget sheet) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.palette.canvas,
      builder: (_) => sheet,
    );

/// Part du profil remplie : utile au constat, qui reprend ces informations.
double profileCompletion(AppUser user) {
  final items = [
    user.photoId != null,
    user.phoneVerified,
    user.licenseNumber != null,
    user.licenseCategory != null,
    user.licenseIssuedAt != null,
    user.licensePhotoId != null,
    // Exigée pour signer un constat (seuls les conducteurs la font vérifier).
    if (user.role == UserRole.driver)
      user.identity.status == IdentityStatus.verified,
  ];
  return items.where((done) => done).length / items.length;
}

String formatDate(BuildContext context, String isoDate) {
  final date = DateTime.tryParse(isoDate);
  if (date == null) return isoDate;
  return DateFormat.yMMMMd(context.t.localeName).format(date);
}

// ---------------------------------------------------------------------------
// En-tête

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final completion = profileCompletion(user);
    final percent = (completion * 100).round();
    final role = user.companyName == null
        ? user.role.labelIn(t)
        : '${user.role.labelIn(t)} · ${user.companyName}';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.palette.hero,
        borderRadius: BorderRadius.circular(AppRadius.hero),
      ),
      child: Stack(
        children: [
          // Anneau décoratif de la maquette, en partie hors du cadre.
          PositionedDirectional(
            end: -60,
            top: -70,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: context.palette.heroRing, width: 28),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Avatar(user: user),
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
                              letterSpacing: -0.4,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            role,
                            style: const TextStyle(
                              color: AppColors.onDarkStrong,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _Pill(
                            icon: user.phoneVerified
                                ? Icons.verified_outlined
                                : Icons.error_outline,
                            label: user.phoneVerified
                                ? t.phoneVerified
                                : t.phoneNotVerified,
                            color: user.phoneVerified
                                ? const Color(0xFF7FE0CC)
                                : AppColors.accent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  t.profileCompletion(percent),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completion,
                    minHeight: 6,
                    color: AppColors.accent,
                    backgroundColor: context.palette.heroTrack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  completion == 1 ? t.profileComplete : t.profileCompleteHint,
                  style: const TextStyle(
                    color: AppColors.onDarkBody,
                    fontSize: 12,
                    height: 1.4,
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.t.changeProfilePhoto,
    child: InkWell(
      onTap: () => changePhoto(context, UserPhoto.profile),
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 68,
              height: 68,
              color: context.palette.heroTrack,
              child: UserPhotoView(
                user: user,
                photo: UserPhoto.profile,
                placeholder: Center(
                  child: Text(
                    user.firstName.characters.first.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: -4,
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: context.palette.hero, width: 2),
              ),
              child: const Icon(
                Icons.photo_camera,
                size: 13,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: context.palette.heroRing,
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Sections

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
    this.onEdit,
    this.editKey,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback? onEdit;
  final Key? editKey;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: context.palette.textMuted,
                  ),
                ),
              ),
              if (onEdit != null)
                TextButton.icon(
                  key: editKey,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(
                    context.t.edit,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i += 1) ...[
                if (i > 0)
                  Divider(height: 1, color: context.palette.surfaceAlt),
                children[i],
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.mono = false,
  });

  final IconData icon;
  final String label, value;
  final Widget? trailing;
  final bool mono;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: context.palette.primaryText),
    title: Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: context.palette.textMuted,
      ),
    ),
    subtitle: Text(
      value,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: context.palette.text,
        fontFamily: mono ? AppFonts.mono : null,
      ),
    ),
    trailing: trailing,
  );
}

class _LicenseCard extends StatelessWidget {
  const _LicenseCard({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (user.licenseNumber == null &&
        user.licenseCategory == null &&
        user.licenseIssuedAt == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.licenseEmpty,
            style: TextStyle(color: context.palette.textMuted, height: 1.4),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _showSheet(context, _LicenseSheet(user: user)),
            icon: const Icon(Icons.badge_outlined),
            label: Text(t.addLicense),
          ),
        ],
      );
    }
    final categories = (user.licenseCategory ?? '')
        .split(',')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.licenseCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.sectionLicense.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.onPrimaryMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Icon(Icons.badge_outlined, color: AppColors.onPrimaryMuted),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            user.licenseNumber ?? t.notProvided,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontFamily: AppFonts.mono,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final category in categories)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.palette.licenseChip,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (user.licenseIssuedAt != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4),
                  child: Text(
                    t.licenseIssuedOn(
                      formatDate(context, user.licenseIssuedAt!),
                    ),
                    style: const TextStyle(
                      color: AppColors.onPrimaryMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LicensePhoto extends StatelessWidget {
  const _LicensePhoto({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final hasPhoto = user.licensePhotoId != null;
    return InkWell(
      onTap: () => changePhoto(context, UserPhoto.license),
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Container(
        height: hasPhoto ? 170 : 52,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: hasPhoto
              ? context.palette.surface
              : context.palette.primaryTint,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: context.palette.primaryText, width: 1.5),
        ),
        child: hasPhoto
            ? Stack(
                fit: StackFit.expand,
                children: [
                  UserPhotoView(
                    user: user,
                    photo: UserPhoto.license,
                    placeholder: const SizedBox.shrink(),
                  ),
                  PositionedDirectional(
                    end: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        t.replace,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.document_scanner_outlined,
                    color: context.palette.primaryText,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      t.licensePhotoAdd,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.palette.primaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PhoneVerification extends StatelessWidget {
  const _PhoneVerification({required this.verified});
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return ListTile(
      leading: Icon(
        verified ? Icons.verified_user_outlined : Icons.sms_outlined,
        color: verified
            ? context.palette.successText
            : context.palette.warningText,
      ),
      title: Text(
        verified ? t.phoneVerified : t.phoneNotVerified,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      trailing: verified
          ? null
          : FilledButton.tonal(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
              onPressed: () => open(context, const OtpScreen(sendOnOpen: true)),
              child: Text(t.verify),
            ),
    );
  }
}

class _BiometricSwitch extends StatefulWidget {
  const _BiometricSwitch();

  @override
  State<_BiometricSwitch> createState() => _BiometricSwitchState();
}

class _BiometricSwitchState extends State<_BiometricSwitch> {
  bool _busy = false;

  Future<void> _toggle(bool enable) async {
    final t = context.t;
    final users = AppScope.of(context).users;
    final messenger = ScaffoldMessenger.of(context);
    String describe(Object error) => errorMessage(context, error);
    setState(() => _busy = true);
    try {
      if (enable) {
        if (await users.enableBiometric(t.biometricEnableReason)) {
          messenger.showSnackBar(SnackBar(content: Text(t.biometricEnabled)));
        }
      } else {
        await users.disableBiometric();
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describe(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => SwitchListTile(
    secondary: Icon(Icons.fingerprint, color: context.palette.primaryText),
    value: AppScope.of(context).users.biometricEnabled,
    onChanged: _busy ? null : _toggle,
    title: Text(
      context.t.biometricTitle,
      style: const TextStyle(fontWeight: FontWeight.w700),
    ),
    subtitle: Text(context.t.biometricSubtitle),
  );
}

// ---------------------------------------------------------------------------
// Feuilles de modification

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
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
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );
}

class _IdentitySheet extends StatefulWidget {
  const _IdentitySheet({required this.user});
  final AppUser user;

  @override
  State<_IdentitySheet> createState() => _IdentitySheetState();
}

class _IdentitySheetState extends State<_IdentitySheet> with FormActions {
  late final _firstName = TextEditingController(text: widget.user.firstName);
  late final _lastName = TextEditingController(text: widget.user.lastName);
  late final _phone = TextEditingController(text: widget.user.phone);

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    final users = AppScope.of(context).users;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final saved = context.t.profileSaved;
    submit(() async {
      await users.updateProfile({
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'phone': _phone.text.trim(),
      });
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(saved)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return _SheetFrame(
      title: t.editIdentityTitle,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null) ...[
              ErrorBanner(error!),
              const SizedBox(height: 14),
            ],
            LabeledField(
              label: t.firstNameLabel,
              controller: _firstName,
              validator: validators.required,
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: t.lastNameLabel,
              controller: _lastName,
              validator: validators.required,
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: t.phoneLabel,
              controller: _phone,
              keyboardType: TextInputType.phone,
              validator: validators.phone,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 6),
            Text(
              t.phoneChangeNotice,
              style: TextStyle(fontSize: 12, color: context.palette.textMuted),
            ),
            const SizedBox(height: 20),
            BusyButton(label: t.save, busy: busy, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _LicenseSheet extends StatefulWidget {
  const _LicenseSheet({required this.user});
  final AppUser user;

  @override
  State<_LicenseSheet> createState() => _LicenseSheetState();
}

class _LicenseSheetState extends State<_LicenseSheet> with FormActions {
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

  void _save() {
    final users = AppScope.of(context).users;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final saved = context.t.profileSaved;
    // Ordre officiel des catégories, quel que soit l'ordre des clics.
    final categories = licenseCategories.where(_categories.contains).join(', ');
    submit(() async {
      await users.updateProfile({
        'licenseNumber': _number.text.trim(),
        'licenseCategory': categories,
        'licenseIssuedAt': _issuedAt ?? '',
      });
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(saved)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return _SheetFrame(
      title: t.editLicenseTitle,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null) ...[
              ErrorBanner(error!),
              const SizedBox(height: 14),
            ],
            LabeledField(
              label: t.licenseNumberLabel,
              controller: _number,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontFamily: AppFonts.mono,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              t.licenseCategoryLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.palette.textMuted,
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
                    showCheckmark: false,
                    selectedColor: context.palette.text,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _categories.contains(category)
                          ? Colors.white
                          : context.palette.text,
                    ),
                    onSelected: (on) => setState(
                      () => on
                          ? _categories.add(category)
                          : _categories.remove(category),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              t.licenseIssuedLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.palette.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              key: const Key('license-date'),
              onPressed: _pickDate,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.palette.border, width: 1.5),
                alignment: AlignmentDirectional.centerStart,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
              ),
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                _issuedAt == null
                    ? t.notProvided
                    : formatDate(context, _issuedAt!),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 20),
            BusyButton(label: t.save, busy: busy, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context) {
    final users = AppScope.of(context).users;
    final messenger = ScaffoldMessenger.of(context);
    return _SheetFrame(
      title: context.t.languageLabel,
      child: Column(
        children: [
          for (final language in AppLanguage.values)
            ListTile(
              title: Text(
                language.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: users.language == language
                  ? Icon(Icons.check_circle, color: context.palette.primaryText)
                  : null,
              onTap: () async {
                const describe = errorMessage;
                final sheetContext = context;
                Navigator.pop(context);
                try {
                  await users.setLanguage(language);
                } catch (e) {
                  if (sheetContext.mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(describe(sheetContext, e))),
                    );
                  }
                }
              },
            ),
        ],
      ),
    );
  }
}

String _themeLabel(AppLocalizations t, ThemeMode mode) => switch (mode) {
  ThemeMode.system => t.themeSystem,
  ThemeMode.light => t.themeLight,
  ThemeMode.dark => t.themeDark,
};

class _ThemeSheet extends StatelessWidget {
  const _ThemeSheet();

  static const _icons = {
    ThemeMode.system: Icons.brightness_auto_outlined,
    ThemeMode.light: Icons.light_mode_outlined,
    ThemeMode.dark: Icons.dark_mode_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final users = AppScope.of(context).users;
    return _SheetFrame(
      title: t.appearanceLabel,
      child: Column(
        children: [
          for (final mode in ThemeMode.values)
            ListTile(
              leading: Icon(_icons[mode]),
              title: Text(
                _themeLabel(t, mode),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: users.themeMode == mode
                  ? Icon(Icons.check_circle, color: context.palette.primaryText)
                  : null,
              onTap: () {
                Navigator.pop(context);
                users.setThemeMode(mode);
              },
            ),
        ],
      ),
    );
  }
}

class _ExportDataTile extends StatefulWidget {
  const _ExportDataTile();

  @override
  State<_ExportDataTile> createState() => _ExportDataTileState();
}

class _ExportDataTileState extends State<_ExportDataTile> {
  bool _busy = false;

  Future<void> _export() async {
    final users = AppScope.of(context).users;
    final messenger = ScaffoldMessenger.of(context);
    String describe(Object error) => errorMessage(context, error);
    setState(() => _busy = true);
    try {
      final pdf = await buildDataExportPdf(await users.exportData());
      // Feuille de partage du téléphone : enregistrer, envoyer par e-mail…
      await Printing.sharePdf(
        bytes: pdf,
        filename: 'mes-donnees-mon-constat.pdf',
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describe(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListTile(
    key: const Key('export-data'),
    leading: Icon(Icons.download_outlined, color: context.palette.primaryText),
    title: Text(
      context.t.exportData,
      style: const TextStyle(fontWeight: FontWeight.w700),
    ),
    subtitle: Text(context.t.exportDataSubtitle),
    trailing: _busy
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.chevron_right),
    onTap: _busy ? null : _export,
  );
}

class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet();

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet>
    with FormActions {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _delete() {
    final users = AppScope.of(context).users;
    final messenger = ScaffoldMessenger.of(context);
    final done = context.t.accountDeleted;
    submit(() async {
      // La déconnexion ferme déjà tous les écrans, cette feuille comprise.
      await users.deleteAccount(_password.text);
      messenger.showSnackBar(SnackBar(content: Text(done)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    return _SheetFrame(
      title: t.deleteAccountTitle,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.errorBg,
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Text(
                t.deleteAccountBody,
                style: TextStyle(color: p.errorText, height: 1.45),
              ),
            ),
            const SizedBox(height: 14),
            if (error != null) ...[
              ErrorBanner(error!),
              const SizedBox(height: 14),
            ],
            PasswordField(
              label: t.passwordLabel,
              controller: _password,
              validator: validators.required,
            ),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('confirm-delete'),
              onPressed: busy ? null : _delete,
              style: FilledButton.styleFrom(backgroundColor: p.errorText),
              child: Text(t.deleteAccountConfirm),
            ),
          ],
        ),
      ),
    );
  }
}
