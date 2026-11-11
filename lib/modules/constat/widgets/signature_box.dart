import 'package:flutter/material.dart';

import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/shared/widgets/drawing_pad.dart';

class SignatureBox extends StatelessWidget {
  const SignatureBox(
    this.label, {
    required this.strokes,
    required this.onChanged,
    super.key,
  });

  final String label;
  final List<List<Map<String, double>>> strokes;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 7),
      DrawingField(
        strokes: strokes,
        title: label,
        hint: context.t.cstSignHint,
        icon: Icons.draw_outlined,
        onChanged: onChanged,
      ),
    ],
  );
}
