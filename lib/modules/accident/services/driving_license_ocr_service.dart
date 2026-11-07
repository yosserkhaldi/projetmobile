import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class DrivingLicenseData {
  const DrivingLicenseData({
    required this.fullName,
    required this.licenseNumber,
    required this.expiryDate,
    required this.rawText,
  });
  final String fullName;
  final String licenseNumber;
  final String expiryDate;
  final String rawText;
}

class DrivingLicenseOcrService {
  Future<DrivingLicenseData> scan(String imagePath) async {
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

  DrivingLicenseData extract(String text) {
    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final dates = RegExp(
      r'\b(\d{2}[./-]\d{2}[./-](?:\d{2}|\d{4}))\b',
    ).allMatches(text).map((match) => match.group(1)!).toList();
    return DrivingLicenseData(
      fullName: _name(lines),
      licenseNumber: _licenseNumber(lines),
      expiryDate: dates.isEmpty
          ? ''
          : dates.last.replaceAll(RegExp(r'[.-]'), '/'),
      rawText: text.trim(),
    );
  }

  String _name(List<String> lines) {
    final fullName = _valueAfterLabel(
      lines,
      RegExp(
        r'^(?:\d+[.)-]?\s*)?(?:nom\s+et\s+pr[ée]nom|full\s*name)\s*[:.-]?\s*',
        caseSensitive: false,
      ),
    );
    if (_isNameValue(fullName)) return fullName;

    final surname = _valueAfterLabel(
      lines,
      RegExp(
        r'^(?:1[.)-]?\s*)?(?:nom|surname|last\s*name)\s*[:.-]?\s*',
        caseSensitive: false,
      ),
    );
    final givenNames = _valueAfterLabel(
      lines,
      RegExp(
        r'^(?:2[.)-]?\s*)?(?:pr[ée]noms?|given\s*names?|first\s*name)\s*[:.-]?\s*',
        caseSensitive: false,
      ),
    );
    final parts = [surname, givenNames].where(_isNameValue).toList();
    if (parts.isNotEmpty) {
      return parts.join(' ').replaceAll(RegExp(r'\s+'), ' ');
    }

    final candidates = lines.where((line) {
      final normalized = line.toLowerCase();
      return line.length >= 5 &&
          RegExp(r"^[A-ZÀ-ÖØ-Ý\s\-']+$").hasMatch(line) &&
          !normalized.contains('permis') &&
          !normalized.contains('conduire') &&
          !normalized.contains('tunisie') &&
          !normalized.contains('driving') &&
          !RegExp(r'\d').hasMatch(line);
    }).toList();
    return candidates.isEmpty ? '' : candidates.first;
  }

  bool _isNameValue(String value) =>
      value.trim().length >= 2 &&
      !RegExp(r'\d').hasMatch(value) &&
      RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ\s\-']+$").hasMatch(value.trim());

  String _licenseNumber(List<String> lines) {
    final labelled = _valueAfterLabel(
      lines,
      RegExp(
        r'^(?:n[o°.]?|num[ée]ro|permis|license\s*(?:no|number)?)\s*[:.-]?\s*',
        caseSensitive: false,
      ),
    );
    if (labelled.isNotEmpty && RegExp(r'\d').hasMatch(labelled)) {
      return labelled;
    }
    for (final line in lines) {
      final match = RegExp(
        r'\b[A-Z]{0,3}\s*\d{5,12}\b',
        caseSensitive: false,
      ).firstMatch(line);
      if (match != null) return match.group(0)!.replaceAll(' ', '');
    }
    return '';
  }

  String _valueAfterLabel(List<String> lines, RegExp label) {
    for (var index = 0; index < lines.length; index++) {
      if (!label.hasMatch(lines[index])) continue;
      final inline = lines[index].replaceFirst(label, '').trim();
      if (inline.isNotEmpty) return inline;
      if (index + 1 < lines.length) return lines[index + 1];
    }
    return '';
  }
}
