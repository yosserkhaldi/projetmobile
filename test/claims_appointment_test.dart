import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/screens/claim_detail_screen.dart';
import 'package:mon_constat_digital/modules/claims/widgets/appointment_alerts.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_timeline.dart';
import 'package:mon_constat_digital/modules/claims/widgets/expertise_card.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

import 'support/fake_backend.dart';

String plain(String text) => text.replaceAll(RegExp('[\u2066-\u2069]'), '');

Claim inExpertise({String type = 'Collision', String by = 'agent'}) => Claim(
  id: 'SIN-7',
  type: type,
  place: 'Tunis',
  date: '12/10/2026 18:40',
  status: ClaimStatus.expertise,
  expertName: 'M. Trabelsi',
  expertPhone: '+216 71 000 000',
  expertPlace: 'Garage Ennour, Ariana',
  expertKind: defaultExpertKind(Claim(id: '', type: type, place: '', date: '')),
  expertAppointment: DateTime(2026, 11, 12, 10),
  appointmentState: 'proposed',
  appointmentBy: by,
)..timeline.addAll([ClaimStatus.inReview, ClaimStatus.expertise]);

/// Le badge « À confirmer » respire sans fin : pumpAndSettle n'attendrait
/// jamais la fin. On avance l'horloge du temps d'une transition.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('créneaux suggérés', () {
    test('jours ouvrables, jamais le dimanche, à partir de demain', () {
      // Samedi 14 novembre 2026.
      final slots = suggestedSlots(now: DateTime(2026, 11, 14, 16));
      expect(slots, hasLength(4));
      expect(slots.any((s) => s.weekday == DateTime.sunday), isFalse);
      expect(slots.first, DateTime(2026, 11, 16, 9));
      expect(slots.every((s) => s.hour >= 9 && s.hour <= 14), isTrue);
    });

    test('évite le créneau déjà refusé', () {
      final now = DateTime(2026, 11, 9, 8);
      final first = suggestedSlots(now: now).first;
      expect(suggestedSlots(now: now, avoid: first), isNot(contains(first)));
    });

    test('un piéton a une expertise médicale', () {
      expect(inExpertise(type: 'Piéton').expertKind, bodilyExpertise);
      expect(inExpertise().expertKind, vehicleExpertise);
    });
  });

  test('textes du rendez-vous dans les trois langues', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final ar = lookupAppLocalizations(const Locale('ar'));
    expect(
      plain(en.claimNotification('SIN-7 : rendez-vous d’expertise confirmé')),
      'SIN-7: expert appointment confirmed',
    );
    expect(
      plain(
        ar.claimNotification('SIN-7 : autre créneau proposé pour l’expertise'),
      ),
      'SIN-7: اقتُرح موعد آخر للخبرة',
    );
    expect(
      en.claimEvent('Rouvert : Montant erroné'),
      'Reopened: Montant erroné',
    );
    expect(en.claimValue('Corporelle'), 'Bodily injury');
    expect(en.claimsRemainingDays(1), 'About 1 day left');
    expect(ar.claimsRemainingDays(2), 'يبقى حوالي يومين');
  });

  group('écrans', () {
    late AppStores stores;

    Future<void> pump(WidgetTester tester, Widget home, UserRole role) async {
      tester.view.physicalSize = const Size(430, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      stores = AppStores(storage: MemoryStorage(), biometric: FakeBiometric());
      stores.users.currentUser = AppUser.fromJson(
        userJson(role: role == UserRole.agent ? 'AGENT' : 'DRIVER'),
      );
      await tester.pumpWidget(
        AppScope(
          stores: stores,
          child: MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            home: home,
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets('le conducteur voit le lieu, quoi apporter, et accepte', (
      tester,
    ) async {
      final claim = inExpertise();
      await pump(tester, ClaimDetail(claim), UserRole.driver);
      expect(find.text('Expertise du véhicule'), findsOneWidget);
      expect(find.text('Garage Ennour, Ariana'), findsOneWidget);
      expect(find.text('M. Trabelsi · +216 71 000 000'), findsOneWidget);
      expect(find.text('La carte grise'), findsOneWidget);
      expect(find.text('À confirmer'), findsOneWidget);

      await tester.tap(find.text('Accepter'));
      await tester.pump(const Duration(seconds: 1));
      expect(claim.appointmentState, 'accepted');
      expect(claim.timeline.last, 'Rendez-vous confirmé');
      expect(find.text('Confirmé'), findsOneWidget);
      expect(find.text('Accepter'), findsNothing);
      final notice = stores.claims.notificationsFor(UserRole.agent).first;
      expect(notice.body, 'SIN-7 : rendez-vous d’expertise confirmé');
    });

    testWidgets('le conducteur propose un créneau suggéré', (tester) async {
      final claim = inExpertise();
      await pump(tester, ClaimDetail(claim), UserRole.driver);
      await tester.tap(find.text('Proposer un autre créneau'));
      await settle(tester);
      await tester.tap(find.byType(ChoiceChip).first);
      await tester.enterText(find.byType(TextField), 'Je travaille le matin.');
      await tester.pump();
      await tester.tap(find.text('Envoyer la proposition'));
      await settle(tester);
      expect(claim.appointmentBy, 'driver');
      expect(claim.appointmentNote, 'Je travaille le matin.');
      expect(claim.timeline.last, 'Autre créneau proposé');
      expect(find.text('En attente de l’agent'), findsOneWidget);
    });

    testWidgets('l’agent ne confirme pas son propre créneau', (tester) async {
      await pump(
        tester,
        ClaimDetail(inExpertise(), agentMode: true),
        UserRole.agent,
      );
      expect(find.text('En attente du conducteur'), findsOneWidget);
      expect(find.text('Accepter'), findsNothing);
      expect(find.text('À apporter'), findsNothing);
    });

    testWidgets('un piéton : examen médical, pas de véhicule', (tester) async {
      await pump(
        tester,
        ClaimDetail(inExpertise(type: 'Piéton')),
        UserRole.driver,
      );
      expect(find.text('Expertise médicale'), findsOneWidget);
      expect(find.text('Les certificats médicaux'), findsOneWidget);
      expect(find.text('La carte grise'), findsNothing);
    });

    testWidgets('le rapport d’expertise a sa propre section', (tester) async {
      final claim = inExpertise()
        ..documents.addAll([
          const ClaimDocument(id: 'a', name: 'devis.pdf'),
          const ClaimDocument(
            id: 'b',
            name: 'rapport.pdf',
            kind: ClaimDocument.expertReport,
          ),
        ]);
      await pump(tester, ClaimDetail(claim), UserRole.driver);
      expect(
        find.text('Rapport de l’expert, joint par l’agent'),
        findsOneWidget,
      );
      expect(find.text('rapport.pdf'), findsOneWidget);
    });

    testWidgets('l’agent rouvre un dossier clôturé', (tester) async {
      final claim = inExpertise()
        ..status = ClaimStatus.closed
        ..responsibility = 100
        ..indemnity = 900;
      await pump(tester, ClaimDetail(claim, agentMode: true), UserRole.agent);
      await tester.ensureVisible(find.text('Rouvrir le dossier'));
      await tester.tap(find.text('Rouvrir le dossier'));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'Montant erroné');
      await tester.tap(find.text('Rouvrir'));
      await settle(tester);
      expect(claim.status, ClaimStatus.inReview);
      expect(claim.indemnity, isNull);
      expect(claim.timeline.last, 'Rouvert : Montant erroné');
    });
  });

  group('chronologie', () {
    testWidgets('au-delà de 4 étapes, trois points en haut', (tester) async {
      final claim = inExpertise()
        ..timeline.insertAll(0, ['Brouillon créé', 'Transmis'])
        ..timeline.addAll(['Rendez-vous confirmé', 'Autre créneau proposé']);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('fr'),
          home: Scaffold(
            body: SingleChildScrollView(child: ClaimTimeline(claim)),
          ),
        ),
      );
      await tester.pump();
      // Les quatre dernières étapes, les précédentes repliées.
      final more = '${claim.timeline.length - 4} étapes précédentes';
      expect(claim.timeline.length, greaterThan(5));
      expect(find.text(more), findsOneWidget);
      expect(find.text('Brouillon créé'), findsNothing);
      expect(find.text('Autre créneau proposé'), findsOneWidget);
      expect(find.text('En instruction'), findsOneWidget);

      await tester.tap(find.text(more));
      await tester.pumpAndSettle();
      expect(find.text('Brouillon créé'), findsWidgets);
      expect(find.text('Transmis'), findsWidgets);
      expect(find.text(more), findsNothing);

      // Et l'inverse : replier revient aux quatre dernières.
      await tester.tap(find.text('Afficher moins'));
      await tester.pumpAndSettle();
      expect(find.text(more), findsOneWidget);
      expect(find.text('Afficher moins'), findsNothing);
    });
  });

  group('alertes de rendez-vous', () {
    late AppStores stores;
    final navigator = GlobalKey<NavigatorState>();

    Future<Claim> pumpApp(WidgetTester tester, UserRole role) async {
      tester.view.physicalSize = const Size(430, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      stores = AppStores(storage: MemoryStorage(), biometric: FakeBiometric());
      stores.users.currentUser = AppUser.fromJson(
        userJson(role: role == UserRole.agent ? 'AGENT' : 'DRIVER'),
      );
      final claim = inExpertise(
        by: role == UserRole.agent ? 'agent' : 'driver',
      );
      stores.claims.claims.add(claim);
      await tester.pumpWidget(
        AppScope(
          stores: stores,
          child: MaterialApp(
            navigatorKey: navigator,
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            builder: (context, child) => AppointmentAlerts(
              navigator: navigator,
              visibleFor: const Duration(seconds: 3),
              child: child!,
            ),
            home: const Scaffold(body: Text('Accueil')),
          ),
        ),
      );
      await tester.pump();
      return claim;
    }

    testWidgets('le conducteur confirme : l’agent voit une alerte', (
      tester,
    ) async {
      final claim = await pumpApp(tester, UserRole.agent);
      // L'autre partie (le conducteur) accepte le créneau de l'agent.
      stores.claims.acceptAppointment(claim, UserRole.driver);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.textContaining('rendez-vous d’expertise confirmé'),
        findsOneWidget,
      );
      // Elle disparaît seule.
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.textContaining('rendez-vous d’expertise confirmé'),
        findsNothing,
      );
    });

    testWidgets('l’agent propose un créneau : le conducteur y est mené', (
      tester,
    ) async {
      final claim = await pumpApp(tester, UserRole.driver);
      stores.claims.proposeAppointment(
        claim,
        UserRole.agent,
        DateTime(2026, 11, 13, 14, 30),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.textContaining('autre créneau proposé pour l’expertise'),
        findsOneWidget,
      );

      await tester.tap(find.text('Voir'));
      await settle(tester);
      expect(find.byType(ClaimDetail), findsOneWidget);
      expect(find.text('Accepter'), findsOneWidget);
      expect(
        stores.claims
            .notificationsFor(UserRole.driver)
            .firstWhere((n) => n.body.contains('autre créneau'))
            .read,
        isTrue,
      );
      expect(
        find.textContaining('autre créneau proposé pour l’expertise'),
        findsNothing,
      );
    });

    testWidgets('ma propre action ne m’alerte pas', (tester) async {
      final claim = await pumpApp(tester, UserRole.driver);
      stores.claims.acceptAppointment(claim, UserRole.driver);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('confirmé'), findsNothing);
    });
  });
}
