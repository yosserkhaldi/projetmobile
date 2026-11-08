# Module 5 test guide: claims, tracking and messaging

For anyone who merges `module-5` and wants to test it, with real Claude answers, on their own machine or phone. Owner: Salma.

## 1. Get the code

```bash
git checkout main && git pull
git merge origin/module-5          # or test the branch directly: git checkout module-5
flutter pub get
cd backend && npm install && cd ..
```

## 2. Database and demo data

```bash
docker compose up -d db                      # PostgreSQL on port 5434
cp backend/.env.example backend/.env         # only if you have no backend/.env yet
```

In `backend/.env`, the database line must use port **5434**, the port Docker exposes:

```
DATABASE_URL=postgresql://monconstat:monconstat@localhost:5434/monconstat
```

Then:

```bash
cd backend
npx prisma migrate deploy     # creates or updates the tables
npm run db:seed               # demo accounts and claims
```

Password for every account: `Password123!`
- `sami@example.com`: driver
- `leila@assurance.tn`: agent

To replay the scenarios from the start, `npm run claims:demo` resets the module 5 claims, and only those.

## 3. Real Claude answers through the Claude Code CLI

The API uses the Claude Code CLI installed on the machine, so any Claude account works (Pro included). No API key is needed, and none is ever committed.

1. **Have Claude Code installed and signed in.** Either of these is enough:
   - the Claude Code **VS Code extension**, signed in: the API finds its binary automatically;
   - the **terminal** version: `claude --version` answers, and you have run `claude` once and signed in.
2. **Run the API on the machine, not in Docker.** A container can't see the CLI.
   ```bash
   docker compose stop api       # if it was running
   cd backend && npm run dev     # API on http://localhost:3000
   ```
3. **Check:** in the app, open a claim, then the assistant (headset icon), and ask a question. The answer is labelled **"Claude (CLI) · claude-sonnet-5-5"** and takes about 5 to 10 seconds. If it says **"Réponse automatique"**, the CLI wasn't found. Add its path in `backend/.env` and restart `npm run dev`:
   ```
   CLAUDE_CLI_PATH=/full/path/to/claude
   ```
   To find it: `which claude`, or `ls ~/.vscode/extensions/anthropic.claude-code-*/resources/native-binary/claude`.

Without Claude, everything still works: the rules answer instead, in the user's language.

## 4. Start the app

**Chrome**, the fastest way to test with two people at once:

```bash
flutter run -d chrome --web-port 5050
```

- Port 5050, not 5000: on a Mac, 5000 is taken by AirPlay.
- Log in as Sami in the normal window and as Leïla in an **incognito** window at `http://localhost:5050`. Two tabs in the same window would share one login.

**Phone on the same Wi-Fi.** Replace `192.168.1.9` with the computer's IP (`ipconfig getifaddr en0` on a Mac):

```bash
flutter run --dart-define=API_URL=http://192.168.1.9:3000/api
```

- Android: USB debugging on, with the Android SDK installed.
- iPhone: needs Xcode and a free Apple ID, and the iPhone must trust the developer profile (Settings > General > VPN & Device Management).
- Expo does **not** work: this is a Flutter app, not React Native.

## 5. Scenarios

**D** = Sami (driver), **A** = Leïla (agent). Every change appears in the other window within a second or two.

### Driver: following a claim
1. **D**, Déclarations tab: the "Déclarations transmises" list shows SIN-2026-0418, 0421, 0422 and 0423 with their status.
2. **D**, search icon at the top of Déclarations: search "0418", "Tunis" or "en instruction". The Statut, Gravité and Date chips filter the list, and an active filter turns violet.
3. **D**, open SIN-2026-0418: the timeline (Brouillon créé → Transmis → En instruction) and the Constat section ("Changeait de file").
4. **D**, tracking card (gradient):
   - the server's sentence for the current status;
   - a 4-step progress bar (Reçu, Étude, Expertise, Décision), with the current step pulsing;
   - an "À faire" list;
   - the estimated days left, which is an estimate and not a commitment. If the usual duration has already passed (SIN-2026-0418 was opened on 13 October), it says the claim is taking longer than usual instead of counting down.
   
   No amount, risk or warning is ever shown to the driver.
5. **D**, "Déposer une pièce": the file appears under "Pièces du dossier", and A gets a notification.

