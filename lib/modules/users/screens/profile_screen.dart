import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/screens/otp_screen.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';
import 'package:mon_constat_digital/shared/navigation.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with FormActions {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _licenseNumber = TextEditingController();
  final _licenseCategory = TextEditingController();
  final _licenseIssuedAt = TextEditingController();
  AppLanguage _language = AppLanguage.fr;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = AppScope.of(context).users.currentUser;
    if (_ready || user == null) return;
    _ready = true;
    _firstName.text = user.firstName;
    _lastName.text = user.lastName;
    _phone.text = user.phone;
    _licenseNumber.text = user.licenseNumber ?? '';
    _licenseCategory.text = user.licenseCategory ?? '';
    _licenseIssuedAt.text = user.licenseIssuedAt ?? '';
    _language = user.language;
  }

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _phone,
      _licenseNumber,
      _licenseCategory,
      _licenseIssuedAt,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickIssueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: now,
      initialDate: DateTime.tryParse(_licenseIssuedAt.text) ?? now,
    );
    if (picked != null) {
      _licenseIssuedAt.text = picked.toIso8601String().substring(0, 10);
    }
  }

  void _save() {
    final users = AppScope.of(context).users;
    final messenger = ScaffoldMessenger.of(context);
    submit(() async {
      await users.updateProfile({
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'phone': _phone.text.trim(),
        'language': _language.apiValue,
        'licenseNumber': _licenseNumber.text.trim(),
        'licenseCategory': _licenseCategory.text.trim(),
        'licenseIssuedAt': _licenseIssuedAt.text.trim(),
      });
      // Le numéro enregistré peut être normalisé par l'API (+216).
      _phone.text = users.currentUser?.phone ?? _phone.text;
      messenger.showSnackBar(
        const SnackBar(content: Text('Profil enregistré')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final users = AppScope.of(context).users;
    final user = users.currentUser;
    if (user == null) return const SizedBox.shrink();
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PageHead(
                  'Mon profil',
                  subtitle: 'Identité, permis et préférences',
                ),
                const SizedBox(height: 8),
                _IdentityCard(user: user),
                const SizedBox(height: 16),
                if (error != null) ...[
                  ErrorBanner(error!),
                  const SizedBox(height: 14),
                ],
                LabeledField(
                  label: 'Prénom',
                  controller: _firstName,
                  validator: Validators.required,
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: 'Nom',
                  controller: _lastName,
                  validator: Validators.required,
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: 'Téléphone',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 8),
                _PhoneStatus(verified: user.phoneVerified),
                const SizedBox(height: 22),
                const _SectionTitle('Permis de conduire'),
                const SizedBox(height: 10),
                LabeledField(
                  label: 'N° de permis',
                  controller: _licenseNumber,
                  style: const TextStyle(
                    fontFamily: AppFonts.mono,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 14),
                LabeledField(label: 'Catégorie', controller: _licenseCategory),
                const SizedBox(height: 14),
                LabeledField(
                  label: 'Date de délivrance',
                  controller: _licenseIssuedAt,
                  readOnly: true,
                  onTap: _pickIssueDate,
                  hint: 'AAAA-MM-JJ',
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                  style: const TextStyle(
                    fontFamily: AppFonts.mono,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 22),
                const _SectionTitle('Préférences'),
                const SizedBox(height: 10),
                DropdownButtonFormField<AppLanguage>(
                  initialValue: _language,
                  decoration: const InputDecoration(labelText: 'Langue'),
                  items: [
                    for (final language in AppLanguage.values)
                      DropdownMenuItem(
                        value: language,
                        child: Text(language.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _language = value);
                  },
                ),
                const SizedBox(height: 22),
                BusyButton(label: 'Enregistrer', busy: busy, onPressed: _save),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: users.logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Se déconnecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title.toUpperCase(),
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      color: AppColors.textMuted,
    ),
  );
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: Text(
              user.firstName.characters.first.toUpperCase(),
              style: const TextStyle(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.companyName == null
                      ? user.role.label
                      : '${user.role.label} • ${user.companyName}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _PhoneStatus extends StatelessWidget {
  const _PhoneStatus({required this.verified});
  final bool verified;

  @override
  Widget build(BuildContext context) {
    if (verified) {
      return const Row(
        children: [
          Icon(Icons.verified_outlined, size: 16, color: AppColors.successText),
          SizedBox(width: 6),
          Text(
            'Numéro vérifié',
            style: TextStyle(
              color: AppColors.successText,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Numéro non vérifié',
              style: TextStyle(
                color: AppColors.warningText,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () => open(context, const OtpScreen(sendOnOpen: true)),
            child: const Text(
              'Vérifier',
              style: TextStyle(color: AppColors.warningText),
            ),
          ),
        ],
      ),
    );
  }
}
