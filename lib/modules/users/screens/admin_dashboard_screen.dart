import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/modules/users/widgets/stat.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const PageHead(
          'Administration',
          subtitle: 'Vue globale de la plateforme',
        ),
        // Les vrais chiffres arriveront avec les données des modules 3 et 5.
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.warningBg,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Text(
            'Données de démonstration',
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
          children: const [
            Stat('Accidents', '248', '+12 %', Icons.car_crash),
            Stat('Ouverts', '41', '16,5 %', Icons.folder_open),
            Stat('Clôturés', '207', '83,5 %', Icons.check_circle),
            Stat('Délai moyen', '3,4 j', '-0,6 j', Icons.timer),
          ],
        ),
        const SizedBox(height: 20),
        const Card(
          child: SizedBox(
            height: 190,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 60, color: AppColors.primary),
                  Text('Carte des zones à forte accidentalité'),
                  Text('Tunis • Ariana • Ben Arous'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            title: Text('Répartition par gravité'),
            subtitle: LinearProgressIndicator(value: .68),
            trailing: Text('68 % matériel'),
          ),
        ),
      ],
    ),
  );
}
