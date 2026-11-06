import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';
import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/shared/widgets/page_head.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final input = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).messages;
    final userName = AppScope.of(context).users.userName;
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
                final mine = m.author == userName;
                return Align(
                  alignment: mine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      color: mine ? AppColors.primary : Colors.white,
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
                    s.sendMessage(userName, input.text);
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
