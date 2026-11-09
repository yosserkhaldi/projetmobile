# Plan de Réalisation — Module 4 : Constat Numérique

**Projet :** Mon Constat Digital (5SAE1 — Esprit, Projet Intégré)  
**Responsable :** Abdelkader Kaddachi (`kaddachiabdelkader1234` / `abdelkader.kaddachi@esprit.tn`)  
**Branche Git dédiée :** `module-4-abdelkader`  
**Dépendances directes :** Module 3 (Déclaration d'accident, photos, GPS)  
**Alimente :** Module 5 (Sinistres, instruction agent, expertise)  

---

## 1. Objectifs & Périmètre du Module

Le **Module 4 (Constat Numérique)** constitue le cœur juridique et opérationnel de la solution. Il remplace le feuillet papier du constat amiable européen/tunisien par un flux 100 % numérique, utilisable sur le bord de la route avec ou sans connexion Internet, jusqu'au scellement cryptographique inviolable.

### Fonctionnalités clés à livrer :
1. **Mode Invité Conducteur B :**
   * Possibilité pour le conducteur B de participer sans compte préalable.
   * Partage par **QR Code** ou lien pour révision et co-signature sur son propre appareil, ou signature directe sur le téléphone de A (handover).
2. **Circonstances normalisées (17 cas officiels) :**
   * Grille interactive des 17 circonstances réglementaires, cochées indépendamment pour le véhicule A (Bleu) et le véhicule B (Ambre).
   * Calcul automatique du nombre de cases cochées par conducteur (mention légale obligatoire).
3. **Point de choc & Croquis interactif :**
   * Sélection précise du point d'impact initial sur silhouette de véhicule.
   * Canvas interactif de dessin vectoriel pour schématiser la trajectoire des véhicules, signalisation, nom des rues et témoins.
4. **Double Signature Manuscrite & Consentement :**
   * Boîtes de signature tactile séparées pour le Conducteur A et le Conducteur B.
   * Horodatage certifié et verrouillage définitif (0 modification possible après signature bilatérale).
5. **Génération PDF & Scellement Cryptographique SHA-256 :**
   * Génération du PDF officiel du constat conforme aux normes d'assurance.
   * Calcul d'une empreinte numérique **SHA-256** garantissant l'intégrité absolue du document.
   * Sauvegarde pérenne et envoi automatique par e-mail (`nodemailer`) aux deux conducteurs et aux agences d'assurance respectives.

---

## 2. Règles & Contraintes d'Ingénierie

* **Zéro Firebase :** Backend 100 % Express 5 + PostgreSQL via Prisma ORM + Docker Compose.
* **Charte graphique (`DESIGN.md`) :**
  * **Conducteur A :** Toujours bleu primaire (`#1537A8` / `AppColors.primary`).
  * **Conducteur B :** Toujours ambre (`#F5A524` / `AppColors.accent`).
  * **Typographie :** JetBrains Mono pour les données immuables (SHA-256, dates, immatriculations).
  * **Thème :** Utilisation systématique de `context.palette` pour le support parfait du Dark Mode.
* **Offline-First :** Le constat doit pouvoir être entièrement renseigné, croqué, signé et prévisualisé en PDF hors réseau grâce à **Drift (SQLite)**.
* **Isolation multi-compagnies :** Association stricte de la compagnie d'assurance du conducteur A et B pour filtrage automatique dans le Module 5 (`companyScope`).

---

## 3. Architecture Technique

### 3.1. Modèle de Données Backend (`backend/prisma/schema.prisma`)

Ajout du modèle `Constat` relié à `Accident` et `User` :

```prisma
enum ConstatStatus {
  SIGNED
  TRANSMITTED
  ARCHIVED
}

model Constat {
  id                String        @id @default(uuid()) @db.Uuid
  accidentId        String        @unique @db.Uuid
  userId            String        @db.Uuid
  status            ConstatStatus @default(SIGNED)
  
  // Empreinte numérique et fichier scellé
  sha256Hash        String        @unique
  pdfFile           String
  
  // Données Conducteur B (Invité)
  driverBName       String
  driverBEmail      String?
  driverBPhone      String?
  driverBPlate      String
  driverBInsurer    String
  driverBPolicy     String?
  companyBId        String?       @db.Uuid
  
  // Circonstances & Croquis
  circumstancesA    String[]
  circumstancesB    String[]
  impactZones       String[]
  sketchData        Json
  observations      String?
  
  // Signatures
  driverASignedAt   DateTime
  driverBSignedAt   DateTime
  
  createdAt         DateTime      @default(now())
  updatedAt         DateTime      @updatedAt

  accident          Accident      @relation(fields: [accidentId], references: [id], onDelete: Cascade)
  user              User          @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId])
  @@index([sha256Hash])
}
```

### 3.2. Spécification des Endpoints API (`backend/src/modules/constats/constats.routes.js`)

| Méthode | Route | Description | Sécurité / Scope |
|---|---|---|---|
| `POST` | `/api/constats` | Scelle un constat : valide les signatures, calcule le hash SHA-256, génère/stocke le PDF, envoie les e-mails. | `requireAuth`, `requireRole('DRIVER')` |
| `GET` | `/api/constats` | Liste les constats signés du conducteur connecté (ou tous pour un agent de la même compagnie). | `requireAuth` |
| `GET` | `/api/constats/:id` | Récupère les métadonnées détaillées du constat et son empreinte SHA-256. | `requireAuth` |
| `GET` | `/api/constats/:id/pdf` | Télécharge le PDF original scellé. | `requireAuth` |
| `GET` | `/api/constats/verify/:hash` | Point d'accès public de vérification d'authenticité par empreinte SHA-256. | Public |

### 3.3. Architecture Mobile Flutter (`lib/modules/constat/`)

```text
lib/modules/constat/
├── models/
│   ├── constat.dart                # Modèle complet du constat scellé
│   └── constat_signature.dart      # Points vectoriels et métadonnées de signature
├── services/
│   ├── constat_service.dart        # Communication API & synchronisation
│   ├── constat_crypto_service.dart # Calcul du SHA-256 et contrôle d'intégrité
│   └── qr_pairing_service.dart     # Génération de payload QR code pour le Conducteur B
├── state/
│   └── constat_store.dart          # Gestion d'état ChangeNotifier intégré dans AppScope
├── screens/
│   ├── constat_summary_screen.dart # Synthèse avant signature
│   ├── constat_sealed_screen.dart  # Écran officiel avec le hash SHA-256, partage et téléchargement
│   └── guest_qr_screen.dart        # QR Code affiché au conducteur B pour co-signature
└── widgets/
    ├── constat_steps.dart          # (Existant) Étapes 3, 4, 5, 6 intégrées au Wizard
    ├── signature_box.dart          # (Existant) Boîte de signature tactile
    ├── circumstances_table.dart    # Grille comparative des 17 cases A vs B
    └── sha256_badge.dart           # Widget visuel affichant l'empreinte avec copie en 1-clic
```

---

## 4. Feuille de Route d'Implémentation (Sprint Plan)

### Étape 1 : Initialisation & Branche Git
- [ ] Créer et basculer sur la branche `module-4-abdelkader` depuis `main`.
- [ ] Mettre à jour `README.md` pour assigner officiellement Abdelkader Kaddachi au Module 4.

### Étape 2 : Backend & Base de Données
- [ ] Ajouter le modèle `Constat` dans `backend/prisma/schema.prisma`.
- [ ] Générer et appliquer la migration Prisma : `npx prisma migrate dev --name module_4_constats`.
- [ ] Implémenter le service de calcul d'empreinte SHA-256 et de stockage sécurisé du PDF dans `backend/src/lib/uploads.js`.
- [ ] Configurer la notification e-mail avec pièce jointe PDF via `backend/src/lib/emails.js`.
- [ ] Implémenter les routes Express dans `backend/src/modules/constats/constats.routes.js`.
- [ ] Documenter les endpoints dans `backend/openapi.yaml` (contrat Swagger).
- [ ] Écrire la suite de tests automatisés dans `backend/test/constats.test.js`.

### Étape 3 : Logique Métier Flutter (Services & Store)
- [ ] Créer `lib/modules/constat/models/constat.dart`.
- [ ] Créer `lib/modules/constat/services/constat_crypto_service.dart` pour le calcul du SHA-256 à partir des octets du PDF produit par `AccidentPdfService`.
- [ ] Créer `lib/modules/constat/services/constat_service.dart` pour envoyer le constat scellé à l'API.
- [ ] Créer `lib/modules/constat/state/constat_store.dart` et l'enregistrer dans `AppScope` ([`lib/core/state/app_scope.dart`](file:///c:/dev/projetmobile/lib/core/state/app_scope.dart)).

### Étape 4 : Interface Utilisateur & Expérience Conducteur
- [ ] Enrichir l'étape 6 du parcours ([`AccidentWizard`](file:///c:/dev/projetmobile/lib/modules/accident/screens/accident_wizard.dart)) :
  * Double signature obligatoire.
  * Déclenchement automatique de la génération PDF, scellement SHA-256 et transmission API.
- [ ] Créer l'écran de succès post-scellement ([`constat_sealed_screen.dart`]) :
  * Affichage de l'empreinte SHA-256 avec badge de sécurité.
  * Boutons de partage direct (WhatsApp, e-mail, aperçu PDF).
  * Création automatique du dossier de sinistre (Module 5) avec statut *Transmis*.
- [ ] Créer l'écran de partage invité par QR code ([`guest_qr_screen.dart`]).

### Étape 5 : Tests & Validation
- [ ] Tests unitaires et d'intégration Flutter (`test/constat_crypto_test.dart`, `test/constat_store_test.dart`).
- [ ] Tests backend (`npm test`).
- [ ] Validation en mode déconnecté (mode avion) : génération et signature locale, puis synchronisation dès le retour du réseau.
- [ ] Relecture de code, formatage (`dart format`), analyse statique (`flutter analyze`).
- [ ] Pull Request propre vers `main`.

---

## 5. Définition du "Terminé" (Definition of Done)

* [ ] Le code respecte 100 % de la charte de `DESIGN.md` (aucun code couleur en dur, Dark Mode opérationnel).
* [ ] 100 % du flux de constat est exécutable hors-ligne jusqu'au PDF signé.
* [ ] L'empreinte SHA-256 est calculée, vérifiable et affichée clairement à l'utilisateur.
* [ ] Le PDF généré contient toutes les mentions légales, croquis, circonstances A/B et signatures.
* [ ] Tous les tests du backend passent au vert (`npm test`).
* [ ] La documentation Swagger (`/api/docs`) est à jour et validée.

