import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_notification.dart';
import 'package:mon_constat_digital/modules/claims/screens/claim_detail_screen.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';

/// Nature d'une notification de rendez-vous d'expertise, d'après son texte
/// (le même côté serveur et côté application).
enum AppointmentAlert { confirmed, proposed }

AppointmentAlert? appointmentAlertOf(String body) {
  if (body.endsWith('rendez-vous d’expertise confirmé')) {
    return AppointmentAlert.confirmed;
  }
  if (body.endsWith('autre créneau proposé pour l’expertise') ||
      body.endsWith('rendez-vous d’expertise déplacé')) {
    return AppointmentAlert.proposed;
  }
  return null;
}

/// Fenêtre surgissante en haut de l'écran quand l'autre partie confirme le
/// rendez-vous d'expertise ou en propose un autre. Un appui ouvre le dossier
/// sur le rendez-vous, là où l'on peut répondre.
///
/// Posée au-dessus du navigateur (MaterialApp.builder) : elle apparaît quel
/// que soit l'écran ouvert.
class AppointmentAlerts extends StatefulWidget {
  const AppointmentAlerts({
    required this.navigator,
    required this.child,
    this.visibleFor = const Duration(seconds: 10),
    super.key,
  });
  final GlobalKey<NavigatorState> navigator;
  final Widget child;
  final Duration visibleFor;

  @override
  State<AppointmentAlerts> createState() => _AppointmentAlertsState();
}

class _AppointmentAlertsState extends State<AppointmentAlerts> {
  AppStores? _stores;
  final _seen = <String>{};
  ClaimNotification? _current;
  Timer? _hide;

  /// Les notifications plus anciennes datent d'avant l'ouverture : elles
  /// restent dans la liste des notifications, sans surgir.
  static const _fresh = Duration(minutes: 10);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stores = AppScope.of(context);
    if (identical(stores, _stores)) return;
    _stores?.claims.removeListener(_check);
    _stores = stores..claims.addListener(_check);
  }

  @override
  void dispose() {
    _hide?.cancel();
    _stores?.claims.removeListener(_check);
    super.dispose();
  }

  void _check() {
    final stores = _stores;
    if (stores == null || stores.users.currentUser == null) return;
    final now = DateTime.now();
    ClaimNotification? latest;
    for (final n in stores.claims.notificationsFor(stores.users.role)) {
      if (n.read || _seen.contains(n.id)) continue;
      if (appointmentAlertOf(n.body) == null) continue;
      if (now.difference(n.createdAt).abs() > _fresh) continue;
      _seen.add(n.id);
      if (latest == null || n.createdAt.isAfter(latest.createdAt)) latest = n;
    }
    if (latest == null) return;
    _hide?.cancel();
    _hide = Timer(widget.visibleFor, _dismiss);
    // Le store prévient pendant une construction : on attend l'image.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _current = latest);
    });
  }

  void _dismiss() {
    _hide?.cancel();
    if (mounted) setState(() => _current = null);
  }

  void _open(ClaimNotification notification) {
    final stores = _stores!;
    final claim = stores.claims.claimById(notification.claimId);
    stores.claims.markNotificationRead(notification);
    _dismiss();
    if (claim == null) return;
    widget.navigator.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => ClaimDetail(
          claim,
          agentMode: stores.users.role == UserRole.agent,
          focusExpertise: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, -.4),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: current == null
                  ? const SizedBox.shrink()
                  : _Banner(
                      key: ValueKey(current.id),
                      notification: current,
                      onOpen: () => _open(current),
                      onClose: _dismiss,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.notification,
    required this.onOpen,
    required this.onClose,
    super.key,
  });
  final ClaimNotification notification;
  final VoidCallback onOpen, onClose;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    final confirmed =
        appointmentAlertOf(notification.body) == AppointmentAlert.confirmed;
    final soft = Colors.white.withValues(alpha: .72);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Material(
            color: p.hero,
            elevation: 8,
            shadowColor: const Color(0x400B1626),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 4, 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        confirmed ? Icons.event_available : Icons.schedule,
                        size: 20,
                        color: confirmed
                            ? const Color(0xFF7FE0A0)
                            : AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t.claimsExpertiseTitle,
                            style: TextStyle(color: soft, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.claimNotification(notification.body),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!confirmed)
                      TextButton(
                        onPressed: onOpen,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent,
                        ),
                        child: Text(t.claimsAlertOpen),
                      ),
                    // Pas d'infobulle : la bannière vit hors du navigateur,
                    // sans calque pour l'afficher.
                    Semantics(
                      button: true,
                      label: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      child: InkResponse(
                        onTap: onClose,
                        radius: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.close, size: 16, color: soft),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
