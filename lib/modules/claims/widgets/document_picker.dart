import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

typedef PickedFile = ({String name, String? path});

/// Ouvre le sélecteur de fichiers. Remplaçable dans les tests.
Future<PickedFile?> Function() pickDocument = () async {
  final files = await FilePicker.pickFiles();
  if (files.isEmpty) return null;
  final file = files.first;
  return (name: file.name, path: kIsWeb ? null : file.path);
};
