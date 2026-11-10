import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/screens/liveness_screen.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';
import 'package:mon_constat_digital/modules/users/widgets/user_photo.dart';

/// Libellés d'une pièce : nom, numéro, faces.
extension IdentityDocumentLabels on IdentityDocument {
  String labelIn(AppLocalizations t) => switch (this) {
    IdentityDocument.cin => t.documentCin,
    IdentityDocument.license => t.documentLicense,
    IdentityDocument.passport => t.documentPassport,
  };

  String numberLabel(AppLocalizations t) => switch (this) {
    IdentityDocument.cin => t.cinNumberLabel,
    IdentityDocument.license => t.licenseNumberLabel,
    IdentityDocument.passport => t.passportNumberLabel,
  };

  String numberError(AppLocalizations t) => switch (this) {
    IdentityDocument.cin => t.cinInvalid,
    IdentityDocument.license => t.licenseNumberInvalid,
    IdentityDocument.passport => t.passportNumberInvalid,
  };

  String frontLabel(AppLocalizations t) => switch (this) {
    IdentityDocument.cin => t.cinFront,
    IdentityDocument.license => t.licenseFront,
    IdentityDocument.passport => t.passportPage,
  };

  String backLabel(AppLocalizations t) =>
      this == IdentityDocument.license ? t.licenseBack : t.cinBack;
}

