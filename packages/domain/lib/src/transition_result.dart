import 'protection_state.dart';

final class TransitionResult {
  const TransitionResult({
    required this.previous,
    required this.current,
    required this.reason,
    required this.monotonicMicros,
    this.graceDeadlineMicros,
    this.accepted = true,
  });

  final ProtectionState previous;
  final ProtectionState current;
  final String reason;
  final int monotonicMicros;
  final int? graceDeadlineMicros;
  final bool accepted;

  bool get changed => previous != current;
}
