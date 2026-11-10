import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_theme.dart';

/// Forme grise qui pulse doucement, à la place du contenu pendant le
/// chargement : la mise en page apparaît tout de suite, sans saut.
class Skeleton extends StatefulWidget {
  const Skeleton({
    this.width,
    this.height = 14,
    this.radius = 8,
    this.circle = false,
    super.key,
  });

  final double? width;
  final double height, radius;
  final bool circle;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return FadeTransition(
      opacity: Tween(
        begin: 0.45,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
      child: Container(
        width: widget.circle ? widget.height : widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.circle
              ? null
              : BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Liste en chargement : des lignes « avatar + deux lignes de texte ».
class SkeletonList extends StatelessWidget {
  const SkeletonList({this.count = 6, this.padding, super.key});
  final int count;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => ListView.separated(
    key: const Key('skeleton'),
    padding: padding ?? const EdgeInsets.all(16),
    physics: const NeverScrollableScrollPhysics(),
    itemCount: count,
    separatorBuilder: (_, _) => const SizedBox(height: 18),
    itemBuilder: (_, i) => Row(
      children: [
        const Skeleton(height: 42, circle: true),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Largeurs variées : plus naturel qu'une colonne régulière.
              FractionallySizedBox(
                widthFactor: [0.6, 0.45, 0.7, 0.5][i % 4],
                child: const Skeleton(height: 14),
              ),
              const SizedBox(height: 8),
              FractionallySizedBox(
                widthFactor: [0.35, 0.5, 0.3, 0.4][i % 4],
                child: const Skeleton(height: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Tableau de bord en chargement : quatre indicateurs puis deux panneaux.
class SkeletonDashboard extends StatelessWidget {
  const SkeletonDashboard({this.columns = 2, super.key});

  /// 2 sur téléphone, 4 sur la console.
  final int columns;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget card(double height) => Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: p.borderSoft),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(height: 22, width: 22, radius: 6),
          Spacer(),
          Skeleton(height: 24, width: 60),
          SizedBox(height: 8),
          Skeleton(height: 11, width: 90),
        ],
      ),
    );
    return Column(
      key: const Key('skeleton'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.35,
          children: [for (var i = 0; i < 4; i++) card(0)],
        ),
        const SizedBox(height: 14),
        for (final height in [190.0, 130.0]) ...[
          Container(
            height: height,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: p.borderSoft),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(height: 11, width: 140),
                SizedBox(height: 18),
                Expanded(child: Skeleton(radius: 10)),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
