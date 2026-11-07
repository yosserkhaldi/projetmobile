import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/modules/accident/services/driving_license_ocr_service.dart';

void main() {
  test('extrait les champs principaux d’un permis OCR', () {
    const text = '''
REPUBLIQUE TUNISIENNE
PERMIS DE CONDUIRE
Nom et prénom : AMINA BEN SALEM
N° : 12345678
12/03/2019
Valable jusqu'au 12/03/2029
''';

    final result = DrivingLicenseOcrService().extract(text);

    expect(result.fullName, 'AMINA BEN SALEM');
    expect(result.licenseNumber, '12345678');
    expect(result.expiryDate, '12/03/2029');
  });
  test('assemble le nom et le prénom sur des lignes séparées', () {
    const text = '''
RÉPUBLIQUE TUNISIENNE
PERMIS DE CONDUIRE
1. Nom
BEN SALEM
2. Prénom
AMINA
N° 12345678
Valable jusqu'au 12/03/2029
''';

    final result = DrivingLicenseOcrService().extract(text);

    expect(result.fullName, 'BEN SALEM AMINA');
  });

  test('extrait le nom complet présent sur la même ligne', () {
    const text = 'Full name: YOUSSEF BEN AMOR\nExpiry 08/11/2030';

    final result = DrivingLicenseOcrService().extract(text);

    expect(result.fullName, 'YOUSSEF BEN AMOR');
  });
}
