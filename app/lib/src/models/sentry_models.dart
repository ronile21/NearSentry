import 'package:nearsentry_domain/nearsentry_domain.dart';

ProtectionState protectionStateFromWire(Object? value) {
  final name = value?.toString().toLowerCase();
  return ProtectionState.values.firstWhere(
    (state) => state.name == name,
    orElse: () => ProtectionState.degraded,
  );
}

class Prerequisite {
  const Prerequisite({
    required this.id,
    required this.label,
    required this.ready,
    required this.required,
    required this.detail,
  });

  final String id;
  final String label;
  final bool ready;
  final bool required;
  final String detail;

  factory Prerequisite.fromMap(Map<Object?, Object?> map) {
    return Prerequisite(
      id: map['id']?.toString() ?? 'unknown',
      label: map['label']?.toString() ?? 'Unknown',
      ready: map['ready'] == true,
      required: map['required'] != false,
      detail: map['detail']?.toString() ?? '',
    );
  }
}

class SentrySnapshot {
  const SentrySnapshot({
    required this.state,
    required this.serviceHealthy,
    required this.anchorName,
    required this.anchorStatus,
    required this.simulationMode,
    required this.runtimeGeneration,
    required this.watchAppStatus,
    required this.watchLastCommand,
    required this.message,
    required this.graceRemainingMs,
    required this.prerequisites,
  });

  final ProtectionState state;
  final bool serviceHealthy;
  final String? anchorName;
  final String anchorStatus;
  final bool simulationMode;
  final int runtimeGeneration;
  final String watchAppStatus;
  final String watchLastCommand;
  final String message;
  final int? graceRemainingMs;
  final List<Prerequisite> prerequisites;

  bool get requiredPrerequisitesReady =>
      prerequisites.where((item) => item.required).every((item) => item.ready);

  factory SentrySnapshot.empty() => const SentrySnapshot(
        state: ProtectionState.disarmed,
        serviceHealthy: false,
        anchorName: null,
        anchorStatus: 'unknown',
        simulationMode: false,
        runtimeGeneration: 0,
        watchAppStatus: 'not_checked',
        watchLastCommand: 'none',
        message: 'Initializing protection runtime…',
        graceRemainingMs: null,
        prerequisites: <Prerequisite>[],
      );

  factory SentrySnapshot.fromMap(Map<Object?, Object?> map) {
    final rawPrerequisites = map['prerequisites'];
    return SentrySnapshot(
      state: protectionStateFromWire(map['state']),
      serviceHealthy: map['serviceHealthy'] == true,
      anchorName: map['anchorName']?.toString(),
      anchorStatus: map['anchorStatus']?.toString() ?? 'unknown',
      simulationMode: map['simulationMode'] == true,
      runtimeGeneration: (map['runtimeGeneration'] as num?)?.toInt() ?? 0,
      watchAppStatus: map['watchAppStatus']?.toString() ?? 'not_checked',
      watchLastCommand: map['watchLastCommand']?.toString() ?? 'none',
      message: map['message']?.toString() ?? '',
      graceRemainingMs: (map['graceRemainingMs'] as num?)?.toInt(),
      prerequisites: rawPrerequisites is List
          ? rawPrerequisites
              .whereType<Map>()
              .map((item) => Prerequisite.fromMap(item))
              .toList(growable: false)
          : const <Prerequisite>[],
    );
  }
}

class TelemetryEntry {
  const TelemetryEntry({
    required this.id,
    required this.wallTime,
    required this.previous,
    required this.current,
    required this.trigger,
    required this.source,
    required this.detail,
    this.rssi,
  });

  final String id;
  final DateTime wallTime;
  final String previous;
  final String current;
  final String trigger;
  final String source;
  final String detail;
  final int? rssi;

  factory TelemetryEntry.fromMap(Map<Object?, Object?> map) {
    return TelemetryEntry(
      id: map['eventId']?.toString() ?? '',
      wallTime: DateTime.tryParse(map['wallTimestamp']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      previous: map['previousState']?.toString() ?? 'unknown',
      current: map['nextState']?.toString() ?? 'unknown',
      trigger: map['trigger']?.toString() ?? 'unknown',
      source: map['source']?.toString() ?? 'unknown',
      detail: map['detail']?.toString() ?? '',
      rssi: (map['rssi'] as num?)?.toInt(),
    );
  }
}

class TrustedAnchor {
  const TrustedAnchor({
    required this.id,
    required this.name,
    required this.status,
  });

  final String id;
  final String name;
  final String status;

  factory TrustedAnchor.fromMap(Map<Object?, Object?> map) {
    return TrustedAnchor(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Garmin device',
      status: map['status']?.toString() ?? 'unknown',
    );
  }
}

class AppSettings {
  const AppSettings({
    required this.onboardingComplete,
    required this.graceSeconds,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.telemetryRetention,
    required this.simulationMode,
  });

  final bool onboardingComplete;
  final int graceSeconds;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final int telemetryRetention;
  final bool simulationMode;

  factory AppSettings.defaults() => const AppSettings(
        onboardingComplete: false,
        graceSeconds: 3,
        soundEnabled: true,
        vibrationEnabled: true,
        telemetryRetention: 250,
        simulationMode: false,
      );

  factory AppSettings.fromMap(Map<Object?, Object?> map) {
    return AppSettings(
      onboardingComplete: map['onboardingComplete'] == true,
      graceSeconds: (map['graceSeconds'] as num?)?.toInt() ?? 3,
      soundEnabled: map['soundEnabled'] != false,
      vibrationEnabled: map['vibrationEnabled'] != false,
      telemetryRetention:
          (map['telemetryRetention'] as num?)?.toInt() ?? 250,
      simulationMode: map['simulationMode'] == true,
    );
  }

  Map<String, Object> toMap() => <String, Object>{
        'onboardingComplete': onboardingComplete,
        'graceSeconds': graceSeconds,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        'telemetryRetention': telemetryRetention,
        'simulationMode': simulationMode,
      };
}
