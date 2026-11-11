import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/accident/l10n/accident_text.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_pdf_service.dart';
import 'package:mon_constat_digital/shared/widgets/drawing_pad.dart';

class AccidentReview extends StatelessWidget {
  const AccidentReview({required this.draft, this.driverA, super.key});
  final AccidentDraft draft;
  final ConstatDriverAData? driverA;
  static final _pdf = AccidentPdfService();

  ConstatDriverAData _resolveDriverA(BuildContext context) {
    if (driverA != null) return driverA!;
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (scope == null) return const ConstatDriverAData();
    final stores = scope.stores;
    final vehicles = stores.vehicles.vehicles;
    final selectedVehicle = draft.vehicleId != null
        ? (vehicles.where((v) => v.id == draft.vehicleId).firstOrNull ??
              vehicles.firstOrNull)
        : vehicles.firstOrNull;
    return ConstatDriverAData.fromUserAndVehicle(
      user: stores.users.currentUser,
      vehicle: selectedVehicle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedA = _resolveDriverA(context);
    final t = context.t;
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Divider(height: 32),
      Text(t.accReportCompleted, style: Theme.of(context).textTheme.titleLarge),
      Text(
        t.accReviewHint,
        style: TextStyle(color: context.palette.textMuted),
      ),
      const SizedBox(height: 14),
      _PdfActions(draft: draft, service: _pdf, driverA: resolvedA),
      const SizedBox(height: 14),
      _Section(
        title: t.accSectionAccident,
        icon: Icons.car_crash_outlined,
        rows: [
          (t.accPlace, draft.place),
          (t.accDateTime, ltr(_dateTime(draft.occurredAt))),
          (
            t.accType,
            '${t.accidentValue(draft.type)} • '
                '${t.accidentValue(draft.severity)}',
          ),
          (
            t.accConditions,
            [
              draft.weather,
              draft.road,
              draft.light,
            ].map(t.accidentValue).join(' • '),
          ),
          (
            t.accVehiclesInjured,
            t.accVehiclesInjuredValue(draft.vehicleCount, draft.injuredCount),
          ),
          if (draft.witnessName.isNotEmpty)
            (t.accWitness, '${draft.witnessName} ${draft.witnessPhone}'),
        ],
      ),
      _Section(
        title: t.accSectionDriverA,
        icon: Icons.directions_car_filled_outlined,
        rows: [
          if (resolvedA.fullName.isNotEmpty) (t.accName, resolvedA.fullName),
          if (resolvedA.phone.isNotEmpty) (t.accPhone, resolvedA.phone),
          if (resolvedA.licenseNumber.isNotEmpty)
            (t.accLicense, resolvedA.licenseNumber),
          if (resolvedA.vehicleLabel.isNotEmpty)
            (t.accVehicle, resolvedA.vehicleLabel),
          if (resolvedA.plate.isNotEmpty) (t.accPlate, resolvedA.plate),
          if (resolvedA.insurerName.isNotEmpty)
            (t.accInsurance, resolvedA.insurerName),
          if (resolvedA.policyNumber.isNotEmpty)
            (t.accPolicyNumber, resolvedA.policyNumber),
        ],
      ),
      _Section(
        title: t.accDriverB,
        icon: Icons.person_outline,
        rows: [
          (t.accName, draft.driverBName),
          if (draft.driverBPermit.isNotEmpty)
            (t.accLicense, draft.driverBPermit),
          if (draft.driverBPermitExpiry.isNotEmpty)
            (t.accLicenseExpiry, draft.driverBPermitExpiry),
          (t.accPlate, draft.driverBPlate),
          (t.accInsurance, draft.driverBInsurer),
          if (draft.driverBPolicy.isNotEmpty)
            (t.accPolicyNumber, draft.driverBPolicy),
        ],
      ),
      _Section(
        title: t.accStepCircumstances,
        icon: Icons.fact_check_outlined,
        rows: [
          // Cases et zones enregistrées en français, traduites à l'affichage.
          (t.accDriverA, t.accidentValues(draft.circumstancesA)),
          (t.accDriverB, t.accidentValues(draft.circumstancesB)),
          if (draft.observations.isNotEmpty)
            (t.accObservations, draft.observations),
          (t.accImpactZones, t.accidentValues(draft.impactZones)),
        ],
      ),
      _ReviewTitle(t.accPhotos),
      _PhotoGrid(draft: draft),
      const SizedBox(height: 16),
      _ReviewTitle(t.accStepSketch),
      DrawingPreview(
        strokes: draft.sketchStrokes,
        height: 160,
        emptyLabel: t.accSketchMissing,
      ),
      const SizedBox(height: 16),
      _ReviewTitle(t.accStepSignatures),
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(t.accDriverA),
                const SizedBox(height: 5),
                DrawingPreview(strokes: draft.driverASignature),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Text(t.accDriverB),
                const SizedBox(height: 5),
                DrawingPreview(strokes: draft.driverBSignature),
              ],
            ),
          ),
        ],
      ),
    ],
  );
  }

  static String _dateTime(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year} '
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

class _PdfActions extends StatefulWidget {
  const _PdfActions({
    required this.draft,
    required this.service,
    required this.driverA,
  });
  final AccidentDraft draft;
  final AccidentPdfService service;
  final ConstatDriverAData driverA;

  @override
  State<_PdfActions> createState() => _PdfActionsState();
}

class _PdfActionsState extends State<_PdfActions> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.accPdfFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    color: context.palette.primaryTint,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_as_pdf_outlined, color: context.palette.primaryText),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.t.accPdfTitle,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            context.t.accPdfHint,
            style: TextStyle(color: context.palette.textMuted),
          ),
          const SizedBox(height: 12),
          if (_busy)
            const LinearProgressIndicator()
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _run(
                      () => widget.service.preview(
                        widget.draft,
                        driverA: widget.driverA,
                      ),
                    ),
                    icon: const Icon(Icons.visibility_outlined),
                    label: Text(context.t.accPreview),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _run(
                      () => widget.service.share(
                        widget.draft,
                        driverA: widget.driverA,
                      ),
                    ),
                    icon: const Icon(Icons.share_outlined),
                    label: Text(context.t.accShare),
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.rows});
  final String title;
  final IconData icon;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.palette.primaryText),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const Divider(height: 20),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 105,
                    child: Text(
                      row.$1,
                      style: TextStyle(color: context.palette.textMuted),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.$2.isEmpty ? context.t.accNotProvided : row.$2,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class _ReviewTitle extends StatelessWidget {
  const _ReviewTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
  );
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.draft});
  final AccidentDraft draft;

  @override
  Widget build(BuildContext context) {
    final photos = draft.evidencePaths.entries
        .where(
          (entry) => entry.value != null && File(entry.value!).existsSync(),
        )
        .toList();
    if (photos.isEmpty) return Text(context.t.accNoPhotos);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(photos[index].value!), fit: BoxFit.cover),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Colors.black54,
                padding: const EdgeInsets.all(6),
                child: Text(
                  context.t.accidentValue(photos[index].key),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
