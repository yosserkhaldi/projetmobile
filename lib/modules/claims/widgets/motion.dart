import 'package:flutter/material.dart';

export 'ink.dart';

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
      duration: Duration(milliseconds: 280 + index.clamp(0, 6) * 40),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 8),
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
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(color: track ?? color.withValues(alpha: .12)),
            ),
            FractionallySizedBox(
              widthFactor: v.clamp(0, 1),
              alignment: AlignmentDirectional.centerStart,
              child: ColoredBox(color: color, child: const SizedBox.expand()),
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
