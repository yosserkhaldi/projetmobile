import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/widgets/motion.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

const vehicleExpertise = 'Véhicule';
const bodilyExpertise = 'Corporelle';

/// Un piéton blessé n'a pas de véhicule à présenter : l'expertise est
/// médicale. Même règle que le serveur.
String defaultExpertKind(Claim claim) =>
    claim.type == 'Piéton' ? bodilyExpertise : vehicleExpertise;

/// « mar. 12 nov. 2026 · 10:00 », dans la langue de l'écran.
String formatSlot(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return '${DateFormat.yMMMEd(locale).format(date)} · '
      '${DateFormat.Hm(locale).format(date)}';
}

/// Créneaux ouvrables proposés d'un geste : du lundi au vendredi à 9 h,
/// 11 h et 14 h 30, le samedi matin, à partir de demain.
List<DateTime> suggestedSlots({DateTime? now, DateTime? avoid, int count = 4}) {
  final start = now ?? DateTime.now();
  const times = [(9, 0), (11, 0), (14, 30)];
  final slots = <DateTime>[];
  for (var day = 1; slots.length < count && day < 21; day++) {
    final date = DateTime(start.year, start.month, start.day + day);
    if (date.weekday == DateTime.sunday) continue;
    final hours = date.weekday == DateTime.saturday ? times.take(2) : times;
    // Un créneau par jour, l'heure tourne : le choix reste varié.
    final (h, m) = hours.elementAt(slots.length % hours.length);
    final slot = DateTime(date.year, date.month, date.day, h, m);
    if (avoid != null && slot == avoid) continue;
    slots.add(slot);
  }
  return slots;
}

/// Rendez-vous d'expertise, pour le conducteur comme pour l'agent.
class ExpertiseCard extends StatelessWidget {
  const ExpertiseCard(this.claim, {required this.role, super.key});
  final Claim claim;
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final palette = context.palette;
    final bodily = claim.expertKind == bodilyExpertise;
    final active = claim.status == ClaimStatus.expertise;
    final myTurn = active && claim.awaitsAnswerFrom(role.name);
    final confirmed = claim.appointmentConfirmed;
    final color = bodily ? ClaimsColors.pink : ClaimsColors.violet;
    final when = claim.expertAppointment;

    final (badge, badgeColor) = confirmed
        ? (t.claimsSlotConfirmed, ClaimsColors.teal)
        : myTurn
        ? (t.claimsSlotYourTurn, ClaimsColors.amber)
        : role == UserRole.driver
        ? (t.claimsSlotWaitingAgent, ClaimsColors.sky)
        : (t.claimsSlotWaitingDriver, ClaimsColors.sky);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: BorderDirectional(start: BorderSide(color: color, width: 5)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: .18),
                  foregroundColor: color,
                  child: Icon(
                    bodily ? Icons.healing_outlined : Icons.directions_car,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bodily
                            ? t.claimsExpertiseBody
                            : t.claimsExpertiseVehicle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (active && claim.appointmentState != null) ...[
                        const SizedBox(height: 4),
                        _Badge(badge, badgeColor, pulse: myTurn),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (when != null)
              _Line(
                Icons.event,
                formatSlot(context, when),
                bold: true,
                color: color,
              ),
            _Line(
              Icons.place_outlined,
              claim.expertPlace ?? t.claimsPlaceFromExpert,
              muted: claim.expertPlace == null,
            ),
            if (claim.expertName != null)
              _Line(
                Icons.badge_outlined,
                [
                  claim.expertName!,
                  if (claim.expertPhone != null) claim.expertPhone!,
                ].join(' · '),
              ),
            if (claim.appointmentNote != null) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: palette.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: t.claimsLabelColon(
                          claim.appointmentBy == UserRole.driver.name
                              ? t.claimsFromDriver
                              : t.claimsFromAgent,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: claim.appointmentNote),
                    ],
                  ),
                ),
              ),
            ],
            if (role == UserRole.driver && active) ...[
              const SizedBox(height: 12),
              Text(
                t.claimsToBring,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              for (final item
                  in bodily
                      ? [
                          t.claimsBringId,
                          t.claimsBringCertificates,
                          t.claimsBringPrescriptions,
                        ]
                      : [
                          t.claimsBringVehicle,
                          t.claimsBringRegistration,
                          t.claimsBringLicence,
                          t.claimsBringInsurance,
                        ])
                _Line(Icons.check_circle_outline, item, color: color),
            ],
            if (myTurn) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: ClaimsColors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => AppScope.of(
                    context,
                  ).claims.acceptAppointment(claim, role),
                  icon: const Icon(Icons.check),
                  label: Text(t.claimsAccept),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => proposeOtherSlot(context, claim, role),
                  icon: const Icon(Icons.schedule),
                  label: Text(t.claimsProposeOther),
                ),
              ),
            ] else if (active && role == UserRole.driver && confirmed)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => proposeOtherSlot(context, claim, role),
                  icon: const Icon(Icons.schedule),
                  label: Text(t.claimsCannotCome),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(
    this.icon,
    this.text, {
    this.bold = false,
    this.muted = false,
    this.color,
  });
  final IconData icon;
  final String text;
  final bool bold, muted;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color ?? context.palette.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : null,
              fontSize: bold ? 15 : null,
              color: muted ? context.palette.textMuted : null,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, this.color, {this.pulse = false});
  final String text;
  final Color color;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: .6)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    return pulse ? Breathing(child: badge) : badge;
  }
}

