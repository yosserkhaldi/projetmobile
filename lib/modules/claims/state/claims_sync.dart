import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_api.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_dao.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_database.dart';
import 'package:mon_constat_digital/modules/claims/data/ids.dart';
import 'package:mon_constat_digital/modules/claims/state/claim_store.dart';
import 'package:mon_constat_digital/modules/claims/state/message_store.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';

/// Envoie la file d'attente à l'API, puis recharge l'état du serveur.
///
/// SQLite reste la source locale : l'application fonctionne sans réseau et
/// rattrape son retard dès que l'API répond.
class ClaimsSync extends ChangeNotifier {
  ClaimsSync({
    required this.api,
    required ClaimsDao dao,
    required this.claims,
    required this.messages,
    required this.users,
  }) : _dao = dao {
    claims.sync = this;
    messages.sync = this;
    users.addListener(_onUserChanged);
  }

  /// Démarre avec l'application, et attend la connexion de l'utilisateur.
  static ClaimsSync start({
    required ApiClient client,
    required ClaimStore claims,
    required MessageStore messages,
    required UserStore users,
  }) {
    final sync = ClaimsSync(
      api: ClaimsApi(client),
      dao: ClaimsDatabase.shared.claimsDao,
      claims: claims,
      messages: messages,
      users: users,
    );
    unawaited(sync._run());
    return sync;
  }

  final ClaimsApi api;
  final ClaimsDao _dao;
  final ClaimStore claims;
  final MessageStore messages;
  final UserStore users;

  bool online = true;
  bool _again = false;
  bool _disposed = false;
  Future<void>? _running;
  String? _userId;
  AppLanguage? _language;
  Timer? _timer;
  io.Socket? _socket;

  ApiIdentity get identity => (
    id: users.currentUser?.id ?? '',
    role: users.role.name,
    name: users.userName,
  );

  Future<void> _run() async {
    await Future.wait([claims.saved, messages.saved]);
    // Le jeton vit 15 minutes : le canal se rouvre avec le jeton renouvelé.
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_userId != null && _socket?.connected != true) connect();
      synchronize();
    });
    _onUserChanged();
  }

  /// Ouvre le canal temps réel : le serveur prévient à chaque changement.
  ///
  /// `enableForceNew` : sans lui, la bibliothèque réutilise la connexion en
  /// cache, avec l'ancien jeton, et le canal ne se rouvre jamais ; les
  /// messages n'arrivaient alors qu'au passage du minuteur de 30 s.
  void connect() {
    _socket?.dispose();
    _socket =
        io.io(
            api.socketUrl,
            io.OptionBuilder()
                .setPath('/api/claims/socket')
                .setTransports(['websocket'])
                .enableForceNew()
                .disableReconnection()
                .setAuth({'token': api.accessToken})
                .build(),
          )
          ..on('claims:changed', (_) => synchronize())
          // Rattrape ce qui a changé pendant la coupure.
          ..onConnect((_) => synchronize())
          ..onConnectError((_) => _reconnectSoon())
          ..onDisconnect((_) => _reconnectSoon());
  }

  Timer? _retry;

  /// Renouvelle le jeton par un passage de synchronisation, puis rouvre.
  void _reconnectSoon() {
    if (_retry?.isActive ?? false) return;
    _retry = Timer(const Duration(seconds: 3), () async {
      if (_disposed || _userId == null || _socket?.connected == true) return;
      await synchronize();
      if (!_disposed && _userId != null) connect();
    });
  }

  void _onUserChanged() {
    final id = users.currentUser?.id;
    final language = users.currentUser?.language;
    if (id == _userId) {
      // Le serveur rédige l'analyse dans la langue du profil : on la recharge
      // dès que le compte a enregistré la nouvelle langue.
      if (id != null && language != _language) {
        _language = language;
        unawaited(synchronize());
      }
      return;
    }
    _userId = id;
    _language = language;
    _retry?.cancel();
    _socket?.dispose();
    _socket = null;
    if (id == null) {
      claims.clearInsights();
      unawaited(_forgetAccount());
      return;
    }
    connect();
    unawaited(synchronize());
  }

  /// Déconnexion : les données du compte quittent le téléphone.
  Future<void> _forgetAccount() async {
    await _dao.clearAccountData();
    await claims.reload();
    await messages.reload();
  }

  /// Ajoute une requête à la file. Elle partira dès que possible.
  Future<void> enqueue(
    String path, {
    Map<String, dynamic> body = const {},
    bool multipart = false,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    await _dao.enqueue(
      ApiRequest(
        id: newId(),
        method: 'POST',
        path: path,
        identity: identity,
        body: body,
        multipart: multipart,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
      ),
    );
    unawaited(synchronize());
  }

  /// Un seul passage à la fois. Un appel pendant un passage en relance un et
  /// attend sa fin.
  Future<void> synchronize() {
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    return _running = _pass().whenComplete(() => _running = null);
  }

  Future<void> _pass() async {
    if (_disposed || users.currentUser == null) return;
    try {
      do {
        _again = false;
        await claims.saved;
        await messages.saved;
        final sent = await _flush();
        if (sent) await _pull();
        _setOnline(sent);
      } while (_again);
    } catch (error) {
      debugPrint('Synchronisation interrompue : $error');
      _setOnline(false);
    }
  }

  /// Renvoie vrai quand la file est vide.
  Future<bool> _flush() async {
    final mine = await _dao.pendingRequests(actorId: identity.id);
    for (final request in mine) {
      final status = await api.send(request);
      if (status >= 500 || status == 401 || status == 408 || status == 429) {
        return false;
      }
      if (status >= 400) {
        // Refus métier : réessayer ne changerait rien, le serveur fait foi.
        debugPrint('Requête refusée ($status) : ${request.path}');
      }
      await _dao.removeRequest(request.id);
    }
    return true;
  }

  Future<void> _pull() async {
    final snapshot = await api.fetchSnapshot();
    if (await _dao.replaceFromServer(snapshot, actorId: identity.id)) {
      await claims.reload();
      await messages.reload();
    } else {
      _again = true;
    }
  }

  void _setOnline(bool value) {
    if (_disposed || online == value) return;
    online = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _retry?.cancel();
    _socket?.dispose();
    users.removeListener(_onUserChanged);
    super.dispose();
  }
}
