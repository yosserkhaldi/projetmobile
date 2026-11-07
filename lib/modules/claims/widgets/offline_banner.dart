import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';

/// Rappelle que les changements partiront au retour du réseau.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = AppScope.of(context).claimsSync;
    if (sync == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: sync,
      builder: (_, _) => sync.online
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              height: 34,
              alignment: Alignment.center,
              color: AppColors.ink,
              child: const Text(
                'Hors ligne : vos changements partiront au retour du réseau',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}
