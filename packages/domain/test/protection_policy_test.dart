import 'package:nearsentry_domain/nearsentry_domain.dart';
import 'package:test/test.dart';

void main() {
  test('development default grace period is three seconds', () {
    const policy = ProtectionPolicy();
    expect(policy.gracePeriod, const Duration(seconds: 3));
  });
}
