import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import 'token_storage.dart';

/// En-têtes qui identifient ce téléphone auprès de l'API :
/// liste « Mes appareils » et alertes de connexion depuis un nouvel appareil.
///
/// L'identifiant est aléatoire, créé une fois et gardé sur le téléphone. Il
/// survit à la déconnexion, sinon chaque reconnexion déclencherait une alerte.
Future<Map<String, String>> loadDeviceHeaders(SessionStorage storage) async {
  const key = 'device_id';
  var id = await storage.read(key);
  if (id == null) {
    final random = Random.secure();
    id = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await storage.write(key, id);
  }
  final name = await _deviceName().timeout(
    const Duration(seconds: 2),
    onTimeout: () => 'Appareil',
  );
  return {'X-Device-Id': id, 'X-Device-Name': name};
}

typedef DeviceHeadersLoader =
    Future<Map<String, String>> Function(SessionStorage storage);

Future<String> _deviceName() async {
  try {
    final info = DeviceInfoPlugin();
    if (kIsWeb) {
      final web = await info.webBrowserInfo;
      return '${web.browserName.name} (web)';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final android = await info.androidInfo;
        final brand = android.manufacturer.toUpperCase();
        return android.model.toUpperCase().startsWith(brand)
            ? android.model
            : '$brand ${android.model}';
      case TargetPlatform.iOS:
        final ios = await info.iosInfo;
        return ios.name.isNotEmpty ? ios.name : ios.model;
      default:
        return defaultTargetPlatform.name;
    }
  } catch (_) {
    // Tests et plateformes sans le plugin.
    return 'Appareil';
  }
}
