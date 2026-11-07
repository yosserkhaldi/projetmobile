import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:mon_constat_digital/app/main_shell.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/modules/users/screens/auth_screen.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';

class MonConstatApp extends StatefulWidget {
  const MonConstatApp({this.stores, super.key});

  /// Fourni par les tests. L'application crée ses propres stores sinon.
  final AppStores? stores;

  @override
  State<MonConstatApp> createState() => _MonConstatAppState();
}

class _MonConstatAppState extends State<MonConstatApp> {
  late final AppStores stores = widget.stores ?? AppStores();
  final _navigator = GlobalKey<NavigatorState>();
  late AuthStatus _lastStatus = stores.users.status;

  @override
  void initState() {
    super.initState();
    stores.users.addListener(_onUsersChanged);
    stores.users.restore();
  }

  @override
  void dispose() {
    stores.users.removeListener(_onUsersChanged);
    super.dispose();
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
    child: MaterialApp(
      navigatorKey: _navigator,
      debugShowCheckedModeBanner: false,
      title: 'Mon Constat Digital',
      theme: AppTheme.light,
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const _SessionGate(),
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
