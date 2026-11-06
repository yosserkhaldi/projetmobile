# Mon Constat Digital: design system

Reference for building the Flutter screens so all 5 modules look like one app.

**Source of truth:** `Mon-Constat-Digital-Maquettes.html` (13 screens, kept with the project documents, outside this repo). All values below come from its CSS. Anything not in the maquette is marked **Proposed**.

The older `maquettes_declaration_accidents.html` (Figtree, `#12263F`, `#F2A900`) and the current theme in `lib/src/app.dart` (`#185ADB`, `#FFA51F`, `#F4F6FA`, `#0D1B32`) do not match this system.

## 1. Product in brief

Flutter app (Android 8+, iOS 13+) replacing the paper *constat amiable*, from the roadside declaration to the insurer's decision. One app, with screens adapted to the role: conducteur, agent d'assurance, administrateur. Conducteur B is a guest without an account.

| # | Module | Scope | Depends on |
|---|---|---|---|
| 1 | Utilisateurs, rôles, administration | Auth (JWT, OTP, biometrics), profile and licence, roles, companies, admin dashboard | None |
| 2 | Véhicules et contrats | Vehicle and contract CRUD, expiry alerts (30, 7 and 1 days), OCR scan | 1 |
| 3 | Déclaration d'accident | GPS, context, description, guided photos, video, voice note, offline drafts and sync | 1, 2 |
| 4 | Constat numérique | Guest mode or QR, 17 circumstance boxes, impact point, sketch, double signature, PDF, SHA-256 | 3 |
| 5 | Sinistres, suivi, communication | Agent workspace, expert and decision, timeline, notifications, chat | 4 |

**Stack (spec v3):** Flutter with Material 3, SQLite through drift, Node.js and Express, PostgreSQL with Prisma, multer, Socket.IO, node-cron, pdfkit, Nodemailer, flutter_map with Nominatim, on-device Google ML Kit, Docker Compose. **No Firebase** (teacher rule). One Git branch per module, code review before merge, shared Swagger contract.

**Case lifecycle (9 statuses):**

```text
Brouillon → Déclaré → Constat signé → Transmis → En instruction → Expertise → Clôturé
                                                   ↑        ↓          ↓
                                                   dépôt    pièce      refus
                                                   ↑        requise    ↓
                                                   Pièce demandée      Rejeté
```

The driver moves the case up to *Transmis*; the agent takes over from there.

**Targets that shape the UI:** full constat in under 10 min for a new user; 100% of the declaration and constat flow usable offline; app start under 3 s; session expires after 30 min of inactivity; 0 edits after double signature.

## 2. Design principles

These are read from the maquette.

1. **Built for someone under stress.** Large text, one main action per screen, a visible step and time estimate (`~9 min`, `8 min 12`).
2. **Navy, blue and amber each have a job.** Navy gives weight, blue is the action, amber marks what needs attention now.
3. **A is always blue, B is always amber.** This holds in every constat screen and on the agent's responsibility bar.
4. **Flat with borders.** Depth comes from 1px borders and color blocks, almost never from shadows.
5. **Mono means data.** IDs, dates, plates, coordinates and emergency numbers use JetBrains Mono.
6. **Trust stays visible.** Offline state, the live indicator and SHA-256 locking are always shown in the UI.

## 3. Color palette

### Core

| Token | Hex | Use |
|---|---|---|
| `ink` | `#0B1626` | Main text, dark hero blocks, sidebar, selected chips, secondary dark buttons |
| `primary` | `#1537A8` | Primary buttons, links, active nav, progress, conducteur A |
| `primaryDark` | `#0E2878` | Link hover or pressed |
| `primaryRaised` | `#2448BD` | Tiles sitting on a `primary` block |
| `primaryTint` | `#E7ECFB` | Info chips, focus ring, scan button, A badges |
| `accent` | `#F5A524` | Current step, swipe handle, send button, shutter, conducteur B |
| `accentDark` | `#C98200` | B's outlines and arrows on white (A's are `primary`) |
| `canvas` | `#F2F4F7` | Screen background |
| `surface` | `#FFFFFF` | Cards, inputs, nav bar |
| `surfaceAlt` | `#EEF1F5` | Tags, progress tracks, segmented-control track, inner dividers |
| `textMuted` | `#4A5568` | Secondary text, labels, inactive nav |
| `border` | `#DCE1E8` | Input and button borders, empty progress segments |
| `borderSoft` | `#E4E8EE` | Card borders, bar dividers |

