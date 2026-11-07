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
      expect(find.text('Dossiers'), findsOneWidget);
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

      await tester.ensureVisible(find.text('Se déconnecter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();
      expect(find.text('Connexion'), findsOneWidget);
      expect(find.byType(ProfileScreen), findsNothing);
      expect(backend.requests, contains('POST /auth/logout'));
      expect(backend.storage.values, isEmpty);
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

      await tester.enterText(
        field('Confirmer le mot de passe'),
        'Password123!',
      );
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

  testWidgets('profil : enregistre sur le serveur', (tester) async {
    final backend = FakeBackend();
    await pumpApp(tester, backend);
    await signIn(tester);
    await tester.ensureVisible(find.text('Mon permis'));
    await tester.tap(find.text('Mon permis'));
    await tester.pumpAndSettle();
    expect(find.text('Mon profil'), findsOneWidget);

    await tester.enterText(field('Prénom'), 'Samir');
    await tester.enterText(field('N° de permis'), '12/345678');
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    final sent = backend.bodies['PATCH /users/me']!;
    expect(sent['firstName'], 'Samir');
    expect(sent['licenseNumber'], '12/345678');
    expect(backend.stores.users.userName, 'Samir Ben Ali');
    expect(find.text('Profil enregistré'), findsOneWidget);
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
      await tester.ensureVisible(toggle);
      await tester.pumpAndSettle();
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(backend.requests, contains('POST /auth/biometric'));
      expect(backend.storage.values['biometric_token'], 'device-1');
      expect(find.text('Connexion biométrique activée'), findsOneWidget);
      // Le message disparaît avant de toucher « Se déconnecter » qu'il recouvre.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Se déconnecter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();
      expect(find.text('Empreinte ou Face ID'), findsOneWidget);
    });

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
}
