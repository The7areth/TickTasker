import 'package:flutter/material.dart';

import 'bootstrap.dart';

Future<void> main() async {
  final scope = await bootstrap(const TickTaskerApp());
  runApp(scope);
}

class TickTaskerApp extends StatelessWidget {
  const TickTaskerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TickTasker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('TickTasker is bootstrapped.'),
        ),
      ),
    );
  }
}
