import 'package:flutter/material.dart';

import '../controllers/protection_controller.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key, required this.controller});

  final ProtectionController controller;

  @override
  Widget build(BuildContext context) {
    final snapshot = controller.snapshot;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _Row('State', snapshot.state.name),
        _Row('Service healthy', snapshot.serviceHealthy.toString()),
        _Row('Runtime generation', snapshot.runtimeGeneration.toString()),
        _Row('Anchor', snapshot.anchorName ?? 'none'),
        _Row('Anchor status', snapshot.anchorStatus),
        _Row('Watch app status', snapshot.watchAppStatus),
        _Row('Watch last command', snapshot.watchLastCommand),
        _Row('Watch last ACK', snapshot.watchLastAck),
        _Row('Simulation', snapshot.simulationMode.toString()),
        _Row('Message', snapshot.message),
        const SizedBox(height: 20),
        Text(
          'Garmin watch app',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: controller.pingWatch,
              icon: const Icon(Icons.wifi_tethering),
              label: const Text('Ping watch'),
            ),
            OutlinedButton.icon(
              onPressed: controller.testWatchAlarm,
              icon: const Icon(Icons.watch),
              label: const Text('Test watch alarm'),
            ),
            OutlinedButton.icon(
              onPressed: controller.stopWatchAlarm,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Stop watch alarm'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (controller.settings.simulationMode) ...[
          Text('Simulation controls',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final action in const <String>[
                'connected',
                'disconnected',
                'transientDisconnect',
                'recovery',
                'degraded',
                'alarm',
                'serviceRestart',
              ])
                OutlinedButton(
                  onPressed: () => controller.simulate(action),
                  child: Text(action),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 140, child: Text(label)),
              Expanded(
                child: SelectableText(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
}
