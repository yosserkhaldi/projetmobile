# Module 5 plan: sinistres, suivi et communication

Owner: Salma. Branch: `module-5`. Reference: cahier des charges **v3** (3 Oct 2026), the version the repo matches (5 modules, Node.js, Prisma, drift). If the professor approved another version, only section "Scope" below needs checking.

## Status

Phases 1 to 4 are done. Phase 4 was tested with simulated providers, and on 2026-11-08 against the real Claude through the Claude Code CLI (assistant, summary, replies, Arabic answer, document reading). The paid APIs (Anthropic key, OpenAI, Perplexity) have only run against simulated servers. Still needed from Salma: try the app on an Android or iOS device or emulator.

## Run the demo

```bash
docker compose up --build        # API on port 3000, migrations and demo accounts included
flutter run -d chrome --web-port=5001                                   # default API: localhost:3000/api
flutter run --dart-define=API_URL=http://10.0.2.2:3000/api              # Android emulator
```

Real login from module 1, password `Password123!`: `sami@example.com` (driver), `leila@assurance.tn` (agent). Changes appear live between two windows. Swagger for this module: `http://localhost:3000/api/claims/docs`.

## Test

```bash
flutter test
docker compose exec db psql -U monconstat -c 'CREATE DATABASE monconstat_test'   # once
cd backend && npm test                                                           # uses port 5434
cd .. && LIVE_API_URL=http://localhost:3000 flutter test test/claims_live_test.dart   # two phones, real API
```

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

## Retrain the model

```bash
cd backend && npm run ml:train    # adds real closed cases when DATABASE_URL is set
```

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

1. Prisma. Since module 1 merged, all models live in the shared `backend/prisma/schema.prisma`.
2. Express routes under `/api/claims`, workflow validated on the server as well.
3. File upload with multer. Socket.IO for chat and live status.
4. Identity comes from module 1 (`requireAuth`, JWT). The temporary dev headers are gone.
5. Swagger for the module's endpoints, and tests with `node --test`.

## Phase 3: connect the app

1. Outbox table in SQLite: every change is saved locally first, then sent. A client-generated id makes retries safe (0 loss, 0 duplicate).
2. Pull server changes, live updates through Socket.IO.
3. Sync starts with the app and waits for login. It goes through the shared `ApiClient`, so tokens renew by themselves. A queued change is only sent by the account that made it.

## Phase 4: intelligence

Goal: help the agent decide faster and keep the driver informed. **The AI never decides and never writes**: every action stays a human click, and the assistants only have read-only tools.

Everything works without a language model. The model is a layer on top of the rules and the ML, and each answer says where it came from (`source`: `ai` or `rules`, and `by`: which model answered).

| Layer | What it does | Needs a key |
|---|---|---|
| Rules | Responsibility, missing documents, deadlines (SLA), vigilance signals, next action | No |
| ML | Estimated indemnity, estimated duration, rejection risk, similar past cases | No |
| Orchestrator | Runs rules then ML, computes a priority, filters the result by role | No |
| Language model | Case summary, reply suggestions, reading documents, assistant | CLI login in dev, or a key |

1. **Rules** (`ai/rules.js`): declarative, thresholds in one place, each result has a human-readable reason.
2. **ML** (`ai/ml.js`, `ai/train.js`): ridge regression and logistic regression written in plain JS, so reasons can be shown per feature, plus nearest neighbours for similar cases. There is no real history yet, so training starts from **synthetic data**; `npm run ml:train` adds real closed cases from the database. Metrics on synthetic data only show the model learned the generator, not that it is accurate on real claims.
3. **Orchestrator** (`ai/insights.js`): pure functions, computed on read and sent in `/sync`, then cached in SQLite for offline reading.
4. **Role filter**: the driver receives guidance and an estimated delay. Risk, signals and estimates stay with the agent, and the driver's assistant never receives them.
5. **Language model** (`ai/llm.js`, `ai/providers/`, `ai/assistant.js`): one entry point, four providers, chosen by `AI_PROVIDER` (default `auto`):
   - `claude-cli`: the Claude Code CLI on the developer's machine, with their Claude login and no key. Only in development; it runs with no tools, no settings, no session saved and a minimal environment (no database URL or secrets).
   - `anthropic`: Claude with `ANTHROPIC_API_KEY`. The only provider that calls the read-only tools itself.
   - `openai`: any OpenAI-format API (OpenAI, Mistral, Groq, OpenRouter, Ollama…), with `OPENAI_BASE_URL`, `OPENAI_API_KEY`, `OPENAI_MODEL`.
   - `perplexity`: Perplexity gateway, with web search turned off so case facts are not sent as search queries.
   In `auto`: CLI first in development, then the first key set; never the CLI in production. Providers without tool calls get the same role-filtered data up front, in the user message, never in the instructions. Answers follow the profile language (FR, AR, EN); rule answers stay in French. Keys stay on the server, in `backend/.env`. Rate limited, every call audited in `AiCall` (`source` is the provider), no names or user ids sent, dossier content treated as data. Any failure falls back to the rules.
6. **Learning loop**: the proposal is saved at decision time, so analytics can compare it with what the agent decided.
7. **App**: analysis card, priority queue, driver guidance, assistant screen, suggested replies, analytics screen, Messages tab badge, real file upload from Chrome.

To use the Claude CLI in development: run the API on the machine (`cd backend && npm run dev`), since the Docker image has no CLI. `GET /api/claims/ai/status` shows which provider answers. To use a key instead, put it in `backend/.env` (see `.env.example`) and set `AI_PROVIDER` if the CLI is also installed.

## Depends on other modules

| Needed | From | Until then |
|---|---|---|
| Insurance company of each driver | Module 2 | Company left empty, all agents see all cases |
| Real photos, video | Module 3 | Evidence count from the timeline |
| Boxes per driver, PDF, SHA-256 | Module 4 | One set of boxes, as the wizard has today |

## Out of scope

Payments (cahier), Firebase push (teacher rule; notifications are in-app and live through Socket.IO), e-mail sending.

## Shared files

Listed here so the team can be warned: `pubspec.yaml`, `backend/package.json`, `backend/Dockerfile`, `backend/src/server.js`, `docker-compose.yml`, `lib/core/state/app_scope.dart`, the notification badge in `lib/app/driver_home.dart`, the claim creation lines in `accident_wizard.dart`, and the debug `AndroidManifest.xml` (allows http to the local API). Phase 4 adds: the Messages badge in `lib/app/main_shell.dart`, `startClaimsSync` in `lib/app/app.dart`, `send`, `timeout`, `baseUrl` and `accessToken` in `lib/core/network/api_client.dart`, `env_file` in `docker-compose.yml`, the module 5 models in `backend/prisma/schema.prisma`, the demo cases in `backend/prisma/seed.js`, and `@anthropic-ai/sdk`, `socket.io` and `ml:train` in `backend/package.json`. The AI providers add: the AI section of `backend/.env.example`, and a `by` column on the module 5 `ClaimAiNote` model (migration `20261108120000_claims_ai_providers`).

## Definition of done

Each scope row works and has a test; format, analyze and tests pass; two-role demo works against the real API; Android or iOS build checked on a real device or emulator by Salma.
