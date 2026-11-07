import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';

/// Création d'un compte agent par un administrateur.
class AgentFormScreen extends StatefulWidget {
  const AgentFormScreen({super.key});
  @override
  State<AgentFormScreen> createState() => _AgentFormScreenState();
}

class _AgentFormScreenState extends State<AgentFormScreen> with FormActions {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  String? _companyId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await AppScope.of(context).admin.loadCompanies();
      } catch (e) {
        if (mounted) setState(() => error = errorMessage(context, e));
      }
    });
  }

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _email,
      _phone,
      _password,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _create() {
    final admin = AppScope.of(context).admin;
    final navigator = Navigator.of(context);
    submit(() async {
      await admin.createAgent(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        password: _password.text,
        companyId: _companyId!,
      );
      navigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final companies = AppScope.of(context).admin.companies;
    return Scaffold(
      appBar: AppBar(title: Text(context.t.createAgentTitle)),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (error != null) ...[
                  ErrorBanner(error!),
                  const SizedBox(height: 14),
                ],
                LabeledField(
                  label: context.t.firstNameLabel,
                  controller: _firstName,
                  validator: validators.required,
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: context.t.lastNameLabel,
                  controller: _lastName,
                  validator: validators.required,
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: context.t.emailLabel,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: validators.email,
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: context.t.phoneLabel,
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  validator: validators.phone,
                ),
                const SizedBox(height: 14),
                PasswordField(
                  label: context.t.tempPasswordLabel,
                  controller: _password,
                  validator: validators.password,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _companyId,
                  decoration: InputDecoration(
                    labelText: context.t.companyLabel,
                  ),
                  validator: validators.required,
                  items: [
                    for (final company in companies)
                      DropdownMenuItem(
                        value: company.id,
                        child: Text(company.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => _companyId = value),
                ),
                const SizedBox(height: 22),
                BusyButton(
                  label: context.t.createAccountButton,
                  busy: busy,
                  onPressed: _create,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
