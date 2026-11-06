import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/vehicles/models/vehicle.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).vehicles;
    return SafeArea(
      child: Column(
        children: [
          PageHead(
            'Véhicules & contrats',
            subtitle: '${s.vehicles.length} véhicule(s)',
            actions: [
              IconButton.filled(
                onPressed: () => _vehicleForm(context),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          Expanded(
            child: s.vehicles.isEmpty
                ? const Center(child: Text('Ajoutez votre premier véhicule'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: s.vehicles.length,
                    itemBuilder: (_, i) {
                      final v = s.vehicles[i];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const CircleAvatar(
                            child: Icon(Icons.directions_car),
                          ),
                          title: Text(
                            '${v.brand} ${v.model}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          subtitle: Text(
                            '${v.plate}\nPolice ${v.policy} • expire ${v.expiry}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (x) {
                              if (x == 'delete') {
                                s.removeVehicle(v);
                              } else if (x == 'archive') {
                                s.archiveVehicle(v);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'archive',
                                child: Text('Archiver'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Supprimer'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _vehicleForm(BuildContext context) {
    final fields = List.generate(6, (_) => TextEditingController());
    final labels = [
      'Immatriculation',
      'Marque',
      'Modèle',
      'Année',
      'N° de police',
      'Expiration JJ/MM/AAAA',
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ajouter un véhicule',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                fields.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: fields[i],
                    decoration: InputDecoration(labelText: labels[i]),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.document_scanner),
                label: const Text('Scanner carte grise / attestation'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  AppScope.of(context).vehicles.addVehicle(
                    Vehicle(
                      plate: fields[0].text,
                      brand: fields[1].text,
                      model: fields[2].text,
                      year: fields[3].text,
                      policy: fields[4].text,
                      expiry: fields[5].text,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
