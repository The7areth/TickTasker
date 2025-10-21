import 'package:isar/isar.dart';

part 'habit.g.dart';

@collection
class Habit {
  Habit({
    this.name = '',
    this.streak = 0,
    this.lastCompleted,
  });

  Id id = Isar.autoIncrement;

  String name;

  int streak;

  DateTime? lastCompleted;
}
