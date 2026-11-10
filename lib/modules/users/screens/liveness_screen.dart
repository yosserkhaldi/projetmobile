import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/models/liveness.dart';
import 'package:mon_constat_digital/modules/users/services/face_guide.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';

/// Caméra frontale utilisée par la vérification du visage. Remplaçable dans
/// les tests, où le plugin de caméra n'existe pas.
abstract class FaceCamera {
  Future<void> open();
  Widget preview();
  Future<Uint8List> capture();
  Future<void> close();
}

class DeviceFaceCamera implements FaceCamera {
  CameraController? _controller;

  @override
  Future<void> open() async {
    if (_controller?.value.isInitialized ?? false) return;
    final cameras = await availableCameras();
    if (cameras.isEmpty) throw CameraException('none', 'No camera');
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    // Résolution moyenne : assez pour l'IA, envoi rapide sur réseau mobile.
    final controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = controller;
    await controller.initialize();
  }

  @override
  Widget preview() {
    final controller = _controller!;
    final size = controller.value.previewSize;
    // Le capteur est en paysage : on remplit l'ovale en portrait.
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: size?.height ?? 480,
        height: size?.width ?? 640,
        child: CameraPreview(controller),
      ),
    );
  }

  @override
  Future<Uint8List> capture() async =>
      (await _controller!.takePicture()).readAsBytes();

  @override
  Future<void> close() async {
    await _controller?.dispose();
    _controller = null;
  }
}

enum _Phase { starting, capturing, analyzing, failed }

/// Vérification du visage (« liveness ») : une photo par consigne, dans
/// l'ordre tiré par l'API, puis analyse par l'IA du serveur. Renvoie `true`
/// quand le visage est vérifié.
class LivenessScreen extends StatefulWidget {
  const LivenessScreen({super.key});

  /// Caméra utilisée : remplacée dans les tests.
  @visibleForTesting
  static FaceCamera Function() cameraFactory = DeviceFaceCamera.new;

  /// Détection du visage sur le téléphone (null : compte à rebours).
  @visibleForTesting
  static FaceGuide? Function() guideFactory = deviceFaceGuide;

  /// Compte à rebours avant chaque photo, sans détection sur le téléphone.
  static const countdown = 3;

  /// Avec détection : temps laissé pour prendre la pose, puis la meilleure
  /// image part quand même (le serveur tranche).
  static const stepTimeout = Duration(seconds: 8);

  @override
  State<LivenessScreen> createState() => _LivenessScreenState();
}

class _LivenessScreenState extends State<LivenessScreen> {
  final FaceCamera _camera = LivenessScreen.cameraFactory();
  final FaceGuide? _guide = LivenessScreen.guideFactory();
  bool _cameraReady = false;

  /// Conseil affiché pendant la détection (visage absent, tête à tourner).
  String? _hint;

