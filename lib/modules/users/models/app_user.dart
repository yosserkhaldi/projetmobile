enum UserRole { driver, agent, admin }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
    UserRole.driver => 'Conducteur',
    UserRole.agent => "Agent d'assurance",
    UserRole.admin => 'Administrateur',
  };
}

class AppUser {
  AppUser(this.name, this.email, this.role, {this.active = true});
  String name, email;
  UserRole role;
  bool active;
}
