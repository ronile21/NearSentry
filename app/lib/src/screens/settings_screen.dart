import 'package:flutter/material.dart';

import '../controllers/protection_controller.dart';
import '../models/sentry_models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});

  final ProtectionController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int grace;
  late int retention;
  late bool sound;
  late bool vibration;
  late bool watchService;
  late bool simulation;

  @override
  void initState() {
    super.initState();
    final settings = widget.controller.settings;
    grace = settings.graceSeconds;
    retention = settings.telemetryRetention;
    sound = settings.soundEnabled;
    vibration = settings.vibrationEnabled;
    watchService = settings.watchServiceEnabled;
    simulation = settings.simulationMode;
  }

  Future<void> _save() async {
    await widget.controller.saveSettings(
      AppSettings(
        onboardingComplete: true,
        graceSeconds: grace.clamp(1, 15),
        soundEnabled: sound,
        vibrationEnabled: vibration,
        watchServiceEnabled: watchService,
        telemetryRetention: retention.clamp(50, 1000),
        simulationMode: simulation,
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Protection', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Text('Grace interval: $grace seconds'),
        Slider(
          value: grace.toDouble(),
          min: 1,
          max: 15,
          divisions: 14,
          label: '$grace s',
          onChanged: (value) => setState(() => grace = value.round()),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: sound,
          onChanged: (value) => setState(() => sound = value),
          title: const Text('Alarm sound'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: vibration,
          onChanged: (value) => setState(() => vibration = value),
          title: const Text('Alarm vibration'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: watchService,
          onChanged: (value) => setState(() => watchService = value),
          title: const Text('Garmin watch background service'),
          subtitle: const Text(
            'Keeps NearSentry registered for Garmin background events. '
            'Garmin does not allow continuous 1-second polling while the '
            'watch app is not in the foreground.',
          ),
        ),
        const Divider(height: 32),
        Text('Diagnostics', style: Theme.of(context).textTheme.titleLarge),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: simulation,
          onChanged: (value) => setState(() => simulation = value),
          title: const Text('Developer simulation mode'),
          subtitle: const Text(
            'Clearly separates simulated anchor events from real Garmin monitoring.',
          ),
        ),
        Text('Telemetry retention: $retention events'),
        Slider(
          value: retention.toDouble(),
          min: 50,
          max: 1000,
          divisions: 19,
          onChanged: (value) => setState(() => retention = value.round()),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _save, child: const Text('Save settings')),
        const SizedBox(height: 24),
        const Text('NearSentry v0.0.0.1'),
      ],
    );
  }
}
