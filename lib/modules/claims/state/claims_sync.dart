import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

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
    _role = users.role;
    users.addListener(_onUserChanged);
  }

  /// Sans `--dart-define=API_URL=...`, l'application reste locale.
  static ClaimsSync? start({
    required ClaimStore claims,
    required MessageStore messages,
    required UserStore users,
  }) {
    const url = String.fromEnvironment('API_URL');
    if (url.isEmpty) return null;
    final sync = ClaimsSync(
      api: ClaimsApi(url),
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
  Future<void>? _running;
  late UserRole _role;
  Timer? _timer;
  io.Socket? _socket;

  ApiIdentity get identity => (
    id: users.role == UserRole.driver
        ? 'demo-driver'
        : 'demo-${users.role.name}',
    role: users.role.name,
    name: users.userName,
  );

  Future<void> _run() async {
    await Future.wait([claims.saved, messages.saved]);
    connect();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => synchronize());
    await synchronize();
  }

  /// Ouvre le canal temps réel : le serveur prévient à chaque changement.
  void connect() {
    _socket?.dispose();
    final user = identity;
    _socket = io.io(
      api.baseUrl,
      io.OptionBuilder()
          .setPath('/api/claims/socket')
          .setTransports(['websocket'])
          .setAuth({'userId': user.id, 'role': user.role, 'name': user.name})
          .build(),
    )..on('claims:changed', (_) => synchronize());
  }

  void _onUserChanged() {
    if (users.role == _role) return;
    _role = users.role;
    if (_socket != null) connect();
    unawaited(synchronize());
  }

  /// Ajoute une requête à la file. Elle partira dès que possible.
  Future<void> enqueue(
    String path, {
    Map<String, dynamic> body = const {},
    bool multipart = false,
    String? filePath,
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
    for (final request in await _dao.pendingRequests()) {
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
    final snapshot = await api.fetchSnapshot(identity);
    if (await _dao.replaceFromServer(snapshot)) {
      await claims.reload();
      await messages.reload();
    } else {
      _again = true;
    }
  }

  void _setOnline(bool value) {
    if (online == value) return;
    online = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _socket?.dispose();
    users.removeListener(_onUserChanged);
    super.dispose();
  }
}
