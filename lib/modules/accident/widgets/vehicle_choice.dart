import 'package:flutter/material.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/vehicles/models/vehicle.dart';
import 'package:mon_constat_digital/modules/vehicles/screens/vehicle_form_screen.dart';

/// Véhicule du conducteur A (module 2), au début de la déclaration : son
/// assureur reçoit le constat et le sinistre, et un contrat expiré bloque la
/// déclaration.
class VehicleChoice extends StatelessWidget {
  const VehicleChoice({required this.draft, required this.onChanged, super.key});
  final AccidentDraft draft;
  final VoidCallback onChanged;

  /// Un seul véhicule : choisi d'office.
  static void preselect(AccidentDraft draft, List<Vehicle> vehicles) {
    if (draft.vehicleId == null && vehicles.length == 1) {
      draft.vehicleId = vehicles.single.id;
    }
  }

  /// Raison qui empêche de continuer, ou null.
  static String? problem(AccidentDraft draft, List<Vehicle> vehicles) {
    final vehicle = vehicles.where((v) => v.id == draft.vehicleId).firstOrNull;
    if (vehicle == null) {
      return 'Choisissez votre véhicule : son assureur reçoit le constat.';
    }
    if (vehicle.isInsuranceExpired) {
      return 'Le contrat d’assurance de ${vehicle.brand} ${vehicle.model} a expiré '
          'le ${_date(vehicle.insuranceExpiry)}. Renouvelez-le dans Véhicules avant de déclarer.';
    }
    return null;
  }

  static String _date(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return iso;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year}';
  }

  Future<void> _add(BuildContext context) async {
    final stores = AppScope.of(context);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VehicleFormScreen()),
    );
    preselect(draft, stores.vehicles.vehicles);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = AppScope.of(context).vehicles.vehicles;
    return Column(
      key: const ValueKey('vehicle-choice'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'VOTRE VÉHICULE',
          style: TextStyle(
            color: context.palette.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 8),
        if (vehicles.isEmpty)
          Card(
            color: context.palette.warningBg,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajoutez votre véhicule et son assureur : c’est à lui que le constat est transmis.',
                    style: TextStyle(
                      color: context.palette.warningText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    key: const ValueKey('add-vehicle'),
                    onPressed: () => _add(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter mon véhicule'),
                  ),
                ],
              ),
            ),
          ),
        for (final vehicle in vehicles)
          _VehicleTile(
            vehicle: vehicle,
            selected: draft.vehicleId == vehicle.id,
            onTap: () {
              draft.vehicleId = vehicle.id;
              onChanged();
            },
          ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });

  final Vehicle vehicle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final expired = vehicle.isInsuranceExpired;
    final insurer = vehicle.companyName ?? vehicle.insurerName;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? context.palette.primaryText : context.palette.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        key: ValueKey('vehicle-${vehicle.id}'),
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? context.palette.primaryText : context.palette.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model} · ${vehicle.plate}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      expired
                          ? 'Contrat expiré le ${VehicleChoice._date(vehicle.insuranceExpiry)}'
                          : '${insurer.isEmpty ? 'Assureur non renseigné' : insurer} · '
                                'jusqu’au ${VehicleChoice._date(vehicle.insuranceExpiry)}',
                      style: TextStyle(
                        color: expired ? context.palette.errorText : context.palette.textMuted,
                        fontWeight: expired ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
