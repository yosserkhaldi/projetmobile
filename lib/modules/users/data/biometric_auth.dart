import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Empreinte ou reconnaissance faciale échouée pour une autre raison qu'une
/// annulation. Le message peut être affiché.
class BiometricException implements Exception {
  const BiometricException(this.message);
  final String message;
}

/// Capteur biométrique de l'appareil. Remplacé par un faux dans les tests.
abstract class BiometricAuth {
  Future<bool> isAvailable();

  /// `true` si l'utilisateur est reconnu, `false` s'il annule.
  Future<bool> authenticate(String reason);
}

class DeviceBiometricAuth implements BiometricAuth {
  final _auth = LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      return await _auth.isDeviceSupported() &&
          (await _auth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (error) {
      switch (error.code) {
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.systemCanceled:
        case LocalAuthExceptionCode.timeout:
          return false;
        default:
          // La description du système est en anglais : message fixe en français.
          throw const BiometricException(
            'Empreinte ou reconnaissance faciale indisponible. '
            'Vérifiez les réglages de sécurité du téléphone.',
          );
      }
    }
  }
}
