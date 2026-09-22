import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nearsentry/src/widgets/protection_status_card.dart';
import 'package:nearsentry_domain/nearsentry_domain.dart';

void main() {
  testWidgets('renders protected state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProtectionStatusCard(
            state: ProtectionState.protected,
            message: 'Monitoring is healthy',
            anchorName: 'Garmin',
          ),
        ),
      ),
    );

    expect(find.text('Protected'), findsOneWidget);
    expect(find.text('Trusted device: Garmin'), findsOneWidget);
  });

  testWidgets('renders grace countdown', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProtectionStatusCard(
            state: ProtectionState.grace,
            message: 'Separated',
            anchorName: 'Garmin',
            graceRemainingMs: 2400,
          ),
        ),
      ),
    );

    expect(find.text('Device separation detected'), findsOneWidget);
    expect(find.text('2.4 s'), findsOneWidget);
  });

  testWidgets('alarm state is unmistakable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProtectionStatusCard(
            state: ProtectionState.alarm,
            message: 'Separation alarm',
            anchorName: 'Garmin',
          ),
        ),
      ),
    );

    expect(find.text('ALARM'), findsOneWidget);
  });
}
