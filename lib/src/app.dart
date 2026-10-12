import 'package:flutter/material.dart';

import 'screens.dart';
import 'store.dart';

class MonConstatApp extends StatefulWidget {
  const MonConstatApp({super.key});
  @override
  State<MonConstatApp> createState() => _MonConstatAppState();
}

class _MonConstatAppState extends State<MonConstatApp> {
  final store = AppStore();
  @override
  Widget build(BuildContext context) => StoreScope(
    store: store,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mon Constat Digital',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF185ADB),
          primary: const Color(0xFF185ADB),
          secondary: const Color(0xFFFFA51F),
          surface: const Color(0xFFF4F6FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        cardTheme: const CardThemeData(color: Colors.white, elevation: 0),
      ),
      home: const AuthScreen(),
    ),
  );
}

class StoreScope extends InheritedNotifier<AppStore> {
  const StoreScope({required AppStore store, required super.child, super.key})
    : super(notifier: store);
  static AppStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StoreScope>()!.notifier!;
}
