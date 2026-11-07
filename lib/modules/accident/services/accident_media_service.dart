import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

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

  Future<String?> captureVideo() async {
    final video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 30),
    );
    if (video == null) return null;
    return _copyToEvidence(video.path, 'scene_video');
  }

  Future<String> voiceNoteDestination() async {
    final documents = await getApplicationDocumentsDirectory();
    final folder = Directory(path.join(documents.path, 'accident_evidence'));
    await folder.create(recursive: true);
    return path.join(
      folder.path,
      'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
  }

  Future<String> _copyToEvidence(String source, String name) async {
    final documents = await getApplicationDocumentsDirectory();
    final folder = Directory(path.join(documents.path, 'accident_evidence'));
    await folder.create(recursive: true);
    final destination = path.join(
      folder.path,
      '${name}_${DateTime.now().millisecondsSinceEpoch}${path.extension(source)}',
    );
    return (await File(source).copy(destination)).path;
  }
}

class AccidentVoiceRecorder {
  final AudioRecorder _recorder = AudioRecorder();

  Future<bool> start(String destination) async {
    if (!await _recorder.hasPermission()) return false;
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: destination,
    );
    return true;
  }

  Future<String?> stop() => _recorder.stop();

  Future<void> cancel() => _recorder.cancel();

  Future<void> dispose() => _recorder.dispose();
}
