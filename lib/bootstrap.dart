import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/habit.dart';
import 'models/task.dart';

final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());

Future<ProviderScope> bootstrap(Widget app) async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [TaskSchema, HabitSchema],
    directory: dir.path,
    inspector: false,
  );
  return ProviderScope(
    overrides: [isarProvider.overrideWithValue(isar)],
    child: app,
  );
}
