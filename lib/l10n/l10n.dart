import 'package:flutter/widgets.dart';

import 'package:mon_constat_digital/l10n/app_localizations.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

export 'package:mon_constat_digital/l10n/app_localizations.dart';

/// Textes traduits : `context.t.signIn`. Les fichiers sont dans `lib/l10n/*.arb`.
extension L10nContext on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this);
}

/// Garde un numéro ou un e-mail de gauche à droite dans une phrase en arabe.
String ltr(String value) =>
    '${String.fromCharCode(0x2066)}$value${String.fromCharCode(0x2069)}';

extension UserRoleText on UserRole {
  String labelIn(AppLocalizations t) => switch (this) {
    UserRole.driver => t.roleDriver,
    UserRole.agent => t.roleAgent,
    UserRole.admin => t.roleAdmin,
  };
}
