# Module 5 plan: sinistres, suivi et communication

Owner: Salma. Branch: `module-5`. Reference: cahier des charges **v3** (3 Oct 2026), the version the repo matches (5 modules, Node.js, Prisma, drift). If the professor approved another version, only section "Scope" below needs checking.

## Scope (from v3)

| Ref | Requirement | Phase |
|---|---|---|
| 5.1 | Transmit the signed constat to the company | 1 (local), 3 (server). Per-company routing needs modules 1 and 2 |
| 5.1 | List claims, filter by status, date, severity | 1 |
| 5.1 | Open the full case: constat, photos, video, documents | 1 for what exists. Real media needs modules 3 and 4 |
| 5.1 | Request a document (devis, facture, PV de police) | 1 |
| 5.1 | Propose responsibility (0, 50, 100 %) from the checked boxes | 1 |
| 5.2 | Appoint an expert, schedule an appointment | 1 |
| 5.2 | Attach the expert report | 1 |
| 5.2 | Set the amount, close or reject with a reason | 1 |
| 5.3 | Case timeline, step by step | 1 |
| 5.3 | Upload requested documents | 1 |
| 5.3 | Notification on every status change | 1 |
| 5.3 | Notification center, read and unread | 1 |
| 5.4 | Messages per case, attachments, read receipts | 1 |
| Backend | Status workflow, case assignment, Socket.IO, notifications | 2 |

## Rules for merging smoothly

- Work stays in `lib/modules/claims/`, `backend/src/modules/claims/`, and test files of its own.
- Public store methods used by other modules keep working: `Claim(...)`, `claim.timeline`, `addClaim`, `claims`, `notifications`.
- Shared files change only where unavoidable, and each change is listed under "Shared files".
- No foreign keys to other modules' tables. User, company and constat are stored as plain ids until those modules exist.
- After each phase: merge `main`, run format, analyze and tests, push to `module-5`.

## Phase 1: Flutter, complete and offline

1. **Workflow.** One source of truth for the 9 statuses and allowed moves: Brouillon, Déclaré, Constat signé, Transmis, En instruction, Pièce demandée, Expertise, Clôturé, Rejeté. Replace the free dropdown with the actions allowed from the current status. Old values (`Accepté`, `Expertise planifiée`, `Décision enregistrée`) are migrated.
2. **Database v2.** Add document requests, expert, decision, read state, dates, attachments, and stable ids. Migration from v1, with a test.
3. **Agent.** Real dashboard counts, working filters, case screen with request, expert, responsibility proposal and decision.
4. **Driver.** Timeline in the DESIGN.md style, pending requests with upload, status chip colors.
5. **Notifications.** Read and unread, unread badge, real dates, link to the case.
6. **Chat.** One conversation per case, attachments, read receipts.

## Phase 2: backend

1. Prisma, with a multi-file schema so each module owns its own file: `backend/prisma/schema/claims.prisma`.
2. Express routes under `/api/claims`, workflow validated on the server as well.
3. File upload with multer. Socket.IO for chat and live status.
4. Temporary identity middleware: accepts a JWT signed with `JWT_SECRET`, and dev headers outside production, until module 1 delivers login.
5. Swagger for the module's endpoints, and tests with `node --test`.

## Phase 3: connect the app

1. Outbox table in SQLite: every change is saved locally first, then sent. A client-generated id makes retries safe (0 loss, 0 duplicate).
2. Pull server changes, live updates through Socket.IO.
3. The app only talks to the API when built with `--dart-define=API_URL=...`. Without it, it stays local, so teammates need no backend to run the app.

## Depends on other modules

| Needed | From | Until then |
|---|---|---|
| Real login and user ids | Module 1 | Dev identity headers |
| Insurance company of each driver | Modules 1, 2 | Company left empty, all agents see all cases |
| Real photos, video | Module 3 | Evidence count from the timeline |
| Boxes per driver, PDF, SHA-256 | Module 4 | One set of boxes, as the wizard has today |

## Out of scope

Payments (cahier), Firebase push (teacher rule; notifications are in-app and live through Socket.IO), e-mail sending.

## Shared files

Listed here so the team can be warned: `pubspec.yaml`, `backend/package.json`, `backend/src/server.js`, `backend/src/app.js`, `docker-compose.yml`, and the claim creation lines in `accident_wizard.dart`.

## Definition of done

Each scope row works and has a test; format, analyze and tests pass; two-role demo works against the real API; Android or iOS build checked on a real device or emulator by Salma.
