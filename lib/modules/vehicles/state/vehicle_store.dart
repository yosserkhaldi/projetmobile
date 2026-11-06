import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/modules/vehicles/models/vehicle.dart';

class VehicleStore extends ChangeNotifier {
  final vehicles = <Vehicle>[
    Vehicle(
      plate: '215 تونس 4521',
      brand: 'Peugeot',
      model: '208',
      year: '2021',
      policy: 'POL-884521',
      expiry: '19/10/2026',
    ),
  ];

  void addVehicle(Vehicle value) {
    vehicles.add(value);
    notifyListeners();
  }

  void removeVehicle(Vehicle value) {
    vehicles.remove(value);
    notifyListeners();
  }

  void archiveVehicle(Vehicle value) {
    value.archived = !value.archived;
    notifyListeners();
  }
}
