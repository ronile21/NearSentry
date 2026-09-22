import 'package:nearsentry_domain/nearsentry_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ProtectionEngine', () {
    test('arm, validate, disconnect, recover', () {
      final engine = ProtectionEngine();
      expect(engine.apply(const ArmRequested(0)).current, ProtectionState.arming);
      expect(
        engine.apply(const PrerequisitesValidated(1, anchorPresent: true)).current,
        ProtectionState.protected,
      );

      final lost = engine.apply(const AnchorLost(2));
      expect(lost.current, ProtectionState.grace);
      expect(lost.graceDeadlineMicros, 3000002);

      final recovered = engine.apply(const AnchorRecovered(2000000));
      expect(recovered.current, ProtectionState.protected);
      expect(engine.graceDeadlineMicros, isNull);
    });

    test('grace expires exactly after monotonic deadline', () {
      final engine = ProtectionEngine();
      engine.apply(const ArmRequested(0));
      engine.apply(const AnchorConfirmed(1));
      engine.apply(const AnchorLost(100));

      final early = engine.apply(const GraceExpired(3000099));
      expect(early.current, ProtectionState.grace);

      final expired = engine.apply(const GraceExpired(3000100));
      expect(expired.current, ProtectionState.alarm);
    });

    test('duplicate disconnect does not extend deadline', () {
      final engine = ProtectionEngine();
      engine.apply(const ArmRequested(0));
      engine.apply(const AnchorConfirmed(1));
      final first = engine.apply(const AnchorLost(100));
      final second = engine.apply(const AnchorLost(500000));

      expect(second.current, ProtectionState.grace);
      expect(second.graceDeadlineMicros, first.graceDeadlineMicros);
    });

    test('alarm recovery cannot silently dismiss alarm', () {
      final engine = ProtectionEngine();
      engine.apply(const ArmRequested(0));
      engine.apply(const AnchorConfirmed(1));
      engine.apply(const AnchorLost(2));
      engine.apply(const GraceExpired(3000002));

      expect(
        engine.apply(const AnchorRecovered(4000000)).current,
        ProtectionState.alarm,
      );
      expect(
        engine.apply(const AlarmDismissed(5000000)).current,
        ProtectionState.disarmed,
      );
    });

    test('runtime degradation requires revalidation after recovery', () {
      final engine = ProtectionEngine();
      engine.apply(const ArmRequested(0));
      engine.apply(const AnchorConfirmed(1));
      expect(
        engine.apply(const RuntimeDegraded(2, 'service')).current,
        ProtectionState.degraded,
      );
      expect(
        engine.apply(const RuntimeRecovered(3)).current,
        ProtectionState.arming,
      );
    });

    test('invalid event is explicit and does not change state', () {
      final engine = ProtectionEngine();
      final result = engine.apply(const GraceExpired(1));
      expect(result.accepted, isFalse);
      expect(result.current, ProtectionState.disarmed);
    });
  });
}
