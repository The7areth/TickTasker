import 'package:isar/isar.dart';

part 'habit.g.dart';

@collection
class Habit {
  Habit();

  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String key;

  DateTime? lastDoneOn;

  int streak = 0;
}
