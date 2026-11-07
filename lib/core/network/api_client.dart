import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'token_storage.dart';

/// Erreur de l'API, avec un message déjà prêt à afficher.
class ApiException implements Exception {
  const ApiException(this.status, this.code, this.message);

  const ApiException.network()
    : status = 0,
      code = 'NETWORK_ERROR',
      message = 'Connexion au serveur impossible. Vérifiez votre réseau.';

  final int status;
  final String code;
  final String message;

  bool get isNetwork => status == 0;

  @override
  String toString() => 'ApiException($status, $code): $message';
}

/// Client de l'API, partagé par tous les modules : `AppScope.of(context).api`.
///
/// Ajoute le jeton d'accès à chaque requête et le renouvelle une seule fois en
/// cas de 401, même si plusieurs requêtes échouent en même temps.
class ApiClient {
  ApiClient({
    required SessionStorage storage,
    http.Client? httpClient,
    String? baseUrl,
  }) : _storage = storage,
       _http = httpClient ?? http.Client(),
       _baseUrl = baseUrl ?? defaultBaseUrl;

  /// `--dart-define=API_URL=...` pour viser un autre serveur.
  static const defaultBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000/api',
  );
  static const _refreshKey = 'refresh_token';
  static const _timeout = Duration(seconds: 15);

  final SessionStorage _storage;
  final http.Client _http;
  final String _baseUrl;

  String? _accessToken;
  Future<Map<String, dynamic>>? _refreshing;

  /// La session ne peut plus être renouvelée : il faut se reconnecter.
  void Function()? onSessionExpired;

  /// La session vient d'être renouvelée. Reçoit la réponse de l'API.
  void Function(Map<String, dynamic> session)? onSessionRefreshed;

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _request('GET', path, query: query);

  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _request('POST', path, body: body, auth: auth);

  Future<dynamic> patch(String path, {Object? body}) =>
      _request('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _request('DELETE', path);

  /// Enregistre la session reçue à la connexion ou à l'inscription.
  Future<void> openSession(Map<String, dynamic> session) async {
    _accessToken = session['accessToken'] as String;
    await _storage.write(_refreshKey, session['refreshToken'] as String);
  }

  /// Déconnexion : prévient le serveur si possible, puis efface la session.
  /// Sans réseau, le jeton expirera seul côté serveur.
  Future<void> endSession() async {
    final token = await _storage.read(_refreshKey);
    if (token != null) {
      try {
        await post('/auth/logout', auth: false, body: {'refreshToken': token});
      } on ApiException {
        // La déconnexion locale reste valable.
      }
    }
    await closeSession();
  }

  Future<void> closeSession() async {
    _accessToken = null;
    await _storage.delete(_refreshKey);
  }

  Future<bool> hasStoredSession() async =>
      await _storage.read(_refreshKey) != null;

  /// Renouvelle la session. Les appels simultanés partagent le même renouvellement.
  Future<Map<String, dynamic>> refreshSession() =>
      _refreshing ??= _refresh().whenComplete(() => _refreshing = null);

  Future<Map<String, dynamic>> _refresh() async {
    final token = await _storage.read(_refreshKey);
    try {
      if (token == null) {
        throw const ApiException(
          401,
          'SESSION_EXPIRED',
          'Session expirée. Reconnectez-vous.',
        );
      }
      final response = await _send(
        'POST',
        '/auth/refresh',
        body: {'refreshToken': token},
        auth: false,
      );
      final session = _decode(response) as Map<String, dynamic>;
      await openSession(session);
      onSessionRefreshed?.call(session);
      return session;
    } on ApiException catch (error) {
      if (error.status == 401) {
        await closeSession();
        onSessionExpired?.call();
      }
      rethrow;
    }
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
  }) async {
    var response = await _send(
      method,
      path,
      body: body,
      query: query,
      auth: auth,
    );
    if (auth && response.statusCode == 401) {
      await refreshSession();
      response = await _send(
        method,
        path,
        body: body,
        query: query,
        auth: auth,
      );
    }
    return _decode(response);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    required bool auth,
  }) async {
    final request =
        http.Request(
            method,
            Uri.parse('$_baseUrl$path').replace(queryParameters: query),
          )
          ..headers.addAll({
            if (body != null) 'Content-Type': 'application/json',
            if (auth && _accessToken != null)
              'Authorization': 'Bearer $_accessToken',
          });
    if (body != null) request.body = jsonEncode(body);
    try {
      final streamed = await _http.send(request).timeout(_timeout);
      return await http.Response.fromStream(streamed).timeout(_timeout);
    } on http.ClientException {
      throw const ApiException.network();
    } on TimeoutException {
      throw const ApiException.network();
    }
  }

  dynamic _decode(http.Response response) {
    final text = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return text.isEmpty ? null : jsonDecode(text);
    }
    try {
      final error = (jsonDecode(text) as Map<String, dynamic>)['error'] as Map;
      throw ApiException(
        response.statusCode,
        error['code'] as String,
        error['message'] as String,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        response.statusCode,
        'UNKNOWN_ERROR',
        'Le serveur a répondu de façon inattendue.',
      );
    }
  }
}
