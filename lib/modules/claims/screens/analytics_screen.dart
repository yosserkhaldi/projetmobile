import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';

typedef LoadAnalytics = Future<Map<String, dynamic>> Function();

/// Activité de l'équipe et mesure du système face aux décisions réelles.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({this.load, super.key});

  /// Remplace l'appel au serveur dans les tests.
  final LoadAnalytics? load;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Future<Map<String, dynamic>>? data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sync = AppScope.of(context).claimsSync;
    data ??=
        widget.load?.call() ??
        sync?.api.analytics() ??
        Future.error(StateError('Application locale'));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Statistiques')),
    body: FutureBuilder(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Statistiques disponibles avec le serveur.',
              style: TextStyle(color: context.palette.textMuted),
            ),
          );
        }
        final json = snapshot.data;
        if (json == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _Report(json);
      },
    ),
  );
}

class _Report extends StatelessWidget {
  const _Report(this.json);
  final Map<String, dynamic> json;

  @override
  Widget build(BuildContext context) {
    final byStatus = (json['byStatus'] as Map).cast<String, int>();
    final ai = (json['ai'] as Map).cast<String, dynamic>();
    final model = (json['model'] as Map).cast<String, dynamic>();
    final metrics = (model['metrics'] as Map).cast<String, dynamic>();
    final trained = (model['trainedOn'] as Map).cast<String, dynamic>();
    final days = (json['averageDays'] as num?)?.toDouble();
    final agreement = (ai['agreement'] as num?)?.toDouble();
    final gap = (ai['estimateErrorTnd'] as num?)?.toDouble();
    final compared = ai['decisionsCompared'] as int;
    final largest = byStatus.values.fold(1, (a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _Tile('Dossiers', '${json['total']}'),
            _Tile('En retard', '${json['overdue']}'),
          ],
        ),
        Row(
          children: [
            _Tile('Durée moyenne', days == null ? '—' : '${days.round()} j'),
            _Tile(
              'Indemnisé (TND)',
              '${(json['totalIndemnity'] as num).round()}',
            ),
          ],
        ),
        const _Title('Dossiers par statut'),
        for (final status in ClaimStatus.all)
          if (byStatus[status] != null)
            _Bar(status, byStatus[status]!, largest),
        const _Title('Le système face aux agents'),
        Text(
          compared == 0
              ? 'Pas encore de décision à comparer.'
              : 'Sur $compared décision(s), la responsabilité proposée a été '
                    'retenue dans ${((agreement ?? 0) * 100).round()} % des cas.',
        ),
        if (gap != null)
          Text('Écart moyen avec le montant décidé : ${gap.round()} TND.'),
        const _Title('Modèle'),
        Text('Version ${model['version']}'),
        Text(
          'Entraîné sur ${trained['synthetic']} cas simulés et '
          '${trained['real']} dossiers réels.',
        ),
        Text(
          'Test : erreur moyenne ${metrics['indemnityMaeTnd']} TND, '
          'AUC rejet ${metrics['rejectionAuc']}.',
        ),
        const SizedBox(height: 6),
        Text(
          'Ces mesures portent sur des données simulées : elles ne disent '
          'pas encore si le modèle est juste sur de vrais sinistres.',
          style: TextStyle(color: context.palette.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
    ),
  );
}

/// Une seule série : une couleur, la valeur écrite à côté de chaque barre.
class _Bar extends StatelessWidget {
  const _Bar(this.label, this.value, this.largest);
  final String label;
  final int value, largest;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        FractionallySizedBox(
          widthFactor: value / largest,
          alignment: Alignment.centerLeft,
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: context.palette.primary,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
            ),
          ),
        ),
      ],
    ),
  );
}
