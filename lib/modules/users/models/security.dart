/// Appareil connecté au compte.
class DeviceSession {
  const DeviceSession({
    required this.id,
    required this.deviceName,
    required this.lastUsedAt,
    required this.createdAt,
    required this.current,
  });

  factory DeviceSession.fromJson(Map<String, dynamic> json) => DeviceSession(
    id: json['id'] as String,
    deviceName: json['deviceName'] as String?,
    lastUsedAt: DateTime.parse(json['lastUsedAt'] as String).toLocal(),
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    current: json['current'] as bool,
  );

  final String id;
  final String? deviceName;
  final DateTime lastUsedAt, createdAt;

  /// L'appareil qui fait la requête.
  final bool current;
}

/// Tentative de connexion, réussie ou non.
class LoginEvent {
  const LoginEvent({
    required this.success,
    required this.method,
    required this.createdAt,
    this.reason,
    this.deviceName,
  });

  factory LoginEvent.fromJson(Map<String, dynamic> json) => LoginEvent(
    success: json['success'] as bool,
    method: json['method'] as String,
    reason: json['reason'] as String?,
    deviceName: json['deviceName'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
  );

  final bool success;

  /// `password`, `biometric` ou `register`.
  final String method;

  /// Pour un échec : `wrong_password`, `locked` ou `suspended`.
  final String? reason;
  final String? deviceName;
  final DateTime createdAt;
}
