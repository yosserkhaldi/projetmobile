import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';

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
          Icon(i, color: AppColors.primary),
          Text(
            v,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          Text(t),
          Text(d, style: const TextStyle(color: AppColors.successText)),
        ],
      ),
    ),
  );
}