### Agent: handling and deciding
6. **A**, home:
   - animated counters;
   - "Dossiers prioritaires" sorted by score. Each card has a priority bar, its reasons as red chips ("Sinistre grave", "En retard de 10 j", "Signal à vérifier"…) and the next action.
   - SIN-2026-0422 comes first (score 100).
7. **A**, SIN-2026-0421: "Prendre en charge" → En instruction.
8. **A**, SIN-2026-0418, "Aide à la décision" card: next action, estimate in TND, usual duration, rejection risk, missing documents, similar claims.
9. **A**, "Demander" (yellow button next to Devis) → Pièce demandée. **D** sees "Pièces demandées" with a "Déposer" button. Once the document is uploaded, the claim goes back to En instruction by itself.
10. **A**, "Résumer le dossier": the summary appears in a violet frame with the name of the model that wrote it. It stays there when you scroll or leave the claim and come back. The ↻ button rewrites it.

### Expert appointment
11. **A**, SIN-2026-0418, "Désigner un expert":
    - choose Véhicule (or Corporelle);
    - enter the expert's name, phone and place (a garage, for example);
    - pick a suggested slot, or another date and time → Expertise.
12. **D** sees the appointment card:
    - date and time, place, expert and phone;
    - what to bring (the unrepaired vehicle, registration, licence, insurance certificate);
    - a pulsing "À confirmer" badge, with **Accepter** and **Proposer un autre créneau**.
13. **D**, "Proposer un autre créneau": pick a slot and write a message → A gets "autre créneau proposé", and the agent's next action becomes "Le conducteur propose un autre créneau : répondre".
14. **A**: Accepter → "Confirmé" on both sides. Either side can still propose a new slot later ("Je ne peux plus venir").
15. **Pedestrian**, SIN-2026-0423: take it on, then appoint an expert. Corporelle is preselected, and D sees a medical examination with ID and medical certificates instead of a vehicle.
16. **A**, "Joindre le rapport d'expertise": the report gets its own green section, separate from the other documents. The next action becomes "Rapport reçu : prendre la décision".

### Decision and correction
17. **A**, Décision card:
    - proposal "A 100 %, B 0 %" because of "Changeait de file";
    - choose 0, 50 or 100 % and enter an amount → Clôturé;
    - an empty amount or "abc" shows "Saisissez un montant valide.";
    - **D** sees the green summary and "Une question sur la décision ? Écrire à l'agent".
18. **A**, reject another claim with a reason → Rejeté, and D sees the reason.
19. **A**, on a closed or rejected claim, "Rouvrir le dossier" with a reason → back to En instruction. The old decision stays in the timeline as "Rouvert : …", and D is notified.

### Messages and notifications
20. Messages between D and A arrive in about a second, without refreshing.
21. The Messages tab shows an unread count, which clears when the conversation is opened. One tick means sent, two ticks mean read.
22. The paperclip attaches a file, and tapping it downloads it.
23. **A**, light bulb in a conversation: 3 suggested replies, and tapping one fills the input box.
24. Bell icon: each change made by one side notifies the other. Tapping a notification opens the claim; "Tout marquer lu" marks them all read.

### Assistant
25. Headset icon on a claim: the suggested questions stay above the input box. The ones already asked move to the end.
26. **D**: "Combien je vais être remboursé ?" → the assistant refuses and sends him to the agent.
27. **A**: "Quelle responsabilité proposes-tu ?" → the proposal and its reason.
28. Answers say who wrote them: "Claude (CLI) · …" or "Réponse automatique".

### Statistics (agent, chart icon)
29. Animated tiles, a donut chart by status, bars by severity and by accident type, a gauge showing how often the agent followed the system, and AI answers per source.

### Languages
30. Profile > language Arabic or English: every module 5 screen switches language, and Arabic reads right to left.
31. Server texts follow too: tracking card, next action, priority reasons, and assistant answers.

### Offline
32. `docker compose stop db` (or stop `npm run dev`): a "Hors ligne" banner appears. Send a message or a document; it waits on the phone.
33. Restart it: the banner disappears and everything is sent, in order.

### Security
34. D never sees risk, estimates, warnings or other drivers' claims, and has no Statistics.
35. Log out → the claims are cleared from the screen.

## 6. Run the tests

```bash
flutter test
docker compose exec db psql -U monconstat -c 'CREATE DATABASE monconstat_test'   # once
cd backend && npm test
```
