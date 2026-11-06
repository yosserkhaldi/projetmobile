# Mon Constat Digital

Application Flutter de déclaration d'accidents et de constat amiable numérique, avec une API Node.js. Projet PI, 5SAE1, Esprit.

> **État actuel :** l'application est un prototype. Les écrans utilisent des données fictives en mémoire et ne sont pas encore reliés à l'API.

## Démarrer

### Application Flutter

Prérequis : Flutter stable (Dart 3.10 ou plus). Pour Android, installer aussi Android Studio.

> **Windows :** cloner le projet dans un chemin sans accents ni espaces, par exemple `C:\dev\projetmobile`. Avec un accent dans le chemin, `flutter analyze` plante et les builds Android peuvent échouer.

```bash
flutter pub get
flutter devices          # liste les appareils disponibles
flutter run -d chrome    # le plus rapide pour vérifier un écran
flutter run              # sur le téléphone branché ou l'émulateur
```

Avant chaque push :

```bash
dart format lib test
flutter analyze
flutter test
```

### API et base de données

Prérequis : Docker.

```bash
docker compose up --build    # API sur http://localhost:3000, PostgreSQL sur le port 5432
```

Vérification : `http://localhost:3000/api/health` répond `{"status":"ok"}`.

Pour développer sans conteneur pour l'API :

```bash
docker compose up db
cd backend
cp .env.example .env
npm install
npm run dev
npm test
```

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
| 1 | Utilisateurs, rôles, administration | `modules/users` | `users` | Aucun | À définir |
| 2 | Véhicules et contrats | `modules/vehicles` | `vehicles` | 1 | À définir |
| 3 | Déclaration d'accident | `modules/accident` | `accidents` | 1, 2 | À définir |
| 4 | Constat numérique | `modules/constat` | `constats` | 3 | À définir |
| 5 | Sinistres, suivi, communication | `modules/claims` | `claims` | 4 | À définir |

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
- Prévenir l'équipe avant de modifier un fichier partagé : `lib/app/`, `lib/core/`, `lib/shared/`, `pubspec.yaml`, `backend/src/app.js`, `docker-compose.yml`.
- Le schéma Prisma et le contrat d'API (Swagger) sont décidés ensemble avant de coder.
- Pas de Firebase (demande de l'enseignante).
- Ne jamais committer de secrets : le fichier `.env` reste local.

## Design

Toute l'interface suit [DESIGN.md](DESIGN.md).

- Utiliser `AppColors` et `AppTheme`, sans valeur de couleur écrite en dur dans les écrans.
- Polices : Manrope, Bricolage Grotesque et JetBrains Mono, déjà incluses dans `assets/fonts/`.
- Le conducteur A est toujours bleu et le conducteur B toujours ambre.
