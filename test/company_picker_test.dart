import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/models/company.dart';
import 'package:mon_constat_digital/modules/users/widgets/company_picker.dart';

import 'support/fake_backend.dart';

Future<FakeBackend> pumpPicker(
  WidgetTester tester,
  void Function(Company?, Agency?) onChanged, {
  bool offline = false,
}) async {
  final backend = FakeBackend()
    ..companies = [
      {
        'id': 'c-star',
        'name': 'STAR Assurances',
        'agencies': [
          {'id': 'a1', 'name': 'Agence Lac', 'city': 'Tunis'},
        ],
      },
      {'id': 'c-comar', 'name': 'COMAR', 'agencies': []},
    ];
  await backend.stores.api.openSession({
    'accessToken': 'access-1',
    'refreshToken': 'refresh-0',
  });
  if (offline) {
    // Une première liste reçue en ligne, puis plus de réseau.
    await backend.stores.companies.load();
    backend.offline = true;
  }
  await tester.pumpWidget(
    AppScope(
      stores: backend.stores,
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: CompanyPicker(onChanged: onChanged)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return backend;
}

void main() {
  testWidgets('choisit une compagnie puis son agence, par identifiant', (
    tester,
  ) async {
    Company? company;
    Agency? agency;
    await pumpPicker(tester, (c, a) {
      company = c;
      agency = a;
    });

    await tester.tap(find.byIcon(Icons.business_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('STAR Assurances').last);
    await tester.pumpAndSettle();
    expect(company!.id, 'c-star');
    expect(find.text('Agence'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.storefront_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agence Lac · Tunis').last);
    await tester.pumpAndSettle();
    expect(agency!.id, 'a1');
    expect(company!.id, 'c-star');
  });

  testWidgets('hors ligne : liste reprise de SQLite, avec la mention', (
    tester,
  ) async {
    final backend = await pumpPicker(tester, (_, _) {}, offline: true);
    expect(backend.stores.companies.offline, isTrue);
    expect(find.textContaining('Hors ligne : liste enregistrée le'), findsOne);
    await tester.tap(find.byIcon(Icons.business_outlined));
    await tester.pumpAndSettle();
    expect(find.text('COMAR'), findsWidgets);
  });
}
