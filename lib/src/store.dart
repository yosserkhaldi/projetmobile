import 'package:flutter/material.dart';

enum UserRole { driver, agent, admin }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
    UserRole.driver => 'Conducteur',
    UserRole.agent => "Agent d'assurance",
    UserRole.admin => 'Administrateur',
  };
}

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

class Claim {
  Claim({
    required this.id,
    required this.type,
    required this.place,
    required this.date,
    this.status = 'Brouillon',
    this.severity = 'Matériel',
  });
  final String id;
  String type, place, date, status, severity;
  final List<String> timeline = ['Brouillon créé'];
  final List<String> documents = [];
}

class ChatMessage {
  ChatMessage(this.author, this.text, {this.read = true});
  final String author, text;
  bool read;
}

class AppUser {
  AppUser(this.name, this.email, this.role, {this.active = true});
  String name, email;
  UserRole role;
  bool active;
}

class AppStore extends ChangeNotifier {
  UserRole role = UserRole.driver;
  String userName = 'Sami Ben Ali';
  String language = 'Français';
  bool biometric = false;
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
  final claims = <Claim>[
    Claim(
      id: 'SIN-2026-0418',
      type: 'Collision',
      place: 'Avenue Habib Bourguiba, Tunis',
      date: '12/10/2026 18:40',
      status: 'En instruction',
    ),
  ];
  final users = <AppUser>[
    AppUser('Sami Ben Ali', 'sami@example.com', UserRole.driver),
    AppUser('Leïla Mansour', 'leila@assurance.tn', UserRole.agent),
    AppUser('Admin MCD', 'admin@monconstat.tn', UserRole.admin),
  ];
  final messages = <ChatMessage>[
    ChatMessage(
      "Agent Leïla",
      'Bonjour, merci de joindre le devis de réparation.',
    ),
    ChatMessage('Sami', 'Je vous le transmets aujourd’hui.'),
  ];
  final notifications = <String>[
    'Votre dossier SIN-2026-0418 est en instruction.',
    'Votre contrat expire dans 7 jours.',
  ];

  void setRole(UserRole value) {
    role = value;
    notifyListeners();
  }

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

  void addClaim(Claim value) {
    claims.insert(0, value);
    notifyListeners();
  }

  void updateClaim(Claim claim, String status) {
    claim.status = status;
    claim.timeline.add(status);
    notifications.insert(0, '${claim.id} : $status');
    notifyListeners();
  }

  void addDocument(Claim claim) {
    claim.documents.add('Document-${claim.documents.length + 1}.pdf');
    notifyListeners();
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    messages.add(ChatMessage(userName, text.trim()));
    notifyListeners();
  }

  void toggleUser(AppUser user) {
    user.active = !user.active;
    notifyListeners();
  }

  void updateProfile(String name, String lang, bool bio) {
    userName = name;
    language = lang;
    biometric = bio;
    notifyListeners();
  }
}
