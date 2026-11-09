import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mon_constat_digital/app/main_shell.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/screens/auth_screen.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';

class MonConstatApp extends StatefulWidget {
  const MonConstatApp({this.stores, super.key});

  /// Fourni par les tests. L'application crée ses propres stores sinon.
  final AppStores? stores;

  @override
  State<MonConstatApp> createState() => _MonConstatAppState();
}

class _MonConstatAppState extends State<MonConstatApp>
    with WidgetsBindingObserver {
  late final AppStores stores =
      widget.stores ?? (AppStores()..startClaimsSync());
  final _navigator = GlobalKey<NavigatorState>();
  late AuthStatus _lastStatus = stores.users.status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    stores.users.addListener(_onUsersChanged);
    stores.users.restore();
    unawaited(stores.accidents.initialize());
    unawaited(stores.vehicles.initialize());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stores.users
      ..removeListener(_onUsersChanged)
      ..stopAutoSync();
    stores.accidents.dispose();
    stores.vehicles.dispose();
    super.dispose();
  }

  /// Retour dans l'application : une empreinte a pu être ajoutée ou retirée
  /// dans les réglages du téléphone entre-temps.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      stores.users.refreshBiometricAvailability();
      // Le réseau est peut-être revenu : envoyer la file hors ligne.
      stores.users.syncPending();
    }
  }

  /// À la déconnexion, ferme les écrans ouverts au-dessus de l'accueil.
  void _onUsersChanged() {
    final status = stores.users.status;
    if (_lastStatus == AuthStatus.signedIn && status == AuthStatus.signedOut) {
      _navigator.currentState?.popUntil((route) => route.isFirst);
    }
    _lastStatus = status;
  }

  @override
  Widget build(BuildContext context) => AppScope(
    stores: stores,
    // Reconstruit l'application quand la langue change.
    child: ListenableBuilder(
      listenable: stores.users,
      builder: (context, home) => MaterialApp(
        navigatorKey: _navigator,
        debugShowCheckedModeBanner: false,
        title: 'Mon Constat Digital',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: stores.users.themeMode,
        // Français, arabe (de droite à gauche) ou anglais, selon le choix de
        // l'utilisateur. Textes dans lib/l10n/*.arb.
        locale: Locale(stores.users.language.code),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: home,
      ),
      child: const _SessionGate(),
    ),
  );
}

/// Choisit le premier écran selon l'état de la session.
class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) => switch (AppScope.of(
    context,
  ).users.status) {
    AuthStatus.unknown => const Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
    ),
    AuthStatus.signedOut => const AuthScreen(),
    AuthStatus.signedIn => const MainShell(),
  };
}
