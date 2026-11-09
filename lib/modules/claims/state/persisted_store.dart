import 'package:flutter/foundation.dart';

/// Garde l'API synchrone des stores : la mémoire change tout de suite, puis
/// SQLite suit dans l'ordre des appels.
///
/// Si la base ne s'ouvre pas, l'application continue en mémoire seule.
mixin PersistedStore on ChangeNotifier {
  bool _available = true;
  Future<void> _pending = Future.value();

  /// Se termine quand le chargement et les écritures en attente sont finis.
  Future<void> get saved => _pending;

  @protected
  void loadFromDatabase(Future<void> Function() load) {
    _pending = load().then(
      (_) => notifyListeners(),
      onError: (Object error) {
        _available = false;
        debugPrint('SQLite indisponible, données en mémoire : $error');
      },
    );
  }

  @protected
  void persist(Future<void> Function() write) {
    _pending = _pending.then((_) async {
      if (!_available) return;
      try {
        await write();
      } catch (error) {
        debugPrint('Écriture SQLite échouée : $error');
      }
    });
  }
}
