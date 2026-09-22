import 'package:flutter/material.dart';

import '../controllers/protection_controller.dart';
import '../widgets/prerequisite_tile.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({
    super.key,
    required this.controller,
    required this.onDone,
  });

  final ProtectionController controller;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final snapshot = controller.snapshot;
    final selectedName = snapshot.anchorName;

    return Scaffold(
      appBar: AppBar(title: const Text('Protection setup')),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Permissions & runtime',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            for (final item in snapshot.prerequisites)
              PrerequisiteTile(
                item: item,
                onAction: () => controller.prerequisiteAction(item.id),
              ),
            const SizedBox(height: 24),
            Text(
              'Trusted Garmin',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (controller.anchors.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'No Garmin device is currently exposed by Garmin Connect IQ. '
                    'Open Garmin Connect, confirm the watch is connected, then refresh.',
                  ),
                ),
              )
            else
              ...controller.anchors.map(
                (anchor) {
                  final selected = selectedName == anchor.name;
                  return Card(
                    child: ListTile(
                      onTap: () => controller.enrollAnchor(anchor.id),
                      leading: Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                      ),
                      title: Text(anchor.name),
                      subtitle: Text('Status: ${anchor.status}'),
                      trailing: selected
                          ? const Icon(Icons.check_circle)
                          : const Icon(Icons.chevron_right),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry discovery'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: snapshot.requiredPrerequisitesReady &&
                      snapshot.anchorName != null
                  ? onDone
                  : null,
              child: const Text('Continue to dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