### Dark surfaces

| Token | Hex | Use |
|---|---|---|
| `navy800` | `#16243A` | Panels and icon buttons on `ink` |
| `navy700` | `#1E2D45` | Swipe track, active sidebar item, sketch toolbar buttons |
| `onDarkStrong` | `#C9D3E3` | Secondary text and inactive controls on navy |
| `onDarkBody` | `#B5C0D3` | Body text on `ink` |
| `onDarkFaint` | `#9AA8BD` | Overlines on navy, inactive pills in the camera |
| `onPrimaryMuted` | `#C9D6FA` | Secondary text on `primary` |
| `cameraBg` | `#05090F` | Camera screen background |
| `cameraPanel` | `#16202E` | Camera buttons and pending pills |
| `cameraSwitch` | `#10182A` | Photo / Vidéo / Note vocale control |
| `cameraPreview` | `#1A2433`, `#222D3D` | Viewfinder placeholder (top, bottom) |
| `thumb` | `#2A3547`, `#334056`, `#3C4A62` | Photo placeholders |

### Semantic

| Meaning | Background | Text or icon | Solid |
|---|---|---|---|
| Warning, action required | `#FFF1D6` | `#7A4300`, or `#4A2900` for stronger text | `#E08A00` (dot) |
| Success | `#E4F4F0` | `#0F6B5E` | `#1FA88C` (online dot) |
| Success or live on dark | `#0F3B33` | `#7FE0CC` | `#2BD4B0` |
| Error, PDF file | `#FDECEA` | `#A3261A` | `#C2331D` (stop sign, impact marker) |
| Notification dot | | | `#E8590C` |
| Signature pad | `#FFF8EA` | `#7A4300` | `#D9A440` (dashed border, baseline) |
| Emergency numbers | `surface` | SAMU `#B4290F`, Police `#1537A8`, Protection civile `#A35A00` | |

### Charts and maps

- **Chart series, in order:** `#1537A8`, `#F5A524`, `#0B1626`, `#8FA3D9`.
- **Map placeholder:** land `#E4E9EF`, water `#CFDCEB`, parks `#D3DCD2`, roads `#FFFFFF` and `#F7F8FA`.
- **Sketch canvas:** dot grid `#D5DBE4` on white (spacing 18), road `#E1E6ED`.
- **Heatmap:** radial gradient from `rgba(232,89,12,0.75)` through `rgba(245,165,36,0.35)` to transparent.

### Contrast (calculated, WCAG)

| Pair | Ratio | Result |
|---|---|---|
| `ink` on `canvas` | 16.47 | Pass |
| `textMuted` on `canvas` | 6.83 | Pass |
| White on `primary` | 9.80 | Pass |
| `ink` on `accent` | 8.89 | Pass |
| `primary` on `primaryTint` | 8.30 | Pass |
| `#7A4300` on `#FFF1D6` | 7.15 | Pass |
| `#0F6B5E` on `#E4F4F0` | 5.63 | Pass |
| `#A3261A` on `#FDECEA` | 6.44 | Pass |
| `#9AA8BD` on `navy800` | 6.46 | Pass |
| `#6B7A93` on `navy700` | 3.19 | Decorative only (swipe chevrons) |
| **`accent` on white** | **2.04** | **Fail: never use amber for text or thin icons on a light background** |

On light backgrounds, use amber only as a fill with `ink` on top. For amber-family text, use `#7A4300`.

## 4. Typography

| Family | Role | Weights embedded in the maquette |
|---|---|---|
| **Bricolage Grotesque** | Titles, big numbers, the A and B letters | 600, 800 (screens use 800) |
| **Manrope** | Everything else | 500, 600, 700, 800 |
| **JetBrains Mono** | IDs, dates, plates, coordinates, emergency numbers | 500, 700 |

