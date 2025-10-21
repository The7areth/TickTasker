import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/today/today_page.dart';

void main() {
  runApp(const ProviderScope(child: TickTaskerApp()));
}

class TickTaskerApp extends StatelessWidget {
  const TickTaskerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TickTasker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TodayPage(),
    );
  }
}
