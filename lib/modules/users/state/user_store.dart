import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/network/device_identity.dart';
import 'package:mon_constat_digital/core/network/token_storage.dart';
import 'package:mon_constat_digital/modules/users/data/biometric_auth.dart';
import 'package:mon_constat_digital/modules/users/data/users_database.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/models/security.dart';

enum AuthStatus { unknown, signedOut, signedIn }

/// Les deux photos d'un compte, avec leur route dans l'API.
/// Photos d'un compte, avec leur route dans l'API.
enum UserPhoto {
  profile('photo'),
  license('license-photo'),
  cinFront('identity/front'),
  cinBack('identity/back');

  const UserPhoto(this.path);
  final String path;

  String? idOf(AppUser user) => switch (this) {
    profile => user.photoId,
    license => user.licensePhotoId,
    cinFront => user.identity.frontId,
    cinBack => user.identity.backId,
  };

  /// Les photos de la CIN ne se suppriment pas : on les remplace.
  bool get deletable => this == profile || this == license;
}

/// Session et profil de l'utilisateur connecté.
class UserStore extends ChangeNotifier {
  UserStore(
    this._api,
    this._storage,
    this._biometric, {
    DeviceHeadersLoader deviceHeaders = loadDeviceHeaders,
    UsersDatabase? localDb,
  }) : _deviceHeaders = deviceHeaders,
       _localDb = localDb {
    _api.onSessionExpired = _signOutLocally;
    _api.onSessionRefreshed = _applySession;
  }

  static const _userKey = 'current_user';
  static const _deviceKey = 'biometric_token';
  static const _languageKey = 'app_language';
  static const _themeKey = 'theme_mode';

  final ApiClient _api;
  final SessionStorage _storage;
  final BiometricAuth _biometric;
  final DeviceHeadersLoader _deviceHeaders;

  /// Copie SQLite du profil, pour démarrer et pré-remplir le constat hors
  /// ligne. `null` sur le web.
  final UsersDatabase? _localDb;

  AuthStatus status = AuthStatus.unknown;
  AppUser? currentUser;

  /// Langue de l'interface. Gardée sur le téléphone, et sur le compte une
  /// fois connecté.
  AppLanguage language = AppLanguage.fr;

  /// Clair, sombre, ou comme le téléphone. Reste sur ce téléphone.
  ThemeMode themeMode = ThemeMode.system;

  // Vrai si la langue a été choisie sur ce téléphone : ce choix l'emporte
  // sur celui du compte à la connexion.
  bool _languageChosen = false;

  // --- File hors ligne (SQLite) -------------------------------------------

  /// Modifications du profil enregistrées sur le téléphone, pas encore
  /// envoyées au serveur.
  int pendingCount = 0;

  /// Refus du serveur pour une modification en attente (téléphone déjà
  /// utilisé…). Plus de nouvel essai automatique tant qu'il est affiché.
  String? pendingError;
  bool syncing = false;
  Timer? _syncTimer;
  static const _syncEvery = Duration(seconds: 20);

  /// Le téléphone a un capteur configuré.
  bool biometricAvailable = false;

  /// La connexion biométrique est activée sur ce téléphone.
  bool biometricEnabled = false;

  // Photos déjà téléchargées, par identifiant de photo.
  final _photoCache = <String, Uint8List>{};

  UserRole get role => currentUser?.role ?? UserRole.driver;
  String get userName => currentUser?.name ?? '';

