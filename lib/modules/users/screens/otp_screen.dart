import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';

/// Vérifie le téléphone. Le code part à l'inscription, ou ici avec [sendOnOpen].
class OtpScreen extends StatefulWidget {
  const OtpScreen({this.sendOnOpen = false, super.key});

  /// Depuis le profil, aucun code n'a encore été envoyé pour cette ouverture.
  final bool sendOnOpen;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with FormActions {
  static const _cooldown = 60;

  final _code = TextEditingController();
  Timer? _timer;
  int _wait = 0;

  @override
  void initState() {
    super.initState();
    if (widget.sendOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _resend());
    } else {
      _startCooldown();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _wait = _cooldown);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _wait -= 1);
      if (_wait <= 0) timer.cancel();
    });
  }

  Future<void> _resend() async {
    final users = AppScope.of(context).users;
    setState(() => error = null);
    try {
      await users.resendPhoneCode();
      if (mounted) _startCooldown();
    } catch (e) {
      if (mounted) setState(() => error = errorMessage(context, e));
    }
  }

  void _verify() {
    final users = AppScope.of(context).users;
    final navigator = Navigator.of(context);
    submit(() async {
      await users.verifyPhone(_code.text.trim());
      navigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final phone = AppScope.of(context).users.currentUser?.phone ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(t.otpTitle)),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                // Numéro isolé pour qu'il reste lisible en arabe.
                t.otpInstructions(ltr(phone)),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: context.palette.textMuted,
                ),
              ),
              const SizedBox(height: 18),
              if (error != null) ...[
                ErrorBanner(error!),
                const SizedBox(height: 14),
              ],
              LabeledField(
                label: t.otpCodeLabel,
                controller: _code,
                keyboardType: TextInputType.number,
                validator: validators.code,
                textDirection: TextDirection.ltr,
                autofillHints: const [AutofillHints.oneTimeCode],
                style: const TextStyle(
                  fontFamily: AppFonts.mono,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 18),
              BusyButton(label: t.validate, busy: busy, onPressed: _verify),
              const SizedBox(height: 6),
              TextButton(
                onPressed: _wait > 0 ? null : _resend,
                child: Text(_wait > 0 ? t.resendCodeIn(_wait) : t.resendCode),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t.later),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
