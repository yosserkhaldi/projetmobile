import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Couleurs vives du module 5, lisibles en clair comme en sombre.
abstract final class ClaimsColors {
  static const violet = Color(0xFF7C5CFF);
  static const teal = Color(0xFF14B8A6);
  static const coral = Color(0xFFFF6B6B);
  static const amber = Color(0xFFF5A524);
  static const sky = Color(0xFF38BDF8);
  static const pink = Color(0xFFEC4899);
  static const lime = Color(0xFF84CC16);
  static const indigo = Color(0xFF4F6BED);

  static const series = [violet, teal, amber, coral, sky, pink, lime, indigo];

  /// Carte de suivi du conducteur : du bleu nuit vers le turquoise.
  static const guidance = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFF4338CA), Color(0xFF7C3AED), Color(0xFF0D9488)],
    stops: [0, .55, 1],
  );

  /// Ce qu'a écrit un modèle de langage : violet vers rose.
  static const ai = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [violet, pink],
  );
}

/// Vrai quand l'utilisateur a demandé moins d'animations au système.
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Un nombre qui monte de 0 à sa valeur.
class CountUp extends StatelessWidget {
  const CountUp(this.value, {this.style, this.format, super.key});
  final num value;
  final TextStyle? style;
  final String Function(num value)? format;

  @override
  Widget build(BuildContext context) {
    String show(num v) =>
        format?.call(v) ??
        (value is int ? '${v.round()}' : v.toStringAsFixed(1));
    if (reduceMotion(context)) return Text(show(value), style: style);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Text(show(v), style: style),
    );
  }
}

/// Respiration : grossit et pâlit doucement, pour ce qui attend une réponse.
class Breathing extends StatefulWidget {
  const Breathing({required this.child, super.key});
  final Widget child;

  @override
  State<Breathing> createState() => _BreathingState();
}

class _BreathingState extends State<Breathing>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      controller.stop();
    } else if (!controller.isAnimating) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (_, child) {
      final v = Curves.easeInOut.transform(controller.value);
      return Opacity(
        opacity: 1 - v * .25,
        child: Transform.scale(scale: 1 + v * .06, child: child),
      );
    },
    child: widget.child,
  );
}

/// Flottement : monte et descend de quelques pixels, en boucle.
class Floating extends StatefulWidget {
  const Floating({required this.child, this.height = 4, super.key});
  final Widget child;
  final double height;

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      controller.stop();
    } else if (!controller.isAnimating) {
      controller.repeat();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (_, child) => Transform.translate(
      offset: Offset(
        0,
        math.sin(controller.value * 2 * math.pi) * widget.height,
      ),
      child: child,
    ),
    child: widget.child,
  );
}

/// Apparition : fondu et glissement vers le haut, avec un retard [index].
class Appear extends StatelessWidget {
  const Appear({required this.child, this.index = 0, super.key});
  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + index * 70),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 14),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Barre qui se remplit de 0 à [value] (entre 0 et 1).
class GrowingBar extends StatelessWidget {
  const GrowingBar({
    required this.value,
    required this.color,
    this.height = 10,
    this.track,
    super.key,
  });
  final double value;
  final Color color;
  final Color? track;
  final double height;

  @override
  Widget build(BuildContext context) {
    Widget bar(double v) => ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(color: track ?? color.withValues(alpha: .15)),
            ),
            FractionallySizedBox(
              widthFactor: v.clamp(0, 1),
              alignment: AlignmentDirectional.centerStart,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: .75), color],
                  ),
                  borderRadius: BorderRadius.circular(height),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
    if (reduceMotion(context)) return bar(value);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => bar(v),
    );
  }
}
