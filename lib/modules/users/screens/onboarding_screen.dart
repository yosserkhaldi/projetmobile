import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/models/license_reading.dart';
import 'package:mon_constat_digital/modules/users/screens/identity_screen.dart';
import 'package:mon_constat_digital/modules/users/screens/profile_screen.dart'
    show formatDate, licenseCategories;
import 'package:mon_constat_digital/modules/users/state/user_store.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';
import 'package:mon_constat_digital/modules/users/widgets/user_photo.dart';

/// Accueil après l'inscription : bienvenue, nom et téléphone (obligatoires),
/// code reçu par WhatsApp, permis, identité, connexion biométrique, puis un
/// récapitulatif. À partir du code, chaque étape se passe ; ce qui reste se
/// termine depuis le profil. Interrompu, il reprend au prochain lancement
/// (UserStore.needsOnboarding).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Step { welcome, profile, phone, license, identity, biometric, done }

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = PageController();
  List<_Step>? _stepsCache;
  int _index = 0;

  /// L'étape biométrique n'apparaît que si le téléphone a un capteur.
  List<_Step> get _steps => _stepsCache ??= [
    _Step.welcome,
    _Step.profile,
    _Step.phone,
    _Step.license,
    _Step.identity,
    if (AppScope.of(context).users.biometricAvailable) _Step.biometric,
    _Step.done,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppScope.of(context).users.keepOnboarding();
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int index) {
    if (index < 0 || index >= _steps.length || index == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = index);
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(index);
    } else {
      _pages.animateToPage(
        index,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _next() => _go(_index + 1);

  /// Nom et téléphone d'abord : rien ne se passe tant qu'ils manquent.
  bool get _canSkip =>
      AppScope.of(context).users.currentUser?.profileComplete ?? false;

  void _toSummary() {
    if (_canSkip) _go(_steps.length - 1);
  }

  Future<void> _finish() async {
    HapticFeedback.lightImpact();
    await AppScope.of(context).users.finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    final middle = steps.length - 2;
    final onStep = _index > 0 && _index < steps.length - 1;
    return PopScope(
      // Retour du téléphone : étape précédente.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(_index - 1);
      },
      child: Scaffold(
        key: const Key('onboarding'),
        backgroundColor: context.palette.canvas,
        body: Stack(
          children: [
            PageView(
              controller: _pages,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final step in steps)
                  switch (step) {
                    _Step.welcome => _WelcomePage(
                      onStart: _next,
                      onSkip: _canSkip ? _toSummary : null,
                    ),
                    _Step.profile => _ProfileStep(onDone: _next),
                    _Step.phone => _PhoneStep(onDone: _next),
                    _Step.license => _LicenseStep(onDone: _next),
                    _Step.identity => _IdentityStep(onDone: _next),
                    _Step.biometric => _BiometricStep(onDone: _next),
                    _Step.done => _DonePage(onFinish: _finish),
                  },
              ],
            ),
            // Barre fixe pendant que les étapes défilent dessous.
            PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
              child: IgnorePointer(
                ignoring: !onStep,
                child: AnimatedOpacity(
                  opacity: onStep ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: _TopBar(
                    current: _index.clamp(1, middle),
                    total: middle,
                    onBack: () => _go(_index - 1),
                    onSkip: _canSkip ? _toSummary : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bienvenue et récapitulatif : fond sombre de la marque, comme la connexion.

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onStart, required this.onSkip});
  final VoidCallback onStart;

  /// null : nom et téléphone encore à donner, rien à passer.
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final firstName =
        AppScope.of(context).users.currentUser?.firstName.split(' ').first ??
        '';
    return _DarkPage(
      content: [
        _Eyebrow(icon: Icons.check_rounded, text: t.onbWelcomeEyebrow),
        const SizedBox(height: 18),
        _DisplayTitle(
          firstName.isEmpty
              ? t.onbWelcomeNewTitle
              : t.onbWelcomeTitle(firstName),
        ),
        const SizedBox(height: 14),
        Text(
          t.onbWelcomeBody,
          style: const TextStyle(
            color: AppColors.onDarkBody,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        for (final (icon, text) in [
          (Icons.timer_outlined, t.heroPoint1),
          (Icons.draw_outlined, t.heroPoint2),
          (Icons.track_changes_outlined, t.heroPoint3),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                _DarkTile(icon: icon),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: AppColors.onDarkBody,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
      actions: [
        _AccentButton(
          key: const Key('onb-start'),
          label: t.onbWelcomeStart,
          icon: Icons.arrow_forward_rounded,
          onPressed: onStart,
        ),
        if (onSkip != null)
          TextButton(
            key: const Key('onb-skip-all'),
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.onDarkStrong,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(t.onbWelcomeSkip),
          ),
      ],
    );
  }
}

class _DonePage extends StatelessWidget {
  const _DonePage({required this.onFinish});
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final users = AppScope.of(context).users;
    final user = users.currentUser;
    if (user == null) return const SizedBox.shrink();
    final license = user.licensePhotoId != null || user.licenseNumber != null
        ? (user.license.status == LicenseStatus.toReview
              ? _State.pending
              : _State.done)
        : _State.todo;
    final identity = switch (user.identity.status) {
      IdentityStatus.verified => _State.done,
      IdentityStatus.pending => _State.pending,
      _ => _State.todo,
    };
    final items = [
      (
        Icons.phone_iphone_rounded,
        t.onbItemPhone,
        _State.of(user.phoneVerified),
      ),
      (Icons.badge_outlined, t.onbItemLicense, license),
      (Icons.verified_user_outlined, t.onbItemIdentity, identity),
      if (users.biometricAvailable)
        (
          Icons.fingerprint_rounded,
          t.onbItemBiometric,
          _State.of(users.biometricEnabled),
        ),
    ];
    final firstName = user.firstName.split(' ').first;
    return _DarkPage(
      content: [
        const _PopIn(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.accent,
            child: Icon(Icons.check_rounded, color: AppColors.ink, size: 40),
          ),
        ),
        const SizedBox(height: 22),
        _DisplayTitle(t.onbDoneTitle(firstName)),
        const SizedBox(height: 12),
        Text(
          t.onbDoneBody,
          style: const TextStyle(
            color: AppColors.onDarkBody,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          key: const Key('onb-summary'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _raised(context),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            children: [
              for (final (index, (icon, label, state)) in items.indexed) ...[
                if (index > 0) Divider(height: 1, color: _raised(context, 0.1)),
                _SummaryRow(icon: icon, label: label, state: state),
              ],
            ],
          ),
        ),
        if (items.any((item) => item.$3 == _State.todo)) ...[
          const SizedBox(height: 14),
          Text(
            t.onbDoneLater,
            style: const TextStyle(
              color: AppColors.onDarkFaint,
              fontSize: 13.5,
            ),
          ),
        ],
      ],
      actions: [
        _AccentButton(
          key: const Key('onb-finish'),
          label: t.onbDoneStart,
          icon: Icons.arrow_forward_rounded,
          onPressed: onFinish,
        ),
      ],
    );
  }
}

/// Surface un peu plus claire que le fond de la marque : anneaux, tuiles,
/// carte du récapitulatif. Calculée sur le fond pour rester visible en mode
/// sombre, où le fond est déjà bleu nuit.
Color _raised(BuildContext context, [double amount = 0.06]) => Color.alphaBlend(
  Colors.white.withValues(alpha: amount),
  context.palette.hero,
);

enum _State {
  done,
  pending,
  todo;

  static _State of(bool done) => done ? _State.done : _State.todo;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.state,
  });

  final IconData icon;
  final String label;
  final _State state;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final (stateText, stateIcon, color) = switch (state) {
      _State.done => (
        t.onbStateDone,
        Icons.check_circle_rounded,
        AppColors.accent,
      ),
      _State.pending => (
        t.onbStatePending,
        Icons.hourglass_top_rounded,
        AppColors.onDarkStrong,
      ),
      _State.todo => (
        t.onbStateTodo,
        Icons.radio_button_unchecked_rounded,
        AppColors.onDarkFaint,
      ),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.onDarkStrong, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            stateText,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Icon(stateIcon, color: color, size: 20),
        ],
      ),
    );
  }
}

/// Page sombre : anneau décoratif, contenu qui apparaît en cascade, boutons
/// en bas.
class _DarkPage extends StatelessWidget {
  const _DarkPage({required this.content, required this.actions});
  final List<Widget> content, actions;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: ColoredBox(
      color: context.palette.hero,
      child: Stack(
        children: [
          const PositionedDirectional(
            end: -110,
            top: -120,
            child: _Ring(size: 340, width: 48),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
                        child: _Cascade(children: content),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: actions,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.width});
  final double size, width;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: _raised(context), width: width),
    ),
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
      decoration: BoxDecoration(
        color: _raised(context),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    ),
  );
}

class _DisplayTitle extends StatelessWidget {
  const _DisplayTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontFamily: AppFonts.display,
      color: Colors.white,
      fontSize: 38,
      fontWeight: FontWeight.w800,
      height: 1.08,
      letterSpacing: -0.5,
    ),
  );
}

