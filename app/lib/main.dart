import 'package:flutter/material.dart';

void main() {
  runApp(const NearSentryApp());
}

class NearSentryApp extends StatelessWidget {
  const NearSentryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NearSentry',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text('NearSentry — repository scaffold 0.0.0.1'),
        ),
      ),
    );
  }
}
