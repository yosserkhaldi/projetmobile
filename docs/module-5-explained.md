# Module 5 explained: claims, tracking and messaging

Owner: Salma Louhichi. Branch: `module-5`, merged into `main` on 10 November 2026.

This document explains what module 5 does and how it was built. Each section starts with a plain-language part ("In simple words") for anyone, then a technical part with the files where things live. Paths are relative to the repository root.

Related documents:
- [module-5-plan.md](module-5-plan.md): scope, phases, and how to run the demo.
- [module-5-test-guide.md](module-5-test-guide.md): step-by-step test scenarios.

---

## Contents

1. [What module 5 is](#1-what-module-5-is)
2. [The people and what each one sees](#2-the-people-and-what-each-one-sees)
3. [The life of a claim](#3-the-life-of-a-claim)
4. [How the pieces fit together](#4-how-the-pieces-fit-together)
5. [The server (backend)](#5-the-server-backend)
6. [The phone app (Flutter)](#6-the-phone-app-flutter)
7. [Working without internet](#7-working-without-internet)
8. [Live updates](#8-live-updates)
9. [Insurance companies: who sees what](#9-insurance-companies-who-sees-what)
10. [Responsibility proposal (who is at fault)](#10-responsibility-proposal-who-is-at-fault)
11. [Expert appointment](#11-expert-appointment)
12. [Messages and notifications](#12-messages-and-notifications)
13. [The intelligent part: rules, model and Claude](#13-the-intelligent-part-rules-model-and-claude)
14. [Statistics screen](#14-statistics-screen)
15. [Design: how the screens look and why](#15-design-how-the-screens-look-and-why)
16. [Three languages](#16-three-languages)
17. [Links with the other modules](#17-links-with-the-other-modules)
18. [Security and privacy](#18-security-and-privacy)
19. [Tests](#19-tests)
20. [How we worked](#20-how-we-worked)
21. [Known limits](#21-known-limits)
22. [File map](#22-file-map)
23. [Glossary](#23-glossary)

---

## 1. What module 5 is

**In simple words.** After a car accident, the two drivers fill in an accident report (the "constat") in the app. Module 5 takes over from there. It sends the report to the insurance company and lets an insurance agent study it. The driver can follow every step, like tracking a parcel. The driver and the agent can talk to each other, an expert can be sent to look at the car, and in the end the agent decides who pays and how much. Along the way, the app helps the agent with suggestions and helps the driver understand what to do next.

**Technically.** Module 5 is the "Sinistres, suivi et communication" part of *Mon Constat Digital*. In our cahier des charges (v3) it covers:
- 5.1: receiving the claim, listing and filtering claims, opening a full case, requesting documents, and proposing responsibility;
- 5.2: expertise (appoint an expert, set an appointment, attach the report);
- 5.3: tracking, notifications and messaging;
- AI help for both the driver and the agent.

It has two halves:
- a **Node.js server module** in `backend/src/modules/claims/`;
- a **Flutter module** in `lib/modules/claims/`.

---

## 2. The people and what each one sees

| Who | In simple words | In the app |
|---|---|---|
| **Driver** (demo: Sami, `sami@example.com`) | The person who had the accident. Follows their claim and answers requests. | Their claims list, the claim screen with a "where am I" tracking card, the expert appointment, documents, messages and the assistant. |
| **Agent** (demo: Leïla, `leila@assurance.tn`) | Works at the insurance company. Studies the claim and decides. | A dashboard sorted by urgency, every claim of **their own company**, the decision help panel, tools to request documents, appoint an expert, close or reject, plus statistics. |
| **Expert** | The person who inspects the car (or the injured person). | Doesn't use the app. The agent enters their name, phone and place, and later attaches their report. |
| **Admin** | Manages the platform (module 1). | Sees everything. |

The demo password for all accounts is `Password123!`. Another agent, Karim (`karim@comar.tn`), works for COMAR. He's useful to check that one company can't see another company's claims.

---

## 3. The life of a claim

**In simple words.** A claim moves through steps, like a parcel being delivered: received, being studied, maybe waiting for a document, maybe an expert visit, and finally a decision. Only certain moves are allowed. For example, a claim can't be closed before someone has looked at it.

```
Brouillon → Déclaré → Constat signé → Transmis → En instruction ─┬→ Pièce demandée ─┬→ En instruction
 (draft)    (declared)  (signed)        (sent)     (in review)   │   (doc requested) └→ Rejeté
                                                                 ├→ Expertise ──────┬→ Clôturé
                                                                 │                  └→ Rejeté
                                                                 ├→ Clôturé (closed)
                                                                 └→ Rejeté (rejected)
```

A closed or rejected claim can be **reopened** by an agent with a reason. It then goes back to "En instruction".

**Technically.**
- **Allowed moves** are listed in `backend/src/modules/claims/claims.workflow.js` (`canMove`). The same list is mirrored in Flutter in `lib/modules/claims/models/claim_status.dart`, so the buttons only offer valid actions.
- **Every step** is saved as a `ClaimEvent` row with its date. Together these rows form the timeline you see on screen ("Chronologie").
- **Time limits per step** are set in `backend/src/modules/claims/ai/rules.js` (`Limits.slaDays`):
  - Transmis: 2 days;
  - En instruction: 10 days;
  - Pièce demandée: 7 days;
  - Expertise: 15 days.

  A claim that stays longer is marked late, and it moves up in the agent's list.

---

## 4. How the pieces fit together

**In simple words.** The phone keeps its own copy of the claims, so it works even without internet. When the internet is there, it sends what you did to the server and gets back what others did. The server is the single source of truth: it checks every action, stores everything in a database, and tells the other phones that something changed.

```
 Driver's phone                      Server (Node.js)                  Agent's phone
 ┌────────────────┐   HTTPS + JWT   ┌──────────────────────┐   HTTPS  ┌────────────────┐
 │ Flutter app    │ ─────────────▶ │ /api/claims routes    │ ◀─────── │ Flutter app    │
 │ SQLite (drift) │ ◀───────────── │ claims.service.js     │ ───────▶ │ SQLite (drift) │
 │ request queue  │   socket.io     │ PostgreSQL (Prisma)   │ socket.io│ request queue  │
 └────────────────┘  "changed!"    │ AI: rules, model, LLM │  "changed!"└────────────────┘
                                   └──────────────────────┘
```

**Technically.**
- **Backend:** Node.js with Express 5, Prisma 7 on PostgreSQL (Docker, host port 5434), socket.io for live updates. The routes are documented with OpenAPI: Swagger UI at `http://localhost:3000/api/claims/docs`, spec in `backend/src/modules/claims/claims.openapi.json`.
- **App:** Flutter 3, with local storage in SQLite through **drift** (claims database schema v6). The app runs on Android, iOS and the web (Chrome).
- **Login** comes from module 1: a JWT access token that lasts 15 minutes and is refreshed automatically.

---

## 5. The server (backend)

**In simple words.** The server is the office behind the counter. It receives every request ("take charge of this claim", "here is a document"), checks that the person is allowed to do it, saves it, and informs everyone concerned.

**Technically.** Everything is in `backend/src/modules/claims/`:

| File | Role |
|---|---|
| `claims.routes.js` | The HTTP routes (list below), the file uploads, and an AI rate limit. |
| `claims.service.js` | The business logic: create, take charge, request a document, schedule an expertise, answer the appointment, close, reject, reopen, messages, notifications, snapshot for sync. Also enforces who can see what (`scopeOf`, `canSee`). |
| `claims.workflow.js` | The status names and allowed moves. |
| `claims.auth.js` | Reads the JWT. `requireUser` for HTTP and `identifySocket` for the live channel, both returning id, role and company. |
| `claims.socket.js` | The socket.io channel. Each user joins rooms `user:<id>`, `role:<role>` and `company:<id>`, and receives `claims:changed`. |
| `claims.db.js` | The shared Prisma client. |
| `claims.errors.js` | Clean error answers (403, 404, 409…). |
| `claims.openapi.json` | API documentation. |
| `ai/` | The intelligent part (section 13). |

**Main routes** (all under `/api/claims`):

| Method and path | What it does |
|---|---|
| `GET /` and `POST /` | List claims (filtered by who you are), and create one (driver). |
| `GET /sync` | The full snapshot the app downloads to catch up. |
| `GET /:id` | One claim. |
| `POST /:id/take-charge` | The agent starts working on it. |
| `POST /:id/document-requests` | Ask the driver for a document. |
| `POST /:id/documents` | Upload a document (photo, PDF, video, voice note). |
| `POST /:id/expertise` | Appoint an expert and propose an appointment. |
| `POST /:id/appointment` | Accept the proposed time, or propose another (`{action: accept \| propose}`). |
| `POST /:id/expert-report` | Attach the expert's report. |
| `POST /:id/close` and `POST /:id/reject` | Final decision. |
| `POST /:id/reopen` | Reopen a decided claim, with a reason (agent only). |
| `GET/POST /:id/messages`, `POST /:id/messages/read` | Messaging and read receipts. |
| `GET /notifications`, `POST /notifications/read` | Notifications. |
| `GET /:id/insights` | The analysis of one claim. |
| `POST /:id/ai/assistant`, `/ai/summary`, `/ai/replies` | The AI features. |
| `GET /analytics` | Statistics (agent). |
| `GET /ai/status` | Which AI provider is active. |
| `GET /files/...` | Download stored files. |

**Database tables** (in `backend/prisma/schema.prisma`):
- `Claim`, `ClaimEvent`, `ClaimDocument`, `DocumentRequest`, `ClaimNotification`, `ClaimAiNote`, `AiCall`;
- plus the message table.

Migrations live in `backend/prisma/migrations/`. Two examples of module 5 migrations:
- `20261109120000_claims_appointment`: the negotiated appointment;
- `20261109180000_claims_driver_b_boxes`: driver B's boxes.

**Demo data**: `backend/prisma/claims-demo.js`, run with `npm run claims:demo`. It resets only module 5's claims (0418, 0421, 0422, 0423 for Sami at STAR, and 0430 for Hedi at COMAR).

---

## 6. The phone app (Flutter)

**In simple words.** The app has a few screens: a list of claims, the page of one claim, the messages, the assistant, and for the agent a dashboard and statistics. The same code runs on Android, iPhone and in a web browser.

**Technically.** Everything is in `lib/modules/claims/`:

**Screens** (`screens/`)

| File | Screen |
|---|---|
| `claims_screen.dart` | List of claims with search and filters (status, severity, dates). Used by both roles. |
| `claim_detail_screen.dart` | One claim: summary card, driver tracking card, appointment, timeline, constat (A and B), documents, expert report, and for the agent the handling tools, the AI icon and the decision help side panel with its guide bubble. |
| `agent_dashboard_screen.dart` | Agent home: three key numbers and the claims sorted by priority. |
| `analytics_screen.dart` | Statistics in a Grafana-like style. |
| `assistant_screen.dart` | The question-and-answer assistant of a claim. |
| `chat_screen.dart` | Conversation between driver and agent about one claim. |
| `messages_screen.dart` | All conversations with their unread counters. |
| `notifications_screen.dart` | The notification list. |

**Widgets** (`widgets/`)

| File | What it draws |
|---|---|
| `claim_card.dart` | A claim in a list: number, status, type, place, date, and for the agent a priority bar, reasons and next step. |
| `claim_status_chip.dart` | The small status label. |
| `claim_timeline.dart` | The timeline. It shows the last 4 steps; three dots at the top open the earlier ones, and "Afficher moins" folds them again. |
| `analysis_card.dart` | `AnalysisCard`, the agent's decision help: next step, estimate, usual duration, rejection risk, signals, missing documents, similar cases, AI summary. Also `GuidanceCard`, the driver's dark tracking card with progress, to-do list and estimated days left. |
| `expertise_card.dart` | The expert appointment for both roles: date, place, expert, what to bring, Accept or "Proposer un autre créneau", and the time-slot picker. |
| `agent_panel.dart` | The agent's actions, including the decision card with the 0/50/100 % split. |
| `appointment_alerts.dart` | The pop-out at the top of the screen when the other person confirms or proposes another appointment time. |
| `ink.dart` | The design building blocks (section 15). |
| `motion.dart` | Small animations (count-up numbers, fade-in, growing bars), all switched off when the phone asks for reduced motion. |
| `offline_banner.dart` | The "offline" banner. |
| `document_picker.dart`, `format.dart` | File picking and date formatting. |

**State** (`state/`)
- `claim_store.dart`: the list of claims in memory, and every action (take charge, request, schedule, accept, propose, close, reopen…).
- `message_store.dart`: the messages.
- `claims_sync.dart`: talks to the server (section 7).
- `persisted_store.dart`: saves to SQLite.

**Data** (`data/`)
- `claims_tables.dart`, `claims_database.dart`, `claims_dao.dart`: the local drift database, with its migrations up to v6.
- `claims_api.dart`: the HTTP client.
- `declaration_files.dart`: finds the insurance company from the driver's vehicles.
- `claims_seed.dart`: demo data used when there's no server.

**Models** (`models/`)
- `claim.dart`, `claim_status.dart`, `claim_insight.dart`, `claim_notification.dart`, `chat_message.dart`, `claim_filter.dart`;
- `responsibility.dart`, which holds the fault scale (section 10).

**Text** (`l10n/claims_text.dart`): translates the labels the server sends (statuses, events, notifications) into the user's language.

---

## 7. Working without internet

**In simple words.** If you're in a car park with no signal, you can still open your claim and even do things, like upload a document. The app writes your action down in a "to send" list. As soon as the internet is back, it sends the list in order, then downloads what changed. You don't have to do anything.

**Technically.** In `lib/modules/claims/state/claims_sync.dart`:
- Every action goes through `enqueue()`. It's saved as an `ApiRequest` row in SQLite, then `synchronize()` runs.
- **A sync pass**:
  1. Send the queued requests one by one.
  2. If they were all sent, download `GET /sync` and replace the local copy (`replaceFromServer`).
  3. Reload the stores.
- **Only one pass runs at a time.** A call made during a pass marks "run again" and waits.
- **If the server is unreachable** (an error of 500 or above, or 401, 408 or 429), the queue is kept for later. If the server refuses for a business reason (any other 4xx), the request is dropped, because retrying wouldn't change anything.
- **A 30-second timer** also triggers a pass, and reopens the live channel if it's closed.
- The **language** of the analysis follows the profile. When the user changes language, the app downloads again so the texts come back in that language.

---

## 8. Live updates

**In simple words.** When the agent asks for a document, the driver's screen updates right away, without refreshing. The server sends a short "something changed" signal, and the phone then fetches the news.

**Technically.**
- **Server:** `backend/src/modules/claims/claims.socket.js` sends `claims:changed` to the driver of the claim and to the agents of its company.
- **App:** `claims_sync.dart` → `connect()`.
- **A bug we fixed:** the socket library reused an old connection with an expired token, so the live channel never reopened and changes only arrived every 30 seconds. The fix is `enableForceNew()` plus `disableReconnection()`. On a disconnect, `_reconnectSoon()` waits 3 seconds, runs a sync (which refreshes the token), then reconnects.

---

## 9. Insurance companies: who sees what

**In simple words.** An agent at STAR must never see claims sent to COMAR. Each claim is linked to the driver's insurance company, and each agent only sees their own company's claims.

**Technically.** We use module 1's `companyScope`, applied in `claims.service.js` → `scopeOf(user)`:
- a **driver** sees only their own claims (`{driverId}`);
- an **agent** sees claims of their company, plus claims whose company is still unknown (`{OR:[{companyId},{companyId:null}]}`). An agent with no company gets a 403;
- an **admin** sees everything.

**How the claim's company is chosen** (`companyOf`, and in Flutter `declarationCompany()` in `data/declaration_files.dart`):
- If the declared vehicle has an insurer, that's the company.
- Otherwise, if all the driver's active vehicles share one insurer, that's the company.
- Otherwise, the app doesn't guess. The claim stays "no company", and every agent sees a "Compagnie non renseignée" tag on it.

A small detail: the search filter and the scope filter are combined with `AND`, so a search can never widen what an agent is allowed to see.

---

## 10. Responsibility proposal (who is at fault)

**In simple words.** On the paper constat, each driver ticks boxes like "was reversing" or "was parked". From those boxes, the app proposes who is at fault: 100 %, 50 % or 0 % for driver A. It's only a proposal. The agent decides, and the screen explains the reason in one sentence.

**Technically.** The same scale runs on the server (`backend/src/modules/claims/ai/rules.js` → `responsibilityProposal(boxesA, boxesB, lang)`) and in the app (`lib/modules/claims/models/responsibility.dart` → `ResponsibilityProposal.fromBoxes(a, b)`). A shared test table checks that both give the same answer.

| Boxes | A's share | Code |
|---|---|---|
| Risky manoeuvre on both sides | 50 % | `both` |
| Risky manoeuvre only by A | 100 % | `fault-a` |
| Risky manoeuvre only by B | 0 % | `fault-b` |
| A parked, B moving | 0 % | `parked-a` |
| B parked, A moving | 100 % | `parked-b` |
| A turn, or nothing decisive | 50 % | `turn` / `unknown` |

Driver B's boxes come from module 4's constat and are stored in `circumstancesB`.

On the agent's decision card (`agent_panel.dart`), a bar shows the split, with A always in blue and B always in amber.

---

## 11. Expert appointment

**In simple words.**
1. The agent picks an expert and proposes a date, place and kind of expertise: vehicle, or medical when a pedestrian is hurt.
2. The driver sees the appointment with "what to bring", and can accept or propose another time.
3. When one side accepts, the other gets a pop-out "confirmed". When one side proposes another time, the other gets a pop-out, and tapping it opens the claim right on the appointment, ready to accept.

**Technically.**
- **Claim fields:** `expertName`, `expertPhone`, `expertPlace`, `expertKind` (`Véhicule` or `Corporelle`; `Corporelle` by default when the claim type is a pedestrian), `expertAppointment`, `appointmentState` (`proposed` or `accepted`), `appointmentBy` (who proposed) and `appointmentNote`.
- **Server:** `scheduleExpertise` and `respondAppointment` in `claims.service.js`, through the routes `POST /:id/expertise` and `POST /:id/appointment`.
- **App:**
  - `ExpertiseCard` decides whose turn it is with `claim.awaitsAnswerFrom(role)`. Someone never confirms their own proposal.
  - The slot picker (`pickSlot`, `suggestedSlots`) suggests working days, never Sunday, from tomorrow, and avoids the time that was just refused.
- **Pop-out:** `widgets/appointment_alerts.dart`.
  - It's placed once above all screens through `MaterialApp.builder` in `lib/app/app.dart`.
  - It watches the notifications and shows new unread ones less than 10 minutes old.
  - Tapping it opens `ClaimDetail(focusExpertise: true)`, which scrolls to the appointment.
  - It closes after 10 seconds, or with ✕.

---

## 12. Messages and notifications

**In simple words.** Each claim has its own conversation between the driver and the agent, with "read" ticks. The app also sends short notices like "document requested" or "claim closed". A counter on the tab shows how many are unread.

**Technically.**
- **Messages:** `chat_screen.dart` and `messages_screen.dart` in the app, `message_store.dart` for the state, and `/:id/messages` routes on the server. Opening a chat sends a read receipt (`/:id/messages/read`).
- **Notifications:** `ClaimNotification` rows. Each has an audience (driver or agent), a claim and a creation date. The server writes them in French; the app translates them when displaying (`claimNotification()` in `l10n/claims_text.dart`).
- **Suggested replies:** for the agent, an AI button proposes short replies (section 13). It only fills the text field; nothing is sent without the agent pressing send.

---

## 13. The intelligent part: rules, model and Claude

**In simple words.** Three kinds of "intelligence" help, each for what it does best:

1. **Rules.** Clear checks anyone can verify, for example "declared more than 5 days after the accident" or "claim waiting longer than allowed". They also give the fault proposal and the priority order.
2. **A small trained model.** It has learned from examples, and it estimates the repair amount and the risk that a claim is rejected, with the reasons.
3. **Claude**, a language AI. It writes in plain language: it answers questions about the claim, summarizes it for the agent, suggests message replies, and reads uploaded documents.

The important decisions (priority, risk, fault share, amount) are **never** made by Claude. The agent always has the last word. And if Claude isn't available, the app still answers using the rules.

### 13.1 Rules (`backend/src/modules/claims/ai/rules.js`)

- **Limits:** declaration within 5 days; more than 2 claims a year is notable; a document amount more than 2× the estimate is notable; an expert is recommended from 3,000 TND or for a severe claim; plus the step durations from section 3.
- **Signals** (things to check), each with a reason the agent can read:
  - late declaration;
  - repeated claims;
  - contradictory boxes (stopped and manoeuvring);
  - severe claim with no impact point;
  - amount far above the estimate;
  - a document that doesn't match what was asked.
- **Priority** (`ai/insights.js` → `priority()`): starts at 10 points, then adds:
  - +35 if the claim is severe;
  - up to +30 if it's late;
  - +10 if no one has touched it yet;
  - up to +15 for signals.

  The score is capped at 100, and every added point comes with a reason that's shown on the card.
- **Next step:** one sentence telling the agent what to do now, or the driver what's expected. For example "Demander : Devis" or "Le conducteur propose un autre créneau : répondre."

### 13.2 The trained model (`ai/ml.js`, `ai/features.js`, `ai/train.js`, `ai/model.json`)

- These are linear models written by hand, small enough to run anywhere, and each prediction can be broken down by variable, which makes it explainable:
  - **ridge regression** for the indemnity estimate (low, middle, high);
  - **logistic regression** for the rejection risk (low, medium, high), with the factors that weigh most;
  - **nearest neighbours** to find similar past claims.
- **Training:** `npm run ml:train`. There's no real claim history yet, so training uses **synthetic data** (a deterministic generator), plus any finished claims in the database. The statistics screen states this honestly: the metrics show that the model learned the generator, not that it's right on real claims.

### 13.3 Claude and other language models (`ai/llm.js`, `ai/providers/`, `ai/assistant.js`)

| Feature | Function | Who |
|---|---|---|
| Assistant (questions on a claim) | `askAssistant` | Driver and agent |
| Summary of a claim | `summarize` | Agent |
| Suggested replies | `suggestReplies` | Agent |
| Reading an uploaded document | `analyzeDocument` | Runs in the background |

- **Choosing the provider** (`AI_PROVIDER` in `backend/.env`, default `auto`):
  1. **In development**, the **Claude Code CLI** installed on the computer (the VS Code extension or the terminal version), which uses the person's Claude account with **no API key** (`providers/claude-cli.js`, model `claude-sonnet-5-5`).
  2. Otherwise the first configured key: `ANTHROPIC_API_KEY` (`providers/anthropic.js`, model `claude-opus-5-5`), any OpenAI-compatible API such as Mistral, Groq or a local Ollama (`providers/openai.js`), or Perplexity with web search turned off.
  3. **In production** the CLI is never used.
  4. If nothing is set up or the call fails (timeout, bad answer), the module **answers with the rules**.
- **What Claude receives:** only the facts of a claim the user is allowed to see (`caseFacts`, `loadContext`), including both drivers' boxes, the appointment and the documents. History is limited to the same scope.
- **Logging:** each call is saved in the `AiCall` table (source, provider, model, success). A logging failure never breaks an answer.
- **Rate limit:** the `/ai/*` routes are rate-limited (`aiLimit` in `claims.routes.js`).
- **On screen:** the answer shows who wrote it, for example "Claude (CLI) · claude-sonnet-5-5" or "Réponse automatique".

### 13.4 What the driver sees vs. the agent

- **The driver** gets a dark **tracking card** (`GuidanceCard`): one sentence on where the claim is, the 4 steps (received, review, expertise, decision), a to-do list, and an estimate of the days left. When the claim takes longer than usual, it says so instead of showing a countdown.
- **The agent** gets **Aide à la décision** (`AnalysisCard`), opened from the ✨ icon in the claim screen's top bar. It slides in from the side. A small guide bubble points at the icon each time a claim is opened, and ✕ closes it.
- The server only sends the driver the driver part. Even an agent analysis stored in the phone's cache stays hidden from a driver (there's a test for this).

---

## 14. Statistics screen

**In simple words.** A one-page overview for the agent: how many claims, how many are late, the average duration, how much was paid, how claims are spread by status, severity and type, and how often the agents agreed with the app's fault proposal.

**Technically.** `lib/modules/claims/screens/analytics_screen.dart`, with data from `GET /api/claims/analytics` (`backend/src/modules/claims/ai/analytics.js`). It's styled like a **Grafana** dashboard:
- a row of **stat panels** you can scroll sideways: total, late, average duration, indemnified (TND);
- a thin **donut** by status, with a legend table showing count and percent;
- **bar gauges** side by side, scrolling sideways: by severity (green/yellow/red), by type, and by AI source;
- a **gauge** with a threshold band (red under 50 %, yellow up to 75 %, green above) for "the system vs. the agents", plus the model's version, training data and test scores, and a clear warning that the data is simulated.

---

## 15. Design: how the screens look and why

**In simple words.** The screens were cleaned up to look calm and professional: white cards with fine borders, one dark "ink" card that catches the eye (the driver's tracking card), thin buttons with a subtle line of light on top, and charts in the well-known Grafana colours. Small groups of information scroll sideways instead of making the page very long.

**Technically.**
- **The app's palette is unchanged** (`lib/core/theme/app_palette.dart`, shared with the other modules). Module 5 only removed its own bright extras (violet/pink gradients, glows, floating and pulsing animations).
- **The building blocks** are in `lib/modules/claims/widgets/ink.dart`:
  - `ClaimsStyle` wraps every module 5 screen with a local theme: 48 px buttons, weight 600 at most, hairline borders, Manrope titles, and a thin lit edge (`LitEdge`) on filled buttons;
  - `InkPanel`: a white card, or the dark ink card;
  - `SectionTitle`;
  - `XStrip`: the sideways strip;
  - `QuietTag`: the small label with a coloured dot;
  - `SeriesDot`;
  - `ClaimsColors`: the Grafana series and the thresholds `ok`, `warn`, `critical` and `info`.
- **Sideways strips** are used for:
  - the analysis figures;
  - the documents;
  - the "what to bring" list;
  - the priority reasons on a card;
  - the statistics panels.
- **Motion** (`widgets/motion.dart`): numbers count up, cards fade in, bars fill once. Everything respects the phone's "reduce motion" setting.

---

## 16. Three languages

**In simple words.** The app speaks French, English and Arabic, and Arabic reads right to left. The server writes some texts in French (statuses, events, notifications), and the app translates them for the user.

**Technically.**
- **Screen texts** are in `lib/l10n/app_fr.arb`, `app_en.arb` and `app_ar.arb`; `flutter gen-l10n` generates the Dart code. These files are shared with the other modules.
- **Server labels** are translated in `lib/modules/claims/l10n/claims_text.dart` (`claimValue`, `claimEvent`, `claimNotification`, `claimProposalReason`).
- **Server-written analysis** (sentences, signals, next steps) comes in the profile's language from `backend/src/modules/claims/ai/i18n.js`.
- **Claim numbers inside Arabic sentences** are wrapped in direction marks so they display correctly.

---

## 17. Links with the other modules

| Module | What module 5 takes from it |
|---|---|
| 1, users | Login (JWT), roles, insurance companies, `companyScope`, the admin console. |
| 2, vehicles | The driver's vehicles and their insurer, used to choose the claim's company. |
| 3, accident | The accident wizard (`accident_wizard.dart`). At the end it creates the claim with A and B's boxes, impact zones and the company. |
| 4, constat | The digital constat signed by both drivers and sealed with SHA-256. Module 5 keeps its id (`constatId`, only when it belongs to the declaring driver), shows the sealing steps in the timeline, and anyone can check the PDF at `GET /api/constats/verify/<hash>`. |

Shared files module 5 had to touch, each time with a note to the team:
- the ARB files;
- `declarations_screen.dart` (its search icon opens the claims list);
- `accident_wizard.dart` (sends the boxes, the company and the constat id);
- `lib/app/app.dart` (hosts the appointment pop-out).

---

## 18. Security and privacy

- **Access:** every route checks the user's role and company. The checks are on the server; hiding a button in the app is never the protection.
- **Ids:** invalid claim ids are refused cleanly instead of crashing (UUID check).
- **Secrets:** keys only go in `backend/.env`, which is never committed. `.env.example` lists the options with no values.
- **AI:** Claude only sees facts the user may see. With Perplexity, web search is turned off so claim data isn't sent to a search engine. In production the local CLI is never used.
- **Files** are served through authenticated routes.
- **The sealed constat** (module 4) can be verified by anyone through its fingerprint, without logging in.

---

## 19. Tests

**In simple words.** Hundreds of small automatic checks run in seconds and make sure nothing breaks when we change something. For example: "a driver never sees an agent's analysis", "an agent from COMAR can't open a STAR claim", "the fault scale gives the same answer on the server and in the app".

**Technically.**
- **Flutter:** `flutter test`. 231 tests on `main` after the last merge. Module 5's files:
  - `test/claims_workflow_test.dart`: actions and screens;
  - `test/claims_intelligence_test.dart`: analysis, dashboard, assistant, statistics;
  - `test/claims_appointment_test.dart`: appointment, slots, timeline folding, pop-outs;
  - `test/claims_company_test.dart`: fault scale and company choice;
  - `test/claims_l10n_test.dart`: translations;
  - `test/claims_persistence_test.dart`: the local database and its migrations;
  - `test/claims_sync_test.dart`: the offline queue and synchronization;
  - `test/claims_live_test.dart`: two phones against a real API, run separately.
- **Backend:** `cd backend && npm test` on a test database (`monconstat_test`, port 5434). 212 tests at the last merge, including:
  - `claims.test.js`: routes, scope, appointment, reopen;
  - `claims.ai.test.js`: rules, model, insights;
  - `claims.providers.test.js`: Claude CLI, Anthropic and OpenAI providers against simulated servers.
- **Manual scenarios:** [module-5-test-guide.md](module-5-test-guide.md).

---

## 20. How we worked

- **Branch:** all work happened on `module-5`. `main` was regularly merged into it to stay up to date with the team, and it was pushed so everyone could see it on GitHub.
- **Merges into main** were only done on request, each time with a backup:
  - `backup/main-before-module-5` and the tag `main-before-module-5` for the first merge;
  - `backup/main-2026-11-10` for the latest one.
- **Shared files:** the team was told about each one module 5 changed (section 17).
- **Commits** were small and described what changed and why. Tests were run before every push.
- **Testers:** teammates got a short French setup message and the test guide. The guide explains how to run the API outside Docker so Claude works through the CLI, and to run `npm install && npx prisma migrate deploy` after each pull.
- **Design pass:** the screens went through an "unslop" review. The audit covered spacing, colour, icons, copy, type, layout, details, visuals and motion. Screenshots were rendered with the real fonts to check the result.

---

## 21. Known limits

- **Module 3 doesn't record which vehicle was involved,** so the company is sometimes guessed from the driver's vehicles, or left empty when they have several insurers.
- **Module 4:** driver B gets no e-mail, and the sealed record shows placeholders for driver A.
- **The trained model has only seen synthetic data.** Its figures are a demonstration, not a validated prediction.
- **On the web,** the agent screen keeps the phone layout; only the admin has a wide-screen console. A wide two-column agent layout is a possible next step.
- **iOS:** `Info.plist` still needs the microphone and location descriptions, and an exception for plain-HTTP local servers, before testing on an iPhone.
- **The expert doesn't use the app.** Their report is attached by the agent.

---

## 22. File map

```
backend/
  prisma/
    schema.prisma                 Claim, ClaimEvent, ClaimDocument, DocumentRequest,
                                  ClaimNotification, ClaimAiNote, AiCall, messages
    migrations/2026110912…        appointment, driver B's boxes, …
    claims-demo.js                demo claims (npm run claims:demo)
  src/modules/claims/
    claims.routes.js              HTTP routes, uploads, AI rate limit
    claims.service.js             business logic, scope, notifications
    claims.workflow.js            statuses and allowed moves
    claims.auth.js                JWT for HTTP and socket
    claims.socket.js              live updates (rooms user/role/company)
    claims.openapi.json           Swagger documentation
    ai/
      rules.js                    limits, signals, fault scale
      insights.js                 analysis per claim, priority, next step, driver view
      features.js  ml.js          features and hand-written models
      train.js     model.json     training (npm run ml:train) and saved weights
      analytics.js                statistics
      assistant.js                assistant, summary, replies, document reading
      llm.js                      provider choice, fallback, logging
      i18n.js                     server texts in FR / EN / AR
      providers/                  claude-cli.js, anthropic.js, openai.js, shared.js
  test/claims*.test.js

lib/modules/claims/
  screens/                        claims, detail, dashboard, analytics, assistant, chat,
                                  messages, notifications
  widgets/                        claim_card, status chip, timeline, analysis_card,
                                  expertise_card, agent_panel, appointment_alerts,
                                  ink (design), motion, offline_banner, …
  state/                          claim_store, message_store, claims_sync, persisted_store
  data/                           drift tables, database, dao, api, declaration_files, seed
  models/                         claim, status, insight, notification, chat message,
                                  filter, responsibility
  l10n/claims_text.dart           translation of server labels

lib/app/app.dart                  hosts the appointment pop-out (shared file)
lib/l10n/app_{fr,en,ar}.arb       screen texts (shared files)
test/claims_*_test.dart           Flutter tests
docs/module-5-plan.md             plan and demo commands
docs/module-5-test-guide.md       test scenarios
docs/module-5-explained.md        this document
```

---

## 23. Glossary

| Word | Meaning |
|---|---|
| **Sinistre / claim** | The insurance file opened after an accident. |
| **Constat amiable** | The accident report both drivers fill in and sign. |
| **Driver A / driver B** | The two drivers on the constat. A is the one declaring. |
| **Agent** | The insurance company employee who handles the claim. |
| **Expertise** | The inspection of the damage (vehicle) or of the injuries (medical). |
| **Indemnité / indemnity** | The amount the insurer pays. |
| **Responsibility share** | The percentage of fault given to driver A (B gets the rest). |
| **SLA** | The normal maximum time a step should take. |
| **API** | The server's "counter" the app talks to. |
| **JWT / token** | A digital pass proving who you are, valid for a short time. |
| **SQLite / drift** | The small database inside the phone. |
| **PostgreSQL / Prisma** | The server's database and the tool used to talk to it. |
| **socket.io** | A channel that stays open so the server can say "something changed" instantly. |
| **LLM / Claude** | A language AI that reads and writes text. |
| **Claude Code CLI** | Claude installed on the developer's computer, used without an API key during development. |
| **Ridge / logistic regression** | Simple statistical models: one estimates an amount, the other a probability. |
| **Synthetic data** | Realistic examples generated by a program, used because there is no real history yet. |
| **Grafana** | A well-known dashboard tool whose chart style we copied. |
| **SHA-256** | A digital fingerprint. If one character of the PDF changes, the fingerprint changes. |
