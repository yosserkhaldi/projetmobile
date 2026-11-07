import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_theme.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/modules/users/state/user_store.dart';
import 'package:mon_constat_digital/modules/users/widgets/form_widgets.dart';
import 'package:mon_constat_digital/modules/users/widgets/user_photo.dart';

/// Envoi de la CIN (recto, verso, numéro) pour vérification.
class IdentityScreen extends StatefulWidget {
  const IdentityScreen({super.key});

  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> with FormActions {
  late final _cin = TextEditingController(
    text: AppScope.of(context).users.currentUser?.identity.cinNumber ?? '',
  );

  @override
  void dispose() {
    _cin.dispose();
    super.dispose();
  }

  void _submit(Identity identity) {
    final t = context.t;
    if (identity.frontId == null || identity.backId == null) {
      setState(() => error = t.identityPhotosRequired);
      return;
    }
    final users = AppScope.of(context).users;
    final messenger = ScaffoldMessenger.of(context);
    submit(() async {
      await users.submitIdentity(_cin.text.trim());
      messenger.showSnackBar(SnackBar(content: Text(t.identitySent)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final user = AppScope.of(context).users.currentUser;
    if (user == null) return const SizedBox.shrink();
    final identity = user.identity;
    return Scaffold(
      appBar: AppBar(title: Text(t.identityTitle)),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              IdentityStatusBanner(identity: identity),
              const SizedBox(height: 16),
              Text(
                t.identityIntro,
                style: TextStyle(
                  color: context.palette.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              if (error != null) ...[
                ErrorBanner(error!),
                const SizedBox(height: 14),
              ],
              LabeledField(
                label: t.cinNumberLabel,
                controller: _cin,
                readOnly: !identity.editable,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                validator: (v) => RegExp(r'^\d{8}$').hasMatch((v ?? '').trim())
                    ? null
                    : t.cinInvalid,
                style: const TextStyle(
                  fontFamily: AppFonts.mono,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _CinPhoto(
                      user: user,
                      photo: UserPhoto.cinFront,
                      label: t.cinFront,
                      editable: identity.editable,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CinPhoto(
                      user: user,
                      photo: UserPhoto.cinBack,
                      label: t.cinBack,
                      editable: identity.editable,
                    ),
                  ),
                ],
              ),
              if (identity.editable) ...[
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
        t.identityVerifiedNote,
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
        Icons.gpp_bad_outlined,
        t.identityStatusRejected,
        t.identityRejectedReason(identity.rejectionReason ?? ''),
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

class _CinPhoto extends StatelessWidget {
  const _CinPhoto({
    required this.user,
    required this.photo,
    required this.label,
    required this.editable,
  });

  final AppUser user;
  final UserPhoto photo;
  final String label;
  final bool editable;

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
                    changePhoto(context, photo);
                  }
                : null,
            borderRadius: BorderRadius.circular(AppRadius.input),
            child: AspectRatio(
              // Format d'une carte bancaire, comme la CIN.
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
