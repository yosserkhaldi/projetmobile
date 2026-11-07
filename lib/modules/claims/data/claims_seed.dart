import 'package:mon_constat_digital/modules/claims/models/chat_message.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';

/// Données de démonstration, écrites dans SQLite au premier lancement.
const demoClaimId = 'SIN-2026-0418';

List<Claim> seedClaims() => [
  Claim(
    id: demoClaimId,
    type: 'Collision',
    place: 'Avenue Habib Bourguiba, Tunis',
    date: '12/10/2026 18:40',
    status: 'En instruction',
  ),
];

List<String> seedNotifications() => [
  'Votre dossier $demoClaimId est en instruction.',
  'Votre contrat expire dans 7 jours.',
];

List<ChatMessage> seedMessages() => [
  ChatMessage(
    'Agent Leïla',
    'Bonjour, merci de joindre le devis de réparation.',
  ),
  ChatMessage('Sami', 'Je vous le transmets aujourd’hui.'),
];
