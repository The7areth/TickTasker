import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Task({
    this.title = '',
    this.notes,
    this.dueDate,
    this.completed = false,
  });

  Id id = Isar.autoIncrement;

  String title;

  String? notes;

  DateTime? dueDate;

  bool completed;
}
