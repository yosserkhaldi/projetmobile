import 'package:mon_constat_digital/modules/claims/data/ids.dart';
import 'package:mon_constat_digital/modules/claims/models/chat_message.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_notification.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

/// Données de démonstration, écrites dans SQLite au premier lancement.
const demoClaimId = 'SIN-2026-0418';

List<Claim> seedClaims() => [
  Claim(
      id: demoClaimId,
      type: 'Collision',
      place: 'Avenue Habib Bourguiba, Tunis',
      date: '12/10/2026 18:40',
      status: ClaimStatus.inReview,
      agentName: 'Leïla Mansour',
    )
    ..timeline.addAll([ClaimStatus.transmitted, ClaimStatus.inReview])
    ..circumstances.add('Changeait de file'),
];

List<ClaimNotification> seedNotifications() => [
  ClaimNotification(
    id: newId(),
    body: 'Votre dossier $demoClaimId est en instruction.',
    audience: UserRole.driver,
    claimId: demoClaimId,
    createdAt: DateTime(2026, 10, 13, 9),
  ),
  ClaimNotification(
    id: newId(),
    body: 'Votre contrat expire dans 7 jours.',
    audience: UserRole.driver,
    createdAt: DateTime(2026, 10, 12, 9),
  ),
];

List<ChatMessage> seedMessages() => [
  ChatMessage(
    id: newId(),
    claimId: demoClaimId,
    author: 'Agent Leïla',
    senderRole: UserRole.agent,
    text: 'Bonjour, merci de joindre le devis de réparation.',
    sentAt: DateTime(2026, 10, 13, 10),
    read: true,
  ),
  ChatMessage(
    id: newId(),
    claimId: demoClaimId,
    author: 'Sami Ben Ali',
    senderRole: UserRole.driver,
    text: 'Je vous le transmets aujourd’hui.',
    sentAt: DateTime(2026, 10, 13, 10, 5),
    read: true,
  ),
];
