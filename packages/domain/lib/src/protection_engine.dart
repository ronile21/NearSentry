import 'protection_event.dart';
import 'protection_policy.dart';
import 'protection_state.dart';
import 'transition_result.dart';

final class ProtectionEngine {
  ProtectionEngine({
    ProtectionPolicy policy = const ProtectionPolicy(),
    ProtectionState initialState = ProtectionState.disarmed,
  })  : _policy = policy,
        _state = initialState;

  ProtectionPolicy _policy;
  ProtectionState _state;
  int? _graceDeadlineMicros;

  ProtectionState get state => _state;
  ProtectionPolicy get policy => _policy;
  int? get graceDeadlineMicros => _graceDeadlineMicros;

  void updatePolicy(ProtectionPolicy policy) {
    _policy = policy;
  }

  TransitionResult apply(ProtectionEvent event) {
    final previous = _state;
    var next = previous;
    var reason = 'ignored:${event.runtimeType}';
    var accepted = true;

    switch (previous) {
      case ProtectionState.disarmed:
        if (event is ArmRequested) {
          next = ProtectionState.arming;
          reason = 'arm_requested';
        } else if (event is DisarmRequested) {
          reason = 'already_disarmed';
        } else {
          accepted = false;
        }

      case ProtectionState.arming:
        if (event is PrerequisitesValidated) {
          next = event.anchorPresent
              ? ProtectionState.protected
              : ProtectionState.disarmed;
          reason = event.anchorPresent
              ? 'prerequisites_validated'
              : 'anchor_not_present';
        } else if (event is AnchorConfirmed) {
          next = ProtectionState.protected;
          reason = 'anchor_confirmed';
        } else if (event is DisarmRequested) {
          next = ProtectionState.disarmed;
          reason = 'disarm_requested';
        } else if (event is RuntimeDegraded ||
            event is PermissionLost ||
            event is BluetoothDisabled) {
          next = ProtectionState.degraded;
          reason = _degradedReason(event);
        } else {
          accepted = false;
        }

      case ProtectionState.protected:
        if (event is AnchorLost) {
          next = ProtectionState.grace;
          _graceDeadlineMicros =
              event.monotonicMicros + _policy.gracePeriod.inMicroseconds;
          reason = 'anchor_lost';
        } else if (event is DisarmRequested) {
          next = ProtectionState.disarmed;
          reason = 'disarm_requested';
        } else if (event is RuntimeDegraded ||
            event is PermissionLost ||
            event is BluetoothDisabled ||
            event is ServiceRestarted) {
          next = ProtectionState.degraded;
          reason = _degradedReason(event);
        } else if (event is AnchorConfirmed ||
            event is AnchorRecovered ||
            event is PrerequisitesValidated) {
          reason = 'anchor_still_present';
        } else {
          accepted = false;
        }

      case ProtectionState.grace:
        if (event is AnchorRecovered || event is AnchorConfirmed) {
          next = ProtectionState.protected;
          reason = 'anchor_recovered';
        } else if (event is GraceExpired) {
          final deadline = _graceDeadlineMicros;
          if (deadline != null && event.monotonicMicros >= deadline) {
            next = ProtectionState.alarm;
            reason = 'grace_expired';
          } else {
            reason = 'grace_not_expired';
          }
        } else if (event is DisarmRequested) {
          next = ProtectionState.disarmed;
          reason = 'disarm_requested';
        } else if (event is RuntimeDegraded ||
            event is PermissionLost ||
            event is BluetoothDisabled ||
            event is ServiceRestarted) {
          next = ProtectionState.degraded;
          reason = _degradedReason(event);
        } else if (event is AnchorLost) {
          reason = 'anchor_still_absent';
        } else {
          accepted = false;
        }

      case ProtectionState.alarm:
        if (event is AlarmDismissRequested) {
          reason = 'dismissal_authentication_required';
        } else if (event is AlarmDismissed || event is DisarmRequested) {
          next = ProtectionState.disarmed;
          reason = event is AlarmDismissed
              ? 'alarm_authenticated_dismissal'
              : 'disarm_requested';
        } else if (event is AnchorRecovered) {
          reason = 'recovery_does_not_cancel_alarm';
        } else {
          accepted = false;
        }

      case ProtectionState.degraded:
        if (event is DisarmRequested) {
          next = ProtectionState.disarmed;
          reason = 'disarm_requested';
        } else if (event is RuntimeRecovered || event is ServiceRestarted) {
          next = ProtectionState.arming;
          reason = 'runtime_recovered_revalidation_required';
        } else if (event is RuntimeDegraded ||
            event is PermissionLost ||
            event is BluetoothDisabled) {
          reason = _degradedReason(event);
        } else {
          accepted = false;
        }
    }

    if (next != ProtectionState.grace) {
      _graceDeadlineMicros = null;
    }

    _state = next;
    return TransitionResult(
      previous: previous,
      current: next,
      reason: reason,
      monotonicMicros: event.monotonicMicros,
      graceDeadlineMicros: _graceDeadlineMicros,
      accepted: accepted,
    );
  }

  String _degradedReason(ProtectionEvent event) {
    return switch (event) {
      RuntimeDegraded(:final reason) => 'runtime_degraded:$reason',
      PermissionLost(:final permission) => 'permission_lost:$permission',
      BluetoothDisabled() => 'bluetooth_disabled',
      ServiceRestarted() => 'service_restarted_revalidation_required',
      _ => 'runtime_degraded',
    };
  }
}
