import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';
import 'package:mon_constat_digital/modules/claims/screens/assistant_screen.dart';
import 'package:mon_constat_digital/modules/claims/screens/chat_screen.dart';
import 'package:mon_constat_digital/modules/claims/widgets/agent_panel.dart';
import 'package:mon_constat_digital/modules/claims/widgets/analysis_card.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_card.dart';
import 'package:mon_constat_digital/modules/claims/widgets/claim_timeline.dart';
import 'package:mon_constat_digital/modules/claims/widgets/document_picker.dart';
import 'package:mon_constat_digital/modules/claims/widgets/expertise_card.dart';
import 'package:mon_constat_digital/modules/claims/widgets/motion.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/shared/navigation.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';

class ClaimDetail extends StatefulWidget {
  const ClaimDetail(
    this.claim, {
    this.agentMode = false,
    this.focusExpertise = false,
    super.key,
  });
  final Claim claim;
  final bool agentMode;

  /// Ouvre l'écran sur le rendez-vous d'expertise : on y arrive depuis
  /// l'alerte « autre créneau proposé ».
  final bool focusExpertise;

  @override
  State<ClaimDetail> createState() => _ClaimDetailState();
}

class _ClaimDetailState extends State<ClaimDetail> {
  final _scaffold = GlobalKey<ScaffoldState>();
  final _helpButton = GlobalKey();
  final _body = GlobalKey();
  final _expertise = GlobalKey();

  /// Le guide réapparaît à chaque ouverture du dossier, jusqu'à la croix.
  bool _showGuide = true;

  /// Centre de l'icône d'aide, dans le repère du corps de l'écran.
  double? _helpX;

