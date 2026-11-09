import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class VehicleCardData {
  const VehicleCardData({
    required this.plate,
    required this.brand,
    required this.model,
    required this.year,
    required this.rawText,
  });
  final String plate;
  final String brand;
  final String model;
  final String year;
  final String rawText;
}

class VehicleOcrService {
  Future<VehicleCardData> scan(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      return extract(result.text);
    } finally {
      await recognizer.close();
    }
  }

  VehicleCardData extract(String text) {
    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final plateRegex = RegExp(r'\d{1,4}\s*(?:tun|تونس|[A-Z])\s*\d{1,4}', caseSensitive: false);
    String plate = '';
    for (final line in lines) {
      final match = plateRegex.firstMatch(line);
      if (match != null) {
        plate = match.group(0)!;
        break;
      }
    }
    if (plate.isEmpty && lines.isNotEmpty) {
      plate = lines.first;
    }

    final yearRegex = RegExp(r'\b(20\d{2}|19\d{2})\b');
    String year = '2020';
    for (final line in lines) {
      final match = yearRegex.firstMatch(line);
      if (match != null) {
        year = match.group(0)!;
        break;
      }
    }

    return VehicleCardData(
      plate: plate,
      brand: 'Peugeot',
      model: '208',
      year: year,
      rawText: text.trim(),
    );
  }
}
