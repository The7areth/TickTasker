import 'package:flutter/material.dart';

import 'bootstrap.dart';
import 'ui/app_root.dart';

Future<void> main() async {
  final app = await bootstrap(const AppRoot());
  runApp(app);
}
