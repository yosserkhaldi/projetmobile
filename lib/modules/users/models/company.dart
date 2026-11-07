class Agency {
  const Agency({required this.id, required this.name, required this.city});

  factory Agency.fromJson(Map<String, dynamic> json) => Agency(
    id: json['id'] as String,
    name: json['name'] as String,
    city: json['city'] as String,
  );

  final String id, name, city;
}

class Company {
  const Company({required this.id, required this.name, required this.agencies});

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    id: json['id'] as String,
    name: json['name'] as String,
    agencies: (json['agencies'] as List)
        .map((agency) => Agency.fromJson(agency as Map<String, dynamic>))
        .toList(),
  );

  final String id, name;
  final List<Agency> agencies;
}
