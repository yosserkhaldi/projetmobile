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

      await scrollProfileTo(tester, find.text('Se déconnecter'));
      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();
      expect(find.text('Connexion'), findsOneWidget);
      expect(find.byType(ProfileScreen), findsNothing);
      expect(backend.requests, contains('POST /auth/logout'));
      // Seule la langue choisie reste sur le téléphone.
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
      // Téléphone vérifié : 1 élément sur 6.
      expect(find.text('Profil complété à 17 %'), findsOneWidget);
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