  Claim get claim => widget.claim;
  bool get agentMode => widget.agentMode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.focusExpertise && _expertise.currentContext != null) {
        Scrollable.ensureVisible(
          _expertise.currentContext!,
          alignment: .05,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _locateHelp() {
    final icon = _helpButton.currentContext?.findRenderObject() as RenderBox?;
    final body = _body.currentContext?.findRenderObject() as RenderBox?;
    if (icon == null || body == null || !icon.attached || !body.attached) {
      return;
    }
    final center = icon.localToGlobal(icon.size.center(Offset.zero));
    final x = body.globalToLocal(center).dx;
    if (x != _helpX) setState(() => _helpX = x);
  }

  void _openHelp() {
    setState(() => _showGuide = false);
    _scaffold.currentState?.openEndDrawer();
  }

  Future<void> _upload(BuildContext context, {DocumentRequest? request}) async {
    final store = AppScope.of(context).claims;
    final file = await pickDocument();
    if (file == null) return;
    store.addDocument(
      claim,
      file.name,
      path: file.path,
      bytes: file.bytes,
      request: request,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final stores = AppScope.of(context);
    final online = stores.claimsSync != null;
    final insight = stores.claims.insightFor(claim.id);
    final help = agentMode && insight != null && insight.isForAgent;
    final requests = claim.openRequests.toList();
    final reports = claim.documents
        .where((d) => d.kind == ClaimDocument.expertReport)
        .toList();
    final files = claim.documents
        .where((d) => d.kind != ClaimDocument.expertReport)
        .toList();
    // L'icône peut bouger (analyse arrivée après coup, rotation) : la bulle
    // se recale après chaque image.
    if (help && _showGuide) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _locateHelp();
      });
    }
    return ClaimsStyle(
      child: Scaffold(
        key: _scaffold,
        appBar: AppBar(
          title: Text(claim.id),
          actions: [
            if (help)
              IconButton(
                key: _helpButton,
                tooltip: t.claimsDecisionHelp,
                onPressed: _openHelp,
                icon: const Icon(Icons.auto_awesome_outlined),
              ),
            if (online)
              IconButton(
                tooltip: t.claimsAssistant,
                onPressed: () => open(context, AssistantScreen(claim)),
                icon: const Icon(Icons.support_agent),
              ),
            IconButton(
              tooltip: t.claimsMessaging,
              onPressed: () => open(context, ChatScreen(claim)),
              icon: const Icon(Icons.chat_outlined),
            ),
          ],
        ),
        // Le panneau glisse depuis le bord de fin (la droite en français).
        endDrawer: help
            ? _HelpDrawer(child: AnalysisCard(claim, insight, titled: false))
            : null,
        body: Stack(
          key: _body,
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                ClaimCard(claim),
                if (insight?.headline != null && !agentMode) ...[
                  const SizedBox(height: 12),
                  GuidanceCard(insight!, status: claim.status),
                ],
                if (claim.status == ClaimStatus.closed ||
                    claim.status == ClaimStatus.rejected) ...[
                  const SizedBox(height: 12),
                  _DecisionSummary(claim),
                  if (!agentMode)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: () => open(context, ChatScreen(claim)),
                        icon: const Icon(Icons.forum_outlined),
                        label: Text(t.claimsQuestionOnDecision),
                      ),
                    ),
                ],
                if (requests.isNotEmpty) ...[
                  _Title(t.claimsRequestedDocuments),
                  ...requests.map(
                    (request) => Card(
                      color: context.palette.warningBg,
                      child: ListTile(
                        leading: Icon(
                          Icons.priority_high,
                          color: context.palette.warningText,
                        ),
                        title: Text(t.claimValue(request.label)),
                        subtitle: request.note.isEmpty
                            ? null
                            : Text(request.note),
                        trailing: agentMode
                            ? null
                            : TextButton(
                                onPressed: () =>
                                    _upload(context, request: request),
                                child: Text(t.claimsUpload),
                              ),
                      ),
                    ),
                  ),
                ],
                if (claim.expertName != null) ...[
                  _Title(t.claimsExpertiseTitle),
                  ExpertiseCard(
                    claim,
                    key: _expertise,
                    role: agentMode ? UserRole.agent : UserRole.driver,
                  ),
                ],
                _Title(t.claimsTimeline),
                ClaimTimeline(claim),
                _Title(t.claimsConstat),
                _ConstatSummary(claim),
                _Title(t.claimsDocuments),
                // Les pièces en bande horizontale : une ligne, quel que soit
                // leur nombre.
                if (files.isNotEmpty)
                  XStrip(
                    children: [
                      for (final document in files)
                        _DocumentTile(document, online: online),
                    ],
                  ),
                if (files.isEmpty && agentMode)
                  Text(
                    t.claimsNoDocument,
                    style: TextStyle(color: context.palette.textMuted),
                  ),
                if (!ClaimStatus.isFinal(claim.status) && !agentMode) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _upload(context),
                    icon: const Icon(Icons.upload_file),
                    label: Text(t.claimsUploadDocument),
                  ),
                ],
                // Le rapport de l'expert vient après les pièces du dossier.
                if (reports.isNotEmpty ||
                    (claim.status == ClaimStatus.expertise && !agentMode)) ...[
                  _Title(t.claimValue(ClaimDocument.expertReport)),
                  _ReportSection(reports, online: online),
                ],
                if (agentMode) ...[_Title(t.claimsHandling), AgentPanel(claim)],
              ],
            ),
            if (help && _showGuide && _helpX != null)
              _Guide(
                arrowX: _helpX!,
                text: t.claimsDecisionHelpGuide,
                onClose: () => setState(() => _showGuide = false),
                onTap: _openHelp,
              ),
          ],
        ),
      ),
    );
  }
}

