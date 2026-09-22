import 'dart:async';

import 'package:flutter/services.dart';

import '../models/sentry_models.dart';

class SentryBridge {
  const SentryBridge();

  static const MethodChannel _methods =
      MethodChannel('nearsentry/control');
  static const EventChannel _events =
      EventChannel('nearsentry/events');

  Stream<Map<Object?, Object?>> get events => _events
      .receiveBroadcastStream()
      .where((event) => event is Map)
      .cast<Map<Object?, Object?>>();

  Future<SentrySnapshot> getSnapshot() async {
    final result = await _methods.invokeMethod<Map<Object?, Object?>>(
      'getCurrentSnapshot',
    );
    return SentrySnapshot.fromMap(result ?? const <Object?, Object?>{});
  }

  Future<AppSettings> getSettings() async {
    final result = await _methods.invokeMethod<Map<Object?, Object?>>(
      'getSettings',
    );
    return AppSettings.fromMap(result ?? const <Object?, Object?>{});
  }

  Future<List<TelemetryEntry>> getTelemetry() async {
    final result =
        await _methods.invokeMethod<List<Object?>>('getRecentTelemetry');
    return (result ?? const <Object?>[])
        .whereType<Map>()
        .map((item) => TelemetryEntry.fromMap(item))
        .toList(growable: false);
  }

  Future<List<TrustedAnchor>> getAvailableAnchors() async {
    final result =
        await _methods.invokeMethod<List<Object?>>('getAvailableAnchors');
    return (result ?? const <Object?>[])
        .whereType<Map>()
        .map((item) => TrustedAnchor.fromMap(item))
        .toList(growable: false);
  }

  Future<void> enrollAnchor(String id) =>
      _methods.invokeMethod<void>('enrollAnchor', <String, Object>{'id': id});

  Future<void> pingWatch() =>
      _methods.invokeMethod<void>('pingWatch');

  Future<void> testWatchAlarm() =>
      _methods.invokeMethod<void>('testWatchAlarm');

  Future<void> stopWatchAlarm() =>
      _methods.invokeMethod<void>('stopWatchAlarm');

  Future<void> arm() => _methods.invokeMethod<void>('arm');
  Future<void> disarm() => _methods.invokeMethod<void>('disarm');

  Future<bool> requestAuthenticatedDismissal() async {
    return await _methods.invokeMethod<bool>('requestAuthenticatedDismissal') ??
        false;
  }

  Future<void> updateSettings(AppSettings settings) =>
      _methods.invokeMethod<void>('updateSettings', settings.toMap());

  Future<void> requestPrerequisiteAction(String id) =>
      _methods.invokeMethod<void>(
        'requestPrerequisiteAction',
        <String, Object>{'id': id},
      );

  Future<void> simulate(String action) =>
      _methods.invokeMethod<void>(
        'simulate',
        <String, Object>{'action': action},
      );
}
