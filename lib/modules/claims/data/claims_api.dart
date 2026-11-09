import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/modules/claims/models/chat_message.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_insight.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_notification.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

/// Auteur d'un changement en attente. L'API s'appuie sur le jeton du module 1.
typedef ApiIdentity = ({String id, String role, String name});

class ServerSnapshot {
  const ServerSnapshot(
    this.claims,
    this.notifications,
    this.messages, {
    this.insights = const {},
  });
  final List<Claim> claims;
  final List<ClaimNotification> notifications;
  final List<ChatMessage> messages;
  final Map<String, ClaimInsight> insights;
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
    this.fileBytes,
    this.fileName,
  });

  final String id, method, path;
  final ApiIdentity identity;
  final Map<String, dynamic> body;
  final bool multipart;
  final String? filePath, fileName;
  final Uint8List? fileBytes;
}

class ClaimsApi {
  ClaimsApi(this._client);

  final ApiClient _client;

  static const _root = '/claims';
  static const _fileTimeout = Duration(seconds: 60);

  /// Un assistant peut lire plusieurs fois le dossier avant de répondre.
  static const _aiTimeout = Duration(seconds: 120);

  /// Adresse du serveur, sans le préfixe `/api` des routes.
  String get socketUrl => _client.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

  String? get accessToken => _client.accessToken;

  /// Renvoie le code HTTP. Une erreur réseau remonte en exception.
  Future<int> send(ApiRequest request) async {
    final headers = {'Idempotency-Key': request.id};
    final path = '$_root${request.path}';
    if (!request.multipart) {
      final response = await _client.send(
        path,
        (uri) => http.Request(request.method, uri)
          ..headers.addAll(headers)
          ..headers['content-type'] = 'application/json'
          ..body = jsonEncode(request.body),
      );
      return response.statusCode;
    }
    final bytes = await _fileBytes(request);
    final response = await _client.send(path, timeout: _fileTimeout, (uri) {
      final multipart = http.MultipartRequest(request.method, uri)
        ..headers.addAll(headers);
      request.body.forEach((key, value) {
        if (value != null) multipart.fields[key] = '$value';
      });
      if (bytes != null) {
        multipart.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: request.fileName,
          ),
        );
      }
      return multipart;
    });
    return response.statusCode;
  }

  /// Un fichier disparu de l'appareil ne doit pas bloquer la file.
  Future<List<int>?> _fileBytes(ApiRequest request) async {
    final bytes = request.fileBytes;
    if (bytes != null) return bytes;
    final path = request.filePath;
    if (path == null) return null;
    try {
      final file = await http.MultipartFile.fromPath('file', path);
      return await file.finalize().toBytes();
    } catch (_) {
      return null;
    }
  }

  /// [kind] vaut `document` ou `message`.
  Future<Uint8List> download(String kind, String id) =>
      _client.getBytes('$_root/files/$kind/$id');

  Future<ServerSnapshot> fetchSnapshot() async {
    final json = await _client.get('$_root/sync') as Map<String, dynamic>;
    List<Map<String, dynamic>> rows(String key) =>
        (json[key] as List<dynamic>).cast<Map<String, dynamic>>();
    return ServerSnapshot(
      rows('claims').map(_claim).toList(),
      rows('notifications').map(_notification).toList(),
      rows('messages').map(_message).toList(),
      insights: {
        for (final MapEntry(:key, :value)
            in (json['insights'] as Map<String, dynamic>? ?? const {}).entries)
          key: ClaimInsight.fromJson(value as Map<String, dynamic>),
      },
    );
  }

  Future<Map<String, dynamic>> _ai(String path, [Object? body]) async =>
      await _client.post('$_root$path', body: body ?? {}, timeout: _aiTimeout)
          as Map<String, dynamic>;

  /// [messages] : échanges précédents, le dernier étant la question.
  Future<AiAnswer> askAssistant(
    String claimId,
    List<({String role, String content})> messages,
  ) async {
    final json = await _ai('/$claimId/ai/assistant', {
      'messages': [
        for (final m in messages) {'role': m.role, 'content': m.content},
      ],
    });
    return (text: json['answer'] as String, by: _author(json));
  }

  Future<AiAnswer> summarize(String claimId) async {
    final json = await _ai('/$claimId/ai/summary');
    return (text: json['summary'] as String, by: _author(json));
  }

  /// Le modèle qui a répondu, ou null pour une réponse des règles.
  String? _author(Map<String, dynamic> json) =>
      json['source'] == 'rules' ? null : json['by'] as String? ?? 'IA';

  Future<List<String>> suggestReplies(String claimId) async =>
      _strings((await _ai('/$claimId/ai/replies'))['replies']);

  Future<Map<String, dynamic>> analytics() async =>
      await _client.get('$_root/analytics') as Map<String, dynamic>;

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
      expertPhone: row['expertPhone'] as String?,
      expertPlace: row['expertPlace'] as String?,
      expertKind: row['expertKind'] as String?,
      appointmentState: row['appointmentState'] as String?,
      appointmentBy: row['appointmentBy'] as String?,
      appointmentNote: row['appointmentNote'] as String?,
      companyId: row['companyId'] as String?,
      constatId: row['constatId'] as String?,
      responsibility: row['responsibility'] as int?,
      indemnity: (row['indemnity'] as num?)?.toDouble(),
      decisionReason: row['decisionReason'] as String?,
    );
    claim.circumstances.addAll(_strings(row['circumstances']));
    claim.impactZones.addAll(_strings(row['impactZones']));
    claim.circumstancesB.addAll(_strings(row['circumstancesB']));

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
              analysis: d['analysis'] == null
                  ? null
                  : DocumentAnalysis.fromJson(
                      d['analysis'] as Map<String, dynamic>,
                    ),
              analysisJson: d['analysis'] == null
                  ? null
                  : jsonEncode(d['analysis']),
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