/// Vérification d'identité : pièce (CIN, permis ou passeport), puis visage
/// comparé par l'IA du serveur.
class IdentityScreen extends StatefulWidget {
  const IdentityScreen({super.key});

  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> with FormActions {
  late final Identity _initial = AppScope.of(
    context,
  ).users.currentUser!.identity;
  late IdentityDocument _document = _initial.documentType;
  late final _number = TextEditingController(text: _initial.cinNumber ?? '');

  /// Dernier numéro lu par l'IA et recopié dans le champ.
  String? _prefilled;

  /// Accord explicite pour l'analyse du visage, demandé à chaque vérification.
  bool _biometricConsent = false;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  /// Le numéro lu sur une nouvelle photo remplit le champ ; l'utilisateur
  /// peut le corriger.
  void _prefill(DocumentReading? reading) {
    final number = reading?.number;
    if (number == null || number == _prefilled) return;
    _prefilled = number;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _number.text = number;
    });
  }

  void _useLicense() {
    final users = AppScope.of(context).users;
    submit(users.useLicenseForIdentity, validate: false);
  }

  Future<void> _faceCheck() async {
    final messenger = ScaffoldMessenger.of(context);
    final done = context.t.livenessSuccess;
    final ok = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const LivenessScreen()));
    if (ok == true && mounted) {
      setState(() => error = null);
      messenger.showSnackBar(SnackBar(content: Text(done)));
    }
  }

  void _submit(Identity identity) {
    final t = context.t;
    // Le numéro d'abord : l'erreur s'affiche sous le champ.
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (identity.frontId == null ||
        (_document.hasBack && identity.backId == null)) {
      setState(() => error = t.identityPhotosRequired);
      return;
    }
    if (!identity.livenessValid) {
      setState(() => error = t.faceCheckRequired);
      return;
    }
    final users = AppScope.of(context).users;
    final messenger = ScaffoldMessenger.of(context);
    submit(() async {
      await users.submitIdentity(_document, _document.normalize(_number.text));
      final verified =
          users.currentUser?.identity.status == IdentityStatus.verified;
      messenger.showSnackBar(
        SnackBar(
          content: Text(verified ? t.identityVerifiedByAi : t.identitySent),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final user = AppScope.of(context).users.currentUser;
    if (user == null) return const SizedBox.shrink();
    final identity = user.identity;
    final editable = identity.editable;
    // Lecture de la pièce actuellement choisie seulement.
    final extracted = identity.extracted;
    final reading = extracted != null && extracted.type == _document.apiValue
        ? extracted
        : null;
    if (editable) _prefill(reading);
    return Scaffold(
      appBar: AppBar(title: Text(t.identityTitle)),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            key: const Key('identity-list'),
            padding: const EdgeInsets.all(20),
            children: [
              IdentityStatusBanner(identity: identity),
              if (editable) ...[
                const SizedBox(height: 16),
                _IdentityProgress(
                  steps: [
                    // Pièce : recto, et verso sauf pour le passeport.
                    identity.frontId != null &&
                        (!_document.hasBack || identity.backId != null),
                    reading != null && !reading.isEmpty,
                    identity.livenessValid,
                    false,
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Text(
                t.identityIntro,
                style: TextStyle(color: p.textMuted, height: 1.45),
              ),
              const SizedBox(height: 18),
              if (error != null) ...[
                ErrorBanner(error!),
                const SizedBox(height: 14),
              ],
              _StepTitle(number: 1, title: t.documentTypeLabel),
              const SizedBox(height: 10),
              SegmentedButton<IdentityDocument>(
                showSelectedIcon: false,
                segments: [
                  for (final document in IdentityDocument.values)
                    ButtonSegment(
                      value: document,
                      label: Text(document.labelIn(t)),
                    ),
                ],
                selected: {_document},
                onSelectionChanged: editable
                    ? (choice) => setState(() {
                        _document = choice.first;
                        error = null;
                      })
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DocumentPhoto(
                      user: user,
                      photo: UserPhoto.cinFront,
                      label: _document.frontLabel(t),
                      editable: editable,
                      // L'IA lit le recto selon la pièce choisie.
                      fields: {'documentType': _document.apiValue},
                      busyMessage: t.readingDocument,
                    ),
                  ),
                  if (_document.hasBack) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DocumentPhoto(
                        user: user,
                        photo: UserPhoto.cinBack,
                        label: _document.backLabel(t),
                        editable: editable,
                        fields: {'documentType': _document.apiValue},
                        busyMessage: t.readingDocument,
                      ),
                    ),
                  ],
                ],
              ),
              // Permis déjà dans le profil : pas besoin de le reprendre en photo.
              if (editable &&
                  _document == IdentityDocument.license &&
                  user.licensePhotoId != null) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  key: const Key('use-license-photo'),
                  onPressed: busy ? null : _useLicense,
                  icon: const Icon(Icons.badge_outlined),
                  label: Text(t.useLicensePhoto),
                ),
              ],
              if (reading != null) ...[
                const SizedBox(height: 14),
                _ReadingCard(reading: reading),
              ],
              const SizedBox(height: 16),
              LabeledField(
                key: ValueKey(_document),
                label: _document.numberLabel(t),
                controller: _number,
                readOnly: !editable,
                keyboardType: _document == IdentityDocument.cin
                    ? TextInputType.number
                    : TextInputType.text,
                textDirection: TextDirection.ltr,
                validator: (v) =>
                    _document.numberPattern.hasMatch(
                      _document.normalize(v ?? ''),
                    )
                    ? null
                    : _document.numberError(t),
                style: const TextStyle(
                  fontFamily: AppFonts.mono,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 3,
                ),
              ),
              if (editable) ...[
                const SizedBox(height: 24),
                _StepTitle(number: 2, title: t.faceCheckTitle),
                const SizedBox(height: 10),
                _FaceCheckCard(
                  done: identity.livenessValid,
                  consent: _biometricConsent,
                  onConsent: (on) => setState(() => _biometricConsent = on),
                  onStart: _faceCheck,
                ),
                const SizedBox(height: 22),
                BusyButton(
                  label: t.submitIdentity,
                  busy: busy,
                  onPressed: () => _submit(identity),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Avancement de la demande : Pièce → Lecture → Visage → Envoi. Étape faite
/// cochée en vert, étape en cours en bleu, les suivantes en gris.
class _IdentityProgress extends StatelessWidget {
  const _IdentityProgress({required this.steps});

  /// Une valeur par étape : faite ou non.
  final List<bool> steps;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final labels = [
      t.identityStepDocument,
      t.identityStepReading,
      t.identityStepFace,
      t.identityStepSend,
    ];
    final current = steps.indexWhere((done) => !done);
    return Container(
      key: const Key('identity-progress'),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: p.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, label) in labels.indexed) ...[
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      // Trait vers l'étape précédente.
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i == 0
                              ? Colors.transparent
                              : steps[i - 1]
                              ? p.successText
                              : p.borderSoft,
                        ),
                      ),
                      _StepDot(
                        number: i + 1,
                        done: steps[i],
                        current: i == current,
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i == labels.length - 1
                              ? Colors.transparent
                              : steps[i]
                              ? p.successText
                              : p.borderSoft,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: i == current
                          ? FontWeight.w800
                          : FontWeight.w700,
                      color: steps[i]
                          ? p.successText
                          : i == current
                          ? p.primaryText
                          : p.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.number,
    required this.done,
    required this.current,
  });
  final int number;
  final bool done, current;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done
            ? p.successText
            : current
            ? p.primaryText
            : p.surfaceAlt,
      ),
      child: done
          ? Icon(Icons.check_rounded, size: 18, color: p.surface)
          : Text(
              '$number',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: current ? p.surface : p.textMuted,
              ),
            ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.number, required this.title});
  final int number;
  final String title;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.primaryTint,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: TextStyle(
              color: p.primaryText,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

/// Étape « visage » : à faire, ou faite et encore valable.
class _FaceCheckCard extends StatelessWidget {
  const _FaceCheckCard({
    required this.done,
    required this.consent,
    required this.onConsent,
    required this.onStart,
  });
  final bool done, consent;
  final ValueChanged<bool> onConsent;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: done ? p.successBg : p.surface,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: done ? p.successText : p.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done ? Icons.verified_rounded : Icons.face_retouching_natural,
            size: 36,
            color: done ? p.successText : p.primaryText,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  done ? t.faceCheckDone : t.faceCheckTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: done ? p.successText : p.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  done ? t.livenessPrivacy : t.faceCheckIntro,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: done ? p.successText : p.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                // Loi n° 2004-63 : le visage est une donnée sensible.
                // Material transparent : l'effet du toucher reste visible
                // sur le fond coloré de la carte.
                Material(
                  type: MaterialType.transparency,
                  child: CheckboxListTile(
                    key: const Key('biometric-consent'),
                    value: consent,
                    onChanged: (on) => onConsent(on ?? false),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    title: Text(
                      t.biometricConsentLabel,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: done ? p.successText : p.text,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (done)
                  TextButton.icon(
                    key: const Key('start-face-check'),
                    onPressed: consent ? onStart : null,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(t.faceCheckRedo),
                  )
                else
                  FilledButton.tonalIcon(
                    key: const Key('start-face-check'),
                    onPressed: consent ? onStart : null,
                    icon: const Icon(Icons.photo_camera_front_outlined),
                    label: Text(t.faceCheckStart),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bandeau d'état, aussi utilisé dans le profil et côté administration.
class IdentityStatusBanner extends StatelessWidget {
  const IdentityStatusBanner({required this.identity, super.key});
  final Identity identity;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final (icon, title, note, bg, fg) = switch (identity.status) {
      IdentityStatus.verified => (
        Icons.verified_user,
        t.identityStatusVerified,
        identity.autoVerified
            ? t.identityVerifiedAutoNote
            : t.identityVerifiedNote,
        p.successBg,
        p.successText,
      ),
      IdentityStatus.pending => (
        Icons.hourglass_top_rounded,
        t.identityStatusPending,
        t.identityPendingNote,
        p.primaryTint,
        p.primaryText,
      ),
      IdentityStatus.rejected => (
        identity.blocked ? Icons.block : Icons.gpp_bad_outlined,
        identity.blocked ? t.identityBlockedChip : t.identityStatusRejected,
        [
          t.identityRejectedReason(identity.rejectionReason ?? ''),
          if (identity.blocked)
            t.identityBlockedNote
          else ...[
            if (identity.waiting)
              t.identityRetryOn(
                DateFormat.yMMMd(
                  t.localeName,
                ).add_Hm().format(identity.retryAt!),
              ),
            t.identityAttemptsLeft(Identity.maxRefusals - identity.refusals),
          ],
        ].join('\n'),
        p.errorBg,
        p.errorText,
      ),
      IdentityStatus.unverified => (
        Icons.badge_outlined,
        t.identityStatusUnverified,
        null,
        p.warningBg,
        p.warningText,
      ),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w800),
                ),
                if (note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    note,
                    style: TextStyle(color: fg, fontSize: 13, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ce que l'IA a lu sur la pièce, à vérifier par l'utilisateur.
class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.reading});
  final DocumentReading reading;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    if (reading.isEmpty) {
      return Container(
        key: const Key('document-reading'),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.warningBg,
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Text(
          t.readNothing,
          style: TextStyle(color: p.warningText, height: 1.4),
        ),
      );
    }
    Widget row(String label, String? value, {bool ltr = false}) => value == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    label,
                    style: TextStyle(color: p.textMuted, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    textDirection: ltr ? TextDirection.ltr : null,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          );
    final birth = [
      reading.birthDate,
      reading.birthPlaceAr,
    ].whereType<String>().join(' · ');
    return Container(
      key: const Key('document-reading'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: p.primaryText),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.document_scanner_outlined, color: p.primaryText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.readOnCard,
                  style: TextStyle(
                    color: p.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          row(t.readNumber, reading.number, ltr: true),
          row(t.readName, reading.fullName),
          row(t.readParents, reading.parentsAr),
          row(t.readBirth, birth.isEmpty ? null : birth),
          row(t.readExpiry, reading.expiresAt),
          const SizedBox(height: 8),
          Text(
            t.readConfirm,
            style: TextStyle(color: p.textMuted, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _DocumentPhoto extends StatelessWidget {
  const _DocumentPhoto({
    required this.user,
    required this.photo,
    required this.label,
    required this.editable,
    this.fields = const {},
    this.busyMessage,
  });

  final AppUser user;
  final UserPhoto photo;
  final String label;
  final bool editable;
  final Map<String, String> fields;
  final String? busyMessage;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final hasPhoto = photo.idOf(user) != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: p.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Semantics(
          button: editable,
          label: label,
          child: InkWell(
            onTap: editable
                ? () {
                    HapticFeedback.selectionClick();
                    changePhoto(
                      context,
                      photo,
                      fields: fields,
                      busyMessage: busyMessage,
                    );
                  }
                : null,
            borderRadius: BorderRadius.circular(AppRadius.input),
            child: AspectRatio(
              // Format d'une carte bancaire, comme la CIN et le permis.
              aspectRatio: 1.58,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: hasPhoto ? p.surface : p.primaryTint,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: p.primaryText, width: 1.5),
                ),
                child: hasPhoto
                    ? UserPhotoView(
                        user: user,
                        photo: photo,
                        placeholder: const SizedBox.shrink(),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            color: p.primaryText,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.t.addPhoto,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: p.primaryText,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
