import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

class Stat extends StatelessWidget {
  const Stat(this.t, this.v, this.d, this.i, {super.key});
  final String t, v, d;
  final IconData i;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(i, color: context.palette.primaryText),
          Text(
            v,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          Text(t),
          Text(d, style: TextStyle(color: context.palette.successText)),
        ],
      ),
    ),
  );
}