| Style | Font | Size / line height | Weight | Tracking | Example |
|---|---|---|---|---|---|
| `displayXL` | Bricolage | 38 / 1.0 | 800 | -1.2 | "Le constat, sans papier." |
| `displayL` | Bricolage | 34 / 1.02 | 800 | -1 | "Passez le téléphone…" |
| `kpi` | Bricolage | 36 | 800 | -1 | "1 284" |
| `displayM` | Bricolage | 30 / 1.05 | 800 | -0.8 | "Un accident ?", current status |
| `titleTablet` | Bricolage | 28 | 800 | -0.6 | "Tableau de bord" |
| `titleCard` | Bricolage | 24 | 800 | -0.5 | "Peugeot 208" |
| `titleSheet` | Bricolage | 22 | 800 | -0.4 | "Connexion" |
| `titleScreen` | Bricolage | 20 | 800 | -0.3 | "Où et quand ?" |
| `button` | Manrope | 16 | 800 | | "Se connecter" |
| `input` | Manrope | 15 | 600 | | Field values |
| `body` | Manrope | 14 / 1.45 | 500–700 | | Chat, descriptions |
| `label` | Manrope | 13 | 700 | | Field labels |
| `overline` | Manrope | 13 (11–12 in tight spots) | 800 | +0.6, uppercase | "MON VÉHICULE" |
| `chip` | Manrope | 12 | 700–800 | | Chips, helper text |
| `nav` | Manrope | 11 | 800 active, 700 inactive | | Bottom nav |
| `monoId` | JetBrains | 12 | 500 | | "SIN-2026-0418" |
| `monoValue` | JetBrains | 15 | 700 | | Date and time inputs |
| `monoLarge` | JetBrains | 18 | 700 | | "190" |

**Fonts must be bundled in `assets/fonts/`.** `google_fonts` downloads at runtime by default, which conflicts with the offline requirement.

**Arabic gap:** the spec requires FR, AR and EN, but the embedded Manrope files have no Arabic subset and RTL is not mocked. **Proposed:** add Noto Sans Arabic as a fallback font and test every screen in RTL.

## 5. Spacing, radius, sizes

**Spacing:** 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 28. Screen margins are 20 (16 on dense screens), card padding is 14–16, gaps between cards are 12–16, gaps within a group are 6–8.

