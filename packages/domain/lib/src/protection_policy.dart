final class ProtectionPolicy {
  const ProtectionPolicy({
    this.gracePeriod = const Duration(seconds: 3),
  });

  final Duration gracePeriod;
}
