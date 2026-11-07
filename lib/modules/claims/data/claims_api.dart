import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:mon_constat_digital/modules/claims/models/chat_message.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_notification.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

/// Identité envoyée à l'API, à remplacer par le jeton JWT du module 1.
typedef ApiIdentity = ({String id, String role, String name});

class ServerSnapshot {
  const ServerSnapshot(this.claims, this.notifications, this.messages);
  final List<Claim> claims;
  final List<ClaimNotification> notifications;
  final List<ChatMessage> messages;
}

/// Une requête en attente, telle que stockée dans la file d'envoi.
class ApiRequest {
  const ApiRequest({
    required this.id,
    required this.method,
    required this.path,
    required this.identity,
    this.body = const {},
    this.multipart = false,
    this.filePath,
  });

  final String id, method, path;
  final ApiIdentity identity;
  final Map<String, dynamic> body;
  final bool multipart;
  final String? filePath;
}

class ClaimsApi {
  ClaimsApi(this.baseUrl, {http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static const _root = '/api/claims';

  Map<String, String> _headers(ApiIdentity identity) => {
    'x-user-id': identity.id,
    'x-user-role': identity.role,
    'x-user-name': Uri.encodeComponent(identity.name),
  };

  /// Renvoie le code HTTP. Une erreur réseau remonte en exception.
  Future<int> send(ApiRequest request) async {
    final uri = Uri.parse('$baseUrl$_root${request.path}');
    final headers = {
      ..._headers(request.identity),
      'Idempotency-Key': request.id,
    };
    if (!request.multipart) {
      final response = await _client.post(
        uri,
        headers: {...headers, 'content-type': 'application/json'},
        body: jsonEncode(request.body),
      );
      return response.statusCode;
    }
    final multipart = http.MultipartRequest(request.method, uri)
      ..headers.addAll(headers);
    request.body.forEach((key, value) {
      if (value != null) multipart.fields[key] = '$value';
    });
    final file = await _file(request.filePath);
    if (file != null) multipart.files.add(file);
    final response = await _client.send(multipart);
    await response.stream.drain<void>();
    return response.statusCode;
  }

  /// Un fichier disparu de l'appareil ne doit pas bloquer la file.
  Future<http.MultipartFile?> _file(String? path) async {
    if (path == null) return null;
    try {
      return await http.MultipartFile.fromPath('file', path);
    } catch (_) {
      return null;
    }
  }

  /// [kind] vaut `document` ou `message`.
  Future<Uint8List> download(
    String kind,
    String id,
    ApiIdentity identity,
  ) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$_root/files/$kind/$id'),
      headers: _headers(identity),
    );
    if (response.statusCode != 200) {
      throw http.ClientException('Téléchargement : ${response.statusCode}');
    }
    return response.bodyBytes;
  }

  Future<ServerSnapshot> fetchSnapshot(ApiIdentity identity) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$_root/sync'),
      headers: _headers(identity),
    );
    if (response.statusCode != 200) {
      throw http.ClientException('Synchronisation : ${response.statusCode}');
    }
    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    List<Map<String, dynamic>> rows(String key) =>
        (json[key] as List<dynamic>).cast<Map<String, dynamic>>();
    return ServerSnapshot(
      rows('claims').map(_claim).toList(),
      rows('notifications').map(_notification).toList(),
      rows('messages').map(_message).toList(),
    );
  }

  DateTime _date(Object? value) => DateTime.parse(value! as String).toLocal();

  List<String> _strings(Object? value) =>
      (value as List<dynamic>? ?? const []).cast<String>();

  Claim _claim(Map<String, dynamic> row) {
    final appointment = row['expertAppointment'];
    final claim = Claim(
      id: row['id'] as String,
      type: row['type'] as String,
      place: row['place'] as String,
      date: row['date'] as String,
      status: row['status'] as String,
      severity: row['severity'] as String,
      observations: row['observations'] as String? ?? '',
      agentName: row['agentName'] as String?,
      expertName: row['expertName'] as String?,
      expertAppointment: appointment == null ? null : _date(appointment),
      responsibility: row['responsibility'] as int?,
      indemnity: (row['indemnity'] as num?)?.toDouble(),
      decisionReason: row['decisionReason'] as String?,
    );
    claim.circumstances.addAll(_strings(row['circumstances']));
    claim.impactZones.addAll(_strings(row['impactZones']));

    final events = (row['events'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    claim.timeline
      ..clear()
      ..addAll(events.map((e) => e['label'] as String));
    claim.timelineDates.addAll({
      for (final (index, event) in events.indexed)
        index: _date(event['createdAt']),
    });
    claim.documents.addAll(
      (row['documents'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(
            (d) => ClaimDocument(
              id: d['id'] as String,
              name: d['name'] as String,
              kind: d['kind'] as String,
              requestId: d['requestId'] as String?,
            ),
          ),
    );
    claim.requests.addAll(
      (row['requests'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(
            (r) => DocumentRequest(
              id: r['id'] as String,
              label: r['label'] as String,
              note: r['note'] as String? ?? '',
              documentId: r['documentId'] as String?,
            ),
          ),
    );
    return claim;
  }

  ClaimNotification _notification(Map<String, dynamic> row) =>
      ClaimNotification(
        id: row['id'] as String,
        body: row['body'] as String,
        audience: UserRole.values.byName(row['audience'] as String),
        claimId: row['claimId'] as String?,
        createdAt: _date(row['createdAt']),
        read: row['read'] as bool,
      );

  ChatMessage _message(Map<String, dynamic> row) => ChatMessage(
    id: row['id'] as String,
    claimId: row['claimId'] as String,
    author: row['author'] as String,
    senderRole: UserRole.values.byName(row['senderRole'] as String),
    text: row['body'] as String,
    sentAt: _date(row['sentAt']),
    attachmentName: row['attachmentName'] as String?,
    read: row['read'] as bool,
  );
}
