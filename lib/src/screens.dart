import 'package:flutter/material.dart';

import 'app.dart';
import 'store.dart';

void open(BuildContext context, Widget page) =>
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController(text: 'sami@example.com');
  final password = TextEditingController(text: 'Password123!');
  bool login = true, hidden = true;
  UserRole role = UserRole.driver;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.car_crash_rounded,
                  size: 58,
                  color: Color(0xFF185ADB),
                ),
                const SizedBox(height: 12),
                Text(
                  'Mon Constat Digital',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Votre constat, simple, rapide et sécurisé.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SegmentedButton<UserRole>(
                  segments: UserRole.values
                      .map(
                        (r) => ButtonSegment(
                          value: r,
                          label: Text(
                            r == UserRole.driver
                                ? 'Conducteur'
                                : r == UserRole.agent
                                ? 'Agent'
                                : 'Admin',
                          ),
                        ),
                      )
                      .toList(),
                  selected: {role},
                  onSelectionChanged: (v) => setState(() => role = v.first),
                ),
                const SizedBox(height: 20),
                if (!login) ...[
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Nom et prénom',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: password,
                  obscureText: hidden,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => hidden = !hidden),
                      icon: Icon(
                        hidden ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () {
                    StoreScope.of(context).setRole(role);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainShell()),
                    );
                  },
                  icon: Icon(login ? Icons.login : Icons.person_add),
                  label: Text(login ? 'Se connecter' : 'Créer mon compte'),
                ),
                TextButton(
                  onPressed: () => setState(() => login = !login),
                  child: Text(
                    login ? 'Créer un compte' : 'J’ai déjà un compte',
                  ),
                ),
                TextButton(
                  onPressed: () => _otpDialog(context),
                  child: const Text('Mot de passe oublié / Vérification OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  void _otpDialog(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Vérification'),
      content: const TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Code OTP à 6 chiffres'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Valider'),
        ),
      ],
    ),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final pages = store.role == UserRole.driver
        ? const [
            DriverHome(),
            VehiclesScreen(),
            ClaimsScreen(),
            MessagesScreen(),
            ProfileScreen(),
          ]
        : store.role == UserRole.agent
        ? const [
            AgentDashboard(),
            ClaimsScreen(agentMode: true),
            MessagesScreen(),
            ProfileScreen(),
          ]
        : const [
            AdminDashboard(),
            UsersScreen(),
            CompaniesScreen(),
            ProfileScreen(),
          ];
    final items = store.role == UserRole.driver
        ? const [
            ('Accueil', Icons.home_rounded),
            ('Véhicules', Icons.directions_car),
            ('Dossiers', Icons.folder),
            ('Messages', Icons.chat),
            ('Profil', Icons.person),
          ]
        : store.role == UserRole.agent
        ? const [
            ('Tableau', Icons.dashboard),
            ('Sinistres', Icons.folder),
            ('Messages', Icons.chat),
            ('Profil', Icons.person),
          ]
        : const [
            ('Tableau', Icons.dashboard),
            ('Comptes', Icons.people),
            ('Compagnies', Icons.business),
            ('Profil', Icons.person),
          ];
    if (index >= pages.length) index = 0;
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: items
            .map((e) => NavigationDestination(icon: Icon(e.$2), label: e.$1))
            .toList(),
      ),
    );
  }
}

class PageHead extends StatelessWidget {
  const PageHead(
    this.title, {
    this.subtitle,
    this.actions = const [],
    super.key,
  });
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null)
                Text(subtitle!, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
        ...actions,
      ],
    ),
  );
}

