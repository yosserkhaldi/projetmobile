import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mon_constat_digital/main.dart';
import 'package:mon_constat_digital/modules/users/screens/liveness_screen.dart';
import 'package:mon_constat_digital/modules/users/models/liveness.dart';
import 'package:mon_constat_digital/modules/users/screens/profile_screen.dart';
import 'package:mon_constat_digital/modules/users/services/face_guide.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';
import 'package:mon_constat_digital/modules/users/widgets/user_photo.dart';

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
      expect(find.text('Constats'), findsOneWidget);
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

      final backend = FakeBackend(usersDb: first.usersDb)..offline = true;
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
      // Le profil est gardé en SQLite tant que la session est ouverte.
      expect(await backend.usersDb.loadProfile(), isNotNull);
      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();
      expect(find.text('Connexion'), findsOneWidget);
      expect(find.byType(ProfileScreen), findsNothing);
      expect(await backend.usersDb.loadProfile(), isNull);
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

    testWidgets('mot de passe : jauge de robustesse et confirmation', (
      tester,
    ) async {
      await pumpApp(tester, FakeBackend());
      await tester.tap(find.text('Créer un compte'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Mot de passe'), 'abc');
      await tester.pump();
      expect(find.text('Faible'), findsOneWidget);
      await tester.enterText(field('Mot de passe'), 'abcdefg1');
      await tester.pump();
      expect(find.text('Moyen'), findsOneWidget);
      await tester.enterText(field('Mot de passe'), 'Abcdefg1!');
      await tester.pump();
      expect(find.text('Excellent'), findsOneWidget);
      // Coche dès que la confirmation correspond.
      expect(find.byKey(const Key('passwords-match')), findsNothing);
      await tester.enterText(field('Confirmer le mot de passe'), 'Abcdefg1!');
      await tester.pump();
      expect(find.byKey(const Key('passwords-match')), findsOneWidget);
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

    testWidgets('en-tête : état de l identité du conducteur', (tester) async {
      await openProfile(
        tester,
        FakeBackend(
          user: {
            ...userJson(),
            'identity': {'status': 'VERIFIED'},
          },
        ),
      );
      expect(find.text('Identité vérifiée'), findsWidgets);
      expect(find.byKey(const Key('identity-pill')), findsOneWidget);
    });

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

    testWidgets('scanner le permis : l IA remplit numéro, catégories, date', (
      tester,
    ) async {
      photoPicker = (_) async => XFile.fromData(tinyPng, name: 'permis.png');
      addTearDown(() => photoPicker = (_) async => null);
      final backend = FakeBackend();
      await openProfile(tester, backend);
      await scrollProfileTo(tester, find.byKey(const Key('edit-license')));
      await tester.tap(find.byKey(const Key('edit-license')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('scan-license')));
      await tester.pumpAndSettle();
      expect(backend.requests, contains('PUT /users/me/license-photo'));
      expect(
        find.text(
          "Rempli par l'IA à partir de la photo. Vérifiez avant d'enregistrer.",
        ),
        findsOneWidget,
      );
      // Rien n'est enregistré avant la confirmation.
      expect(backend.requests, isNot(contains('PATCH /users/me')));

      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(backend.bodies['PATCH /users/me'], {
        'licenseNumber': '12/345678',
        'licenseCategory': 'B, B+E',
        'licenseIssuedAt': '2018-06-15',
      });
    });

    testWidgets('scanner le permis : date de naissance différente signalée', (
      tester,
    ) async {
      photoPicker = (_) async => XFile.fromData(tinyPng, name: 'permis.png');
      addTearDown(() => photoPicker = (_) async => null);
      final backend = FakeBackend()
        ..licenseReading = {
          'number': '12/345678',
          'categories': ['B'],
          'issuedAt': '2018-06-15',
          'birthDateMatchesIdentity': false,
        };
      await openProfile(tester, backend);
      await scrollProfileTo(tester, find.byKey(const Key('edit-license')));
      await tester.tap(find.byKey(const Key('edit-license')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('scan-license')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('la date de naissance du permis ne correspond pas'),
        findsOneWidget,
      );
    });

    testWidgets('scanner le permis d un proche : « pas à votre nom »', (
      tester,
    ) async {
      photoPicker = (_) async => XFile.fromData(tinyPng, name: 'permis.png');
      addTearDown(() => photoPicker = (_) async => null);
      final backend = FakeBackend()
        ..licenseReading = {
          'number': '08/12345',
          'categories': <String>[],
          'issuedAt': '2017-08-18',
          'nameMatchesAccount': false,
        };
      await openProfile(tester, backend);
      await scrollProfileTo(tester, find.byKey(const Key('edit-license')));
      await tester.tap(find.byKey(const Key('edit-license')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('scan-license')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining("ce permis n'est pas à votre nom"),
        findsOneWidget,
      );
    });

    testWidgets('photo du permis : ouvre le permis pour la remplacer', (
      tester,
    ) async {
      final backend = FakeBackend(
        user: {...userJson(), 'licensePhotoId': 'permis.jpg'},
      );
      await openProfile(tester, backend);
      await scrollProfileTo(tester, find.byKey(const Key('license-photo')));
      await tester.tap(find.byKey(const Key('license-photo')));
      await tester.pumpAndSettle();
      // La photo actuelle, et le scan qui la remplace en relisant la carte.
      expect(find.byKey(const Key('license-sheet-photo')), findsOneWidget);
      expect(find.byKey(const Key('scan-license')), findsOneWidget);
    });

    testWidgets('administrateur : pas de section permis dans le profil', (
      tester,
    ) async {
      final backend = FakeBackend(user: userJson(role: 'ADMIN'));
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      // Le profil est bien affiché, sans la section permis.
      await scrollProfileTo(tester, find.byKey(const Key('export-data')));
      expect(find.byKey(const Key('edit-license')), findsNothing);
      expect(find.byKey(const Key('license-photo')), findsNothing);
    });

    testWidgets('scanner le permis illisible : formulaire à compléter', (
      tester,
    ) async {
      photoPicker = (_) async => XFile.fromData(tinyPng, name: 'permis.png');
      addTearDown(() => photoPicker = (_) async => null);
      final backend = FakeBackend()..licenseReading = null;
      await openProfile(tester, backend);
      await scrollProfileTo(tester, find.byKey(const Key('edit-license')));
      await tester.tap(find.byKey(const Key('edit-license')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('scan-license')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          "Photo enregistrée, mais l'IA n'a pas pu lire le permis. Complétez les champs.",
        ),
        findsOneWidget,
      );
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
    setUp(() {
      LivenessScreen.cameraFactory = FakeFaceCamera.new;
      // Par défaut sans détection sur le téléphone : compte à rebours.
      LivenessScreen.guideFactory = () => null;
    });
    tearDown(() {
      LivenessScreen.cameraFactory = DeviceFaceCamera.new;
      LivenessScreen.guideFactory = deviceFaceGuide;
    });

    /// Compte avec les photos de la pièce, et au besoin le visage déjà vérifié.
    Map<String, dynamic> withIdentity({
      bool back = true,
      bool liveness = false,
    }) => {
      ...userJson(),
      'identity': {
        'status': 'UNVERIFIED',
        'frontId': 'front.jpg',
        if (back) 'backId': 'back.jpg',
        if (liveness) 'selfieId': 'selfie.jpg',
        if (liveness) 'livenessAt': DateTime.now().toUtc().toIso8601String(),
      },
    };

    final identityList = find
        .descendant(
          of: find.byKey(const Key('identity-list')),
          matching: find.byType(Scrollable),
        )
        .first;

    Future<void> tapSubmit(WidgetTester tester) async {
      // Un message en bas d'écran masquerait le bouton.
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .clearSnackBars();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Envoyer pour vérification'),
        200,
        scrollable: identityList,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Envoyer pour vérification'));
      await tester.pumpAndSettle();
    }

    /// Trois consignes de trois secondes, puis l'analyse.
    Future<void> pumpCountdown(WidgetTester tester) async {
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();
    }

    Future<void> openFaceCheck(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.byKey(const Key('start-face-check')),
        200,
        scrollable: identityList,
      );
      await tester.pumpAndSettle();
      // Sans accord, le bouton reste inactif.
      await tester.tap(find.byKey(const Key('start-face-check')));
      await tester.pumpAndSettle();
      expect(find.byType(LivenessScreen), findsNothing);
      await tester.tap(find.byKey(const Key('biometric-consent')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('start-face-check')));
      await tester.pumpAndSettle();
    }

    Future<void> runFaceCheck(WidgetTester tester) async {
      await openFaceCheck(tester);
      await pumpCountdown(tester);
    }

    Future<void> openIdentity(
      WidgetTester tester,
      FakeBackend backend, {
      bool unverified = true,
    }) async {
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      await scrollProfileTo(tester, find.byKey(const Key('open-identity')));
      if (unverified) {
        expect(find.text('Identité non vérifiée'), findsOneWidget);
      }
      await tester.tap(find.byKey(const Key('open-identity')));
      await tester.pumpAndSettle();
    }

    testWidgets('sans photos : demande refusée avant tout envoi', (
      tester,
    ) async {
      final backend = FakeBackend();
      await openIdentity(tester, backend);
      await tester.enterText(field('N° de CIN'), '12345678');
      await tapSubmit(tester);
      await tester.scrollUntilVisible(
        find.text('Ajoutez les photos de la pièce.'),
        -200,
        scrollable: identityList,
      );
      expect(find.text('Ajoutez les photos de la pièce.'), findsOneWidget);
      expect(
        backend.requests,
        isNot(contains('POST /users/me/identity/submit')),
      );
    });

    testWidgets('avancement : pièce faite, lecture en cours', (tester) async {
      final backend = FakeBackend(user: withIdentity());
      await openIdentity(tester, backend);
      expect(find.byKey(const Key('identity-progress')), findsOneWidget);
      // Étape 1 cochée (recto et verso), les autres numérotées.
      final progress = find.byKey(const Key('identity-progress'));
      expect(
        find.descendant(
          of: progress,
          matching: find.byIcon(Icons.check_rounded),
        ),
        findsOneWidget,
      );
      for (final number in ['2', '3', '4']) {
        expect(
          find.descendant(of: progress, matching: find.text(number)),
          findsOneWidget,
        );
      }
    });

    testWidgets('sans vérification du visage : demande refusée', (
      tester,
    ) async {
      final backend = FakeBackend(user: withIdentity());
      await openIdentity(tester, backend);
      await tester.enterText(field('N° de CIN'), '1234');
      await tapSubmit(tester);
      await tester.scrollUntilVisible(
        find.text('Le numéro de CIN contient 8 chiffres.'),
        -200,
        scrollable: identityList,
      );
      expect(
        find.text('Le numéro de CIN contient 8 chiffres.'),
        findsOneWidget,
      );
      await tester.enterText(field('N° de CIN'), '12345678');
      await tapSubmit(tester);
      await tester.scrollUntilVisible(
        find.text("Faites d'abord la vérification du visage."),
        -200,
        scrollable: identityList,
      );
      expect(
        find.text("Faites d'abord la vérification du visage."),
        findsOneWidget,
      );
      expect(
        backend.requests,
        isNot(contains('POST /users/me/identity/submit')),
      );
    });

    testWidgets(
      'parcours complet : visage vérifié, identité validée par l IA',
      (tester) async {
        final backend = FakeBackend(user: withIdentity());
        await openIdentity(tester, backend);
        await runFaceCheck(tester);

        // Défi demandé, puis trois photos envoyées avec le jeton.
        expect(backend.requests, contains('POST /users/me/identity/liveness'));
        final upload = backend.uploads['POST /users/me/identity/selfie']!;
        final body = latin1.decode(upload.bodyBytes);
        expect(body, contains('challenge-1'));
        expect('filename='.allMatches(body).length, 3);
        expect(find.text('Visage vérifié'), findsOneWidget);

        await tester.enterText(field('N° de CIN'), '12345678');
        await tapSubmit(tester);
        expect(backend.bodies['POST /users/me/identity/submit'], {
          'documentType': 'CIN',
          'number': '12345678',
        });
        expect(find.text('Identité vérifiée'), findsOneWidget);
        expect(
          find.text(
            'Vérifiée automatiquement par reconnaissance faciale. '
            'Vous pouvez signer vos constats.',
          ),
          findsOneWidget,
        );
        expect(find.text('Envoyer pour vérification'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('IA dans le doute : la demande attend un administrateur', (
      tester,
    ) async {
      final backend = FakeBackend(user: withIdentity(liveness: true))
        ..aiMatch = 0.4;
      await openIdentity(tester, backend);
      await tester.enterText(field('N° de CIN'), '12345678');
      await tapSubmit(tester);
      expect(find.text('Vérification en cours'), findsOneWidget);
      // Verrouillée pendant la vérification.
      expect(find.text('Envoyer pour vérification'), findsNothing);
    });

    testWidgets('passeport : une seule page et le numéro du passeport', (
      tester,
    ) async {
      final backend = FakeBackend(
        user: withIdentity(back: false, liveness: true),
      );
      await openIdentity(tester, backend);
      await tester.tap(find.text('Passeport'));
      await tester.pumpAndSettle();
      expect(find.text('Page photo du passeport'), findsOneWidget);
      expect(find.text('Verso de la CIN'), findsNothing);

      await tester.enterText(field('N° du passeport'), '123');
      await tapSubmit(tester);
      expect(
        find.text('Numéro de passeport invalide (ex. X1234567).'),
        findsOneWidget,
      );
      await tester.enterText(field('N° du passeport'), 'x 1234567');
      await tapSubmit(tester);
      expect(backend.bodies['POST /users/me/identity/submit'], {
        'documentType': 'PASSPORT',
        'number': 'X1234567',
      });
    });

    testWidgets('visage refusé par l IA : message, puis nouvel essai', (
      tester,
    ) async {
      final backend = FakeBackend(user: withIdentity())
        ..failures['POST /users/me/identity/selfie'] = (
          422,
          'LIVENESS_NO_TURN',
          'Tournez davantage la tête quand la consigne le demande.',
        );
      await openIdentity(tester, backend);
      await runFaceCheck(tester);
      expect(
        find.text('Tournez davantage la tête quand la consigne le demande.'),
        findsOneWidget,
      );
      backend.failures.clear();
      await tester.tap(find.byKey(const Key('liveness-retry')));
      await pumpCountdown(tester);
      expect(find.text('Visage vérifié'), findsOneWidget);
    });

    testWidgets(
      'lecture de la pièce : informations lues et numéro pré-rempli',
      (tester) async {
        final backend = FakeBackend(
          user: {
            ...withIdentity(),
            'identity': {
              ...withIdentity()['identity'] as Map<String, dynamic>,
              'documentType': 'CIN',
              'extracted': {
                'type': 'CIN',
                'number': '12345678',
                'lastNameAr': 'بن علي',
                'firstNameAr': 'سامي',
                'parentsAr': 'بن محمد بن صالح',
                'birthDate': '1999-03-12',
              },
            },
          },
        );
        await openIdentity(tester, backend);
        expect(find.text("Lu sur la pièce par l'IA"), findsOneWidget);
        expect(find.text('سامي بن علي'), findsOneWidget);
        expect(find.text('بن محمد بن صالح'), findsOneWidget);
        await tester.scrollUntilVisible(
          field('N° de CIN'),
          200,
          scrollable: identityList,
        );
        final input = tester.widget<EditableText>(
          find.descendant(
            of: field('N° de CIN'),
            matching: find.byType(EditableText),
          ),
        );
        expect(input.controller.text, '12345678');

        // Une autre pièce choisie : la lecture de la CIN ne s'applique plus.
        await tester.tap(find.text('Passeport'));
        await tester.pumpAndSettle();
        expect(find.text("Lu sur la pièce par l'IA"), findsNothing);
      },
    );

    testWidgets('permis du profil réutilisé comme pièce, puis lu par l IA', (
      tester,
    ) async {
      final backend = FakeBackend(
        user: {
          ...userJson(),
          'licensePhotoId': 'permis.jpg',
          'identity': {'status': 'UNVERIFIED'},
        },
      )..documentReading = {'number': '12/345678'};
      await openIdentity(tester, backend);
      expect(find.byKey(const Key('use-license-photo')), findsNothing);
      await tester.tap(find.text('Permis'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('use-license-photo')));
      await tester.pumpAndSettle();
      expect(
        backend.requests,
        contains('POST /users/me/identity/front/from-license'),
      );
      expect(find.text("Lu sur la pièce par l'IA"), findsOneWidget);
      expect(find.text('12/345678'), findsWidgets);
    });

    testWidgets('détection sur le téléphone : photos prises au bon moment', (
      tester,
    ) async {
      final guide = FakeFaceGuide([
        null, // personne devant la caméra
        (faces: 1, yaw: 3.0), // de face : gardée
        (faces: 1, yaw: 8.0), // pas assez tournée
        (faces: 1, yaw: 31.0), // tournée : gardée
        (faces: 1, yaw: 27.0), // même sens : refusée
        (faces: 1, yaw: -29.0), // sens opposé : gardée
      ]);
      LivenessScreen.guideFactory = () => guide;
      final backend = FakeBackend(user: withIdentity());
      await openIdentity(tester, backend);
      await openFaceCheck(tester);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      await tester.pumpAndSettle();
      expect(guide.seen, 6);
      final upload = backend.uploads['POST /users/me/identity/selfie']!;
      expect('filename='.allMatches(latin1.decode(upload.bodyBytes)).length, 3);
      expect(find.text('Visage vérifié'), findsOneWidget);
    });

    test('pose attendue : de face, puis deux rotations de sens opposés', () {
      expect(poseMatches(LivenessStep.center, (faces: 1, yaw: 5)), isTrue);
      expect(poseMatches(LivenessStep.center, (faces: 1, yaw: 25)), isFalse);
      expect(poseMatches(LivenessStep.center, (faces: 2, yaw: 0)), isFalse);
      expect(poseMatches(LivenessStep.left, (faces: 1, yaw: 15)), isFalse);
      expect(poseMatches(LivenessStep.left, (faces: 1, yaw: -24)), isTrue);
      expect(
        poseMatches(LivenessStep.right, (
          faces: 1,
          yaw: -30,
        ), firstTurnSign: -1),
        isFalse,
      );
      expect(
        poseMatches(LivenessStep.right, (faces: 1, yaw: 30), firstTurnSign: -1),
        isTrue,
      );
    });

    testWidgets('caméra refusée : message clair, aucune requête', (
      tester,
    ) async {
      LivenessScreen.cameraFactory = () => FakeFaceCamera(fail: true);
      final backend = FakeBackend(user: withIdentity());
      await openIdentity(tester, backend);
      await openFaceCheck(tester);
      expect(
        find.text(
          "Caméra indisponible. Autorisez l'accès à la caméra, puis réessayez.",
        ),
        findsOneWidget,
      );
      expect(
        backend.requests,
        isNot(contains('POST /users/me/identity/liveness')),
      );
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
      await tester.tap(find.byTooltip('Identités'));
      await tester.pumpAndSettle();
      expect(find.text('Mouna Trabelsi'), findsOneWidget);

      await tester.tap(find.text('Mouna Trabelsi'));
      await tester.pumpAndSettle();
      expect(find.text('87654321'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Valider'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
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
      await tester.tap(find.byTooltip('Identités'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mouna Trabelsi'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Refuser'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Refuser'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Photo floue'));
      await tester.pumpAndSettle();
      // Photo floue : nouvelle demande possible, pas de refus définitif.
      expect(
        tester
            .widget<SwitchListTile>(find.byKey(const Key('reject-severe')))
            .value,
        isFalse,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Refuser'));
      await tester.pumpAndSettle();
      expect(backend.bodies['POST /users/u2/identity/reject'], {
        'reason': 'Photo floue',
        'severe': false,
      });
    });

    testWidgets('administrateur : visage différent = refus définitif', (
      tester,
    ) async {
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
      await tester.tap(find.byTooltip('Identités'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mouna Trabelsi'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Refuser'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Refuser'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Le visage ne correspond pas à la pièce'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Refuser'));
      await tester.pumpAndSettle();
      expect(backend.bodies['POST /users/u2/identity/reject'], {
        'reason': 'Le visage ne correspond pas à la pièce',
        'severe': true,
      });
    });

    testWidgets('refusée : 24 h d attente, essais restants, demande fermée', (
      tester,
    ) async {
      final backend = FakeBackend(
        user: {
          ...userJson(),
          'identity': {
            'status': 'REJECTED',
            'rejectionReason': 'Photo floue',
            'refusals': 1,
            'retryAt': DateTime.now()
                .add(const Duration(hours: 20))
                .toUtc()
                .toIso8601String(),
          },
        },
      );
      await openIdentity(tester, backend, unverified: false);
      expect(
        find.textContaining('Nouvelle demande possible le'),
        findsOneWidget,
      );
      expect(find.textContaining('Essais restants : 2.'), findsOneWidget);
      expect(find.text('Envoyer pour vérification'), findsNothing);
    });

    testWidgets('bloquée : message support, demande fermée', (tester) async {
      final backend = FakeBackend(
        user: {
          ...userJson(),
          'identity': {
            'status': 'REJECTED',
            'rejectionReason': 'Pièce non valable',
            'refusals': 1,
            'blocked': true,
          },
        },
      );
      await openIdentity(tester, backend, unverified: false);
      expect(find.text('Vérification bloquée'), findsWidgets);
      expect(find.textContaining('Contactez le support'), findsOneWidget);
      expect(find.text('Envoyer pour vérification'), findsNothing);
    });
  });

  group("modifications hors ligne (file SQLite)", () {
    Future<void> editNameOffline(
      WidgetTester tester,
      FakeBackend backend,
    ) async {
      await pumpApp(tester, backend);
      await signIn(tester);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      backend.offline = true;
      await tester.tap(find.byKey(const Key('edit-identity')));
      await tester.pumpAndSettle();
      await tester.enterText(field('Prénom'), 'Samir');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      // Le nouvel essai toutes les 20 s ne doit pas survivre au test.
      addTearDown(backend.stores.users.stopAutoSync);
    }

    testWidgets('sans réseau : affichée tout de suite, gardée en attente', (
      tester,
    ) async {
      final backend = FakeBackend();
      await editNameOffline(tester, backend);
      expect(
        find.textContaining('Enregistré sur le téléphone'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('pending-sync')), findsOneWidget);
      expect(backend.stores.users.userName, 'Samir Ben Ali');
      expect(await backend.usersDb.pending(), hasLength(1));
      expect(backend.requests, isNot(contains('PATCH /users/me')));
    });

    testWidgets('retour du réseau : envoyée puis retirée de la file', (
      tester,
    ) async {
      final backend = FakeBackend();
      await editNameOffline(tester, backend);
      backend.offline = false;
      await tester.tap(find.text('Synchroniser'));
      await tester.pumpAndSettle();
      expect(backend.bodies['PATCH /users/me']!['firstName'], 'Samir');
      expect(await backend.usersDb.pending(), isEmpty);
      expect(find.byKey(const Key('pending-sync')), findsNothing);
    });

    testWidgets('refus du serveur : motif affiché, modification annulable', (
      tester,
    ) async {
      final backend = FakeBackend();
      await editNameOffline(tester, backend);
      backend
        ..offline = false
        ..failures['PATCH /users/me'] = (
          409,
          'ALREADY_EXISTS',
          'E-mail ou téléphone déjà utilisé.',
        );
      await tester.tap(find.text('Synchroniser'));
      await tester.pumpAndSettle();
      expect(find.textContaining('déjà utilisé'), findsOneWidget);
      expect(find.text('Annuler les modifications'), findsOneWidget);

      backend.failures.remove('PATCH /users/me');
      await tester.tap(find.text('Annuler les modifications'));
      await tester.pumpAndSettle();
      expect(await backend.usersDb.pending(), isEmpty);
      expect(backend.stores.users.userName, 'Sami Ben Ali');
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
    // Bilan de l'IA.
    await tester.scrollUntilVisible(
      find.byKey(const Key('dash-ai')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('63 %'), findsOneWidget);
    expect(find.text('71 %'), findsOneWidget);
    expect(find.text("validées par l'IA seule"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group("console d'administration (grand écran)", () {
    Future<FakeBackend> openConsole(WidgetTester tester) async {
      final backend =
          FakeBackend(
              user: userJson(id: 'me', firstName: 'Admin', role: 'ADMIN'),
            )
            ..users = [
              userJson(id: 'me', firstName: 'Admin', role: 'ADMIN'),
              userJson(id: 'u2'),
              userJson(
                id: 'u3',
                firstName: 'Leïla',
                lastName: 'Mansour',
                role: 'AGENT',
              ),
            ]
            ..pendingIdentities = [
              {
                ...userJson(id: 'u4', firstName: 'Mouna', lastName: 'Trabelsi'),
                'identity': {
                  'status': 'PENDING',
                  'cinNumber': '08123456',
                  'frontId': 'f.png',
                  'backId': 'b.png',
                  'submittedAt': '2026-11-09T10:00:00.000Z',
                },
              },
            ]
            ..companies = [
              {
                'id': 'c1',
                'name': 'STAR Assurances',
                'agencies': [
                  {'id': 'a1', 'name': 'Agence Lac', 'city': 'Tunis'},
                ],
              },
            ];
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MonConstatApp(stores: backend.stores));
      await tester.pumpAndSettle();
      await signIn(tester);
      return backend;
    }

    testWidgets('barre latérale, tableau de bord et demande à traiter', (
      tester,
    ) async {
      await openConsole(tester);
      expect(find.text('Tableau de bord'), findsWidgets);
      // Pas d'onglets du téléphone sur grand écran.
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Mouna Trabelsi'), findsOneWidget);
      expect(find.text('Examiner'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('comptes : tableau et filtre par rôle', (tester) async {
      final backend = await openConsole(tester);
      await tester.tap(find.text('Comptes'));
      await tester.pumpAndSettle();
      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text('Leïla Mansour'), findsOneWidget);
      expect(find.text('3 comptes'), findsOneWidget);

      await tester.tap(find.text('Agents'));
      await tester.pumpAndSettle();
      expect(backend.headers.keys, contains('GET /users'));
      expect(
        backend.requests.where((r) => r == 'GET /users').length,
        greaterThan(1),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'identités : examen depuis le tableau de bord, puis validation',
      (tester) async {
        final backend = await openConsole(tester);
        await tester.tap(find.text('Examiner'));
        await tester.pumpAndSettle();
        expect(find.text('08123456'), findsWidgets);
        await tester.tap(find.text('Valider'));
        await tester.pumpAndSettle();
        expect(backend.requests, contains('POST /users/u4/identity/approve'));
        expect(find.text('Aucune demande en attente.'), findsOneWidget);
      },
    );

    testWidgets('compagnies : agences de la compagnie choisie', (tester) async {
      await openConsole(tester);
      await tester.tap(find.text('Compagnies'));
      await tester.pumpAndSettle();
      expect(find.text('Agence Lac'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
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
      await tester.tap(find.byTooltip('Compagnies'));
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