/// Panneau latéral de l'aide à la décision.
class _HelpDrawer extends StatelessWidget {
  const _HelpDrawer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final p = context.palette;
    return Drawer(
      width: width < 480 ? width * .92 : 440,
      backgroundColor: p.canvas,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 4, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 18,
                    color: p.primaryText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.t.claimsDecisionHelp,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const CloseButton(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bulle d'aide sous l'icône, avec une flèche qui la désigne.
class _Guide extends StatelessWidget {
  const _Guide({
    required this.arrowX,
    required this.text,
    required this.onClose,
    required this.onTap,
  });
  final double arrowX;
  final String text;
  final VoidCallback onClose, onTap;

  static const _width = 264.0;
  static const _arrow = 8.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final screen = MediaQuery.sizeOf(context).width;
    final left = (arrowX - _width + 28).clamp(12.0, screen - _width - 12);
    final arrowLeft = (arrowX - left - _arrow).clamp(12.0, _width - 28);
    return Positioned(
      top: 2,
      left: left,
      width: _width,
      child: Appear(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: arrowLeft),
              child: CustomPaint(
                size: const Size(_arrow * 2, _arrow),
                painter: _ArrowPainter(p.hero),
              ),
            ),
            Material(
              color: p.hero,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 4, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        visualDensity: VisualDensity.compact,
                        onPressed: onClose,
                        icon: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white.withValues(alpha: .72),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.color != color;
}

IconData _iconOf(String kind) => switch (kind) {
  ClaimDocument.photo => Icons.photo_outlined,
  ClaimDocument.video => Icons.videocam_outlined,
  ClaimDocument.voiceNote => Icons.mic_none,
  ClaimDocument.accidentReport => Icons.picture_as_pdf_outlined,
  _ => Icons.attach_file,
};

/// Le résumé de la pièce vient du modèle de langage, en français : la pièce
/// est lue en arrière-plan, sans utilisateur.
String _describe(AppLocalizations t, ClaimDocument document) {
  final analysis = document.analysis;
  if (analysis == null) return t.claimValue(document.kind);
  final amount = analysis.amount == null
      ? ''
      : ', ${analysis.amount!.round()} TND';
  final warning = analysis.matches ? '' : ' ${t.claimsDocMismatch}';
  return '${t.claimValue(analysis.type)}$amount. ${analysis.summary}$warning';
}

/// Le rapport de l'expert, à part : c'est la pièce qui décide du dossier.
/// L'expert n'utilise pas l'application ; il envoie son rapport à
/// l'assureur, et l'agent le joint au dossier.
class _ReportSection extends StatelessWidget {
  const _ReportSection(this.reports, {required this.online});
  final List<ClaimDocument> reports;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (reports.isEmpty) {
      return Text(
        t.claimsReportPending,
        style: TextStyle(color: context.palette.textMuted),
      );
    }
    final p = context.palette;
    return Appear(
      child: InkPanel(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            for (final report in reports)
              ListTile(
                leading: Icon(Icons.verified_outlined, color: p.successText),
                title: Text(report.name),
                subtitle: Text(
                  report.analysis == null
                      ? t.claimsReportReceived
                      : _describe(t, report),
                ),
                trailing: online
                    ? IconButton(
                        tooltip: t.claimsDownload,
                        onPressed: () => saveFromServer(
                          context,
                          kind: 'document',
                          id: report.id,
                          name: report.name,
                        ),
                        icon: const Icon(Icons.download, size: 20),
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

/// Une pièce : icône, nom, ce que le modèle y a lu, téléchargement.
class _DocumentTile extends StatelessWidget {
  const _DocumentTile(this.document, {required this.online});
  final ClaimDocument document;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = context.palette;
    return SizedBox(
      width: 232,
      child: InkPanel(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconOf(document.kind), size: 20, color: p.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _describe(t, document),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: p.textMuted),
                  ),
                ],
              ),
            ),
            if (online)
              IconButton(
                tooltip: t.claimsDownload,
                visualDensity: VisualDensity.compact,
                onPressed: () => saveFromServer(
                  context,
                  kind: 'document',
                  id: document.id,
                  name: document.name,
                ),
                icon: Icon(Icons.download, size: 18, color: p.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => SectionTitle(text);
}

class _DecisionSummary extends StatelessWidget {
  const _DecisionSummary(this.claim);
  final Claim claim;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final rejected = claim.status == ClaimStatus.rejected;
    final share = claim.responsibility;
    return Card(
      color: rejected ? context.palette.errorBg : context.palette.successBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rejected ? t.claimsRejectedTitle : t.claimsClosedTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (claim.decisionReason != null)
              Text(t.claimsReason(claim.decisionReason!)),
            if (share != null)
              Text(t.claimsResponsibilitySplit('$share', '${100 - share}')),
            if (claim.indemnity != null)
              Text(t.claimsIndemnity(claim.indemnity!.toStringAsFixed(3))),
          ],
        ),
      ),
    );
  }
}

class _ConstatSummary extends StatelessWidget {
  const _ConstatSummary(this.claim);
  final Claim claim;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final rows = [
      if (claim.circumstances.isNotEmpty)
        (t.claimsCircumstancesA, t.claimValues(claim.circumstances)),
      if (claim.circumstancesB.isNotEmpty)
        (t.claimsCircumstancesB, t.claimValues(claim.circumstancesB)),
      if (claim.impactZones.isNotEmpty)
        (t.claimsImpactPoint, t.claimValues(claim.impactZones)),
      if (claim.observations.isNotEmpty)
        (t.claimsObservations, claim.observations),
    ];
    if (rows.isEmpty) {
      return Text(
        t.claimsNoConstat,
        style: TextStyle(color: context.palette.textMuted),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: t.claimsLabelColon(label),
                    style: TextStyle(color: context.palette.textMuted),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
