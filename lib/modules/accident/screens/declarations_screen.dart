import 'package:flutter/material.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/accident/screens/accident_wizard.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/screens/claim_detail_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/claims_screen.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_card.dart';
import 'package:mon_constat_digital/shared/navigation.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class DeclarationsScreen extends StatelessWidget {
  const DeclarationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stores = AppScope.of(context);
    final draft = stores.accidents.draft;
    final claims = stores.claims.claims;
    return ColoredBox(
      color: context.palette.canvas,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            PageHead(
              'Mes déclarations',
              subtitle: 'Brouillons et dossiers transmis',
              actions: [
                // Module 5 : recherche et filtres sur tous les dossiers.
                IconButton(
                  tooltip: context.t.claimsSearchMine,
                  onPressed: () => open(
                    context,
                    Scaffold(appBar: AppBar(), body: const ClaimsScreen()),
                  ),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                onPressed: () {
                  final value = stores.accidents.startNew();
                  open(context, AccidentWizard(initialDraft: value));
                },
                icon: const Icon(Icons.add),
                label: const Text('Nouvelle déclaration'),
              ),
            ),
            if (draft != null) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(18, 24, 18, 10),
                child: Text(
                  'BROUILLON EN COURS',
                  style: TextStyle(
                    color: context.palette.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .6,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: context.palette.warningBg,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.ink,
                              child: Icon(Icons.edit_note),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Étape ${stores.accidents.currentStep + 1} sur 7',
                                    style: TextStyle(
                                      color: context.palette.warningText,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    draft.place,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        LinearProgressIndicator(
                          value: (stores.accidents.currentStep + 1) / 7,
                          backgroundColor: Colors.white,
                          color: AppColors.accentDark,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _confirmDelete(context),
                                child: const Text('Supprimer'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.ink,
                                ),
                                onPressed: () => open(
                                  context,
                                  AccidentWizard(
                                    initialDraft: draft,
                                    initialStep: stores.accidents.currentStep,
                                  ),
                                ),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Reprendre'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.fromLTRB(18, draft == null ? 24 : 28, 18, 10),
              child: Text(
                'DÉCLARATIONS TRANSMISES',
                style: TextStyle(
                  color: context.palette.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .6,
                ),
              ),
            ),
            if (claims.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Aucune déclaration transmise.')),
              )
            else
              ...claims.map(
                (claim) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => open(context, ClaimDetail(claim)),
                      child: ClaimCard(claim),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer le brouillon ?'),
        content: const Text('Les informations non transmises seront perdues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              AppScope.of(context).accidents.clearDraft();
              Navigator.pop(dialogContext);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