  /// Pose attendue reconnue : l'ovale passe au vert.
  bool _matched = false;
  _Phase _phase = _Phase.starting;
  LivenessChallenge? _challenge;
  int _step = 0;
  int? _seconds;
  bool _flash = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    unawaited(_camera.close());
    unawaited(_guide?.close());
    super.dispose();
  }

  Future<void> _start() async {
    final users = AppScope.of(context).users;
    final t = context.t;
    setState(() {
      _phase = _Phase.starting;
      _error = null;
      _step = 0;
    });
    try {
      if (!_cameraReady) {
        await _camera.open();
        _cameraReady = true;
      }
    } catch (_) {
      // Permission refusée, pas de caméra, ou navigateur sans accès.
      return _fail(t.livenessNoCamera);
    }
    try {
      _challenge = await users.startLiveness();
    } catch (e) {
      if (mounted) _fail(errorMessage(context, e));
      return;
    }
    await _capture();
  }

  Future<void> _capture() =>
      _guide == null ? _captureWithCountdown() : _captureWithGuide(_guide);

  /// Avec détection sur le téléphone : une image environ toutes les demi-
  /// secondes, gardée dès que la pose correspond à la consigne.
  Future<void> _captureWithGuide(FaceGuide guide) async {
    final challenge = _challenge!;
    final t = context.t;
    final frames = <Uint8List>[];
    double? firstTurnSign;
    for (var i = 0; i < challenge.steps.length; i++) {
      final step = challenge.steps[i];
      if (!mounted) return;
      setState(() {
        _phase = _Phase.capturing;
        _step = i;
        _hint = null;
        _matched = false;
      });
      final deadline = DateTime.now().add(LivenessScreen.stepTimeout);
      Uint8List? kept;
      (Uint8List, double)? best;
      while (kept == null && DateTime.now().isBefore(deadline)) {
        final Uint8List frame;
        try {
          frame = await _camera.capture();
        } catch (_) {
          if (mounted) _fail(t.livenessNoCamera);
          return;
        }
        if (!mounted) return;
        FacePose? pose;
        try {
          pose = await guide.poseOf(frame);
        } catch (_) {
          pose = null;
        }
        if (!mounted) return;
        if (pose != null &&
            poseMatches(step, pose, firstTurnSign: firstTurnSign)) {
          kept = frame;
          if (step != LivenessStep.center) firstTurnSign ??= pose.yaw.sign;
          break;
        }
        // Meilleure image à défaut : la plus de face, ou la plus tournée.
        if (pose != null && pose.faces == 1) {
          final score = step == LivenessStep.center
              ? -pose.yaw.abs()
              : pose.yaw.abs();
          if (best == null || score > best.$2) best = (frame, score);
        }
        setState(
          () => _hint = switch (pose) {
            null => t.livenessHintNoFace,
            (faces: final n, yaw: _) when n > 1 => t.errorLivenessManyFaces,
            _ when step == LivenessStep.center => t.livenessHintLookStraight,
            _ => t.livenessHintTurnMore,
          },
        );
      }
      kept ??= best?.$1;
      if (kept == null) {
        // Aucun visage pendant tout le délai : inutile d'envoyer.
        _fail(t.errorLivenessNoFace);
        return;
      }
      frames.add(kept);
      setState(() {
        _hint = null;
        _matched = true;
        _flash = true;
      });
      unawaited(HapticFeedback.mediumImpact());
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() => _flash = false);
    }
    await _analyze(challenge, frames);
  }

  /// Sans détection (web, tests) : compte à rebours avant chaque photo.
  Future<void> _captureWithCountdown() async {
    final challenge = _challenge!;
    final frames = <Uint8List>[];
    for (var i = 0; i < challenge.steps.length; i++) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.capturing;
        _step = i;
      });
      for (var s = LivenessScreen.countdown; s > 0; s--) {
        if (!mounted) return;
        setState(() => _seconds = s);
        await Future<void>.delayed(const Duration(seconds: 1));
      }
      if (!mounted) return;
      setState(() {
        _seconds = null;
        _flash = true;
      });
      unawaited(HapticFeedback.lightImpact());
      try {
        frames.add(await _camera.capture());
      } catch (_) {
        if (mounted) _fail(context.t.livenessNoCamera);
        return;
      }
      if (!mounted) return;
      setState(() => _flash = false);
    }
    await _analyze(challenge, frames);
  }

  Future<void> _analyze(
    LivenessChallenge challenge,
    List<Uint8List> frames,
  ) async {
    final users = AppScope.of(context).users;
    final navigator = Navigator.of(context);
    setState(() => _phase = _Phase.analyzing);
    try {
      await users.sendLiveness(challenge, frames);
      navigator.pop(true);
    } on ApiException catch (e) {
      if (mounted) _fail(errorMessage(context, e));
    } catch (e) {
      if (mounted) _fail(errorMessage(context, e));
    }
  }

  void _fail(String message) {
    setState(() {
      _phase = _Phase.failed;
      _error = message;
      _seconds = null;
      _flash = false;
      _hint = null;
      _matched = false;
    });
  }

  String _instruction(BuildContext context, LivenessStep step) {
    final t = context.t;
    return switch (step) {
      LivenessStep.center => t.livenessCenter,
      LivenessStep.left => t.livenessLeft,
      LivenessStep.right => t.livenessRight,
    };
  }

  IconData _icon(LivenessStep step) => switch (step) {
    LivenessStep.center => Icons.face_retouching_natural,
    // Vu par l'utilisateur, l'aperçu est un miroir : la flèche suit son geste.
    LivenessStep.left => Icons.west_rounded,
    LivenessStep.right => Icons.east_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final steps = _challenge?.steps ?? const [];
    final step = steps.isEmpty ? null : steps[_step];
    final ringColor = switch (_phase) {
      _Phase.failed => AppColors.errorSolid,
      _Phase.analyzing => AppColors.primary,
      // Pose reconnue par la détection sur le téléphone : vert.
      _ when _matched => const Color(0xFF22C55E),
      _ => AppColors.accent,
    };
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(t.faceCheckTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              // Consigne en cours.
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 96),
                child: _phase == _Phase.capturing && step != null
                    ? Column(
                        key: ValueKey(_step),
                        children: [
                          Text(
                            t.livenessStepOf(_step + 1, steps.length),
                            style: const TextStyle(
                              color: AppColors.onDarkBody,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_icon(step), color: AppColors.accent),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  _instruction(context, step),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: AppFonts.display,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Conseil de la détection sur le téléphone.
                          if (_hint != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _hint!,
                              key: const Key('liveness-hint'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      )
                    : null,
              ),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipOval(
                          child: _cameraReady
                              ? _camera.preview()
                              : const ColoredBox(color: AppColors.navy800),
                        ),
                        // Anneau de l'ovale, coloré selon l'étape.
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: ShapeDecoration(
                            shape: OvalBorder(
                              side: BorderSide(color: ringColor, width: 5),
                            ),
                            color: _flash
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.transparent,
                          ),
                        ),
                        if (_seconds != null)
                          Center(
                            child: Text(
                              '$_seconds',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w800,
                                fontSize: 96,
                                shadows: const [
                                  Shadow(blurRadius: 16, color: Colors.black54),
                                ],
                              ),
                            ),
                          ),
                        if (_phase == _Phase.analyzing ||
                            _phase == _Phase.starting)
                          ClipOval(
                            child: ColoredBox(
                              color: AppColors.ink.withValues(alpha: 0.6),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(
                                      color: AppColors.accent,
                                    ),
                                    if (_phase == _Phase.analyzing) ...[
                                      const SizedBox(height: 14),
                                      Text(
                                        t.livenessAnalyzing,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_phase == _Phase.failed) ...[
                ErrorBanner(_error ?? t.errorGeneric),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('liveness-retry'),
                    onPressed: _start,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(t.retry),
                  ),
                ),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: AppColors.onDarkBody,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.livenessPrivacy,
                        style: const TextStyle(
                          color: AppColors.onDarkBody,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
