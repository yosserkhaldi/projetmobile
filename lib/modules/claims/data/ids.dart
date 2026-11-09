import 'dart:math';

final _random = Random.secure();

/// Identifiant créé sur l'appareil : il reste le même une fois sur le serveur.
String newId() => List.generate(
  16,
  (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();
