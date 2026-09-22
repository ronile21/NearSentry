import 'package:flutter/material.dart';
import 'package:nearsentry_domain/nearsentry_domain.dart';

class ProtectionStatusCard extends StatelessWidget {
  const ProtectionStatusCard({
    super.key,
    required this.state,
    required this.message,
    required this.anchorName,
    this.graceRemainingMs,
  });

  final ProtectionState state;
  final String message;
  final String? anchorName;
  final int? graceRemainingMs;

  IconData get _icon => switch (state) {
        ProtectionState.disarmed => Icons.shield_outlined,
        ProtectionState.arming => Icons.sync,
        ProtectionState.protected => Icons.verified_user,
        ProtectionState.grace => Icons.timer_outlined,
        ProtectionState.alarm => Icons.notification_important,
        ProtectionState.degraded => Icons.warning_amber,
      };

  String get _title => switch (state) {
        ProtectionState.disarmed => 'Protection off',
        ProtectionState.arming => 'Arming…',
        ProtectionState.protected => 'Protected',
        ProtectionState.grace => 'Device separation detected',
        ProtectionState.alarm => 'ALARM',
        ProtectionState.degraded => 'Protection degraded',
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final critical =
        state == ProtectionState.alarm || state == ProtectionState.degraded;
    final warning = state == ProtectionState.grace;

    final background = critical
        ? scheme.errorContainer
        : warning
            ? scheme.tertiaryContainer
            : scheme.primaryContainer;
    final foreground = critical
        ? scheme.onErrorContainer
        : warning
            ? scheme.onTertiaryContainer
            : scheme.onPrimaryContainer;

    return Semantics(
      label: 'Protection status: $_title',
      child: Card(
        color: background,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon, size: 42, color: foreground),
              const SizedBox(height: 20),
              Text(
                _title,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(message, style: TextStyle(color: foreground)),
              if (anchorName != null) ...[
                const SizedBox(height: 12),
                Text('Trusted device: $anchorName',
                    style: TextStyle(color: foreground)),
              ],
              if (state == ProtectionState.grace &&
                  graceRemainingMs != null) ...[
                const SizedBox(height: 20),
                Text(
                  '${(graceRemainingMs! / 1000).clamp(0, 99).toStringAsFixed(1)} s',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
