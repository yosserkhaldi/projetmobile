import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/modules/users/models/app_user.dart';

class UserStore extends ChangeNotifier {
  UserRole role = UserRole.driver;
  String userName = 'Sami Ben Ali';
  String language = 'Français';
  bool biometric = false;
  final users = <AppUser>[
    AppUser('Sami Ben Ali', 'sami@example.com', UserRole.driver),
    AppUser('Leïla Mansour', 'leila@assurance.tn', UserRole.agent),
    AppUser('Admin MCD', 'admin@monconstat.tn', UserRole.admin),
  ];

  void setRole(UserRole value) {
    role = value;
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
