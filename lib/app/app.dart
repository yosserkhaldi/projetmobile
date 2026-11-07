import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/modules/users/screens/auth_screen.dart';

class MonConstatApp extends StatefulWidget {
  const MonConstatApp({super.key});
  @override
  State<MonConstatApp> createState() => _MonConstatAppState();
}

class _MonConstatAppState extends State<MonConstatApp> {
  final stores = AppStores();

  @override
  void initState() {
    super.initState();
    unawaited(stores.accidents.initialize());
  }

  @override
  void dispose() {
    stores.accidents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScope(
    stores: stores,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mon Constat Digital',
      theme: AppTheme.light,
      home: const AuthScreen(),
    ),
  );
}
