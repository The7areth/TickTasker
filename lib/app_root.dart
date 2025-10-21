import 'package:flutter/material.dart';
import 'today/today_page.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TickTasker',
      debugShowCheckedModeBanner: false,
      home: const TodayPage(),
    );
  }
}
