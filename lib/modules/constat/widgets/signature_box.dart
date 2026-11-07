import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

class SignatureBox extends StatelessWidget {
  const SignatureBox(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    height: 130,
    width: double.infinity,
    decoration: BoxDecoration(
      color: context.palette.surface,
      border: Border.all(color: context.palette.border),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Center(
      child: Text('$label\nSignez ici', textAlign: TextAlign.center),
    ),
  );
}
