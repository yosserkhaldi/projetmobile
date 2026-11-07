import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/main.dart';
import 'package:mon_constat_digital/modules/users/screens/profile_screen.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';

import 'support/fake_backend.dart';

Future<void> pumpApp(WidgetTester tester, FakeBackend backend) async {
  tester.view.physicalSize = const Size(430, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MonConstatApp(stores: backend.stores));
  await tester.pumpAndSettle();
}

Finder field(String label) => find.byKey(ValueKey(label));

/// Fait défiler le profil jusqu'à [target].
Future<void> scrollProfileTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    200,
    scrollable: find
        .descendant(
          of: find.byType(ProfileScreen),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

Future<void> signIn(WidgetTester tester) async {
  await tester.enterText(field('E-mail ou téléphone'), 'sami@example.com');
  await tester.enterText(field('Mot de passe'), 'Password123!');
  await tester.tap(find.text('Se connecter'));
  await tester.pumpAndSettle();
}

void main() {
  group('connexion', () {
    testWidgets('conducteur : accès aux cinq onglets', (tester) async {
      await pumpApp(tester, FakeBackend());
      expect(find.text('Le constat,\nsans papier.'), findsOneWidget);
      await signIn(tester);
      expect(find.textContaining('Bonjour, Sami'), findsOneWidget);
      expect(find.text('Véhicules'), findsOneWidget);
      expect(find.text('Déclarations'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets("le rôle vient du compte, sans choix à l'écran", (
      tester,
    ) async {
      final backend = FakeBackend(user: userJson(role: 'ADMIN'));
      await pumpApp(tester, backend);
      expect(find.text('Conducteur'), findsNothing);
      await signIn(tester);
      expect(find.text('Comptes'), findsOneWidget);
      expect(find.text('Compagnies'), findsOneWidget);
      expect(find.text('Véhicules'), findsNothing);
    });

    testWidgets("affiche l'erreur du serveur et reste sur l'écran", (
      tester,
    ) async {
      final backend = FakeBackend()
        ..failures['POST /auth/login'] = (
          401,
          'INVALID_CREDENTIALS',
          'Identifiant ou mot de passe incorrect.',
        );
      await pumpApp(tester, backend);
      await signIn(tester);
      expect(
        find.text('Identifiant ou mot de passe incorrect.'),
        findsOneWidget,
      );
      expect(find.text('Connexion'), findsOneWidget);
      expect(backend.requests.contains('POST /auth/refresh'), isFalse);
    });

    testWidgets('champs vides : aucune requête envoyée', (tester) async {
      final backend = FakeBackend();
      await pumpApp(tester, backend);
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();
      expect(find.text('Champ obligatoire.'), findsNWidgets(2));
      expect(backend.requests, isEmpty);
    });

    testWidgets('sans réseau : message clair', (tester) async {
      final backend = FakeBackend()..offline = true;
      await pumpApp(tester, backend);
      await signIn(tester);
      expect(find.textContaining('Connexion au serveur impossible'), findsOne);
    });
  });

  group('session', () {
    testWidgets('reprise au démarrage avec une session enregistrée', (
      tester,
    ) async {
      final backend = FakeBackend();
      backend.storage.values['refresh_token'] = 'refresh-0';
      await pumpApp(tester, backend);
      expect(backend.requests, ['POST /auth/refresh']);
      expect(find.textContaining('Bonjour, Sami'), findsOneWidget);
    });

    testWidgets('stockage illisible : connexion, pas de chargement sans fin', (
      tester,
    ) async {
      final backend = FakeBackend();
      backend.storage.broken = true;
      await pumpApp(tester, backend);
      expect(find.text('Connexion'), findsOneWidget);
    });

    testWidgets('session expirée au démarrage : retour à la connexion', (
      tester,
    ) async {
      final backend = FakeBackend()..refreshAllowed = false;
      backend.storage.values['refresh_token'] = 'refresh-0';
      await pumpApp(tester, backend);
      expect(find.text('Connexion'), findsOneWidget);
      expect(backend.storage.values.containsKey('refresh_token'), isFalse);
    });

    testWidgets('hors ligne au démarrage : dernier profil connu', (
      tester,
    ) async {
      final first = FakeBackend();
      await pumpApp(tester, first);
      await signIn(tester);

      final backend = FakeBackend()..offline = true;
      backend.storage.values.addAll(first.storage.values);
      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, backend);
      expect(find.textContaining('Bonjour, Sami'), findsOneWidget);
      expect(backend.storage.values.containsKey('refresh_token'), isTrue);
    });

    testWidgets('déconnexion : ferme les écrans ouverts et efface la session', (
      tester,
    ) async {
      final backend = FakeBackend();
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.ensureVisible(find.text('Mon permis'));
      await tester.tap(find.text('Mon permis'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);

      await scrollProfileTo(tester, find.text('Se déconnecter'));
      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();
      expect(find.text('Connexion'), findsOneWidget);
      expect(find.byType(ProfileScreen), findsNothing);
      expect(backend.requests, contains('POST /auth/logout'));
      // Seule la langue choisie reste sur le téléphone.
      // L'identifiant de l'appareil reste : sinon chaque reconnexion
      // déclencherait une alerte « nouvel appareil ».
      expect(backend.storage.values.keys, isNot(contains('refresh_token')));
      expect(backend.storage.values.keys, isNot(contains('current_user')));
    });
  });

  group('inscription', () {
    testWidgets('valide les champs, crée le compte, puis demande le code', (
      tester,
    ) async {
      final backend = FakeBackend(user: userJson(phoneVerified: false));
      await pumpApp(tester, backend);
      await tester.tap(find.text('Créer un compte'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Créer mon compte'));
      await tester.pumpAndSettle();
      expect(backend.requests, isEmpty);

      await tester.enterText(field('Prénom'), 'Sami');
      await tester.enterText(field('Nom'), 'Ben Ali');
      await tester.enterText(field('E-mail'), 'sami@example.com');
      await tester.enterText(field('Téléphone'), '20 123 456');
      await tester.enterText(field('Mot de passe'), 'Password123!');
      await tester.enterText(field('Confirmer le mot de passe'), 'Different1!');
      await tester.ensureVisible(find.text('Créer mon compte'));
      await tester.tap(find.text('Créer mon compte'));
      await tester.pumpAndSettle();
      expect(
        find.text('Les mots de passe ne correspondent pas.'),
        findsOneWidget,
      );
      // Sans la case cochée, pas de compte (loi n° 2004-63).
      expect(
        find.text('Votre accord est nécessaire pour créer un compte.'),
        findsOneWidget,
      );

      await tester.enterText(
        field('Confirmer le mot de passe'),
        'Password123!',
      );
      await tester.ensureVisible(find.byKey(const Key('consent')));
      await tester.tap(find.byKey(const Key('consent')));
      await tester.ensureVisible(find.text('Créer mon compte'));
      await tester.tap(find.text('Créer mon compte'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Vérifier mon téléphone'), findsOneWidget);

      await tester.enterText(field('Code de vérification'), '123456');
      await tester.tap(find.text('Valider'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(backend.bodies['POST /auth/phone/verify'], {'code': '123456'});
      expect(find.textContaining('Bonjour, Sami'), findsOneWidget);
      expect(backend.stores.users.currentUser!.phoneVerified, isTrue);
      expect(backend.bodies['POST /auth/register']!['consent'], isTrue);
    });

    testWidgets('e-mail déjà utilisé : erreur affichée', (tester) async {
      final backend = FakeBackend()
        ..failures['POST /auth/register'] = (
          409,
          'ALREADY_EXISTS',
          'E-mail ou téléphone déjà utilisé.',
        );
      await pumpApp(tester, backend);
      await tester.tap(find.text('Créer un compte'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Prénom'), 'Sami');
      await tester.enterText(field('Nom'), 'Ben Ali');
      await tester.enterText(field('E-mail'), 'sami@example.com');
      await tester.enterText(field('Téléphone'), '20123456');
      await tester.enterText(field('Mot de passe'), 'Password123!');
      await tester.enterText(
        field('Confirmer le mot de passe'),
        'Password123!',
      );
      await tester.ensureVisible(find.byKey(const Key('consent')));
      await tester.tap(find.byKey(const Key('consent')));
      await tester.ensureVisible(find.text('Créer mon compte'));
      await tester.tap(find.text('Créer mon compte'));
      await tester.pumpAndSettle();
      expect(find.text('E-mail ou téléphone déjà utilisé.'), findsOneWidget);
    });
  });

  testWidgets('mot de passe oublié : code puis nouveau mot de passe', (
    tester,
  ) async {
    final backend = FakeBackend();
    await pumpApp(tester, backend);
    await tester.tap(find.text('Mot de passe oublié ?'));
    await tester.pumpAndSettle();

    await tester.enterText(field('E-mail'), 'sami@example.com');
    await tester.tap(find.text('Recevoir un code'));
    await tester.pumpAndSettle();
    expect(backend.bodies['POST /auth/password/forgot'], {
      'email': 'sami@example.com',
    });

    await tester.enterText(field('Code reçu par e-mail'), '654321');
    await tester.enterText(field('Nouveau mot de passe'), 'NouveauPass456!');
    await tester.tap(find.text('Changer le mot de passe'));
    await tester.pumpAndSettle();
    expect(backend.bodies['POST /auth/password/reset'], {
      'email': 'sami@example.com',
      'code': '654321',
      'password': 'NouveauPass456!',
    });
    expect(find.text('Connexion'), findsOneWidget);
    expect(find.textContaining('Mot de passe modifié'), findsOneWidget);
  });

  group('profil', () {
    Future<void> openProfile(WidgetTester tester, FakeBackend backend) async {
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.ensureVisible(find.text('Mon permis'));
      await tester.tap(find.text('Mon permis'));
      await tester.pumpAndSettle();
      expect(find.text('Mon profil'), findsOneWidget);
    }

    testWidgets('sections, complétion et permis vide', (tester) async {
      final backend = FakeBackend();
      await openProfile(tester, backend);
      // Téléphone vérifié : 1 élément sur 7 (photo, téléphone, permis ×4, identité).
      expect(find.text('Profil complété à 14 %'), findsOneWidget);
      expect(find.text('IDENTITÉ'), findsOneWidget);
      await scrollProfileTo(tester, find.text('Ajouter mon permis'));
      expect(find.text('PRÉFÉRENCES'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets("modifier l'identité dans sa feuille", (tester) async {
      final backend = FakeBackend();
      await openProfile(tester, backend);
      await tester.tap(find.byKey(const Key('edit-identity')));
      await tester.pumpAndSettle();
      expect(find.text("Modifier l'identité"), findsOneWidget);

      await tester.enterText(field('Prénom'), 'Samir');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(backend.bodies['PATCH /users/me'], {
        'firstName': 'Samir',
        'lastName': 'Ben Ali',
        'phone': '+21620000001',
      });
      expect(backend.stores.users.userName, 'Samir Ben Ali');
      expect(find.text("Modifier l'identité"), findsNothing);
      expect(find.text('Samir Ben Ali'), findsWidgets);
      expect(find.text('Profil enregistré'), findsOneWidget);
    });

    testWidgets('modifier le permis : numéro et catégories dans l ordre', (
      tester,
    ) async {
      final backend = FakeBackend();
      await openProfile(tester, backend);
      await scrollProfileTo(tester, find.byKey(const Key('edit-license')));
      await tester.tap(find.byKey(const Key('edit-license')));
      await tester.pumpAndSettle();

      await tester.enterText(field('N° de permis'), '12/345678');
      await tester.tap(find.text('B'));
      await tester.tap(find.text('A'));
      await tester.pump();
      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(backend.bodies['PATCH /users/me'], {
        'licenseNumber': '12/345678',
        'licenseCategory': 'A, B',
        'licenseIssuedAt': '',
      });
      await scrollProfileTo(tester, find.text('12/345678'));
      expect(find.text('Profil complété à 50 %'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('langues', () {
    testWidgets("connexion en anglais, puis l'arabe de droite à gauche", (
      tester,
    ) async {
      final backend = FakeBackend();
      await pumpApp(tester, backend);
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsNWidgets(2));
      expect(find.text('Email or phone'), findsOneWidget);
      expect(backend.storage.values['app_language'], 'EN');

      await tester.tap(find.text('ع'));
      await tester.pumpAndSettle();
      expect(find.text('تسجيل الدخول'), findsNWidgets(2));
      final direction = Directionality.of(
        tester.element(find.text('كلمة المرور')),
      );
      expect(direction, TextDirection.rtl);
      expect(tester.takeException(), isNull);
    });

    testWidgets('erreur traduite à partir du code de l API', (tester) async {
      final backend = FakeBackend()
        ..failures['POST /auth/login'] = (
          401,
          'INVALID_CREDENTIALS',
          'Identifiant ou mot de passe incorrect.',
        );
      backend.storage.values['app_language'] = 'EN';
      await pumpApp(tester, backend);
      await tester.enterText(field('Email or phone'), 'sami@example.com');
      await tester.enterText(field('Password'), 'x');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Wrong login or password.'), findsOneWidget);
    });

    testWidgets('langue choisie avant la connexion : gardée et enregistrée', (
      tester,
    ) async {
      final backend = FakeBackend();
      await pumpApp(tester, backend);
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Email or phone'), 'sami@example.com');
      await tester.enterText(field('Password'), 'Password123!');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(backend.bodies['PATCH /users/me'], {'language': 'EN'});
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets(
      'nouveau téléphone : la langue du compte, puis le choix du profil',
      (tester) async {
        final backend = FakeBackend(user: {...userJson(), 'language': 'AR'});
        await pumpApp(tester, backend);
        await signIn(tester);
        // Le compte est en arabe : l'interface suit après la connexion.
        expect(find.text('الملف'), findsOneWidget);
        await tester.tap(find.text('الملف'));
        await tester.pumpAndSettle();

        await scrollProfileTo(tester, find.text('اللغة'));
        await tester.tap(find.text('اللغة'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('English'));
        await tester.pumpAndSettle();
        expect(backend.bodies['PATCH /users/me'], {'language': 'EN'});
        expect(find.text('Profile'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('apparence', () {
    testWidgets('mode sombre choisi dans le profil, gardé au redémarrage', (
      tester,
    ) async {
      final backend = FakeBackend();
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      await scrollProfileTo(tester, find.text('Apparence'));
      await tester.tap(find.text('Apparence'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sombre'));
      await tester.pumpAndSettle();

      final theme = Theme.of(tester.element(find.text('Apparence')));
      expect(theme.brightness, Brightness.dark);
      expect(backend.storage.values['theme_mode'], 'dark');
      expect(tester.takeException(), isNull);

      // Au redémarrage, l'écran de connexion est déjà sombre.
      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();
      final restarted = FakeBackend()..storage.values['theme_mode'] = 'dark';
      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, restarted);
      expect(
        Theme.of(tester.element(find.text('Connexion'))).brightness,
        Brightness.dark,
      );
    });

    testWidgets('mode sombre : chaque écran du module s affiche sans erreur', (
      tester,
    ) async {
      final backend =
          FakeBackend(
              user: userJson(id: 'me', firstName: 'Admin', role: 'ADMIN'),
            )
            ..storage.values['theme_mode'] = 'dark'
            ..users = [userJson(id: 'me', role: 'ADMIN'), userJson(id: 'u2')]
            ..companies = [
              {'id': 'c1', 'name': 'STAR Assurances', 'agencies': []},
            ];
      await pumpApp(tester, backend);
      await signIn(tester);
      for (final tab in ['Comptes', 'Compagnies', 'Profil', 'Tableau']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: tab);
      }
    });
  });

  group('sécurité du compte', () {
    Future<void> openSecurity(WidgetTester tester, FakeBackend backend) async {
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      await scrollProfileTo(tester, find.text('Appareils connectés'));
      await tester.tap(find.text('Appareils connectés'));
      await tester.pumpAndSettle();
    }

    testWidgets('liste les appareils, puis en déconnecte un', (tester) async {
      final backend = FakeBackend();
      await openSecurity(tester, backend);
      expect(find.text('Pixel de test'), findsWidgets);
      expect(find.text('Cet appareil'), findsOneWidget);
      expect(find.text('Chrome (web)'), findsWidgets);
      // Alerte expliquée à l'utilisateur.
      expect(find.textContaining('nouvel appareil'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Déconnecter'));
      await tester.pumpAndSettle();
      expect(find.text('Déconnecter Chrome (web) ?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Déconnecter'));
      await tester.pumpAndSettle();
      expect(backend.requests, contains('DELETE /users/me/sessions/s-pc'));
      expect(find.widgetWithText(TextButton, 'Déconnecter'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('déconnecte tous les autres appareils', (tester) async {
      final backend = FakeBackend();
      await openSecurity(tester, backend);
      await tester.tap(find.text('Déconnecter les autres appareils'));
      await tester.pumpAndSettle();
      expect(
        backend.requests,
        contains('POST /users/me/sessions/revoke-others'),
      );
      expect(find.text('1 appareil déconnecté'), findsOneWidget);
    });

    testWidgets('historique : échecs signalés avec leur motif', (tester) async {
      final backend = FakeBackend();
      await openSecurity(tester, backend);
      await tester.scrollUntilVisible(find.text('Mot de passe incorrect'), 200);
      expect(find.text('Mot de passe incorrect'), findsOneWidget);
      expect(find.text('Connexion réussie · mot de passe'), findsOneWidget);
    });

    testWidgets('envoie les en-têtes de l appareil à chaque requête', (
      tester,
    ) async {
      final backend = FakeBackend();
      await pumpApp(tester, backend);
      await signIn(tester);
      final login = backend.headers['POST /auth/login']!;
      expect(login['X-Device-Id'], 'device-test');
      expect(login['X-Device-Name'], 'Pixel de test');
    });
  });

  group("vérification d'identité", () {
    Future<void> openIdentity(WidgetTester tester, FakeBackend backend) async {
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      await scrollProfileTo(tester, find.byKey(const Key('open-identity')));
      expect(find.text('Identité non vérifiée'), findsOneWidget);
      await tester.tap(find.byKey(const Key('open-identity')));
      await tester.pumpAndSettle();
    }

    testWidgets('sans photos : demande refusée avant tout envoi', (
      tester,
    ) async {
      final backend = FakeBackend();
      await openIdentity(tester, backend);
      await tester.enterText(field('N° de CIN'), '12345678');
      await tester.tap(find.text('Envoyer pour vérification'));
      await tester.pumpAndSettle();
      expect(
        find.text('Ajoutez le recto et le verso de votre CIN.'),
        findsOneWidget,
      );
      expect(
        backend.requests,
        isNot(contains('POST /users/me/identity/submit')),
      );
    });

    testWidgets('avec les photos : envoyée, puis en cours de vérification', (
      tester,
    ) async {
      final backend = FakeBackend(
        user: {
          ...userJson(),
          'identity': {
            'status': 'UNVERIFIED',
            'frontId': 'front.jpg',
            'backId': 'back.jpg',
          },
        },
      );
      await openIdentity(tester, backend);
      await tester.enterText(field('N° de CIN'), '1234');
      await tester.tap(find.text('Envoyer pour vérification'));
      await tester.pumpAndSettle();
      expect(
        find.text('Le numéro de CIN contient 8 chiffres.'),
        findsOneWidget,
      );

      await tester.enterText(field('N° de CIN'), '12345678');
      await tester.tap(find.text('Envoyer pour vérification'));
      await tester.pumpAndSettle();
      expect(backend.bodies['POST /users/me/identity/submit'], {
        'cinNumber': '12345678',
      });
      expect(find.text('Vérification en cours'), findsOneWidget);
      // Verrouillée pendant la vérification.
      expect(find.text('Envoyer pour vérification'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('administrateur : valide une demande de la file', (
      tester,
    ) async {
      final backend =
          FakeBackend(
              user: userJson(id: 'me', firstName: 'Admin', role: 'ADMIN'),
            )
            ..pendingIdentities = [
              {
                ...userJson(id: 'u2', firstName: 'Mouna', lastName: 'Trabelsi'),
                'identity': {
                  'status': 'PENDING',
                  'cinNumber': '87654321',
                  'frontId': 'f.jpg',
                  'backId': 'b.jpg',
                  'submittedAt': '2026-11-07T10:00:00.000Z',
                },
              },
            ];
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.tap(find.text('Identités'));
      await tester.pumpAndSettle();
      expect(find.text('Mouna Trabelsi'), findsOneWidget);

      await tester.tap(find.text('Mouna Trabelsi'));
      await tester.pumpAndSettle();
      expect(find.text('87654321'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Valider'), 200);
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(backend.requests, contains('POST /users/u2/identity/approve'));
      expect(find.text('Aucune demande en attente.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('administrateur : refus avec un motif choisi', (tester) async {
      final backend =
          FakeBackend(
              user: userJson(id: 'me', firstName: 'Admin', role: 'ADMIN'),
            )
            ..pendingIdentities = [
              {
                ...userJson(id: 'u2', firstName: 'Mouna', lastName: 'Trabelsi'),
                'identity': {'status': 'PENDING', 'cinNumber': '87654321'},
              },
            ];
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.tap(find.text('Identités'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mouna Trabelsi'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Refuser'), 200);
      await tester.tap(find.text('Refuser'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Photo floue'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Refuser'));
      await tester.pumpAndSettle();
      expect(backend.bodies['POST /users/u2/identity/reject'], {
        'reason': 'Photo floue',
      });
    });
  });

  group('données personnelles', () {
    testWidgets('suppression du compte : mot de passe, puis déconnexion', (
      tester,
    ) async {
      final backend = FakeBackend();
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      await scrollProfileTo(tester, find.byKey(const Key('delete-account')));
      await tester.tap(find.byKey(const Key('delete-account')));
      await tester.pumpAndSettle();
      expect(find.text('Supprimer votre compte ?'), findsOneWidget);

      await tester.tap(find.byKey(const Key('confirm-delete')));
      await tester.pumpAndSettle();
      expect(backend.requests, isNot(contains('DELETE /users/me')));

      await tester.enterText(field('Mot de passe'), 'Password123!');
      await tester.tap(find.byKey(const Key('confirm-delete')));
      await tester.pumpAndSettle();
      expect(backend.bodies['DELETE /users/me'], {'password': 'Password123!'});
      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('Votre compte a été supprimé.'), findsOneWidget);
    });

    testWidgets("export : récupère les données de l'API", (tester) async {
      final backend = FakeBackend();
      await pumpApp(tester, backend);
      await signIn(tester);
      final data = await backend.stores.users.exportData();
      expect(data['account']['email'], 'sami@example.com');
    });

    testWidgets('administrateur : pas de suppression depuis le profil', (
      tester,
    ) async {
      final backend = FakeBackend(user: userJson(role: 'ADMIN'));
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      await scrollProfileTo(tester, find.byKey(const Key('export-data')));
      expect(find.byKey(const Key('delete-account')), findsNothing);
    });
  });

  testWidgets('tableau de bord : chiffres réels des comptes', (tester) async {
    final backend = FakeBackend(user: userJson(role: 'ADMIN'));
    await pumpApp(tester, backend);
    await signIn(tester);
    expect(find.text('Utilisateurs'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('3 identités vérifiées'), findsOneWidget);
    expect(find.text('75 %'), findsOneWidget);
    // Plus de chiffres fictifs d'accidents.
    expect(find.text('248'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('administration', () {
    FakeBackend adminBackend() =>
        FakeBackend(
            user: userJson(id: 'me', firstName: 'Admin', role: 'ADMIN'),
          )
          ..users = [
            userJson(id: 'me', firstName: 'Admin', role: 'ADMIN'),
            userJson(id: 'u2'),
          ]
          ..companies = [
            {'id': 'c1', 'name': 'STAR Assurances', 'agencies': []},
          ];

    testWidgets('suspend un compte, jamais le sien', (tester) async {
      final backend = adminBackend();
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.tap(find.text('Comptes'));
      await tester.pumpAndSettle();

      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2));
      expect(tester.widget<Switch>(switches.at(0)).onChanged, isNull);

      await tester.tap(switches.at(1));
      await tester.pumpAndSettle();
      expect(backend.bodies['PATCH /users/u2/status'], {'active': false});
      expect(tester.widget<Switch>(switches.at(1)).value, isFalse);
    });

    testWidgets('ajoute une compagnie', (tester) async {
      final backend = adminBackend();
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.tap(find.text('Compagnies'));
      await tester.pumpAndSettle();
      expect(find.text('STAR Assurances'), findsOneWidget);

      await tester.tap(find.byTooltip('Ajouter une compagnie'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Nom de la compagnie'), 'COMAR');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(backend.bodies['POST /companies'], {'name': 'COMAR'});
      expect(find.text('COMAR'), findsOneWidget);
    });
  });

  group('connexion biométrique', () {
    FakeBackend enrolled() =>
        FakeBackend()..storage.values['biometric_token'] = 'device-0';

    testWidgets('bouton masqué tant qu elle n est pas activée', (tester) async {
      await pumpApp(tester, FakeBackend());
      expect(find.text('Empreinte ou Face ID'), findsNothing);
    });

    testWidgets('empreinte reconnue : connexion et nouvelle clé', (
      tester,
    ) async {
      final backend = enrolled();
      await pumpApp(tester, backend);
      await tester.tap(find.text('Empreinte ou Face ID'));
      await tester.pumpAndSettle();
      expect(backend.biometric.prompts, 1);
      expect(backend.bodies['POST /auth/biometric/login'], {
        'deviceToken': 'device-0',
      });
      expect(find.textContaining('Bonjour, Sami'), findsOneWidget);
      expect(backend.storage.values['biometric_token'], 'device-1');
    });

    testWidgets('empreinte annulée : aucune requête', (tester) async {
      final backend = enrolled()..biometric.accept = false;
      await pumpApp(tester, backend);
      await tester.tap(find.text('Empreinte ou Face ID'));
      await tester.pumpAndSettle();
      expect(backend.requests, isNot(contains('POST /auth/biometric/login')));
      expect(find.text('Connexion'), findsOneWidget);
    });

    testWidgets('clé expirée : message, clé oubliée, bouton retiré', (
      tester,
    ) async {
      final backend = enrolled()
        ..failures['POST /auth/biometric/login'] = (
          401,
          'BIOMETRIC_INVALID',
          'Connexion biométrique expirée.',
        );
      await pumpApp(tester, backend);
      await tester.tap(find.text('Empreinte ou Face ID'));
      await tester.pumpAndSettle();
      expect(find.text('Connexion biométrique expirée.'), findsOneWidget);
      expect(find.text('Empreinte ou Face ID'), findsNothing);
      expect(backend.storage.values.containsKey('biometric_token'), isFalse);
    });

    testWidgets('activation depuis le profil, puis déconnexion conservée', (
      tester,
    ) async {
      final backend = FakeBackend();
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      final toggle = find.text('Connexion par empreinte');
      await scrollProfileTo(tester, toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(backend.requests, contains('POST /auth/biometric'));
      expect(backend.storage.values['biometric_token'], 'device-1');
      expect(find.text('Connexion biométrique activée'), findsOneWidget);
      // Le message disparaît avant de toucher « Se déconnecter » qu'il recouvre.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await scrollProfileTo(tester, find.text('Se déconnecter'));
      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();
      expect(find.text('Empreinte ou Face ID'), findsOneWidget);
    });

    testWidgets(
      'empreinte ajoutée dans les réglages : option visible au retour',
      (tester) async {
        final backend = FakeBackend()..biometric.available = false;
        await pumpApp(tester, backend);
        await signIn(tester);
        await tester.tap(find.text('Profil'));
        await tester.pumpAndSettle();
        expect(find.text('Connexion par empreinte'), findsNothing);

        backend.biometric.available = true;
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();
        await scrollProfileTo(tester, find.text('Connexion par empreinte'));
        expect(find.text('Connexion par empreinte'), findsOneWidget);
      },
    );

    testWidgets('sans capteur : pas d option dans le profil', (tester) async {
      final backend = FakeBackend()..biometric.available = false;
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Connexion par empreinte'), findsNothing);
    });
  });

  testWidgets('photo de profil : envoyée puis affichée', (tester) async {
    final backend = FakeBackend();
    await pumpApp(tester, backend);
    await signIn(tester);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsNothing);

    await backend.stores.users.uploadPhoto(
      UserPhoto.profile,
      Uint8List.fromList([9, 9, 9]),
      'moi.jpg',
    );
    await tester.pumpAndSettle();
    final upload = backend.uploads['PUT /users/me/photo']!;
    expect(upload.headers['Content-Type'], startsWith('multipart/form-data'));
    expect(
      utf8.decode(upload.bodyBytes, allowMalformed: true),
      contains('name="photo"; filename="moi.jpg"'),
    );
    expect(find.byType(Image), findsOneWidget);
    expect(backend.requests, contains('GET /users/u1/photo'));
  });

  testWidgets('démarre le parcours de déclaration', (tester) async {
    await pumpApp(tester, FakeBackend());
    await signIn(tester);
    await tester.tap(find.text('Commencer une déclaration'));
    await tester.pumpAndSettle();
    expect(find.text('Contexte'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets('exige deux preuves avant le constat', (tester) async {
    await pumpApp(tester, FakeBackend());
    await signIn(tester);
    await tester.tap(find.text('Commencer une déclaration'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Que s’est-il passé ?'), findsOneWidget);

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Photos guidées'), findsOneWidget);

    await tester.tap(find.text('Continuer vers le constat'));
    await tester.pump();
    expect(
      find.text('Ajoutez au moins 2 photos avant de continuer.'),
      findsOneWidget,
    );

    expect(find.text('Touchez pour ouvrir la caméra'), findsNWidgets(4));
  });

  testWidgets('le raccourci Constat ouvre les déclarations', (tester) async {
    await pumpApp(tester, FakeBackend());
    await signIn(tester);
    await tester.ensureVisible(find.text('Constat'));
    await tester.tap(find.text('Constat'));
    await tester.pumpAndSettle();
    expect(find.text('Mes déclarations'), findsOneWidget);
    expect(find.text('DÉCLARATIONS TRANSMISES'), findsOneWidget);
    expect(find.text('Conducteur B'), findsNothing);
  });

  testWidgets('reprend un brouillon à la dernière étape', (tester) async {
    await pumpApp(tester, FakeBackend());
    await signIn(tester);
    await tester.tap(find.text('Commencer une déclaration'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Que s’est-il passé ?'), findsOneWidget);
    // pageBack() cherche l'infobulle anglaise « Back » ; l'app est en français.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Constat'));
    await tester.tap(find.text('Constat'));
    await tester.pumpAndSettle();
    expect(find.text('Étape 2 sur 7'), findsOneWidget);
    await tester.tap(find.text('Reprendre'));
    await tester.pumpAndSettle();
    expect(find.text('Que s’est-il passé ?'), findsOneWidget);
  });
}
