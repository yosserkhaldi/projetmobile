import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/network/token_storage.dart';
import 'package:mon_constat_digital/modules/users/data/biometric_auth.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

enum AuthStatus { unknown, signedOut, signedIn }

/// Les deux photos d'un compte, avec leur route dans l'API.
enum UserPhoto {
  profile('photo'),
  license('license-photo');

  const UserPhoto(this.path);
  final String path;

  String? idOf(AppUser user) =>
      this == profile ? user.photoId : user.licensePhotoId;
}

/// Session et profil de l'utilisateur connecté.
class UserStore extends ChangeNotifier {
  UserStore(this._api, this._storage, this._biometric) {
    _api.onSessionExpired = _signOutLocally;
    _api.onSessionRefreshed = _applySession;
  }

  static const _userKey = 'current_user';
  static const _deviceKey = 'biometric_token';

  final ApiClient _api;
  final SessionStorage _storage;
  final BiometricAuth _biometric;

  AuthStatus status = AuthStatus.unknown;
  AppUser? currentUser;

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
    try {
      await _api.refreshSession();
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
      },
    );
    await _startSession(session as Map<String, dynamic>);
  }

  Future<void> logout() async {
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

  Future<void> updateProfile(Map<String, Object?> changes) async {
    _setUser(await _api.patch('/users/me', body: changes));
  }

  /// Active la connexion biométrique après une empreinte réussie.
  /// Renvoie `false` si l'utilisateur annule.
  Future<bool> enableBiometric() async {
    if (!await _biometric.authenticate(
      'Confirmez pour activer la connexion biométrique',
    )) {
      return false;
    }
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
  Future<void> loginWithBiometric() async {
    final token = await _storage.read(_deviceKey);
    if (token == null) return;
    if (!await _biometric.authenticate('Connectez-vous à Mon Constat')) return;
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

  Future<void> _startSession(Map<String, dynamic> session) async {
    await _api.openSession(session);
    _applySession(session);
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
  }

  void _signOutLocally() {
    currentUser = null;
    status = AuthStatus.signedOut;
    notifyListeners();
    _storage.delete(_userKey);
  }

  Future<AppUser?> _readCachedUser() async {
    final text = await _storage.read(_userKey);
    return text == null
        ? null
        : AppUser.fromJson(jsonDecode(text) as Map<String, dynamic>);
  }
}
