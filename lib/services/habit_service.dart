import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../bootstrap.dart';
import '../models/habit.dart';

final habitServiceProvider = Provider<HabitService>((ref) {
  final isar = ref.watch(isarProvider);
  return HabitService(isar);
});

class HabitService {
  HabitService(this.isar);
  final Isar isar;

  Future<void> markDone(String key, DateTime when) async {
    await isar.writeTxn(() async {
      var habit = await isar.habits.filter().keyEqualTo(key).findFirst();
      final day = DateTime(when.year, when.month, when.day);
      if (habit == null) {
        habit = Habit()
          ..key = key
          ..lastDoneOn = day
          ..streak = 1;
        await isar.habits.put(habit);
        return;
      }
      final last = habit.lastDoneOn;
      if (last == null) {
        habit.lastDoneOn = day;
        habit.streak = 1;
      } else {
        final lastDay = DateTime(last.year, last.month, last.day);
        final diff = day.difference(lastDay).inDays;
        if (diff == 0) {
          // same day: do nothing
        } else if (diff == 1) {
          habit.streak += 1; // consecutive
          habit.lastDoneOn = day;
        } else if (diff == 2) {
          habit.streak += 1; // missed one day -> still keeps streak (Two-Day Rule)
          habit.lastDoneOn = day;
        } else {
          habit.streak = 1; // missed 2+ days -> reset
          habit.lastDoneOn = day;
        }
      }
      await isar.habits.put(habit);
    });
  }

  Future<bool> isTwoDayWarning(String key) async {
    final h = await isar.habits.filter().keyEqualTo(key).findFirst();
    if (h?.lastDoneOn == null) return false;
    final today = DateTime.now();
    final last =
        DateTime(h!.lastDoneOn!.year, h.lastDoneOn!.month, h.lastDoneOn!.day);
    final diff =
        DateTime(today.year, today.month, today.day).difference(last).inDays;
    return diff == 1; // if true, today is the save-the-streak day
  }
}
