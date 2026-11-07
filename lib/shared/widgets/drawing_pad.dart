import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';

class DrawingPad extends StatefulWidget {
  const DrawingPad({
    required this.strokes,
    required this.onChanged,
    required this.hint,
    this.height = 220,
    super.key,
  });

  final List<List<Map<String, double>>> strokes;
  final VoidCallback onChanged;
  final String hint;
  final double height;

  @override
  State<DrawingPad> createState() => _DrawingPadState();
}

class DrawingPreview extends StatelessWidget {
  const DrawingPreview({
    required this.strokes,
    this.height = 110,
    this.emptyLabel = 'Non renseigné',
    super.key,
  });

  final List<List<Map<String, double>>> strokes;
  final double height;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: CustomPaint(
        painter: _StrokePainter(strokes),
        child: strokes.isEmpty
            ? Center(
                child: Text(
                  emptyLabel,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              )
            : null,
      ),
    ),
  );
}

class _DrawingPadState extends State<DrawingPad> {
  Size _size = Size.zero;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          _size = Size(constraints.maxWidth, widget.height);
          return GestureDetector(
            key: const ValueKey('drawing-surface'),
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) {
              widget.strokes.add([_normalize(details.localPosition)]);
              setState(() {});
            },
            onPanUpdate: (details) {
              if (widget.strokes.isEmpty) return;
              widget.strokes.last.add(_normalize(details.localPosition));
              setState(() {});
            },
            onPanEnd: (_) => widget.onChanged(),
            child: Container(
              height: widget.height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(
                  color: widget.strokes.isEmpty
                      ? AppColors.border
                      : AppColors.primary,
                  width: widget.strokes.isEmpty ? 1.5 : 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CustomPaint(
                  painter: _StrokePainter(widget.strokes),
                  child: widget.strokes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.gesture_rounded,
                                size: 42,
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.hint,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
            ),
          );
        },
      ),
      if (widget.strokes.isNotEmpty)
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              setState(widget.strokes.clear);
              widget.onChanged();
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Effacer'),
          ),
        ),
    ],
  );

  Map<String, double> _normalize(Offset point) => {
    'x': (point.dx / _size.width).clamp(0, 1),
    'y': (point.dy / _size.height).clamp(0, 1),
  };
}

class _StrokePainter extends CustomPainter {
  const _StrokePainter(this.strokes);
  final List<List<Map<String, double>>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      final path = Path();
      path.moveTo(
        stroke.first['x']! * size.width,
        stroke.first['y']! * size.height,
      );
      for (final point in stroke.skip(1)) {
        path.lineTo(point['x']! * size.width, point['y']! * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) => true;
}
