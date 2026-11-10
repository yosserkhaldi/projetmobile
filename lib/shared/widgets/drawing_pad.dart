import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

/// Format commun des dessins : celui du PDF (cadre 1000 × 500). L'aperçu, le
/// plein écran et le PDF ont les mêmes proportions : un trait reste à sa
/// place partout.
const drawingAspectRatio = 2.0;

/// Zone de dessin dans un formulaire : un aperçu qu'on touche pour dessiner
/// en plein écran. Dessiner dans la page faisait défiler le formulaire en
/// même temps que le trait.
class DrawingField extends StatelessWidget {
  const DrawingField({
    required this.strokes,
    required this.onChanged,
    required this.title,
    required this.hint,
    this.icon = Icons.gesture_rounded,
    super.key,
  });

  final List<List<Map<String, double>>> strokes;
  final VoidCallback onChanged;

  /// Titre du plein écran (« Croquis de l'accident », « Signature… »).
  final String title;
  final String hint;
  final IconData icon;

  Future<void> _open(BuildContext context) async {
    final result = await Navigator.of(context)
        .push<List<List<Map<String, double>>>>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => FullscreenDrawingPage(
              title: title,
              hint: hint,
              initial: strokes,
            ),
          ),
        );
    if (result == null) return; // fermé sans valider : rien ne change
    strokes
      ..clear()
      ..addAll(result);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final empty = strokes.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: empty ? AppColors.border : AppColors.primary,
              width: empty ? 1.5 : 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const ValueKey('drawing-field'),
            onTap: () => _open(context),
            child: AspectRatio(
              aspectRatio: drawingAspectRatio,
              child: empty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 40, color: AppColors.primary),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              hint,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Touchez pour dessiner en plein écran',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    )
                  : CustomPaint(painter: _StrokePainter(strokes)),
            ),
          ),
        ),
        if (!empty)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  strokes.clear();
                  onChanged();
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Effacer'),
              ),
              TextButton.icon(
                onPressed: () => _open(context),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Modifier'),
              ),
            ],
          ),
      ],
    );
  }
}

/// Dessin en plein écran, en paysage pour une grande surface. « Terminé »
/// renvoie les traits ; la croix ferme sans rien changer.
class FullscreenDrawingPage extends StatefulWidget {
  const FullscreenDrawingPage({
    required this.title,
    required this.hint,
    required this.initial,
    super.key,
  });

  final String title, hint;
  final List<List<Map<String, double>>> initial;

  @override
  State<FullscreenDrawingPage> createState() => _FullscreenDrawingPageState();
}

class _FullscreenDrawingPageState extends State<FullscreenDrawingPage> {
  // Copie : rien ne change dans le constat avant « Terminé ».
  late final List<List<Map<String, double>>> _strokes = [
    for (final stroke in widget.initial) [...stroke],
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Retour à l'orientation libre du reste de l'application.
    SystemChrome.setPreferredOrientations(const []);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surfaceAlt,
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Fermer sans enregistrer',
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(widget.title),
      actions: [
        IconButton(
          tooltip: 'Annuler le dernier trait',
          onPressed: _strokes.isEmpty
              ? null
              : () => setState(_strokes.removeLast),
          icon: const Icon(Icons.undo),
        ),
        IconButton(
          tooltip: 'Tout effacer',
          onPressed: _strokes.isEmpty ? null : () => setState(_strokes.clear),
          icon: const Icon(Icons.delete_outline),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilledButton.icon(
            key: const ValueKey('drawing-done'),
            onPressed: () => Navigator.pop(context, _strokes),
            icon: const Icon(Icons.check),
            label: const Text('Terminé'),
          ),
        ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: AspectRatio(
            aspectRatio: drawingAspectRatio,
            child: LayoutBuilder(
              builder: (context, box) {
                Map<String, double> at(Offset point) => {
                  'x': (point.dx / box.maxWidth).clamp(0, 1),
                  'y': (point.dy / box.maxHeight).clamp(0, 1),
                };
                return GestureDetector(
                  key: const ValueKey('fullscreen-drawing-surface'),
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (d) =>
                      setState(() => _strokes.add([at(d.localPosition)])),
                  onPanUpdate: (d) {
                    if (_strokes.isEmpty) return;
                    setState(() => _strokes.last.add(at(d.localPosition)));
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CustomPaint(
                        painter: _StrokePainter(_strokes),
                        child: _strokes.isEmpty
                            ? Center(
                                child: Text(
                                  widget.hint,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
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
