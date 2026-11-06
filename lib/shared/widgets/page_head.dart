import 'package:flutter/material.dart';

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
