import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/modules/accident/data/accident_database.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';

class AccidentStore extends ChangeNotifier {
  AccidentStore({AccidentDatabase? database})
    : _database = database ?? AccidentDatabase();

  final AccidentDatabase _database;
  Future<void> _writeQueue = Future.value();
  bool _disposed = false;

  AccidentDraft? draft;
  int currentStep = 0;
  bool isLoading = false;
  bool isPersistent = true;

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();
    try {
      final saved = await _database.loadDraft();
      if (saved != null && draft == null) {
        draft = saved.draft;
        currentStep = saved.currentStep.clamp(0, 6);
      }
      isPersistent = true;
    } catch (_) {
      // Les tests et plateformes sans SQLite (Drift) continuent en mémoire.
      isPersistent = false;
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  void saveDraft(AccidentDraft value, int step) {
    draft = value;
    currentStep = step.clamp(0, 6);
    value.touch();
    notifyListeners();
    _enqueue(() => _database.saveDraft(value, currentStep));
  }

  AccidentDraft startNew() {
    draft = AccidentDraft();
    currentStep = 0;
    notifyListeners();
    _enqueue(() => _database.saveDraft(draft!, currentStep));
    return draft!;
  }

  /// Envoie la déclaration au serveur (/api/accidents) et la marque transmise.
  /// Renvoie son identifiant, à lier au constat, ou null hors ligne : le
  /// constat est alors scellé sur le téléphone.
  Future<String?> submitToServer(
    ApiClient api,
    AccidentDraft value, {
    required String clientId,
  }) async {
    try {
      final saved =
          await api.post(
                '/accidents',
                body: {
                  'clientId': clientId,
                  'currentStep': 6,
                  'place': value.place.trim().isEmpty ? 'Non précisé' : value.place,
                  'occurredAt': value.occurredAt.toUtc().toIso8601String(),
                  'payload': value.toDatabaseMap(currentStep: 6)
                    ..remove('id')
                    ..remove('current_step'),
                },
              )
              as Map<String, dynamic>;
      final id = (saved['accident'] as Map<String, dynamic>)['id'] as String;
      await api.post('/accidents/$id/submit');
      value.serverId = id;
      return id;
    } on ApiException catch (error) {
      if (error.isNetwork) return null;
      rethrow;
    }
  }

  void clearDraft() {
    draft = null;
    currentStep = 0;
    notifyListeners();
    _enqueue(_database.deleteDraft);
  }

  void _enqueue(Future<void> Function() operation) {
    _writeQueue = _writeQueue.then((_) => operation()).catchError((_) {
      isPersistent = false;
      if (!_disposed) notifyListeners();
    });
    unawaited(_writeQueue);
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_writeQueue.whenComplete(_database.close));
    super.dispose();
  }
}
