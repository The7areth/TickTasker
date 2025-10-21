import 'package:isar/isar.dart';

part 'habit.g.dart';

@collection
class Habit {
  Id id = Isar.autoIncrement;

  /// e.g. "write_daily", "run_morning"
  @Index(unique: true, caseSensitive: false)
  late String key;

  /// Last calendar day (local) when the habit was completed
  DateTime? lastDoneOn;

  /// Streak count for UI
  int streak = 0;
}
