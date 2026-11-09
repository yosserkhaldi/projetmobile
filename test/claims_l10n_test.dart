import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/models/responsibility.dart';
import 'package:mon_constat_digital/modules/claims/screens/claim_detail_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/claims_screen.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

import 'support/fake_backend.dart';

/// Retire les marqueurs de direction ajoutés autour des numéros de dossier.
String plain(String text) => text.replaceAll(RegExp('[\u2066-\u2069]'), '');

void main() {
  final fr = lookupAppLocalizations(const Locale('fr'));
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  group('valeurs enregistrées en français', () {
    test('se traduisent à l’affichage', () {
      expect(
        en.claimValue(ClaimStatus.documentRequested),
        'Document requested',
      );
      expect(ar.claimValue(ClaimStatus.inReview), 'قيد الدراسة');
      expect(en.claimValue('Reculait'), 'Reversing');
      expect(en.claimValue("Rapport d'expertise"), 'Expert report');
      expect(en.claimValues(['Avant', 'Côté droit']), 'Front, Right side');
      expect(fr.claimValue('Transmis'), 'Transmis');
    });

    test('un texte libre reste tel quel', () {
      expect(
        en.claimValue('Carte grise du véhicule'),
        'Carte grise du véhicule',
      );
    });

    test('toutes les valeurs connues ont une traduction', () {
      const values = [
        ...ClaimStatus.all,
        'Collision',
        'Sortie de route',
        'Piéton',
        'Accident matériel',
        'Autre',
        'Matériel',
        'Léger',
        'Grave',
        'En stationnement',
        'Quittait un stationnement',
        'Changeait de file',
        'Doublait',
        'Virait à droite',
        'Virait à gauche',
        'Reculait',
        'Avant',
        'Arrière',
        'Côté gauche',
        'Côté droit',
        ...DocumentRequest.labels,
        ClaimDocument.supporting,
        ClaimDocument.expertReport,
        ClaimDocument.photo,
        ClaimDocument.video,
        ClaimDocument.voiceNote,
        ClaimDocument.accidentReport,
      ];
      for (final value in values) {
        expect(ar.claimValue(value), isNot(value), reason: value);
      }
    });
  });

  group('chronologie et notifications', () {
    test('étapes connues, avec précision ou nombre', () {
      expect(en.claimEvent('Brouillon créé'), 'Draft created');
      expect(en.claimEvent('3 preuves ajoutées'), '3 pieces of evidence added');
      expect(
        en.claimEvent('Pièce demandée : Devis'),
        'Document requested: Repair quote',
      );
      expect(ar.claimEvent('Rapport d’expertise joint'), 'أُرفق تقرير الخبير');
      expect(en.claimEvent('Clôturé'), 'Closed');
    });

    test('notifications du serveur et de l’appareil', () {
      expect(
        plain(en.claimNotification('Nouveau sinistre reçu : SIN-1')),
        'New claim received: SIN-1',
      );
      expect(
        plain(en.claimNotification('SIN-1 : pièce demandée (PV de police)')),
        'SIN-1: document requested (Police report)',
      );
      expect(
        plain(en.claimNotification('SIN-1 : pièce déposée (devis.pdf)')),
        'SIN-1: document uploaded (devis.pdf)',
      );
      expect(
        plain(en.claimNotification('SIN-1 : Pièce demandée : Facture')),
        'SIN-1: Document requested: Invoice',
      );
      expect(
        plain(ar.claimNotification('SIN-1 : rendez-vous d’expertise déplacé')),
        'SIN-1: تم تغيير موعد الخبرة',
      );
      expect(en.claimNotification('Message libre'), 'Message libre');
    });

    test('le numéro de dossier garde son sens de lecture en arabe', () {
      final text = ar.claimNotification('Nouveau sinistre reçu : SIN-1');
      expect(text, contains('\u2066SIN-1\u2069'));
    });
  });

  test('la raison de la proposition suit la langue', () {
    final proposal = ResponsibilityProposal.fromCircumstances(['Reculait']);
    expect(proposal.reason, 'Reculait : manœuvre à risque de A.');
    expect(
      en.claimProposalReason(proposal),
      'Reversing: risky manoeuvre by A.',
    );
    expect(
      ar.claimProposalReason(ResponsibilityProposal.fromCircumstances([])),
      'الخانات غير كافية: مسؤولية مشتركة افتراضيًا.',
    );
  });

  group('écrans', () {
    Future<void> pump(WidgetTester tester, Widget home, Locale locale) async {
      tester.view.physicalSize = const Size(430, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final stores = AppStores(
        storage: MemoryStorage(),
        biometric: FakeBiometric(),
      );
      stores.users.currentUser = AppUser.fromJson(userJson(role: 'AGENT'));
      await tester.pumpWidget(
        AppScope(
          stores: stores,
          child: MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            home: Scaffold(body: home),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }

    Claim claim() =>
        Claim(
            id: 'SIN-9',
            type: 'Collision',
            place: 'Tunis',
            date: '12/10/2026 18:40',
            severity: 'Grave',
            status: ClaimStatus.inReview,
          )
          ..circumstances.add('Reculait')
          ..timeline.add('Transmis aux assureurs');

    testWidgets('le dossier en anglais', (tester) async {
      await pump(
        tester,
        ClaimDetail(claim(), agentMode: true),
        const Locale('en'),
      );
      expect(find.text('Under review'), findsOneWidget);
      expect(find.text('Collision • Serious'), findsOneWidget);
      expect(find.text('Sent to the insurers'), findsOneWidget);
      expect(find.text('Request a document'), findsOneWidget);
      expect(
        find.textContaining('Reversing', findRichText: true),
        findsWidgets,
      );
      expect(find.textContaining('Proposal: A 100 %, B 0 %.'), findsOneWidget);
    });

    testWidgets('le dossier en arabe, de droite à gauche', (tester) async {
      await pump(
        tester,
        ClaimDetail(claim(), agentMode: true),
        const Locale('ar'),
      );
      expect(find.text('قيد الدراسة'), findsOneWidget);
      expect(find.text('طلب وثيقة'), findsOneWidget);
      final direction = Directionality.of(
        tester.element(find.text('قيد الدراسة')),
      );
      expect(direction, TextDirection.rtl);
    });

    testWidgets('la recherche trouve un statut traduit', (tester) async {
      await pump(
        tester,
        const ClaimsScreen(agentMode: true),
        const Locale('en'),
      );
      expect(find.text('Received claims'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'under review');
      await tester.pump();
      expect(find.text('SIN-2026-0418'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'closed');
      await tester.pump();
      expect(find.text('No claim matches.'), findsOneWidget);
    });
  });
}
