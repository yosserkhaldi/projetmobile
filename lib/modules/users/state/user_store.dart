import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/network/token_storage.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

enum AuthStatus { unknown, signedOut, signedIn }

/// Session et profil de l'utilisateur connecté.
class UserStore extends ChangeNotifier {
  UserStore(this._api, this._storage) {
    _api.onSessionExpired = _signOutLocally;
    _api.onSessionRefreshed = _applySession;
  }

  static const _userKey = 'current_user';

  final ApiClient _api;
  final SessionStorage _storage;

  AuthStatus status = AuthStatus.unknown;
  AppUser? currentUser;

  UserRole get role => currentUser?.role ?? UserRole.driver;
  String get userName => currentUser?.name ?? '';

  /// Au démarrage : reprend la session enregistrée.
  /// Sans réseau, le dernier profil connu suffit, car une déclaration doit
  /// rester possible hors ligne.
  Future<void> restore() async {
    try {
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
