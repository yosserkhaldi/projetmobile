import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/widgets/stat.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        PageHead(context.t.adminTitle, subtitle: context.t.adminSubtitle),
        // Les vrais chiffres arriveront avec les données des modules 3 et 5.
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.warningBg,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            context.t.demoData,
            style: TextStyle(
              color: AppColors.warningText,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            Stat(context.t.statAccidents, '248', '+12 %', Icons.car_crash),
            Stat(context.t.statOpen, '41', '16,5 %', Icons.folder_open),
            Stat(context.t.statClosed, '207', '83,5 %', Icons.check_circle),
            Stat(context.t.statAvgDelay, '3,4 j', '-0,6 j', Icons.timer),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: SizedBox(
            height: 190,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 60, color: AppColors.primary),
                  Text(context.t.heatmapTitle),
                  Text('Tunis • Ariana • Ben Arous'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: Text(context.t.severityTitle),
            subtitle: LinearProgressIndicator(value: .68),
            trailing: Text(context.t.severityMaterial(68)),
          ),
        ),
      ],
    ),
  );
}
