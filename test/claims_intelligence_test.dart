import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mon_constat_digital/app/main_shell.dart';
import 'package:mon_constat_digital/core/network/api_client.dart';
import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_api.dart';
import 'package:mon_constat_digital/modules/claims/data/claims_database.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_insight.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/screens/agent_dashboard_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/analytics_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/assistant_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/chat_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/claim_detail_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/messages_screen.dart';
import 'package:mon_constat_digital/modules/claims/state/claim_store.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

import 'support/fake_backend.dart';

const identity = (id: 'a', role: 'agent', name: 'Leïla');

ClaimsApi apiWith(http.Client client) => ClaimsApi(
  ApiClient(
    storage: MemoryStorage(),
    httpClient: client,
    baseUrl: 'http://api/api',
  ),
);

Map<String, dynamic> agentJson({int priority = 50}) => {
  'estimate': {'low': 400, 'mid': 600, 'high': 900},
  'duration': {'totalDays': 12, 'remainingDays': 9},
  'risk': {
    'probability': 0.2,
    'level': 'moyen',
    'factors': ['délai de déclaration'],
  },
  'signals': [
    {'id': 'x', 'label': 'Cases contradictoires.'},
  ],
  'missingDocuments': [
    {'label': 'Devis', 'reason': 'Nécessaire pour chiffrer.'},
  ],
  'recommendExpert': true,
  'service': {'limitDays': 2, 'spentDays': 5, 'overdueDays': 3},
  'priority': {
    'score': priority,
    'reasons': ['Sinistre grave'],
  },
  'nextAction': {'code': 'request', 'label': 'Demander : Devis.'},
  'similar': [
    {
      'id': 'SIN-OLD',
      'similarity': 80,
      'outcome': 'Clôturé',
      'responsibility': 100,
      'indemnity': 700,
    },
  ],
};

const driverJson = {
  'driver': {
    'headline': 'Un agent étudie votre dossier.',
    'todo': ['Déposer : Facture'],
    'remainingDays': 9,
  },
};

Claim claimNamed(String id, {String status = ClaimStatus.inReview}) =>
    Claim(id: id, type: 'Collision', place: 'Tunis', date: 'x', status: status);

