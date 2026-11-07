import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_database.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_filter.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/models/responsibility.dart';
import 'package:mon_constat_digital/modules/claims/screens/agent_dashboard_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/chat_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/claim_detail_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/claims_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/notifications_screen.dart';
import 'package:mon_constat_digital/modules/claims/state/claim_store.dart';
import 'package:mon_constat_digital/modules/claims/widgets/document_picker.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

Claim claimWith(String status, {String id = 'SIN-3'}) => Claim(
  id: id,
  type: 'Collision',
  place: 'Tunis',
  date: '12/10/2026 18:40',
  status: status,
);

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('cycle de vie', () {
    test('compte neuf statuts', () => expect(ClaimStatus.all, hasLength(9)));

    test('un statut final ne bouge plus', () {
      expect(ClaimStatus.nextOf(ClaimStatus.closed), isEmpty);
      expect(ClaimStatus.nextOf(ClaimStatus.rejected), isEmpty);
    });

    test('tous les statuts atteignent une fin', () {
      for (final status in ClaimStatus.all) {
        final seen = <String>{};
        final queue = [status];
        while (queue.isNotEmpty) {
          final current = queue.removeLast();
          if (seen.add(current)) queue.addAll(ClaimStatus.nextOf(current));
        }
        expect(seen.any(ClaimStatus.isFinal), isTrue, reason: status);
      }
    });
  });

  group('store', () {
    late ClaimsDatabase db;
    late ClaimStore store;

    setUp(() async {
      db = ClaimsDatabase(NativeDatabase.memory());
      store = ClaimStore(dao: db.claimsDao);
      await store.saved;
    });
    tearDown(() async {
      await store.saved;
      await db.close();
    });

    test('refuse un passage hors du cycle de vie', () {
      final claim = claimWith(ClaimStatus.transmitted);
      expect(store.updateClaim(claim, ClaimStatus.closed), isFalse);
      expect(claim.status, ClaimStatus.transmitted);

      store.closeClaim(claim, 100, 500);
      expect(claim.indemnity, isNull);
      store.rejectClaim(claim, 'Fraude');
      expect(claim.decisionReason, isNull);
    });

    test('la dernière pièce déposée relance l’instruction', () {
      final claim = claimWith(ClaimStatus.inReview);
      store.addClaim(claim);
      store.requestDocument(claim, 'Devis');
      store.requestDocument(claim, 'Facture');
      expect(claim.status, ClaimStatus.documentRequested);
      expect(claim.openRequests, hasLength(2));

      store.addDocument(claim, 'a.pdf', request: claim.openRequests.first);
      expect(claim.status, ClaimStatus.documentRequested);
      store.addDocument(claim, 'b.pdf', request: claim.openRequests.first);
      expect(claim.status, ClaimStatus.inReview);
    });

    test('une pièce libre ne relance pas l’instruction', () {
      final claim = claimWith(ClaimStatus.inReview);
      store.addClaim(claim);
      store.requestDocument(claim, 'Devis');
      store.addDocument(claim, 'photo.jpg');
      expect(claim.status, ClaimStatus.documentRequested);
    });

    test('chaque changement notifie le conducteur', () {
      final claim = claimWith(ClaimStatus.transmitted);
      store.addClaim(claim);
      final before = store.unreadCount(UserRole.driver);
      store.takeCharge(claim, 'Leïla');
      store.rejectClaim(claim, 'Hors garantie');
      expect(store.unreadCount(UserRole.driver), before + 2);
      expect(claim.decisionReason, 'Hors garantie');
    });

    test('un dépôt notifie l’agent, pas le conducteur', () {
      final claim = claimWith(ClaimStatus.inReview);
      store.addClaim(claim);
      final agent = store.unreadCount(UserRole.agent);
      final driver = store.unreadCount(UserRole.driver);
      store.addDocument(claim, 'photo.jpg');
      expect(store.unreadCount(UserRole.agent), agent + 1);
      expect(store.unreadCount(UserRole.driver), driver);
    });
  });

  group('responsabilité', () {
    int share(List<String> boxes) =>
        ResponsibilityProposal.fromCircumstances(boxes).driverA;

    test('propose 0, 50 ou 100 %', () {
      expect(share(['Reculait']), 100);
      expect(share(['En stationnement']), 0);
      expect(share(['Virait à gauche']), 50);
      expect(share([]), 50);
    });

    test('une manœuvre à risque l’emporte', () {
      expect(share(['Virait à droite', 'Doublait']), 100);
    });
  });

  group('filtres', () {
    final claim = claimWith(ClaimStatus.inReview)..severity = 'Grave';

    test('par texte, statut et gravité', () {
      expect(const ClaimFilter(query: 'sin-3').matches(claim), isTrue);
      expect(const ClaimFilter(query: 'sfax').matches(claim), isFalse);
      expect(
        const ClaimFilter(status: ClaimStatus.closed).matches(claim),
        isFalse,
      );
      expect(const ClaimFilter(severity: 'Grave').matches(claim), isTrue);
    });

    test('par date, jour de fin inclus, pour les deux formats', () {
      bool inRange(Claim value) => ClaimFilter(
        dates: DateTimeRange(
          start: DateTime(2026, 10, 1),
          end: DateTime(2026, 10, 12),
        ),
      ).matches(value);

      expect(inRange(claim), isTrue);
      expect(inRange(claimWith('x')..date = '2026-10-12 23:59'), isTrue);
      expect(inRange(claimWith('x')..date = '2026-10-13 00:00'), isFalse);
      expect(inRange(claimWith('x')..date = 'inconnue'), isFalse);
    });
  });

  group('écrans', () {
    late AppStores stores;

    Future<void> pump(WidgetTester tester, Widget home) async {
      tester.view.physicalSize = const Size(430, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      stores = AppStores();
      await tester.pumpWidget(
        AppScope(
          stores: stores,
          child: MaterialApp(home: Scaffold(body: home)),
        ),
      );
      await tester.pump();
    }

    testWidgets('l’agent prend en charge un dossier transmis', (tester) async {
      final claim = claimWith(ClaimStatus.transmitted);
      await pump(tester, ClaimDetail(claim, agentMode: true));
      await tester.tap(find.text('Prendre en charge'));
      await tester.pumpAndSettle();
      expect(claim.status, ClaimStatus.inReview);
      expect(find.text('Demander une pièce'), findsOneWidget);
    });

    testWidgets('la décision refuse un montant invalide', (tester) async {
      final claim = claimWith(ClaimStatus.inReview)
        ..circumstances.add('Reculait');
      await pump(tester, ClaimDetail(claim, agentMode: true));
      expect(find.textContaining('A 100 %, B 0 %'), findsOneWidget);

      await tester.tap(find.text('Clôturer le dossier'));
      await tester.pump();
      expect(find.text('Saisissez un montant valide.'), findsOneWidget);
      expect(claim.status, ClaimStatus.inReview);

      await tester.enterText(find.byType(TextField).last, '1200,5');
      await tester.tap(find.text('Clôturer le dossier'));
      await tester.pumpAndSettle();
      expect(claim.status, ClaimStatus.closed);
      expect(claim.indemnity, 1200.5);
      expect(claim.responsibility, 100);
      expect(find.text('Dossier clôturé'), findsOneWidget);
    });

    testWidgets('le conducteur dépose la pièce demandée', (tester) async {
      final original = pickDocument;
      addTearDown(() => pickDocument = original);
      pickDocument = () async => (name: 'devis.pdf', path: null);

      final claim = claimWith(ClaimStatus.documentRequested)
        ..requests.add(const DocumentRequest(id: 'r1', label: 'Devis'));
      await pump(tester, ClaimDetail(claim));
      await tester.tap(find.text('Déposer'));
      await tester.pumpAndSettle();
      expect(claim.status, ClaimStatus.inReview);
      expect(find.text('devis.pdf'), findsOneWidget);
      expect(find.text('Pièces demandées'), findsNothing);
    });

    testWidgets('le tableau de bord compte les vrais dossiers', (tester) async {
      await pump(tester, const AgentDashboard());
      stores.claims.addClaim(claimWith(ClaimStatus.expertise));
      stores.claims.addClaim(claimWith(ClaimStatus.closed, id: 'SIN-4'));
      await tester.pump();
      final count = find.descendant(
        of: find.ancestor(
          of: find.text('À traiter'),
          matching: find.byType(Column),
        ),
        matching: find.text('2'),
      );
      expect(count, findsOneWidget);
      expect(find.text('SIN-4'), findsNothing);
    });

    testWidgets('le filtre de recherche réduit la liste', (tester) async {
      await pump(tester, const ClaimsScreen(agentMode: true));
      expect(find.text('SIN-2026-0418'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'rien');
      await tester.pump();
      expect(find.text('Aucun dossier ne correspond.'), findsOneWidget);
    });

    testWidgets('lire une notification baisse le compteur', (tester) async {
      await pump(tester, const NotificationsScreen());
      expect(stores.claims.unreadCount(UserRole.driver), 2);
      await tester.tap(find.text('Tout marquer lu'));
      await tester.pump();
      expect(stores.claims.unreadCount(UserRole.driver), 0);
      expect(find.text('Tout marquer lu'), findsNothing);
    });

    testWidgets('ouvrir le chat envoie l’accusé de lecture', (tester) async {
      await pump(tester, ChatScreen(claimWith('x', id: 'SIN-5')));
      stores.messages.sendMessage('SIN-5', 'Leïla', UserRole.agent, 'Bonjour');
      expect(stores.messages.unreadCount(UserRole.driver), 1);
      await tester.pump();
      await tester.pump();
      expect(find.text('Bonjour'), findsOneWidget);
      expect(stores.messages.unreadCount(UserRole.driver), 0);

      await tester.enterText(find.byType(TextField), 'Merci');
      await tester.tap(find.byTooltip('Envoyer'));
      await tester.pump();
      expect(find.text('Merci'), findsOneWidget);
      expect(find.byIcon(Icons.done), findsOneWidget);
    });
  });
}
