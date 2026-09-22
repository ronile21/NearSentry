import 'package:flutter/material.dart';

import '../models/sentry_models.dart';

class PrerequisiteTile extends StatelessWidget {
  const PrerequisiteTile({
    super.key,
    required this.item,
    required this.onAction,
  });

  final Prerequisite item;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      leading: CircleAvatar(
        child: Icon(item.ready ? Icons.check : Icons.priority_high),
      ),
      title: Text(item.label),
      subtitle: Text(item.detail),
      trailing: item.ready
          ? const Icon(Icons.check_circle)
          : FilledButton.tonal(
              onPressed: onAction,
              child: Text(item.required ? 'Fix' : 'Review'),
            ),
    );
  }
}
