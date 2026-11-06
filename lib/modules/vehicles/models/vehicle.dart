class Vehicle {
  Vehicle({
    required this.plate,
    required this.brand,
    required this.model,
    required this.year,
    required this.policy,
    required this.expiry,
    this.archived = false,
  });
  String plate, brand, model, year, policy, expiry;
  bool archived;
}
