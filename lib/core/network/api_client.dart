import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

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

  String get baseUrl => _baseUrl;

  String? _accessToken;

  /// Jeton courant, pour les canaux hors HTTP (Socket.IO).
  String? get accessToken => _accessToken;

  /// X-Device-Id et X-Device-Name, ajoutés à chaque requête (device_identity.dart).
  Map<String, String> deviceHeaders = const {};
  Future<Map<String, dynamic>>? _refreshing;

  /// La session ne peut plus être renouvelée : il faut se reconnecter.
  void Function()? onSessionExpired;

  /// La session vient d'être renouvelée. Reçoit la réponse de l'API.
  void Function(Map<String, dynamic> session)? onSessionRefreshed;

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _request('GET', path, query: query);

  /// [timeout] : pour les appels longs, comme un assistant qui lit un dossier.
  Future<dynamic> post(
    String path, {
    Object? body,
    bool auth = true,
    Duration? timeout,
  }) => _request('POST', path, body: body, auth: auth, timeout: timeout);

  /// Requête sur mesure (en-têtes, multipart). Renvoie la réponse sans la
  /// décoder : le code HTTP reste à l'appelant.
  Future<http.Response> send(
    String path,
    http.BaseRequest Function(Uri uri) build, {
    Duration? timeout,
  }) => _execute(() => build(_uri(path)), timeout: timeout);

  Future<dynamic> patch(String path, {Object? body}) =>
      _request('PATCH', path, body: body);

  Future<dynamic> delete(String path, {Object? body}) =>
      _request('DELETE', path, body: body);

  /// Envoie un fichier en multipart, dans le champ [field], avec d'éventuels
  /// champs texte ([fields]).
  Future<dynamic> upload(
    String path, {
    required String field,
    required List<int> bytes,
    required String filename,
    Map<String, String> fields = const {},
    String method = 'PUT',
  }) async {
    final response = await _execute(
      () => http.MultipartRequest(method, _uri(path))
        ..fields.addAll(fields)
        ..files.add(
          http.MultipartFile.fromBytes(field, bytes, filename: filename),
        ),
    );
    return _decode(response);
  }

  /// Envoie plusieurs fichiers dans le même champ, avec des champs texte.
  Future<dynamic> uploadMany(
    String path, {
    required String field,
    required List<List<int>> files,
    Map<String, String> fields = const {},
    String method = 'POST',
  }) async {
    final response = await _execute(() {
      final request = http.MultipartRequest(method, _uri(path))
        ..fields.addAll(fields);
      for (final (index, bytes) in files.indexed) {
        request.files.add(
          http.MultipartFile.fromBytes(field, bytes, filename: '$index.jpg'),
        );
      }
      return request;
    });
    return _decode(response);
  }

  /// Télécharge un fichier protégé (photo…) avec le jeton de l'utilisateur.
  Future<Uint8List> getBytes(String path) async {
    final response = await _execute(() => http.Request('GET', _uri(path)));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }
    return _decode(response) as Never;
  }

  /// Envoie un fichier en multipart et récupère une réponse binaire (ex: PDF scellé).
  Future<Uint8List> uploadForBytes(
    String path, {
    required String field,
    required List<int> bytes,
    required String filename,
    String method = 'POST',
    Map<String, String>? fields,
  }) async {
    final response = await _execute(
      () => http.MultipartRequest(method, _uri(path))
        ..fields.addAll(fields ?? const {})
        ..files.add(
          http.MultipartFile.fromBytes(field, bytes, filename: filename),
        ),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }
    return _decode(response) as Never;
  }

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
      final request = http.Request('POST', _uri('/auth/refresh'))
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode({'refreshToken': token});
      final response = await _send(request, auth: false);
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

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$_baseUrl$path').replace(queryParameters: query);

  Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
    Duration? timeout,
  }) async {
    http.BaseRequest build() {
      final request = http.Request(method, _uri(path, query));
      if (body != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(body);
      }
      return request;
    }

    return _decode(await _execute(build, auth: auth, timeout: timeout));
  }

  /// Envoie la requête. En cas de 401, renouvelle la session puis la rejoue
  /// une fois : [build] crée une nouvelle requête à chaque essai.
  Future<http.Response> _execute(
    http.BaseRequest Function() build, {
    bool auth = true,
    Duration? timeout,
  }) async {
    var response = await _send(build(), auth: auth, timeout: timeout);
    if (auth && response.statusCode == 401) {
      await refreshSession();
      response = await _send(build(), auth: auth, timeout: timeout);
    }
    return response;
  }

  Future<http.Response> _send(
    http.BaseRequest request, {
    required bool auth,
    Duration? timeout,
  }) async {
    final limit = timeout ?? _timeout;
    request.headers.addAll(deviceHeaders);
    if (auth && _accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }
    try {
      final streamed = await _http.send(request).timeout(limit);
      return await http.Response.fromStream(streamed).timeout(limit);
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
