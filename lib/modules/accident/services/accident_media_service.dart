import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AccidentMediaService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> capturePhoto(String evidenceName) async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (photo == null) return null;

    final documents = await getApplicationDocumentsDirectory();
    final folder = Directory(path.join(documents.path, 'accident_evidence'));
    await folder.create(recursive: true);
    final safeName = evidenceName.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );
    final destination = path.join(
      folder.path,
      '${safeName}_${DateTime.now().millisecondsSinceEpoch}${path.extension(photo.path)}',
    );
    return (await File(photo.path).copy(destination)).path;
  }
}
