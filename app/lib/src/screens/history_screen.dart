import 'package:flutter/material.dart';

import '../controllers/protection_controller.dart';
import '../widgets/telemetry_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.controller});

  final ProtectionController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.telemetry.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No protection events have been recorded yet.'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: controller.telemetry.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) =>
            TelemetryTile(entry: controller.telemetry[index]),
      ),
    );
  }
}
