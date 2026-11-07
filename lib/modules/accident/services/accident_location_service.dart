import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AccidentLocation {
  const AccidentLocation({
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  final String label;
  final double latitude;
  final double longitude;
  final double accuracy;
}

class AccidentLocationException implements Exception {
  const AccidentLocationException(this.message);
  final String message;
}

class AccidentLocationService {
  Future<AccidentLocation> determineLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const AccidentLocationException(
        'Activez la localisation GPS de l’appareil.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const AccidentLocationException(
        'La permission de localisation a été refusée.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const AccidentLocationException(
        'Autorisez la localisation dans les paramètres de l’application.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );

    return resolveCoordinates(
      position.latitude,
      position.longitude,
      accuracy: position.accuracy,
    );
  }

  Future<AccidentLocation> searchAddress(String address) async {
    final locations = await Geocoding().locationFromAddress(address);
    if (locations.isEmpty) {
      throw const AccidentLocationException('Adresse introuvable.');
    }
    final location = locations.first;
    return resolveCoordinates(location.latitude, location.longitude);
  }

  Future<AccidentLocation> resolveCoordinates(
    double latitude,
    double longitude, {
    double accuracy = 0,
  }) async {
    String label = _coordinatesLabel(latitude, longitude);
    try {
      final marks = await Geocoding().placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (marks.isNotEmpty) label = _placemarkLabel(marks.first, label);
    } catch (_) {
      // Les coordonnées restent utilisables si le géocodage est indisponible.
    }

    return AccidentLocation(
      label: label,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
    );
  }

  static String _coordinatesLabel(double latitude, double longitude) =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  static String _placemarkLabel(Placemark mark, String fallback) {
    final parts =
        <String?>[
              mark.street,
              mark.locality,
              mark.administrativeArea,
              mark.country,
            ]
            .whereType<String>()
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList();
    return parts.isEmpty ? fallback : parts.join(', ');
  }
}
