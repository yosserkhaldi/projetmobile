import 'package:mon_constat_digital/modules/users/models/app_user.dart';

class ClaimNotification {
  ClaimNotification({
    required this.id,
    required this.body,
    required this.audience,
    required this.createdAt,
    this.claimId,
    this.read = false,
  });

  final String id, body;
  final UserRole audience;
  final DateTime createdAt;
  final String? claimId;
  bool read;
}