class _DarkTile extends StatelessWidget {
  const _DarkTile({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: _raised(context),
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    child: Icon(icon, color: AppColors.accent),
  );
}

class _AccentButton extends StatelessWidget {
  const _AccentButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.ink,
      minimumSize: const Size.fromHeight(56),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        if (icon != null) ...[
          const SizedBox(width: 8),
          Directionality.of(context) == TextDirection.rtl
              ? Transform.flip(flipX: true, child: Icon(icon, size: 20))
              : Icon(icon, size: 20),
        ],
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Étapes : page claire, illustration, titre, contenu, boutons en bas.

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.current,
    required this.total,
    required this.onBack,
    required this.onSkip,
  });

  final int current, total;
  final VoidCallback onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    return ColoredBox(
      color: p.canvas,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              IconButton(
                key: const Key('onb-back'),
                tooltip: t.onbBack,
                onPressed: onBack,
                icon: const BackButtonIcon(),
              ),
              Expanded(
                child: Semantics(
                  label: t.onbProgress(current, total),
                  child: Row(
                    children: [
                      for (var i = 1; i <= total; i++) ...[
                        if (i > 1) const SizedBox(width: 6),
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i <= current ? p.primary : p.border,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Place gardée : la barre ne bouge pas quand « Passer » apparaît.
              Visibility.maintain(
                visible: onSkip != null,
                child: TextButton(
                  key: const Key('onb-skip'),
                  onPressed: onSkip,
                  child: Text(t.onbSkip),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepPage extends StatelessWidget {
  const _StepPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.primary,
    this.secondary,
    this.content = const [],
    this.aiTag = false,
  });

  final IconData icon;
  final String title, body;
  final List<Widget> content;
  final Widget primary;
  final Widget? secondary;

  /// Pastille « IA » sur l'illustration.
  final bool aiTag;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 64, 24, 16),
                  child: _Cascade(
                    children: [
                      _Illustration(icon: icon, aiTag: aiTag),
                      const SizedBox(height: 26),
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppFonts.display,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: p.text,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        body,
                        style: TextStyle(
                          color: p.textMuted,
                          fontSize: 15.5,
                          height: 1.5,
                        ),
                      ),
                      if (content.isNotEmpty) const SizedBox(height: 22),
                      ...content,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    primary,
                    if (secondary != null) ...[
                      const SizedBox(height: 4),
                      secondary!,
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

/// Bandeau de la marque : anneaux, et l'icône de l'étape qui apparaît.
class _Illustration extends StatelessWidget {
  const _Illustration({required this.icon, this.aiTag = false});
  final IconData icon;
  final bool aiTag;

  @override
  Widget build(BuildContext context) => Container(
    height: 184,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: context.palette.hero,
      borderRadius: BorderRadius.circular(AppRadius.hero),
    ),
    child: Stack(
      children: [
        const PositionedDirectional(
          end: -50,
          top: -70,
          child: _Ring(size: 200, width: 30),
        ),
        const PositionedDirectional(
          start: -60,
          bottom: -90,
          child: _Ring(size: 180, width: 24),
        ),
        Center(
          child: _PopIn(
            // Halo autour du disque, plutôt qu'une ombre qui ternit le fond.
            child: Container(
              width: 124,
              height: 124,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _raised(context, 0.08),
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 42, color: AppColors.ink),
              ),
            ),
          ),
        ),
        if (aiTag)
          PositionedDirectional(
            top: 14,
            start: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _raised(context),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: AppColors.accent),
                  SizedBox(width: 5),
                  Text(
                    'IA',
                    style: TextStyle(
                      color: AppColors.onDarkStrong,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
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

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => FilledButton(
    key: const Key('onb-primary'),
    onPressed: busy ? null : onPressed,
    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
    child: busy
        ? const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          ),
  );
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    key: const Key('onb-secondary'),
    onPressed: onPressed,
    style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    child: Text(label),
  );
}

/// Bloc d'information sous le texte de l'étape.
class _Note extends StatelessWidget {
  const _Note({
    required this.icon,
    required this.text,
    this.tone = _Tone.neutral,
    super.key,
  });

  final IconData icon;
  final String text;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (bg, fg) = switch (tone) {
      _Tone.neutral => (p.surface, p.textMuted),
      _Tone.success => (p.successBg, p.successText),
      _Tone.warning => (p.warningBg, p.warningText),
      _Tone.info => (p.primaryTint, p.primaryText),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: tone == _Tone.neutral ? Border.all(color: p.borderSoft) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _Tone { neutral, success, warning, info }

// --- Nom et téléphone --------------------------------------------------------

/// Obligatoire : le nom figure sur les constats, le téléphone sert à se
/// connecter et à recevoir le suivi. Le code part dès qu'on continue.
class _ProfileStep extends StatefulWidget {
  const _ProfileStep({required this.onDone});
  final VoidCallback onDone;

  @override
  State<_ProfileStep> createState() => _ProfileStepState();
}

class _ProfileStepState extends State<_ProfileStep>
    with FormActions, AutomaticKeepAliveClientMixin {
  late final AppUser? _user = AppScope.of(context).users.currentUser;
  late final _firstName = TextEditingController(text: _user?.firstName);
  late final _lastName = TextEditingController(text: _user?.lastName);
  // Affiché sans l'indicatif, déjà devant le champ.
  late final _phone = TextEditingController(
    text: (_user?.phone ?? '').replaceFirst(RegExp(r'^\+216'), ''),
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    for (final controller in [_firstName, _lastName, _phone]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _continue() {
    final users = AppScope.of(context).users;
    final user = users.currentUser;
    submit(() async {
      final phone = _phone.text.trim();
      final changes = <String, Object?>{
        if (_firstName.text.trim() != user?.firstName)
          'firstName': _firstName.text.trim(),
        if (_lastName.text.trim() != user?.lastName)
          'lastName': _lastName.text.trim(),
        if (phone.replaceAll(' ', '') !=
            (user?.phone ?? '').replaceFirst(RegExp(r'^\+216'), ''))
          'phone': phone,
      };
      if (changes.isNotEmpty) await users.updateProfile(changes);
      // Nouveau numéro, ou pas encore vérifié : le code part maintenant.
      if (!(users.currentUser?.phoneVerified ?? true)) {
        try {
          await users.resendPhoneCode();
        } catch (_) {
          // Code déjà envoyé il y a moins d'une minute : l'étape suivante
          // permet d'en redemander un.
        }
      }
      widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final t = context.t;
    final v = validators;
    const gap = SizedBox(height: 14);
    return Form(
      key: formKey,
      child: _StepPage(
        icon: Icons.person_outline_rounded,
        title: t.onbProfileTitle,
        body: t.onbProfileBody,
        content: [
          if (error != null) ...[ErrorBanner(error!), gap],
          LabeledField(
            label: t.firstNameLabel,
            controller: _firstName,
            validator: v.required,
            prefixIcon: Icons.person_outline,
            autofillHints: const [AutofillHints.givenName],
          ),
          gap,
          LabeledField(
            label: t.lastNameLabel,
            controller: _lastName,
            validator: v.required,
            prefixIcon: Icons.badge_outlined,
            autofillHints: const [AutofillHints.familyName],
          ),
          gap,
          LabeledField(
            label: t.phoneLabel,
            controller: _phone,
            keyboardType: TextInputType.phone,
            validator: v.phone,
            hint: '20 123 456',
            prefixIcon: Icons.phone_outlined,
            prefixText: '+216',
            textDirection: TextDirection.ltr,
            autofillHints: const [AutofillHints.telephoneNumber],
          ),
          const SizedBox(height: 8),
          Text(
            t.registerPhoneHint,
            style: TextStyle(color: context.palette.textMuted, fontSize: 13),
          ),
        ],
        primary: _PrimaryButton(
          label: t.onbContinue,
          busy: busy,
          onPressed: _continue,
        ),
      ),
    );
  }
}

/// Code à 6 chiffres reçu sur WhatsApp. Peut se faire plus tard.
class _PhoneStep extends StatefulWidget {
  const _PhoneStep({required this.onDone});
  final VoidCallback onDone;

  @override
  State<_PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends State<_PhoneStep>
    with FormActions, AutomaticKeepAliveClientMixin {
  final _code = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _verify() {
    final users = AppScope.of(context).users;
    submit(() async {
      await users.verifyPhone(_code.text.trim());
      HapticFeedback.lightImpact();
      widget.onDone();
    });
  }

  Future<void> _resend() async {
    final users = AppScope.of(context).users;
    final messenger = ScaffoldMessenger.of(context);
    final sent = context.t.onbCodeSent;
    String describe(Object e) => errorMessage(context, e);
    try {
      await users.resendPhoneCode();
      messenger.showSnackBar(SnackBar(content: Text(sent)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describe(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final t = context.t;
    final user = AppScope.of(context).users.currentUser;
    final verified = user?.phoneVerified ?? false;
    return Form(
      key: formKey,
      child: _StepPage(
        icon: Icons.sms_outlined,
        title: t.onbPhoneTitle,
        body: t.otpInstructions(ltr(user?.phone ?? '')),
        content: [
          if (error != null) ...[
            ErrorBanner(error!),
            const SizedBox(height: 10),
          ],
          if (verified)
            _Note(
              key: const Key('onb-phone-verified'),
              icon: Icons.verified_rounded,
              text: t.phoneVerified,
              tone: _Tone.success,
            )
          else ...[
            LabeledField(
              label: t.otpCodeLabel,
              controller: _code,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              autofillHints: const [AutofillHints.oneTimeCode],
              validator: (value) => RegExp(r'^\d{6}$').hasMatch(value ?? '')
                  ? null
                  : t.codeFormat,
              style: const TextStyle(
                fontFamily: AppFonts.mono,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: 6,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const Key('onb-resend'),
                onPressed: busy ? null : _resend,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(t.resendCode),
              ),
            ),
          ],
        ],
        primary: verified
            ? _PrimaryButton(label: t.onbContinue, onPressed: widget.onDone)
            : _PrimaryButton(label: t.validate, busy: busy, onPressed: _verify),
        secondary: verified
            ? null
            : _SecondaryButton(label: t.onbLater, onPressed: widget.onDone),
      ),
    );
  }
}

// --- Permis -----------------------------------------------------------------

class _LicenseStep extends StatefulWidget {
  const _LicenseStep({required this.onDone});
  final VoidCallback onDone;

  @override
  State<_LicenseStep> createState() => _LicenseStepState();
}

class _LicenseStepState extends State<_LicenseStep>
    with AutomaticKeepAliveClientMixin {
  bool _scanning = false, _saving = false, _scanned = false;
  LicenseReading? _reading;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  Future<void> _scan() async {
    final users = AppScope.of(context).users;
    String describe(Object e) => errorMessage(context, e);
    final file = await pickPhoto(context);
    if (file == null || !mounted) return;
    setState(() {
      _scanning = true;
      _error = null;
    });
    try {
      final reading = await users.scanLicense(
        await file.readAsBytes(),
        file.name,
      );
      if (!mounted) return;
      HapticFeedback.lightImpact();
      setState(() {
        _reading = reading;
        _scanned = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = describe(e);
          _scanned = false;
        });
      }
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  /// Ce que l'IA a lu remplit le permis du profil, comme « Enregistrer ».
  Future<void> _continue() async {
    final reading = _reading;
    final changes = <String, Object?>{
      if (reading?.number != null) 'licenseNumber': reading!.number,
      if (reading != null && reading.categories.isNotEmpty)
        'licenseCategory': licenseCategories
            .where(reading.categories.contains)
            .join(', '),
      if (reading?.issuedAt != null) 'licenseIssuedAt': reading!.issuedAt,
    };
    if (changes.isEmpty) return widget.onDone();
    final users = AppScope.of(context).users;
    String describe(Object e) => errorMessage(context, e);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await users.updateProfile(changes);
      widget.onDone();
    } catch (e) {
      if (mounted) setState(() => _error = describe(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final t = context.t;
    final user = AppScope.of(context).users.currentUser;
    final reading = _reading;
    return _StepPage(
      icon: Icons.badge_outlined,
      aiTag: true,
      title: t.onbLicenseTitle,
      body: t.onbLicenseBody,
      content: [
        if (_error != null) ...[
          ErrorBanner(_error!),
          const SizedBox(height: 10),
        ],
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _scanning
              ? _Note(
                  key: const ValueKey('reading'),
                  icon: Icons.document_scanner_outlined,
                  text: t.onbLicenseReading,
                  tone: _Tone.info,
                )
              : !_scanned
              ? _Note(
                  key: const ValueKey('tip'),
                  icon: Icons.lightbulb_outline_rounded,
                  text: t.onbLicenseTip,
                )
              : reading == null || reading.isEmpty
              ? _Note(
                  key: const ValueKey('unread'),
                  icon: Icons.info_outline_rounded,
                  text: t.onbLicenseUnread,
                  tone: _Tone.warning,
                )
              : user == null
              ? const SizedBox.shrink()
              : _LicenseResult(user: user, reading: reading),
        ),
      ],
      primary: _scanned
          ? _PrimaryButton(
              label: t.onbContinue,
              busy: _saving,
              onPressed: _continue,
            )
          : _PrimaryButton(
              label: t.onbLicenseScan,
              icon: Icons.photo_camera_outlined,
              busy: _scanning,
              onPressed: _scan,
            ),
      secondary: _SecondaryButton(
        label: _scanned ? t.onbLicenseRescan : t.onbLater,
        onPressed: _scanning || _saving
            ? null
            : _scanned
            ? _scan
            : widget.onDone,
      ),
    );
  }
}

/// Le permis tel que l'IA l'a lu : photo, numéro, catégories, date, état.
class _LicenseResult extends StatelessWidget {
  const _LicenseResult({required this.user, required this.reading});
  final AppUser user;
  final LicenseReading reading;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final toReview = user.license.status == LicenseStatus.toReview;
    return Column(
      key: const Key('onb-license-result'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.licenseCard,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                // Cadre clair derrière la photo, visible pendant le chargement.
                child: Container(
                  width: 86,
                  height: 56,
                  color: Colors.white.withValues(alpha: 0.12),
                  child: UserPhotoView(
                    user: user,
                    photo: UserPhoto.license,
                    placeholder: const Icon(
                      Icons.badge_outlined,
                      color: AppColors.onPrimaryMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          t.onbLicenseRead.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.onPrimaryMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reading.number ?? t.notProvided,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontFamily: AppFonts.mono,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final category in reading.categories)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: p.licenseChip,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (reading.issuedAt != null)
                          Text(
                            t.licenseIssuedOn(
                              formatDate(context, reading.issuedAt!),
                            ),
                            style: const TextStyle(
                              color: AppColors.onPrimaryMuted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (toReview)
          _Note(
            icon: Icons.hourglass_top_rounded,
            text: t.licenseToReviewNote,
            tone: _Tone.warning,
          ),
      ],
    );
  }
}

// --- Identité ---------------------------------------------------------------

class _IdentityStep extends StatefulWidget {
  const _IdentityStep({required this.onDone});
  final VoidCallback onDone;

  @override
  State<_IdentityStep> createState() => _IdentityStepState();
}

class _IdentityStepState extends State<_IdentityStep>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _verify() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IdentityScreen()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final t = context.t;
    final p = context.palette;
    final user = AppScope.of(context).users.currentUser;
    final status = user?.identity.status ?? IdentityStatus.unverified;
    final sent =
        status == IdentityStatus.verified || status == IdentityStatus.pending;
    return _StepPage(
      icon: Icons.face_retouching_natural,
      aiTag: true,
      title: t.onbIdentityTitle,
      body: t.onbIdentityBody,
      content: [
        if (status == IdentityStatus.verified)
          _Note(
            key: const Key('onb-identity-verified'),
            icon: Icons.verified_user_rounded,
            text: user!.identity.autoVerified
                ? t.identityVerifiedByAi
                : t.identityStatusVerified,
            tone: _Tone.success,
          )
        else if (status == IdentityStatus.pending)
          _Note(
            key: const Key('onb-identity-pending'),
            icon: Icons.hourglass_top_rounded,
            text: t.identityPendingNote,
            tone: _Tone.warning,
          )
        else ...[
          // Le parcours en trois temps, pour savoir à quoi s'attendre.
          for (final (index, (icon, text)) in [
            (Icons.badge_outlined, t.onbIdentityStep1),
            (Icons.face_outlined, t.onbIdentityStep2),
            (Icons.auto_awesome, t.onbIdentityStep3),
          ].indexed)
            _TimelineRow(
              number: index + 1,
              icon: icon,
              text: text,
              last: index == 2,
            ),
          const SizedBox(height: 12),
          if (user?.licensePhotoId != null)
            _Note(
              icon: Icons.auto_fix_high_rounded,
              text: t.onbIdentityLicenseHint,
              tone: _Tone.info,
            ),
          Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 16, color: p.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  t.onbIdentityPrivacy,
                  style: TextStyle(color: p.textMuted, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ],
      primary: sent
          ? _PrimaryButton(label: t.onbContinue, onPressed: widget.onDone)
          : _PrimaryButton(
              label: t.onbIdentityStart,
              icon: Icons.shield_outlined,
              onPressed: _verify,
            ),
      secondary: sent
          ? null
          : _SecondaryButton(label: t.onbLater, onPressed: widget.onDone),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.number,
    required this.icon,
    required this.text,
    required this.last,
  });

  final int number;
  final IconData icon;
  final String text;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: p.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: p.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5, bottom: last ? 0 : 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: p.text,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, size: 20, color: p.textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Connexion biométrique --------------------------------------------------

class _BiometricStep extends StatefulWidget {
  const _BiometricStep({required this.onDone});
  final VoidCallback onDone;

  @override
  State<_BiometricStep> createState() => _BiometricStepState();
}

class _BiometricStepState extends State<_BiometricStep> {
  bool _busy = false;
  String? _error;

  Future<void> _enable() async {
    final users = AppScope.of(context).users;
    final reason = context.t.biometricEnableReason;
    String describe(Object e) => errorMessage(context, e);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (await users.enableBiometric(reason)) HapticFeedback.lightImpact();
    } catch (e) {
      if (mounted) setState(() => _error = describe(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final enabled = AppScope.of(context).users.biometricEnabled;
    return _StepPage(
      icon: Icons.fingerprint_rounded,
      title: t.onbBiometricTitle,
      body: t.onbBiometricBody,
      content: [
        if (_error != null) ErrorBanner(_error!),
        if (enabled)
          _Note(
            key: const Key('onb-biometric-on'),
            icon: Icons.check_circle_rounded,
            text: t.biometricEnabled,
            tone: _Tone.success,
          ),
      ],
      primary: enabled
          ? _PrimaryButton(label: t.onbContinue, onPressed: widget.onDone)
          : _PrimaryButton(
              label: t.onbBiometricEnable,
              icon: Icons.fingerprint_rounded,
              busy: _busy,
              onPressed: _enable,
            ),
      secondary: enabled
          ? null
          : _SecondaryButton(label: t.onbLater, onPressed: widget.onDone),
    );
  }
}

// ---------------------------------------------------------------------------
// Animations d'entrée, jouées une fois.

/// Les éléments d'une page apparaissent l'un après l'autre (fondu et léger
/// glissement), une seule fois, sans minuterie.
class _Cascade extends StatefulWidget {
  const _Cascade({required this.children});
  final List<Widget> children;

  @override
  State<_Cascade> createState() => _CascadeState();
}

class _CascadeState extends State<_Cascade>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.isDismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.children.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, child) in widget.children.indexed)
          Builder(
            builder: (context) {
              // Décalage de 0 à 40 % de l'animation selon la position.
              final start = count <= 1 ? 0.0 : 0.4 * index / (count - 1);
              final animation = CurvedAnimation(
                parent: _controller,
                curve: Interval(start, start + 0.6, curve: Curves.easeOutCubic),
              );
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Apparition avec un léger rebond (icône d'étape, coche finale).
class _PopIn extends StatelessWidget {
  const _PopIn({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.6, end: 1),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 650),
    curve: Curves.easeOutBack,
    builder: (context, value, child) => Transform.scale(
      scale: value,
      child: Opacity(opacity: ((value - 0.6) / 0.4).clamp(0, 1), child: child),
    ),
    child: child,
  );
}
