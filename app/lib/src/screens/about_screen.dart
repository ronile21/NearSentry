import 'package:flutter/material.dart';

import '../app_info.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About NearSentry')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppInfo.displayName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Version ${AppInfo.version}'),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'Created by ${AppInfo.ownerName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (AppInfo.ownerEmail.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SelectableText(AppInfo.ownerEmail),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
