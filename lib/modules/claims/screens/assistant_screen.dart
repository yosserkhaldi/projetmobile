import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_palette.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_insight.dart';
import 'package:mon_constat_digital/modules/users/models/app_user.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';

typedef AskAssistant =
    Future<AiAnswer> Function(List<({String role, String content})> messages);

/// Questions sur un dossier. L'assistant lit, il ne modifie rien.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen(this.claim, {this.ask, super.key});
  final Claim claim;

  /// Remplace l'appel au serveur dans les tests.
  final AskAssistant? ask;

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final input = TextEditingController();
  final turns = <({String role, String content, String? by})>[];
  bool waiting = false;

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final question = text.trim();
    if (question.isEmpty || waiting) return;
    final stores = AppScope.of(context);
    final sync = stores.claimsSync;
    final unavailable = context.t.claimsAssistantUnavailable;
    setState(() {
      turns.add((role: 'user', content: question, by: null));
      waiting = true;
    });
    input.clear();
    final history = [
      for (final turn in turns) (role: turn.role, content: turn.content),
    ];
    try {
      final ask = widget.ask;
      final AiAnswer answer;
      if (ask != null) {
        answer = await ask(history);
      } else if (sync != null) {
        answer = await sync.api.askAssistant(widget.claim.id, history);
      } else {
        throw StateError('Application locale');
      }
      _add(answer.text, answer.by);
    } catch (_) {
      _add(unavailable, null);
    }
  }

  void _add(String text, String? by) {
    if (!mounted) return;
    setState(() {
      waiting = false;
      turns.add((role: 'assistant', content: text, by: by));
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final role = AppScope.of(context).users.role;
    final ideas = role == UserRole.driver
        ? [t.claimsDriverIdea1, t.claimsDriverIdea2, t.claimsDriverIdea3]
        : [t.claimsAgentIdea1, t.claimsAgentIdea2, t.claimsAgentIdea3];
    return Scaffold(
      appBar: AppBar(title: Text(t.claimsAssistantTitle(widget.claim.id))),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (turns.isEmpty) ...[
                    Text(
                      t.claimsAssistantIntro,
                      style: TextStyle(color: context.palette.textMuted),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final idea in ideas)
                          ActionChip(
                            label: Text(idea),
                            onPressed: () => _send(idea),
                          ),
                      ],
                    ),
                  ],
                  for (final turn in turns) _Turn(turn),
                  if (waiting)
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        t.claimsAssistantReading,
                        style: TextStyle(color: context.palette.textMuted),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      onSubmitted: _send,
                      decoration: InputDecoration(
                        hintText: t.claimsYourQuestion,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: t.claimsSend,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: context.palette.text,
                    ),
                    onPressed: () => _send(input.text),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Turn extends StatelessWidget {
  const _Turn(this.turn);
  final ({String role, String content, String? by}) turn;

  @override
  Widget build(BuildContext context) {
    final mine = turn.role == 'user';
    // Directionnel : en arabe, mes messages passent à gauche.
    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : context.palette.surface,
          border: mine ? null : Border.all(color: context.palette.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              turn.content,
              style: TextStyle(
                color: mine ? Colors.white : context.palette.text,
              ),
            ),
            if (!mine) ...[
              const SizedBox(height: 4),
              Text(
                turn.by ?? context.t.claimsAutomaticAnswer,
                style: TextStyle(
                  fontSize: 11,
                  color: context.palette.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
