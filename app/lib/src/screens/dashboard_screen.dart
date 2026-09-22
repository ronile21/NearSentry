import 'package:flutter/material.dart';
import 'package:nearsentry_domain/nearsentry_domain.dart';

import '../controllers/protection_controller.dart';
import '../widgets/protection_status_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final ProtectionController controller;

  @override
  Widget build(BuildContext context) {
    final snapshot = controller.snapshot;
    final armed = snapshot.state != ProtectionState.disarmed;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ProtectionStatusCard(
          state: snapshot.state,
          message: snapshot.message,
          anchorName: snapshot.anchorName,
          graceRemainingMs: snapshot.graceRemainingMs,
        ),
        if (snapshot.simulationMode) ...[
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.science_outlined),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Developer simulation mode is ON. This is not verified Garmin protection.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _StatusRow(
                  label: 'Native runtime',
                  value: snapshot.serviceHealthy ? 'Healthy' : 'Unavailable',
                ),
                _StatusRow(
                  label: 'Trusted device',
                  value: snapshot.anchorName ?? 'Not configured',
                ),
                _StatusRow(
                  label: 'Anchor signal',
                  value: snapshot.anchorStatus,
                ),
                _StatusRow(
                  label: 'Runtime generation',
                  value: '#${snapshot.runtimeGeneration}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 60,
          child: snapshot.state == ProtectionState.alarm
              ? FilledButton.icon(
                  onPressed: controller.requestDismissal,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Authenticate to dismiss alarm'),
                )
              : FilledButton.icon(
                  onPressed: armed
                      ? controller.disarm
                      : snapshot.requiredPrerequisitesReady &&
                              snapshot.anchorName != null
                          ? controller.arm
                          : null,
                  icon: Icon(armed ? Icons.shield_outlined : Icons.shield),
                  label: Text(armed ? 'Disarm protection' : 'Arm NearSentry'),
                ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
