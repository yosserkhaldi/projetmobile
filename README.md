# Mon Constat Digital

Application Flutter de déclaration d'accidents et de constat amiable numérique, avec une API Node.js. Projet PI, 5SAE1, Esprit.

> **État actuel :** le module 1 (comptes, connexion, rôles, compagnies) utilise la vraie API. Les autres écrans utilisent encore des données fictives en mémoire.

## Démarrer

### Application Flutter

Prérequis : Flutter stable (Dart 3.10 ou plus). Pour Android, installer aussi Android Studio.

> **Windows :** cloner le projet dans un chemin sans accents ni espaces, par exemple `C:\dev\projetmobile`. Avec un accent dans le chemin, `flutter analyze` plante et les builds Android peuvent échouer. Activer aussi le mode développeur (`start ms-settings:developers`), nécessaire aux plugins Flutter.

```bash
flutter pub get
flutter devices          # liste les appareils disponibles
flutter run -d chrome    # le plus rapide pour vérifier un écran
flutter run              # sur le téléphone branché ou l'émulateur
```

L'application a besoin de l'API pour se connecter (voir ci-dessous). Sur un téléphone branché ou un émulateur, rediriger d'abord le port de l'API :

```bash
adb reverse tcp:3000 tcp:3000
```

Pour viser un autre serveur : `flutter run --dart-define=API_URL=http://192.168.1.10:3000/api`.

> **Erreur Java/Gradle au premier build Android :** Android Studio récent fournit Java 25, trop récent pour la version de Gradle du projet. Installer un JDK 17 puis : `flutter config --jdk-dir="C:\Program Files\Java\jdk-17"`.
>
> **Huawei / Xiaomi :** au premier `flutter run`, accepter l'invite « Installer via USB » sur le téléphone.

Avant chaque push :

```bash
dart format lib test
flutter analyze
flutter test
```

### Console d'administration (web)

La même application sert de console aux administrateurs sur ordinateur : à partir de 1000 px de large, un compte administrateur voit une barre latérale (tableau de bord, comptes, vérification des CIN, compagnies) au lieu des onglets du téléphone.

```bash
flutter run -d chrome                     # en développement
flutter build web                         # version à déployer (dossier build/web)
```

Les bases SQLite (drift) marchent aussi dans le navigateur grâce à `web/sqlite3.wasm` et `web/drift_worker.js` (release drift 2.35.3) : à mettre à jour avec le paquet drift. Chaque base passe `web: driftWebOptions` (`lib/core/data/drift_web.dart`).

### API et base de données

Prérequis : Docker.

```bash
docker compose up --build    # API sur http://localhost:3000, PostgreSQL sur le port 5434
```

Vérification : `http://localhost:3000/api/health` répond `{"status":"ok"}`.

Comptes de démonstration créés au démarrage (mot de passe `Password123!`) :

| Rôle | E-mail |
|---|---|
| Conducteur | `sami@example.com` |
| Agent | `leila@assurance.tn` |
| Administrateur | `admin@monconstat.tn` |

Sans fournisseur configuré, les codes OTP et de réinitialisation s'affichent dans les logs : `docker compose logs api`.

Pour développer sans conteneur pour l'API :

```bash
docker compose up db
cd backend
cp .env.example .env
npm install
npm run db:deploy            # applique les migrations
npm run db:seed              # comptes de démonstration
npm run dev
npm test                     # nécessite la base : docker compose up db
```

Pour modifier le schéma : éditer `backend/prisma/schema.prisma`, puis `npm run db:migrate`.

Contrat d'API (Swagger) : `http://localhost:3000/api/docs`, à partir de `backend/openapi.yaml`. Chaque module y documente ses endpoints ; un test vérifie que chaque route documentée existe.

## Organisation du code

```text
lib/
  app/                 Démarrage, navigation par rôle, accueil, assistance
  core/
    theme/             Couleurs et thème (DESIGN.md)
    state/             AppScope : accès aux stores
  shared/              Éléments communs à plusieurs modules
  modules/
    users/             Module 1
    vehicles/          Module 2
    accident/          Module 3
    constat/           Module 4
    claims/            Module 5
backend/src/modules/   Mêmes modules côté API
```

Chaque module Flutter suit la même structure : `models/`, `state/`, `screens/`, `widgets/`. Chaque module backend ajoute ses endpoints dans son fichier `<module>.routes.js`.

