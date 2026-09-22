sealed class ProtectionEvent {
  const ProtectionEvent();
}

final class ArmRequested extends ProtectionEvent {
  const ArmRequested();
}

final class AnchorConfirmed extends ProtectionEvent {
  const AnchorConfirmed();
}

final class AnchorLost extends ProtectionEvent {
  const AnchorLost();
}

final class AnchorRecovered extends ProtectionEvent {
  const AnchorRecovered();
}

final class GraceExpired extends ProtectionEvent {
  const GraceExpired();
}

final class RuntimeDegraded extends ProtectionEvent {
  const RuntimeDegraded(this.reason);
  final String reason;
}
