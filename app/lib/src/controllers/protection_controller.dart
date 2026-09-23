import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/sentry_models.dart';
import '../platform/sentry_bridge.dart';

class ProtectionController extends ChangeNotifier {
  ProtectionController({SentryBridge bridge = const SentryBridge()})
      : _bridge = bridge;

  final SentryBridge _bridge;
  StreamSubscription<Map<Object?, Object?>>? _subscription;

  SentrySnapshot snapshot = SentrySnapshot.empty();
  AppSettings settings = AppSettings.defaults();
  List<TelemetryEntry> telemetry = const <TelemetryEntry>[];
  List<TrustedAnchor> anchors = const <TrustedAnchor>[];
  bool loading = true;
  String? error;

  Future<void> initialize() async {
    loading = true;
    notifyListeners();
    try {
      settings = await _bridge.getSettings();
      snapshot = await _bridge.getSnapshot();
      telemetry = await _bridge.getTelemetry();
      anchors = await _bridge.getAvailableAnchors();
      await _subscription?.cancel();
      _subscription = _bridge.events.listen(
        _onNativeEvent,
        onError: (Object value) {
          error = 'Native event channel failed: $value';
          notifyListeners();
        },
      );
      error = null;
    } catch (exception) {
      error = 'Unable to reach the protection runtime: $exception';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    try {
      snapshot = await _bridge.getSnapshot();
      telemetry = await _bridge.getTelemetry();
      anchors = await _bridge.getAvailableAnchors();
      error = null;
    } catch (exception) {
      error = 'Refresh failed: $exception';
    }
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    settings = AppSettings(
      onboardingComplete: true,
      graceSeconds: settings.graceSeconds,
      soundEnabled: settings.soundEnabled,
      vibrationEnabled: settings.vibrationEnabled,
      watchServiceEnabled: settings.watchServiceEnabled,
      telemetryRetention: settings.telemetryRetention,
      simulationMode: settings.simulationMode,
    );
    await _bridge.updateSettings(settings);
    notifyListeners();
  }

  Future<void> saveSettings(AppSettings next) async {
    await _bridge.updateSettings(next);
    settings = next;
    await refresh();
  }

  Future<void> enrollAnchor(String id) async {
    await _bridge.enrollAnchor(id);
    await refresh();
  }

  Future<void> pingWatch() async {
    await _bridge.pingWatch();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await refresh();
  }

  Future<void> testWatchAlarm() async {
    await _bridge.testWatchAlarm();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await refresh();
  }

  Future<void> stopWatchAlarm() async {
    await _bridge.stopWatchAlarm();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await refresh();
  }

  Future<void> arm() async {
    await _bridge.arm();
    await refresh();
  }

  Future<void> disarm() async {
    await _bridge.disarm();
    await refresh();
  }

  Future<void> requestDismissal() async {
    final dismissed = await _bridge.requestAuthenticatedDismissal();
    if (dismissed) {
      await refresh();
    }
  }

  Future<void> prerequisiteAction(String id) async {
    await _bridge.requestPrerequisiteAction(id);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await refresh();
  }

  Future<void> simulate(String action) async {
    await _bridge.simulate(action);
    await refresh();
  }

  void _onNativeEvent(Map<Object?, Object?> event) {
    final type = event['type']?.toString();
    if (type == 'snapshot' && event['payload'] is Map) {
      snapshot =
          SentrySnapshot.fromMap(event['payload'] as Map<Object?, Object?>);
      notifyListeners();
      return;
    }
    if (type == 'telemetry') {
      refresh();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