| Module | Périmètre | Flutter | Backend | Dépend de | Responsable |
|---|---|---|---|---|---|
| 1 | Utilisateurs, rôles, administration | `modules/users` | `users` | Aucun | Iheb Jlassi |
| 2 | Véhicules et contrats | `modules/vehicles` | `vehicles` | 1 | Emna Homrani |
| 3 | Déclaration d'accident | `modules/accident` | `accidents` | 1, 2 | Yosser Khaldi |
| 4 | Constat numérique | `modules/constat` | `constats` | 3 | Abdelkader Kaddachi |
| 5 | Sinistres, suivi, communication | `modules/claims` | `claims` | 4 | Salma Louhichi |

### Utiliser l'authentification dans un module

Côté API, protéger les routes avec le middleware du module 1 :

```js
import { requireAuth, requireRole } from '../../middleware/auth.js';

router.use(requireAuth);                              // req.user contient le compte connecté
router.get('/', requireRole('AGENT', 'ADMIN'), ...);  // limite à certains rôles
```

Côté Flutter, passer par le client partagé. Il ajoute le jeton, le renouvelle si besoin et lève une `ApiException` dont le message peut être affiché :

```dart
final response = await AppScope.of(context).api.get('/vehicles');
final user = AppScope.of(context).users.currentUser;
// Compagnies et agences (module 1), disponibles hors ligne grâce à SQLite :
await AppScope.of(context).companies.load();
final companies = AppScope.of(context).companies.companies;
final star = AppScope.of(context).companies.byId(companyId);
```

### Compagnie d'assurance : du contrat jusqu'à l'agent

Pour qu'un sinistre arrive aux agents de la bonne compagnie, chaque maillon garde l'**identifiant** de la compagnie (pas son nom en texte libre) :

```text
Contrat (module 2) --companyId--> Accident (module 3, véhicule déclaré) --> Sinistre (module 5, companyId) --> agents de cette compagnie
```

- **Module 2 :** choisir l'assureur avec `CompanyPicker` (liste du module 1, disponible hors ligne) et enregistrer `company.id` (et `agency.id`) dans le contrat. Côté API, vérifier avec `assertCompanyExists(companyId)`.
- **Module 3 :** enregistrer le véhicule concerné dans la déclaration.
- **Module 5 :** reprendre le `companyId` du contrat sur le sinistre, et filtrer les listes avec `companyScope(req)` : l'agent ne voit que sa compagnie, l'administrateur tout.

```dart
CompanyPicker(
  companyId: contract.companyId,
  onChanged: (company, agency) => setState(() => contract.companyId = company?.id),
)
```

```js
import { assertCompanyExists, companyScope, requireAuth } from '../../middleware/auth.js';

await assertCompanyExists(req.body.companyId);                       // module 2
prisma.claim.findMany({ where: { ...companyScope(req), status } });   // module 5
```

## Travailler en équipe

1. Partir de `main` à jour :
   ```bash
   git switch main
   git pull
   git switch -c module-<numéro>-<prénom>
   ```
2. Travailler surtout dans le dossier de son module.
3. Récupérer régulièrement `main` dans sa branche : `git merge main`.
4. Ouvrir une pull request vers `main`. Un autre membre la relit avant la fusion.

**Règles :**

- Ne pas pousser directement sur `main`.
- Prévenir l'équipe avant de modifier un fichier partagé : `lib/app/`, `lib/core/`, `lib/shared/`, `pubspec.yaml`, `backend/src/app.js`, `backend/prisma/schema.prisma`, `docker-compose.yml`.
- Le schéma Prisma et le contrat d'API (Swagger) sont décidés ensemble avant de coder.
- Pas de Firebase (demande de l'enseignante).
- Ne jamais committer de secrets : le fichier `.env` reste local.

## Design

Toute l'interface suit [DESIGN.md](DESIGN.md).

- Couleurs : `context.palette.surface`, `context.palette.text`… (`lib/core/theme/app_palette.dart`), jamais une couleur fixe ni `Colors.white` / `Colors.grey`, sinon l'écran casse en mode sombre. `AppColors` reste pour ce qui ne change pas (ambre, conducteurs A et B).
- Textes : dans `lib/l10n/app_fr.arb` (puis `app_en.arb`, `app_ar.arb`), utilisés avec `context.t.maCle`. L'arabe s'affiche de droite à gauche : préférer `EdgeInsetsDirectional` et `PositionedDirectional`.
- Polices : Manrope, Bricolage Grotesque et JetBrains Mono, déjà incluses dans `assets/fonts/`.
- Le conducteur A est toujours bleu et le conducteur B toujours ambre.