void main() {
  group('modèle', () {
    test('lit la vue de l’agent', () {
      final insight = ClaimInsight.fromJson(agentJson());
      expect(insight.isForAgent, isTrue);
      expect(insight.estimateHigh, 900);
      expect(insight.overdueDays, 3);
      expect(insight.missing.single.label, 'Devis');
      expect(insight.similar.single.indemnity, 700);
    });

    test('la vue du conducteur laisse le reste vide', () {
      final insight = ClaimInsight.fromJson(driverJson);
      expect(insight.isForAgent, isFalse);
      expect(insight.riskLevel, isNull);
      expect(insight.estimateLow, isNull);
      expect(insight.signals, isEmpty);
      expect(insight.todo, ['Déposer : Facture']);
    });
  });

  group('API', () {
    test('envoie les octets d’un fichier et son nom', () async {
      late http.Request received;
      final api = apiWith(
        MockClient((request) async {
          received = request;
          return http.Response('{}', 201);
        }),
      );
      final status = await api.send(
        ApiRequest(
          id: '1',
          method: 'POST',
          path: '/SIN-1/documents',
          identity: identity,
          multipart: true,
          fileBytes: Uint8List.fromList(utf8.encode('contenu')),
          fileName: 'devis.pdf',
          body: const {'name': 'devis.pdf'},
        ),
      );
      expect(status, 201);
      expect(received.body, contains('filename="devis.pdf"'));
      expect(received.body, contains('contenu'));
    });

    test('l’assistant a le temps de répondre', () async {
      final api = apiWith(
        MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 1));
          return http.Response(
            jsonEncode({
              'answer': 'ok',
              'source': 'ai',
              'by': 'Claude (CLI) · claude-sonnet-5-5',
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      final answer = await api.askAssistant('SIN-1', [
        (role: 'user', content: 'x'),
      ]);
      expect(answer.by, 'Claude (CLI) · claude-sonnet-5-5');
    });

    test('dit si la réponse vient des règles', () async {
      final api = apiWith(
        MockClient(
          (_) async => http.Response(
            jsonEncode({'answer': 'Bonjour', 'source': 'rules'}),
            200,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      final answer = await api.askAssistant('SIN-1', [
        (role: 'user', content: 'Statut ?'),
      ]);
      expect(answer.text, 'Bonjour');
      expect(answer.by, isNull);
    });

    test('une erreur du serveur remonte', () async {
      final api = apiWith(MockClient((_) async => http.Response('{}', 429)));
      expect(api.summarize('SIN-1'), throwsA(isA<ApiException>()));
    });
  });

  group('SQLite', () {
    late Directory directory;
    late File file;

    setUp(() {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      directory = Directory.systemTemp.createTempSync('claims-ai');
      file = File('${directory.path}/claims.sqlite');
    });
    tearDown(() => directory.deleteSync(recursive: true));

    test('l’analyse reste lisible hors ligne après un redémarrage', () async {
      final first = ClaimsDatabase(NativeDatabase(file));
      final done = await first.claimsDao.replaceFromServer(
        ServerSnapshot(
          [claimNamed('SIN-1')],
          const [],
          const [],
          insights: {'SIN-1': ClaimInsight.fromJson(agentJson())},
        ),
      );
      expect(done, isTrue);
      await first.close();

      final second = ClaimsDatabase(NativeDatabase(file));
      addTearDown(second.close);
      final store = ClaimStore(dao: second.claimsDao);
      await store.saved;
      expect(store.insightFor('SIN-1')?.nextAction, 'Demander : Devis.');
    });

    test('une nouvelle synchronisation efface l’analyse précédente', () async {
      final db = ClaimsDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.claimsDao.replaceFromServer(
        ServerSnapshot(
          [claimNamed('SIN-1')],
          const [],
          const [],
          insights: {'SIN-1': ClaimInsight.fromJson(agentJson())},
        ),
      );
      await db.claimsDao.replaceFromServer(
        ServerSnapshot(
          [claimNamed('SIN-1')],
          const [],
          const [],
          insights: {'SIN-1': ClaimInsight.fromJson(driverJson)},
        ),
      );
      final saved = await db.claimsDao.loadInsights();
      expect(saved['SIN-1']?.isForAgent, isFalse);
      expect(saved['SIN-1']?.raw.containsKey('risk'), isFalse);
    });

    test('garde la lecture d’une pièce', () async {
      final db = ClaimsDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final analysis = {
        'documentType': 'Devis',
        'amount': 1200,
        'summary': 'Devis garage.',
        'matchesRequest': true,
      };
      await db.claimsDao.insertClaim(
        claimNamed('SIN-1')
          ..documents.add(
            ClaimDocument(
              id: 'd',
              name: 'x.pdf',
              analysis: DocumentAnalysis.fromJson(analysis),
              analysisJson: jsonEncode(analysis),
            ),
          ),
      );
      final document =
          (await db.claimsDao.loadClaims()).single.documents.single;
      expect(document.analysis?.amount, 1200);
    });

    test('garde les octets d’un dépôt en attente', () async {
      final db = ClaimsDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.claimsDao.enqueue(
        ApiRequest(
          id: '1',
          method: 'POST',
          path: '/x',
          identity: identity,
          multipart: true,
          fileBytes: Uint8List.fromList([1, 2, 3]),
          fileName: 'a.png',
        ),
      );
      final request = (await db.claimsDao.pendingRequests()).single;
      expect(request.fileBytes, [1, 2, 3]);
      expect(request.fileName, 'a.png');
    });

    test('la migration de la v2 à la v5 garde les données', () async {
      final v2 = ClaimsDatabase(NativeDatabase(file));
      await v2.claimsDao.insertClaim(
        claimNamed('SIN-1')
          ..documents.add(const ClaimDocument(id: 'd', name: 'x.pdf')),
      );
      await v2.customStatement('DROP TABLE claim_insights');
      await v2.customStatement(
        'ALTER TABLE claim_documents DROP COLUMN analysis',
      );
      await v2.customStatement(
        'ALTER TABLE sync_outbox DROP COLUMN file_bytes',
      );
      await v2.customStatement('ALTER TABLE sync_outbox DROP COLUMN file_name');
      // Colonnes de la v4 : rendez-vous d'expertise.
      for (final column in [
        'expert_phone',
        'expert_place',
        'expert_kind',
        'appointment_state',
        'appointment_by',
        'appointment_note',
        // v5 : cases de B et compagnie.
        'circumstances_b',
        'company_id',
      ]) {
        await v2.customStatement('ALTER TABLE claims DROP COLUMN $column');
      }
      await v2.customStatement('PRAGMA user_version = 2');
      await v2.close();

      final v3 = ClaimsDatabase(NativeDatabase(file));
      addTearDown(v3.close);
      final claim = (await v3.claimsDao.loadClaims()).single;
      expect(claim.documents.single.name, 'x.pdf');
      expect(claim.expertPlace, isNull);
      expect(claim.circumstancesB, isEmpty);
      expect(claim.companyId, isNull);
      expect(await v3.claimsDao.loadInsights(), isEmpty);
    });
  });

  group('écrans', () {
    late AppStores stores;

    Future<void> pump(
      WidgetTester tester,
      Widget home, {
      UserRole role = UserRole.driver,
      void Function(AppStores)? prepare,
    }) async {
      tester.view.physicalSize = const Size(430, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      stores = AppStores(storage: MemoryStorage(), biometric: FakeBiometric());
      stores.users.currentUser = AppUser.fromJson(
        userJson(role: role.apiValue),
      );
      prepare?.call(stores);
      await tester.pumpWidget(
        AppScope(
          stores: stores,
          child: MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            home: Scaffold(body: home),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets('l’onglet Messages affiche les non lus et se vide', (
      tester,
    ) async {
      await pump(tester, const MainShell());
      Finder badge() => find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('1'),
      );
      expect(badge(), findsNothing);

      stores.messages.sendMessage(
        'SIN-2026-0418',
        'Leïla',
        UserRole.agent,
        'Bonjour',
      );
      await tester.pump();
      expect(badge(), findsOneWidget);

      stores.messages.markRead('SIN-2026-0418', UserRole.driver);
      await tester.pump();
      expect(badge(), findsNothing);
    });

    testWidgets('l’agent voit aussi le compteur de messages', (tester) async {
      await pump(tester, const MainShell(), role: UserRole.agent);
      stores.messages.sendMessage(
        'SIN-2026-0418',
        'Sami',
        UserRole.driver,
        'Bonjour',
      );
      await tester.pump();
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('le compteur reste en arabe', (tester) async {
      await pump(tester, const MainShell());
      stores.users.language = AppLanguage.ar;
      stores.messages.sendMessage(
        'SIN-2026-0418',
        'Leïla',
        UserRole.agent,
        'Bonjour',
      );
      await tester.pump();
      expect(find.widgetWithText(Badge, '1'), findsOneWidget);
    });

    testWidgets('chaque conversation affiche ses non lus', (tester) async {
      await pump(tester, const MessagesScreen());
      stores.messages.sendMessage(
        'SIN-2026-0418',
        'Leïla',
        UserRole.agent,
        'Un',
      );
      stores.messages.sendMessage(
        'SIN-2026-0418',
        'Leïla',
        UserRole.agent,
        'Deux',
      );
      await tester.pump();
      expect(find.widgetWithText(Badge, '2'), findsOneWidget);
    });

    testWidgets('l’agent voit l’analyse et demande la pièce manquante', (
      tester,
    ) async {
      final claim = claimNamed('SIN-1');
      await pump(
        tester,
        ClaimDetail(claim, agentMode: true),
        role: UserRole.agent,
        prepare: (s) => s.claims
          ..claims.add(claim)
          ..insights['SIN-1'] = ClaimInsight.fromJson(agentJson()),
      );
      expect(find.text('Aide à la décision'), findsOneWidget);
      expect(find.text('400 à 900 TND'), findsOneWidget);
      expect(find.text('Retard 3 j'), findsOneWidget);
      expect(find.text('Cases contradictoires.'), findsOneWidget);
      expect(find.textContaining('SIN-OLD (80 %)'), findsOneWidget);
      expect(find.textContaining('données simulées'), findsOneWidget);

      await tester.tap(find.text('Demander'));
      await tester.pump();
      expect(claim.requests.single.label, 'Devis');
      expect(claim.status, ClaimStatus.documentRequested);
    });

    testWidgets('le conducteur voit un guide et aucune analyse', (
      tester,
    ) async {
      final claim = claimNamed('SIN-1');
      await pump(
        tester,
        ClaimDetail(claim),
        prepare: (s) => s.claims
          ..claims.add(claim)
          ..insights['SIN-1'] = ClaimInsight.fromJson(driverJson),
      );
      expect(find.text('Un agent étudie votre dossier.'), findsOneWidget);
      expect(find.text('Déposer : Facture'), findsOneWidget);
      expect(find.textContaining('environ 9 jours'), findsOneWidget);
      expect(find.text('Aide à la décision'), findsNothing);
    });

    testWidgets(
      'même une analyse d’agent en cache reste cachée au conducteur',
      (tester) async {
        final claim = claimNamed('SIN-1');
        await pump(
          tester,
          ClaimDetail(claim),
          prepare: (s) => s.claims
            ..claims.add(claim)
            ..insights['SIN-1'] = ClaimInsight.fromJson(agentJson()),
        );
        expect(find.text('Aide à la décision'), findsNothing);
        expect(find.textContaining('TND'), findsNothing);
      },
    );

    testWidgets('la lecture d’une pièce apparaît pour l’agent', (tester) async {
      final claim = claimNamed('SIN-1')
        ..documents.add(
          ClaimDocument(
            id: 'd',
            name: 'x.pdf',
            analysis: DocumentAnalysis.fromJson(const {
              'documentType': 'Facture',
              'amount': 1200,
              'summary': 'Facture garage.',
              'matchesRequest': false,
            }),
          ),
        );
      await pump(
        tester,
        ClaimDetail(claim, agentMode: true),
        role: UserRole.agent,
      );
      expect(find.textContaining('1200 TND'), findsOneWidget);
      expect(find.textContaining('Ne correspond pas'), findsOneWidget);
    });

    testWidgets('le tableau de bord classe par priorité', (tester) async {
      final low = claimNamed('SIN-LOW');
      final high = claimNamed('SIN-HIGH');
      await pump(
        tester,
        const AgentDashboard(),
        role: UserRole.agent,
        prepare: (s) => s.claims
          ..claims.insertAll(0, [low, high])
          ..insights['SIN-LOW'] = ClaimInsight.fromJson(agentJson(priority: 10))
          ..insights['SIN-HIGH'] = ClaimInsight.fromJson(
            agentJson(priority: 90),
          ),
      );
      final top = tester.getTopLeft(find.text('SIN-HIGH')).dy;
      expect(top, lessThan(tester.getTopLeft(find.text('SIN-LOW')).dy));
      expect(find.text('Sinistre grave'), findsNWidgets(2));
    });

    testWidgets('sans analyse, le classement ne change pas', (tester) async {
      await pump(tester, const SizedBox());
      final store = stores.claims;
      final first = claimNamed('A');
      final second = claimNamed('B');
      expect(store.byPriority([first, second]), [first, second]);
    });

    testWidgets('l’assistant garde l’historique et nomme sa source', (
      tester,
    ) async {
      final calls = <int>[];
      await pump(
        tester,
        AssistantScreen(
          claimNamed('SIN-1'),
          ask: (messages) async {
            calls.add(messages.length);
            return (
              text: 'Réponse ${calls.length}',
              by: calls.length == 1 ? 'Perplexity · sonar' : null,
            );
          },
        ),
      );
      await tester.tap(find.text('Où en est mon dossier ?'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Réponse 1'), findsOneWidget);
      expect(find.text('Perplexity · sonar'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Et ensuite ?');
      await tester.tap(find.byTooltip('Envoyer'));
      await tester.pump();
      await tester.pump();
      expect(calls, [1, 3]);
      expect(find.text('Réponse automatique'), findsOneWidget);
    });

    testWidgets('une panne de l’assistant ne casse pas l’écran', (
      tester,
    ) async {
      await pump(
        tester,
        AssistantScreen(
          claimNamed('SIN-1'),
          ask: (_) => Future.error(const SocketException('réseau')),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Statut ?');
      await tester.tap(find.byTooltip('Envoyer'));
      await tester.pump();
      await tester.pump();
      expect(find.textContaining('indisponible'), findsOneWidget);
      expect(find.text('Statut ?'), findsOneWidget);
    });

    testWidgets('une suggestion remplit le champ sans envoyer', (tester) async {
      final claim = claimNamed('SIN-1');
      await pump(
        tester,
        ChatScreen(claim, suggest: () async => ['Bonjour Sami']),
        role: UserRole.agent,
      );
      await tester.tap(find.byTooltip('Suggérer une réponse'));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Bonjour Sami'));
      await tester.pump();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text, 'Bonjour Sami');
      expect(stores.messages.messagesFor('SIN-1'), isEmpty);
    });

    testWidgets('le conducteur n’a pas le bouton de suggestion', (
      tester,
    ) async {
      await pump(
        tester,
        ChatScreen(claimNamed('SIN-1'), suggest: () async => const []),
      );
      expect(find.byTooltip('Suggérer une réponse'), findsNothing);
    });

    testWidgets('les statistiques disent qu’elles sont simulées', (
      tester,
    ) async {
      await pump(
        tester,
        AnalyticsScreen(
          load: () async => {
            'total': 7,
            'overdue': 1,
            'averageDays': 12.4,
            'totalIndemnity': 3200,
            'byStatus': {'Transmis': 2, 'Clôturé': 5},
            'ai': {
              'decisionsCompared': 4,
              'agreement': 0.75,
              'estimateErrorTnd': 120,
            },
            'model': {
              'version': 'v1',
              'trainedOn': {'synthetic': 3000, 'real': 0},
              'metrics': {'indemnityMaeTnd': 326, 'rejectionAuc': 0.83},
            },
          },
        ),
        role: UserRole.agent,
      );
      expect(find.text('12 j'), findsOneWidget);
      expect(find.textContaining('75 %'), findsOneWidget);
      expect(find.textContaining('données simulées'), findsOneWidget);
      expect(find.text('Transmis'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