class DriverHome extends StatelessWidget {
  const DriverHome({super.key});
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          PageHead(
            'Bonjour, ${s.userName.split(' ').first}',
            subtitle: 'Prêt à prendre la route ?',
            actions: [
              IconButton(
                onPressed: () => open(context, const NotificationsScreen()),
                icon: Badge(
                  label: Text('${s.notifications.length}'),
                  child: const Icon(Icons.notifications_outlined),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: const Color(0xFF0D1B32),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UN ACCIDENT ?',
                      style: TextStyle(
                        color: Color(0xFFFFA51F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Déclarez-le en moins de 10 minutes, même hors ligne.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA51F),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => open(context, const AccidentWizard()),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Commencer une déclaration'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'Accès rapides',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.05,
              children: [
                _quick(
                  context,
                  Icons.badge_outlined,
                  'Mon permis',
                  const ProfileScreen(),
                ),
                _quick(
                  context,
                  Icons.warning_amber,
                  'Alertes',
                  const AlertsScreen(),
                ),
                _quick(
                  context,
                  Icons.description,
                  'Constat',
                  const AccidentWizard(startAtConstat: true),
                ),
                _quick(
                  context,
                  Icons.phone,
                  'Urgences',
                  const EmergencyScreen(),
                ),
                _quick(
                  context,
                  Icons.notifications,
                  'Notifications',
                  const NotificationsScreen(),
                ),
                _quick(
                  context,
                  Icons.help_outline,
                  'Assistance',
                  const HelpScreen(),
                ),
              ],
            ),
          ),
          if (s.claims.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClaimCard(s.claims.first),
            ),
        ],
      ),
    );
  }

  Widget _quick(BuildContext c, IconData i, String t, Widget p) => InkWell(
    onTap: () => open(c, p),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, color: const Color(0xFF185ADB)),
            const SizedBox(height: 8),
            Text(
              t,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return SafeArea(
      child: Column(
        children: [
          PageHead(
            'Véhicules & contrats',
            subtitle: '${s.vehicles.length} véhicule(s)',
            actions: [
              IconButton.filled(
                onPressed: () => _vehicleForm(context),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          Expanded(
            child: s.vehicles.isEmpty
                ? const Center(child: Text('Ajoutez votre premier véhicule'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: s.vehicles.length,
                    itemBuilder: (_, i) {
                      final v = s.vehicles[i];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const CircleAvatar(
                            child: Icon(Icons.directions_car),
                          ),
                          title: Text(
                            '${v.brand} ${v.model}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          subtitle: Text(
                            '${v.plate}\nPolice ${v.policy} • expire ${v.expiry}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (x) {
                              if (x == 'delete') {
                                s.removeVehicle(v);
                              } else if (x == 'archive') {
                                s.archiveVehicle(v);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'archive',
                                child: Text('Archiver'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Supprimer'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _vehicleForm(BuildContext context) {
    final fields = List.generate(6, (_) => TextEditingController());
    final labels = [
      'Immatriculation',
      'Marque',
      'Modèle',
      'Année',
      'N° de police',
      'Expiration JJ/MM/AAAA',
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ajouter un véhicule',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                fields.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: fields[i],
                    decoration: InputDecoration(labelText: labels[i]),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.document_scanner),
                label: const Text('Scanner carte grise / attestation'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  StoreScope.of(context).addVehicle(
                    Vehicle(
                      plate: fields[0].text,
                      brand: fields[1].text,
                      model: fields[2].text,
                      year: fields[3].text,
                      policy: fields[4].text,
                      expiry: fields[5].text,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClaimsScreen extends StatelessWidget {
  const ClaimsScreen({this.agentMode = false, super.key});
  final bool agentMode;
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return SafeArea(
      child: Column(
        children: [
          PageHead(
            agentMode ? 'Sinistres reçus' : 'Mes dossiers',
            subtitle: 'Suivi en temps réel',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Filtrer par numéro, statut ou gravité',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: s.claims.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => InkWell(
                onTap: () => open(
                  context,
                  ClaimDetail(s.claims[i], agentMode: agentMode),
                ),
                child: ClaimCard(s.claims[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClaimCard extends StatelessWidget {
  const ClaimCard(this.claim, {super.key});
  final Claim claim;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  claim.id,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Chip(label: Text(claim.status)),
            ],
          ),
          Text('${claim.type} • ${claim.severity}'),
          const SizedBox(height: 4),
          Text(claim.place, style: TextStyle(color: Colors.grey.shade600)),
          Text(claim.date, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    ),
  );
}

class ClaimDetail extends StatelessWidget {
  const ClaimDetail(this.claim, {this.agentMode = false, super.key});
  final Claim claim;
  final bool agentMode;
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(claim.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClaimCard(claim),
          const SizedBox(height: 16),
          const Text(
            'Chronologie',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          ...claim.timeline.map(
            (e) => ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(e),
            ),
          ),
          const Divider(),
          const Text(
            'Pièces du dossier',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          ...claim.documents.map(
            (e) => ListTile(
              leading: const Icon(Icons.attach_file),
              title: Text(e),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => s.addDocument(claim),
            icon: const Icon(Icons.upload_file),
            label: const Text('Déposer une pièce'),
          ),
          if (agentMode) ...[
            const SizedBox(height: 16),
            const Text(
              'Instruction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            DropdownButtonFormField<String>(
              initialValue: claim.status,
              items: [
                'En instruction',
                'Pièce demandée',
                'Expertise planifiée',
                'Accepté',
                'Rejeté',
                'Clôturé',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                if (v != null) s.updateClaim(claim, v);
              },
              decoration: const InputDecoration(labelText: 'Statut'),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Responsabilité',
                hintText: '0 %, 50 % ou 100 %',
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Montant d'indemnisation (TND)",
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => s.updateClaim(claim, 'Décision enregistrée'),
              icon: const Icon(Icons.gavel),
              label: const Text('Enregistrer la décision'),
            ),
          ],
        ],
      ),
    );
  }
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final input = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return SafeArea(
      child: Column(
        children: [
          const PageHead('Messagerie', subtitle: 'Dossier SIN-2026-0418'),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: s.messages.length,
              itemBuilder: (_, i) {
                final m = s.messages[i];
                final mine = m.author == s.userName;
                return Align(
                  alignment: mine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      color: mine ? const Color(0xFF185ADB) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.author,
                          style: TextStyle(
                            fontSize: 11,
                            color: mine ? Colors.white70 : Colors.grey,
                          ),
                        ),
                        Text(
                          m.text,
                          style: TextStyle(
                            color: mine ? Colors.white : Colors.black,
                          ),
                        ),
                        const Text('✓✓', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.attach_file),
                ),
                Expanded(
                  child: TextField(
                    controller: input,
                    decoration: const InputDecoration(
                      hintText: 'Votre message',
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: () {
                    s.sendMessage(input.text);
                    input.clear();
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController name;
  bool ready = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!ready) {
      name = TextEditingController(text: StoreScope.of(context).userName);
      ready = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const PageHead(
            'Mon profil',
            subtitle: 'Identité, permis et préférences',
          ),
          const CircleAvatar(radius: 44, child: Icon(Icons.person, size: 45)),
          const SizedBox(height: 18),
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Nom et prénom'),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Téléphone',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'N° de permis',
              prefixIcon: Icon(Icons.badge),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Catégorie et date de délivrance',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: s.language,
            decoration: const InputDecoration(labelText: 'Langue'),
            items: [
              'Français',
              'العربية',
              'English',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) {
              if (v != null) s.language = v;
            },
          ),
          SwitchListTile(
            value: s.biometric,
            onChanged: (v) => setState(() => s.biometric = v),
            title: const Text('Connexion biométrique'),
            subtitle: const Text(
              'Empreinte digitale ou reconnaissance faciale',
            ),
          ),
          FilledButton(
            onPressed: () {
              s.updateProfile(name.text, s.language, s.biometric);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil enregistré')),
              );
            },
            child: const Text('Enregistrer'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AuthScreen()),
              (_) => false,
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}

class AccidentWizard extends StatefulWidget {
  const AccidentWizard({this.startAtConstat = false, super.key});
  final bool startAtConstat;
  @override
  State<AccidentWizard> createState() => _AccidentWizardState();
}

class _AccidentWizardState extends State<AccidentWizard> {
  int step = 0;
  String type = 'Collision', severity = 'Matériel';
  bool injured = false;
  final place = TextEditingController(text: 'Position GPS détectée — Tunis');
  final guest = TextEditingController();
  final observations = TextEditingController();
  final steps = [
    'Contexte',
    'Description',
    'Preuves',
    'Conducteur B',
    'Circonstances',
    'Croquis',
    'Signatures',
  ];
  @override
  void initState() {
    super.initState();
    if (widget.startAtConstat) step = 3;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Constat • ${step + 1}/${steps.length}')),
    body: SafeArea(
      child: Column(
        children: [
          LinearProgressIndicator(value: (step + 1) / steps.length),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  steps[step],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Brouillon enregistré localement • synchronisation automatique',
                ),
                const SizedBox(height: 22),
                _content(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => step--),
                      child: const Text('Retour'),
                    ),
                  ),
                if (step > 0) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _next,
                    child: Text(
                      step == steps.length - 1
                          ? 'Signer et transmettre'
                          : 'Continuer',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  Widget _content() => switch (step) {
    0 => Column(
      children: [
        TextField(
          controller: place,
          decoration: const InputDecoration(
            labelText: 'Lieu',
            prefixIcon: Icon(Icons.location_on),
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Date et heure',
            prefixIcon: Icon(Icons.schedule),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField(
          items: [
            'Ensoleillé',
            'Pluie',
            'Brouillard',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (_) {},
          decoration: const InputDecoration(labelText: 'Météo'),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'État de la route et luminosité',
          ),
        ),
      ],
    ),
    1 => Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: type,
          items: [
            'Collision',
            'Sortie de route',
            'Piéton',
            'Accident matériel',
            'Autre',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => type = v!),
          decoration: const InputDecoration(labelText: "Type d'accident"),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: severity,
          items: [
            'Matériel',
            'Léger',
            'Grave',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => severity = v!),
          decoration: const InputDecoration(labelText: 'Gravité'),
        ),
        SwitchListTile(
          value: injured,
          onChanged: (v) => setState(() => injured = v),
          title: const Text('Il y a des blessés'),
        ),
        if (injured)
          const Card(
            color: Color(0xFFFFE2E2),
            child: ListTile(
              title: Text(
                'Urgences : SAMU 190 • Police 197 • Protection civile 198',
              ),
            ),
          ),
        const TextField(
          decoration: InputDecoration(labelText: 'Témoin : nom et téléphone'),
        ),
      ],
    ),
    2 => Column(
      children: <Widget>[
        ...[
          'Vue d’ensemble',
          'Dégâts véhicule A',
          'Dégâts véhicule B',
          'Plaques',
        ].map(
          (e) => Card(
            child: ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(e),
              trailing: const Icon(Icons.add_circle_outline),
            ),
          ),
        ),
        const ListTile(
          leading: Icon(Icons.videocam),
          title: Text('Vidéo de la scène (max. 30 s)'),
        ),
        const ListTile(leading: Icon(Icons.mic), title: Text('Note vocale')),
      ],
    ),
    3 => Column(
      children: [
        const Card(
          child: ListTile(
            leading: Icon(Icons.screen_lock_portrait),
            title: Text('Mode invité isolé'),
            subtitle: Text(
              'Le conducteur B ne peut pas consulter vos données.',
            ),
          ),
        ),
        TextField(
          controller: guest,
          decoration: const InputDecoration(labelText: 'Nom du conducteur B'),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Permis / véhicule / assurance',
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Rejoindre par QR code'),
        ),
      ],
    ),
    4 => Column(
      children: [
        for (final e in [
          'En stationnement',
          'Quittait un stationnement',
          'Changeait de file',
          'Doublait',
          'Virait à droite',
          'Virait à gauche',
          'Reculait',
        ])
          CheckboxListTile(value: false, onChanged: (_) {}, title: Text(e)),
        TextField(
          controller: observations,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Observations'),
        ),
      ],
    ),
    5 => Column(
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gesture, size: 60),
                Text('Zone de croquis tactile'),
                Text('Dessinez les véhicules, voies et panneaux'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: ['Avant', 'Arrière', 'Côté gauche', 'Côté droit']
              .map(
                (e) => FilterChip(
                  label: Text(e),
                  selected: false,
                  onSelected: (_) {},
                ),
              )
              .toList(),
        ),
      ],
    ),
    _ => const Column(
      children: [
        Text('Relisez les informations puis signez dans les deux zones.'),
        SizedBox(height: 16),
        SignatureBox('Signature conducteur A'),
        SizedBox(height: 14),
        SignatureBox('Signature conducteur B'),
        SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: Icon(Icons.lock),
            title: Text('Verrouillage SHA-256'),
            subtitle: Text(
              'Le constat sera rendu infalsifiable après la double signature.',
            ),
          ),
        ),
      ],
    ),
  };
  void _next() {
    if (step < steps.length - 1) {
      setState(() => step++);
      return;
    }
    final s = StoreScope.of(context);
    final c = Claim(
      id: 'SIN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      type: type,
      place: place.text,
      date: DateTime.now().toString().substring(0, 16),
      severity: severity,
      status: 'Transmis',
    );
    c.timeline.addAll([
      'Double signature',
      'PDF verrouillé',
      'Transmis aux assureurs',
    ]);
    s.addClaim(c);
    Navigator.pop(context);
  }
}

class SignatureBox extends StatelessWidget {
  const SignatureBox(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    height: 130,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Center(
      child: Text('$label\nSignez ici', textAlign: TextAlign.center),
    ),
  );
}

class AgentDashboard extends StatelessWidget {
  const AgentDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const PageHead("Espace agent", subtitle: 'Instruction des sinistres'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metric('À traiter', '${s.claims.length}', Colors.orange),
              _metric('En expertise', '3', Colors.blue),
              _metric('Clôturés', '18', Colors.green),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Dossiers prioritaires',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...s.claims.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => open(context, ClaimDetail(c, agentMode: true)),
                child: ClaimCard(c),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String t, String v, Color c) => SizedBox(
    width: 110,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(
              v,
              style: TextStyle(
                fontSize: 28,
                color: c,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(t, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const PageHead(
          'Administration',
          subtitle: 'Vue globale de la plateforme',
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.35,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: const [
            Stat('Accidents', '248', '+12 %', Icons.car_crash),
            Stat('Ouverts', '41', '16,5 %', Icons.folder_open),
            Stat('Clôturés', '207', '83,5 %', Icons.check_circle),
            Stat('Délai moyen', '3,4 j', '-0,6 j', Icons.timer),
          ],
        ),
        const SizedBox(height: 20),
        const Card(
          child: SizedBox(
            height: 190,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 60, color: Colors.blue),
                  Text('Carte des zones à forte accidentalité'),
                  Text('Tunis • Ariana • Ben Arous'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            title: Text('Répartition par gravité'),
            subtitle: LinearProgressIndicator(value: .68),
            trailing: Text('68 % matériel'),
          ),
        ),
      ],
    ),
  );
}

class Stat extends StatelessWidget {
  const Stat(this.t, this.v, this.d, this.i, {super.key});
  final String t, v, d;
  final IconData i;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(i, color: Colors.blue),
          Text(
            v,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          Text(t),
          Text(d, style: const TextStyle(color: Colors.green)),
        ],
      ),
    ),
  );
}

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return SafeArea(
      child: Column(
        children: [
          const PageHead(
            'Gestion des comptes',
            subtitle: 'Rôles, agents et suspensions',
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: s.users.length,
              itemBuilder: (_, i) {
                final u = s.users[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(u.name[0])),
                    title: Text(u.name),
                    subtitle: Text('${u.email}\n${u.role.label}'),
                    isThreeLine: true,
                    trailing: Switch(
                      value: u.active,
                      onChanged: (_) => s.toggleUser(u),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const PageHead(
          "Compagnies d'assurance",
          subtitle: 'Compagnies et agences',
        ),
        for (final e in [
          'STAR Assurances • 18 agences',
          'COMAR • 12 agences',
          'GAT Assurances • 15 agences',
        ])
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.business)),
              title: Text(e),
              trailing: const Icon(Icons.edit_outlined),
            ),
          ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Ajouter une compagnie'),
        ),
      ],
    ),
  );
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: s.notifications.length,
        itemBuilder: (_, i) => ListTile(
          leading: const CircleAvatar(child: Icon(Icons.notifications)),
          title: Text(s.notifications[i]),
          subtitle: const Text('Maintenant'),
          trailing: const Icon(Icons.circle, size: 10, color: Colors.blue),
        ),
      ),
    );
  }
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Alertes d’échéance')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.warning, color: Colors.orange),
            title: Text('Assurance expire dans 7 jours'),
            subtitle: Text('Peugeot 208 • POL-884521'),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.build),
            title: Text('Visite technique dans 30 jours'),
          ),
        ),
      ],
    ),
  );
}

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Numéros d’urgence')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: CircleAvatar(child: Text('190')),
          title: Text('SAMU'),
          trailing: Icon(Icons.call),
        ),
        ListTile(
          leading: CircleAvatar(child: Text('197')),
          title: Text('Police'),
          trailing: Icon(Icons.call),
        ),
        ListTile(
          leading: CircleAvatar(child: Text('198')),
          title: Text('Protection civile'),
          trailing: Icon(Icons.call),
        ),
      ],
    ),
  );
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Assistance')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ExpansionTile(
          title: Text('Comment remplir un constat ?'),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Suivez les sept étapes guidées. Chaque étape est sauvegardée localement.',
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('Puis-je travailler hors ligne ?'),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Oui. Le dossier sera synchronisé dès le retour du réseau.',
              ),
            ),
          ],
        ),
        ListTile(
          leading: Icon(Icons.support_agent),
          title: Text('Contacter le support'),
        ),
      ],
    ),
  );
}
