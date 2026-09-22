sealed class ProtectionEvent {
  const ProtectionEvent(this.monotonicMicros);

  final int monotonicMicros;
}

final class ArmRequested extends ProtectionEvent {
  const ArmRequested(super.monotonicMicros);
}

final class DisarmRequested extends ProtectionEvent {
  const DisarmRequested(super.monotonicMicros);
}

final class PrerequisitesValidated extends ProtectionEvent {
  const PrerequisitesValidated(
    super.monotonicMicros, {
    required this.anchorPresent,
  });

  final bool anchorPresent;
}

final class AnchorConfirmed extends ProtectionEvent {
  const AnchorConfirmed(super.monotonicMicros);
}

final class AnchorLost extends ProtectionEvent {
  const AnchorLost(super.monotonicMicros);
}

final class AnchorRecovered extends ProtectionEvent {
  const AnchorRecovered(super.monotonicMicros);
}

final class GraceExpired extends ProtectionEvent {
  const GraceExpired(super.monotonicMicros);
}

final class AlarmDismissRequested extends ProtectionEvent {
  const AlarmDismissRequested(super.monotonicMicros);
}

final class AlarmDismissed extends ProtectionEvent {
  const AlarmDismissed(super.monotonicMicros);
}

final class RuntimeDegraded extends ProtectionEvent {
  const RuntimeDegraded(super.monotonicMicros, this.reason);

  final String reason;
}

final class RuntimeRecovered extends ProtectionEvent {
  const RuntimeRecovered(super.monotonicMicros);
}

final class PermissionLost extends ProtectionEvent {
  const PermissionLost(super.monotonicMicros, this.permission);

  final String permission;
}

final class BluetoothDisabled extends ProtectionEvent {
  const BluetoothDisabled(super.monotonicMicros);
}

final class ServiceRestarted extends ProtectionEvent {
  const ServiceRestarted(super.monotonicMicros);
}
