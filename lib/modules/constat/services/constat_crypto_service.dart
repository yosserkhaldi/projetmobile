import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class ConstatCryptoService {
  const ConstatCryptoService();

  /// Calcule l'empreinte cryptographique SHA-256 des octets du document PDF.
  String computeSha256(Uint8List bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString().toLowerCase();
  }

  /// Calcule l'empreinte SHA-256 canonique des signatures manuscrites des 2 conducteurs.
  String computeSignaturesHash(
    List<List<Map<String, double>>> driverASignature,
    List<List<Map<String, double>>> driverBSignature,
  ) {
    final encoded = utf8.encode(
      jsonEncode({
        'a': driverASignature,
        'b': driverBSignature,
      }),
    );
    return sha256.convert(encoded).toString().toLowerCase();
  }

  /// Formate le hash pour un affichage lisible par blocs de 8 caractères.
  String formatHash(String hash) {
    if (hash.length != 64) return hash;
    final buffer = StringBuffer();
    for (int i = 0; i < hash.length; i += 8) {
      if (i > 0) buffer.write(' ');
      buffer.write(hash.substring(i, i + 8));
    }
    return buffer.toString();
  }
}

