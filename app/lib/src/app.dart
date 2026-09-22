import 'package:flutter/material.dart';
import 'package:nearsentry_domain/nearsentry_domain.dart';

import 'controllers/protection_controller.dart';
import 'screens/dashboard_screen.dart';
import 'screens/diagnostics_screen.dart';
import 'screens/history_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/setup_screen.dart';
import 'theme/app_theme.dart';

class NearSentryApp extends StatefulWidget {
  const NearSentryApp({super.key});

  @override
  State<NearSentryApp> createState() => _NearSentryAppState();
}

class _NearSentryAppState extends State<NearSentryApp> {
  final ProtectionController _controller = ProtectionController();

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NearSentry',
      debugShowCheckedModeBanner: false,
      theme: NearSentryTheme.light(),
      darkTheme: NearSentryTheme.dark(),
      themeMode: ThemeMode.system,
      home: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (_controller.error != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('NearSentry')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 56),
                      const SizedBox(height: 18),
                      Text(
                        'Protection runtime unavailable',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _controller.error!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _controller.initialize,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          if (!_controller.settings.onboardingComplete) {
            return OnboardingScreen(
              onContinue: _controller.completeOnboarding,
            );
          }
          if (_controller.snapshot.anchorName == null ||
              !_controller.snapshot.requiredPrerequisitesReady) {
            return SetupScreen(
              controller: _controller,
              onDone: _controller.refresh,
            );
          }
          return _HomeShell(controller: _controller);
        },
      ),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell({required this.controller});

  final ProtectionController controller;

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final alarm = widget.controller.snapshot.state == ProtectionState.alarm;
    if (alarm) {
      return Scaffold(
        appBar: AppBar(title: const Text('NearSentry alarm')),
        body: DashboardScreen(controller: widget.controller),
      );
    }

    final pages = <Widget>[
      DashboardScreen(controller: widget.controller),
      HistoryScreen(controller: widget.controller),
      SettingsScreen(controller: widget.controller),
      DiagnosticsScreen(controller: widget.controller),
    ];
    final titles = <String>[
      'NearSentry',
      'Event history',
      'Settings',
      'Diagnostics',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[index]),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: widget.controller.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Protect',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            label: 'Diagnostics',
          ),
        ],
      ),
    );
  }
}