  /// Au démarrage : reprend la session enregistrée.
  /// Sans réseau, le dernier profil connu suffit, car une déclaration doit
  /// rester possible hors ligne.
  Future<void> restore() async {
    try {
      _api.deviceHeaders = await _deviceHeaders(_storage);
      final theme = await _storage.read(_themeKey);
      themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == theme,
        orElse: () => ThemeMode.system,
      );
      final saved = await _storage.read(_languageKey);
      if (saved != null) {
        language = AppLanguage.fromApi(saved);
        _languageChosen = true;
      }
      biometricAvailable = await _biometric.isAvailable();
      biometricEnabled =
          biometricAvailable && await _storage.read(_deviceKey) != null;
      if (await _api.hasStoredSession()) {
        await _restoreSession();
      } else {
        _signOutLocally();
      }
    } catch (_) {
      // Stockage illisible : on repart de l'écran de connexion plutôt que de
      // rester bloqué sur le chargement.
      status = AuthStatus.signedOut;
      notifyListeners();
    }
  }

  Future<void> _restoreSession() async {
    final cached = await _readCachedUser();
    await _refreshPending();
    try {
      await _api.refreshSession();
      unawaited(syncPending());
    } on ApiException catch (error) {
      if (error.status == 401) return; // onSessionExpired a déjà déconnecté.
      if (cached == null) {
        _signOutLocally();
      } else {
        currentUser = cached;
        status = AuthStatus.signedIn;
        notifyListeners();
      }
    }
  }

  Future<void> login(String identifier, String password) async {
    final session = await _api.post(
      '/auth/login',
      auth: false,
      body: {'identifier': identifier, 'password': password},
    );
    await _startSession(session as Map<String, dynamic>);
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final session = await _api.post(
      '/auth/register',
      auth: false,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'language': language.apiValue,
        // Case cochée à l'inscription (loi n° 2004-63).
        'consent': true,
      },
    );
    await _startSession(session as Map<String, dynamic>);
  }

  Future<void> logout() async {
    // Dernière chance d'envoyer les modifications, puis la file est vidée :
    // le prochain compte sur ce téléphone ne doit pas les recevoir.
    await syncPending();
    await _localDb?.clearPending();
    await _refreshPending();
    await _api.endSession();
    _signOutLocally();
  }

  Future<void> resendPhoneCode() async {
    await _api.post('/auth/phone/send');
  }

  Future<void> verifyPhone(String code) async {
    final response = await _api.post(
      '/auth/phone/verify',
      body: {'code': code},
    );
    _setUser(response);
  }

  Future<void> forgotPassword(String email) async {
    await _api.post(
      '/auth/password/forgot',
      auth: false,
      body: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    await _api.post(
      '/auth/password/reset',
      auth: false,
      body: {'email': email, 'code': code, 'password': password},
    );
  }

  /// Enregistre sur le serveur. Sans réseau, la modification est appliquée
  /// tout de suite à l'écran et gardée dans la file SQLite.
  /// Renvoie `false` si elle attend le retour du réseau.
  Future<bool> updateProfile(Map<String, Object?> changes) async {
    final db = _localDb;
    // Des modifications attendent déjà : on passe derrière elles, sinon
    // l'ancienne écraserait la nouvelle à la synchronisation.
    if (db != null && pendingCount > 0) {
      await _queue(changes);
      await syncPending();
      return pendingCount == 0;
    }
    try {
      _setUser(await _api.patch('/users/me', body: changes));
      return true;
    } on ApiException catch (error) {
      if (!error.isNetwork || db == null || currentUser == null) rethrow;
      await _queue(changes);
      return false;
    }
  }

  Future<void> _queue(Map<String, Object?> changes) async {
    await _localDb!.enqueue('profile', changes);
    _setUser({'user': _applyLocally(currentUser!, changes)});
    await _refreshPending();
  }

  /// Ce que le serveur fera de la modification, pour l'afficher sans attendre.
  static Map<String, dynamic> _applyLocally(
    AppUser user,
    Map<String, Object?> changes,
  ) {
    final json = user.toJson();
    for (final MapEntry(:key, :value) in changes.entries) {
      json[key] = value == '' ? null : value;
    }
    final phone = changes['phone'];
    if (phone is String) {
      final compact = phone.replaceAll(RegExp(r'[\s.-]'), '');
      json['phone'] = RegExp(r'^\d{8}$').hasMatch(compact)
          ? '+216$compact'
          : compact;
      // Un nouveau numéro devra être revérifié, comme côté serveur.
      if (json['phone'] != user.phone) json['phoneVerified'] = false;
    }
    return json;
  }

  /// Envoie les modifications en attente, dans l'ordre.
  Future<void> syncPending() async {
    final db = _localDb;
    if (db == null || syncing || status != AuthStatus.signedIn) return;
    syncing = true;
    notifyListeners();
    try {
      for (final row in await db.pending()) {
        if (row.lastError != null) continue;
        try {
          final response = await _api.patch(
            '/users/me',
            body: jsonDecode(row.payload),
          );
          await db.removePending(row.id);
          _setUser(response);
        } on ApiException catch (error) {
          if (error.isNetwork) {
            await db.markAttempted(row.id);
            break;
          }
          if (error.status == 401) break;
          await db.markFailed(row.id, error.message);
        }
      }
    } catch (e) {
      debugPrint('Synchronisation impossible : $e');
    } finally {
      syncing = false;
      await _refreshPending();
    }
  }

  /// Réessayer après un refus du serveur.
  Future<void> retryPending() async {
    await _localDb?.clearPendingErrors();
    await _refreshPending();
    await syncPending();
  }

  /// Abandonner les modifications en attente et reprendre le profil du serveur.
  Future<void> discardPending() async {
    await _localDb?.clearPending();
    await _refreshPending();
    try {
      _setUser(await _api.get('/users/me'));
    } on ApiException catch (error) {
      if (!error.isNetwork) rethrow;
    }
  }

  Future<void> _refreshPending() async {
    final rows = await _localDb?.pending() ?? const <PendingChangeRow>[];
    pendingCount = rows.length;
    pendingError = rows
        .where((r) => r.lastError != null)
        .map((r) => r.lastError)
        .firstOrNull;
    // Nouvel essai régulier tant que des modifications attendent le réseau.
    if (pendingCount > 0 && pendingError == null) {
      _syncTimer ??= Timer.periodic(_syncEvery, (_) => syncPending());
    } else {
      _syncTimer?.cancel();
      _syncTimer = null;
    }
    notifyListeners();
  }

  /// Arrête les nouveaux essais automatiques (fermeture de l'application).
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  @override
  void dispose() {
    stopAutoSync();
    super.dispose();
  }

  /// Revérifie le capteur, par exemple après un passage dans les réglages.
  Future<void> refreshBiometricAvailability() async {
    final available = await _biometric.isAvailable();
    final enabled = available && await _storage.read(_deviceKey) != null;
    if (available == biometricAvailable && enabled == biometricEnabled) return;
    biometricAvailable = available;
    biometricEnabled = enabled;
    notifyListeners();
  }

  /// Active la connexion biométrique après une empreinte réussie.
  /// Renvoie `false` si l'utilisateur annule.
  Future<bool> enableBiometric(String reason) async {
    if (!await _biometric.authenticate(reason)) return false;
    final key = await _api.post('/auth/biometric') as Map<String, dynamic>;
    await _storage.write(_deviceKey, key['deviceToken'] as String);
    biometricEnabled = true;
    notifyListeners();
    return true;
  }

  Future<void> disableBiometric() async {
    final token = await _storage.read(_deviceKey);
    await _storage.delete(_deviceKey);
    biometricEnabled = false;
    notifyListeners();
    if (token == null) return;
    try {
      await _api.delete('/auth/biometric', body: {'deviceToken': token});
    } on ApiException catch (error) {
      // Sans réseau, la clé expirera seule. Elle n'est plus sur le téléphone.
      if (!error.isNetwork) rethrow;
    }
  }

  /// Connexion par empreinte. Ne fait rien si l'utilisateur annule.
  Future<void> loginWithBiometric(String reason) async {
    final token = await _storage.read(_deviceKey);
    if (token == null) return;
    if (!await _biometric.authenticate(reason)) return;
    final Map<String, dynamic> session;
    try {
      session =
          await _api.post(
                '/auth/biometric/login',
                auth: false,
                body: {'deviceToken': token},
              )
              as Map<String, dynamic>;
    } on ApiException catch (error) {
      if (error.code == 'BIOMETRIC_INVALID') {
        await _storage.delete(_deviceKey);
        biometricEnabled = false;
        notifyListeners();
      }
      rethrow;
    }
    await _storage.write(_deviceKey, session['deviceToken'] as String);
    await _startSession(session);
  }

  Future<void> setThemeMode(ThemeMode value) async {
    themeMode = value;
    notifyListeners();
    await _storage.write(_themeKey, value.name);
  }

  /// Change la langue tout de suite, puis l'enregistre sur le compte.
  Future<void> setLanguage(AppLanguage value) async {
    _languageChosen = true;
    if (value == language) return;
    language = value;
    notifyListeners();
    await _storage.write(_languageKey, value.apiValue);
    if (status == AuthStatus.signedIn) {
      try {
        // Sans réseau, la langue part dans la file d'attente.
        await updateProfile({'language': value.apiValue});
      } on ApiException catch (error) {
        if (!error.isNetwork) rethrow;
      }
    }
  }

  Future<void> uploadPhoto(
    UserPhoto photo,
    Uint8List bytes,
    String filename,
  ) async {
    _setUser(
      await _api.upload(
        '/users/me/${photo.path}',
        field: 'photo',
        bytes: bytes,
        filename: filename,
      ),
    );
  }

  Future<void> deletePhoto(UserPhoto photo) async {
    _setUser(await _api.delete('/users/me/${photo.path}'));
  }

  /// Image d'une photo, téléchargée une seule fois par version.
  Future<Uint8List?> photoBytes(UserPhoto photo, AppUser user) async {
    final id = photo.idOf(user);
    if (id == null) return null;
    return _photoCache[id] ??= await _api.getBytes(
      '/users/${user.id}/${photo.path}',
    );
  }

  // --- Sécurité du compte -------------------------------------------------

  Future<List<DeviceSession>> loadSessions() async {
    final body = await _api.get('/users/me/sessions') as Map<String, dynamic>;
    return [
      for (final item in body['items'] as List)
        DeviceSession.fromJson(item as Map<String, dynamic>),
    ];
  }

  /// Déconnecter cet appareil-ci revient à se déconnecter.
  Future<void> revokeSession(DeviceSession session) async {
    if (session.current) return logout();
    await _api.delete('/users/me/sessions/${session.id}');
  }

  Future<int> revokeOtherSessions() async {
    final body =
        await _api.post('/users/me/sessions/revoke-others')
            as Map<String, dynamic>;
    return body['revoked'] as int;
  }

  Future<List<LoginEvent>> loadLoginEvents() async {
    final body =
        await _api.get('/users/me/login-events') as Map<String, dynamic>;
    return [
      for (final item in body['items'] as List)
        LoginEvent.fromJson(item as Map<String, dynamic>),
    ];
  }

  // --- Données personnelles (loi n° 2004-63) ---------------------------------

  /// Tout ce que l'API garde sur le compte.
  Future<Map<String, dynamic>> exportData() async =>
      await _api.get('/users/me/export') as Map<String, dynamic>;

  /// Supprime (anonymise) le compte, puis déconnecte ce téléphone.
  Future<void> deleteAccount(String password) async {
    await _api.delete('/users/me', body: {'password': password});
    await _localDb?.clearPending();
    await _refreshPending();
    await _storage.delete(_deviceKey);
    biometricEnabled = false;
    await _api.closeSession();
    _signOutLocally();
  }

  // --- Vérification d'identité ----------------------------------------------

  Future<void> submitIdentity(String cinNumber) async {
    _setUser(
      await _api.post(
        '/users/me/identity/submit',
        body: {'cinNumber': cinNumber},
      ),
    );
  }

  Future<void> _startSession(Map<String, dynamic> session) async {
    await _api.openSession(session);
    _applySession(session);
    await _syncLanguage();
    await _refreshPending();
    unawaited(syncPending());
  }

  /// À la connexion : la langue choisie sur ce téléphone est enregistrée sur
  /// le compte. Sur un nouveau téléphone, c'est celle du compte qui s'applique.
  Future<void> _syncLanguage() async {
    final user = currentUser!;
    if (!_languageChosen) {
      language = user.language;
      notifyListeners();
      return;
    }
    if (user.language == language) return;
    try {
      await updateProfile({'language': language.apiValue});
    } on ApiException {
      // La langue reste appliquée sur ce téléphone ; le compte suivra plus tard.
    }
  }

  void _applySession(Map<String, dynamic> session) {
    _setUser(session);
  }

  void _setUser(dynamic response) {
    final user = AppUser.fromJson(
      (response as Map<String, dynamic>)['user'] as Map<String, dynamic>,
    );
    currentUser = user;
    status = AuthStatus.signedIn;
    notifyListeners();
    _storage.write(_userKey, jsonEncode(user.toJson()));
    _localDb?.saveProfile(user).catchError((Object e) {
      debugPrint('Profil hors ligne non enregistré : $e');
    });
  }

  void _signOutLocally() {
    currentUser = null;
    status = AuthStatus.signedOut;
    notifyListeners();
    // Ancien emplacement du profil (avant SQLite), effacé au passage.
    _storage.delete(_userKey);
    _localDb?.clearProfile().catchError((Object e) {
      debugPrint('Profil hors ligne non effacé : $e');
    });
  }

  Future<AppUser?> _readCachedUser() async {
    final saved = await _localDb?.loadProfile();
    if (saved != null) return saved;
    // Profil enregistré par une version précédente de l'application.
    final text = await _storage.read(_userKey);
    return text == null
        ? null
        : AppUser.fromJson(jsonDecode(text) as Map<String, dynamic>);
  }
}
