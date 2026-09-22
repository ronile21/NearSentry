final class ProtectionPolicy {
  const ProtectionPolicy({
    this.gracePeriod = const Duration(seconds: 3),
  }) : assert(!gracePeriod.isNegative);

  final Duration gracePeriod;
}
