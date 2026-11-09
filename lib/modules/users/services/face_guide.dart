import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mon_constat_digital/modules/users/models/liveness.dart';

/// Ce que le téléphone voit sur une image de la caméra.
typedef FacePose = ({int faces, double yaw});

/// Détection du visage sur le téléphone, pour guider la vérification et
/// prendre les photos au bon moment. La décision reste celle du serveur.
abstract class FaceGuide {
  /// Nombre de visages et rotation de la tête du plus grand (degrés), ou
  /// null si aucun visage.
  Future<FacePose?> poseOf(Uint8List jpeg);
  Future<void> close();
}

/// ML Kit, modèle livré avec l'application : marche sans les services
/// Google (téléphones Huawei récents).
class MlKitFaceGuide implements FaceGuide {
  final _detector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );
  int _frame = 0;

  @override
  Future<FacePose?> poseOf(Uint8List jpeg) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/liveness_${_frame++ % 2}.jpg');
    await file.writeAsBytes(jpeg, flush: true);
    final faces = await _detector.processImage(
      InputImage.fromFilePath(file.path),
    );
    if (faces.isEmpty) return null;
    final main = faces.reduce(
      (a, b) =>
          a.boundingBox.width * a.boundingBox.height >=
              b.boundingBox.width * b.boundingBox.height
          ? a
          : b,
    );
    return (faces: faces.length, yaw: main.headEulerAngleY ?? 0);
  }

  @override
  Future<void> close() => _detector.close();
}

/// ML Kit sur Android et iOS ; ailleurs (web, ordinateur), pas de guide :
/// compte à rebours.
FaceGuide? deviceFaceGuide() {
  if (kIsWeb) return null;
  if (!Platform.isAndroid && !Platform.isIOS) return null;
  return MlKitFaceGuide();
}

/// Seuils de la pose attendue, en degrés de rotation de la tête.
const centerMaxYaw = 12.0;
const turnMinYaw = 20.0;

/// La pose correspond-elle à la consigne ? Pour la seconde rotation, le sens
/// doit être l'inverse de la première (le sens exact dépend du miroir de la
/// caméra, comme côté serveur).
bool poseMatches(LivenessStep step, FacePose pose, {double? firstTurnSign}) {
  if (pose.faces != 1) return false;
  final yaw = pose.yaw;
  if (step == LivenessStep.center) return yaw.abs() <= centerMaxYaw;
  if (yaw.abs() < turnMinYaw) return false;
  return firstTurnSign == null || yaw.sign != firstTurnSign;
}
