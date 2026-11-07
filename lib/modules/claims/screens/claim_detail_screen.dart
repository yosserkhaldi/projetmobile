import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_card.dart';

class ClaimDetail extends StatelessWidget {
  const ClaimDetail(this.claim, {this.agentMode = false, super.key});
  final Claim claim;
  final bool agentMode;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).claims;
    return Scaffold(
      appBar: AppBar(title: Text(claim.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClaimCard(claim),
          const SizedBox(height: 16),
          const Text(
            'Chronologie',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          ...claim.timeline.map(
            (e) => ListTile(
              leading: Icon(
                Icons.check_circle,
                color: context.palette.successText,
              ),
              title: Text(e),
            ),
          ),
          const Divider(),
          const Text(
            'Pièces du dossier',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          ...claim.documents.map(
            (e) => ListTile(
              leading: const Icon(Icons.attach_file),
              title: Text(e),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => s.addDocument(claim),
            icon: const Icon(Icons.upload_file),
            label: const Text('Déposer une pièce'),
          ),
          if (agentMode) ...[
            const SizedBox(height: 16),
            const Text(
              'Instruction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            DropdownButtonFormField<String>(
              initialValue: claim.status,
              items: [
                'En instruction',
                'Pièce demandée',
                'Expertise planifiée',
                'Accepté',
                'Rejeté',
                'Clôturé',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                if (v != null) s.updateClaim(claim, v);
              },
              decoration: const InputDecoration(labelText: 'Statut'),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Responsabilité',
                hintText: '0 %, 50 % ou 100 %',
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Montant d'indemnisation (TND)",
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => s.updateClaim(claim, 'Décision enregistrée'),
              icon: const Icon(Icons.gavel),
              label: const Text('Enregistrer la décision'),
            ),
          ],
        ],
      ),
    );
  }
}