/// Feuille « Proposer un autre créneau » : créneaux suggérés, ou date et
/// heure au choix, avec un mot pour l'autre partie.
Future<void> proposeOtherSlot(
  BuildContext context,
  Claim claim,
  UserRole role,
) async {
  final store = AppScope.of(context).claims;
  final picked = await pickSlot(
    context,
    title: context.t.claimsProposeOther,
    initial: claim.expertAppointment,
    withNote: true,
  );
  if (picked == null) return;
  store.proposeAppointment(claim, role, picked.at, note: picked.note);
}

typedef PickedSlot = ({DateTime at, String note});

Future<PickedSlot?> pickSlot(
  BuildContext context, {
  required String title,
  DateTime? initial,
  bool withNote = false,
}) {
  final note = TextEditingController();
  final suggestions = suggestedSlots(avoid: initial);
  DateTime? chosen;
  return showModalBottomSheet<PickedSlot>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setState) {
        final t = sheetContext.t;
        Future<void> pickCustom() async {
          final base = chosen ?? initial ?? suggestions.first;
          final day = await showDatePicker(
            context: sheetContext,
            initialDate: base.isBefore(DateTime.now()) ? DateTime.now() : base,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 180)),
          );
          if (day == null || !sheetContext.mounted) return;
          final time = await showTimePicker(
            context: sheetContext,
            initialTime: TimeOfDay.fromDateTime(base),
          );
          if (time == null) return;
          setState(
            () => chosen = DateTime(
              day.year,
              day.month,
              day.day,
              time.hour,
              time.minute,
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                t.claimsSuggestedSlots,
                style: TextStyle(color: sheetContext.palette.textMuted),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final slot in suggestions)
                    ChoiceChip(
                      label: Text(formatSlot(sheetContext, slot)),
                      selected: chosen == slot,
                      selectedColor: ClaimsColors.violet.withValues(alpha: .25),
                      onSelected: (_) => setState(() => chosen = slot),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: pickCustom,
                icon: const Icon(Icons.edit_calendar),
                label: Text(
                  chosen != null && !suggestions.contains(chosen)
                      ? formatSlot(sheetContext, chosen!)
                      : t.claimsOtherDateTime,
                ),
              ),
              if (withNote) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: note,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: t.claimsNoteOptional),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: chosen == null
                    ? null
                    : () => Navigator.pop(sheetContext, (
                        at: chosen!,
                        note: note.text,
                      )),
                icon: const Icon(Icons.send),
                label: Text(t.claimsSendProposal),
              ),
            ],
          ),
        );
      },
    ),
  );
}
