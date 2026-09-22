import 'package:flutter/material.dart';

import '../models/sentry_models.dart';

class TelemetryTile extends StatelessWidget {
  const TelemetryTile({super.key, required this.entry});

  final TelemetryEntry entry;

  @override
  Widget build(BuildContext context) {
    final local = entry.wallTime.toLocal();
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}:${local.second.toString().padLeft(2, '0')}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: const Icon(Icons.timeline),
      title: Text('${entry.previous} → ${entry.current}'),
      subtitle: Text('${entry.trigger} • ${entry.source}\n${entry.detail}'),
      trailing: Text(time),
      isThreeLine: true,
    );
  }
}