| Radius | Use |
|---|---|
| 3–4 | Progress segments and tracks |
| 8 | Plates, small tags |
| 10 | Small tiles, segmented buttons |
| 12 | Icon buttons, avatars (36–40) |
| 14 | Inputs, avatars (44), inner panels |
| 16 | Buttons (52–56), list tiles |
| 18 | Chat bubbles (6 on the sender's corner), sketch toolbar |
| 20–22 | Cards |
| 24 | Vehicle card, sketch canvas |
| 28 | Hero card, bottom corners of the status header, camera preview |
| 32 | Top corners of the login sheet |
| 99 | Pills, chips, swipe control |

| Element | Height |
|---|---|
| Icon button | 44 × 44 |
| Input | 52 (48 in dense forms, 46 in chat) |
| Primary button | 56 |
| Secondary or in-card button | 48–52 |
| Hand-off button | 60 |
| Swipe control | 64 (handle 52) |
| Choice chip | 40 |
| Segmented option | 36–40 |
| Bottom nav | 78 |

**Shadows (the only ones used):**

- Focused input: spread ring `0 0 0 4px #E7ECFB` with a 1.5px `primary` border.
- Selected segment: `0 1px 3px rgba(11,22,38,0.12)`.
- Vehicles on the sketch: `0 6px 14px` in `rgba(21,55,168,0.3)` for A and `rgba(201,130,0,0.3)` for B.
- Live dot: ring `0 0 0 4px #0F3B33`.

**Layouts:** phone 390 × 844. Admin dashboard is tablet 1180 × 820 with a 220 sidebar.

**Icons:** outlined on a 24 grid with round caps and joins. Stroke is 2, 2.2 when active, up to 2.6 for emphasis. Size is 20–22, 14 inside pills.

## 6. Components

**Buttons**

| Variant | Style |
|---|---|
| Primary | `primary` fill, white 800 text, radius 16, height 56 |
| Secondary | White fill, 1.5px `ink` border, radius 16 |
| Quiet | White fill, 1px `border`, used for "Observations", "Effacer" |
| Dark | `ink` fill, white text, used on warning or amber blocks |
| Scan / dashed | `primaryTint` fill, 1.5px dashed `primary`, `primary` text, height 52 |
| Icon | 44 × 44, radius 12, white with 1px `border`; `navy800` with no border on dark |
| Swipe to declare | 64 pill on `navy700`, amber circular handle 52 with arrow, label "Glisser pour déclarer" |

**Inputs:** label above (13/700 `textMuted`, gap 4–6), white fill, 1.5px `border`, radius 14, padding 0 16. Focus uses the `primary` border and the tint ring.

**Chips**

- Choice (météo, chaussée): height 40, radius 99, selected `ink` with white text, unselected white with `border`.
- Status: padding 6 × 10, radius 99, 12/800, tinted background (section 7).
- Tag: `surfaceAlt`, 12/700.
- Warning with dot: `#FFF1D6` and `#7A4300`, 7px `#E08A00` dot.

**Segmented control:** track `surfaceAlt` (or white with a border), radius 12–14, padding 4. Selected is white with the shadow, or `ink` for periods on the dashboard.

**Cards:** white, 1px `borderSoft`, radius 20–22, padding 14–16, overline header. Inner rows are split by 1px `surfaceAlt`.

**Hero blocks:** `ink` with radius 28 and a decorative ring (28px `navy800` border, partly off-canvas), or `primary` with radius 24 for the vehicle.

**Progress**

- Wizard: 5 segments, height 5, gap 6, `primary` done, `border` remaining.
- Case: 9 segments, height 6, gap 4, `primary` done, `accent` current, `border` remaining.

**Timeline dots (22):** done is `primary` with a white check, current is `accent` with a 4px `#FFE3A8` border, upcoming is white with a 2px `#C3CAD5` border. Connector is 2px, `primary` when done, `border` otherwise.

**License plate:** mono 700, 16 (14 on the blue card), with "تونس" between the numbers in a sans font. Radius 8. `ink` background with white text, or white with a 2px `ink` border on a colored card.

**Bottom nav (driver):** Accueil, Véhicules, Dossiers, Messages, Profil. White, 1px top border. Active is `primary` 800, inactive `textMuted` 700.

**Chat bubbles:** max width 82%. Incoming is white with a border and radius 18/18/18/6, outgoing is `primary` with radius 18/18/6/18. System events are centered, 12/700, with a 6px dot. The send button is amber and the attach button is outlined, both 46.

**Other shared pieces:**

- Offline banner: full width, height 34, `ink`, 12/700.
- Live indicator: `#2BD4B0` dot with ring, `#7FE0CC` text.
- Signature pad: `#FFF8EA`, 1.5px dashed `#D9A440`, baseline, inside a card with a 2px `accent` border while it is that signer's turn.
- Security card: `ink` with a padlock on `navy800`.
- Camera frame: 4px amber corners, radius 10, 34 long, with an amber target circle.

## 7. Status mapping

Only the rows marked Maquette are defined there. **Proposed** rows extend the same palette and need team agreement.

| Status | Background | Text | Source |
|---|---|---|---|
| Brouillon | `#EEF1F5` | `#4A5568` | Proposed |
| Déclaré | `#E7ECFB` | `#1537A8` | Proposed |
| Constat signé | `#E4F4F0` | `#0F6B5E` | Proposed |
| Transmis | `#E7ECFB` | `#1537A8` | Proposed |
| En instruction | `#E7ECFB` | `#1537A8` | Maquette |
| Pièce demandée | `#FFF1D6` | `#7A4300` | Maquette (banner), `#F5A524` as title on navy |
| Expertise | `#E7ECFB` | `#0E2878` | Proposed |
| Clôturé | `#E4F4F0` | `#0F6B5E` | Proposed |
| Rejeté | `#FDECEA` | `#A3261A` | Proposed |

## 8. Screen coverage

| Module | In the maquette | Still needs a design (follow this system) |
|---|---|---|
| 1 | Connexion, tablet admin dashboard | Inscription, OTP, password reset, profile and licence, account and company management, phone layout for admin |
| 2 | Véhicule, contrat et échéances | Vehicle list, add/edit forms, OCR review, alerts list |
| 3 | Contexte (step 1), photos guidées (step 3) | Accident description (step 2, assumed), witnesses, emergency prompt when injured, video and voice states, drafts and history |
| 4 | Passation, circonstances, croquis, signature | B's identity/vehicle/insurance form, QR join, observations, PDF confirmation |
| 5 | Suivi, messagerie, instruction agent | Agent case list, expert and decision, notification center, document upload |
| All | Accueil conducteur | Agent home, loading, empty and error states |

## 9. Open questions

1. **Case progress vs. branches.** Home shows 9 linear segments and the timeline shows 8 steps, but *Clôturé* and *Rejeté* are alternatives and *Pièce demandée* can repeat, so "Étape 5 / 9" isn't a true sequence.
2. **Same case, different status.** Home shows *En instruction* while Suivi and Messagerie show *Pièce demandée* for `SIN-2026-0418`.
3. **Small touch targets.** Language toggle 32, segmented options 36, chips 40, against 44 elsewhere. **Proposed:** use at least 44 in the roadside flow.
4. **Placeholder content.** The franchise shows a literal `[MONTANT] DT`; the dashboard uses "Compagnie A–D".
5. **Dark mode.** No dark theme is defined. The dark screens are fixed per-screen designs. **Proposed:** light only for v1.

## 10. Flutter tokens

```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF0B1626);
  static const primary = Color(0xFF1537A8);
  static const primaryDark = Color(0xFF0E2878);
  static const primaryRaised = Color(0xFF2448BD);
  static const primaryTint = Color(0xFFE7ECFB);
  static const accent = Color(0xFFF5A524);
  static const accentDark = Color(0xFFC98200);
  static const canvas = Color(0xFFF2F4F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFEEF1F5);
  static const textMuted = Color(0xFF4A5568);
  static const border = Color(0xFFDCE1E8);
  static const borderSoft = Color(0xFFE4E8EE);

  static const navy800 = Color(0xFF16243A);
  static const navy700 = Color(0xFF1E2D45);
  static const onDarkStrong = Color(0xFFC9D3E3);
  static const onDarkBody = Color(0xFFB5C0D3);
  static const onDarkFaint = Color(0xFF9AA8BD);
  static const onPrimaryMuted = Color(0xFFC9D6FA);

  static const warningBg = Color(0xFFFFF1D6);
  static const warningText = Color(0xFF7A4300);
  static const successBg = Color(0xFFE4F4F0);
  static const successText = Color(0xFF0F6B5E);
  static const errorBg = Color(0xFFFDECEA);
  static const errorText = Color(0xFFA3261A);
  static const errorSolid = Color(0xFFC2331D);

  static const driverA = primary;
  static const driverB = accent;
}

abstract final class AppRadius {
  static const sm = 8.0, md = 12.0, input = 14.0, button = 16.0;
  static const card = 20.0, hero = 28.0, pill = 99.0;
}

final appColorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.primary,
).copyWith(
  primary: AppColors.primary,
  onPrimary: Colors.white,
  secondary: AppColors.accent,
  onSecondary: AppColors.ink,
  surface: AppColors.surface,
  onSurface: AppColors.ink,
  onSurfaceVariant: AppColors.textMuted,
  outline: AppColors.border,
  outlineVariant: AppColors.borderSoft,
  error: AppColors.errorSolid,
);
```

Set `scaffoldBackgroundColor` to `AppColors.canvas`, because the scheme's `surface` is the white card color.
