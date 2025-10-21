import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';

final taskRepoProvider = Provider<TaskRepo>((ref) {
  final repo = TaskRepo();
  ref.onDispose(repo.dispose);
  return repo;
});

class TaskRepo {
  TaskRepo() {
    _seedTasks();
  }

  final _tasks = <Task>[];
  final _controller = StreamController<List<Task>>.broadcast();

  void dispose() {
    _controller.close();
  }

  Stream<List<Task>> watchToday({bool twoMinuteOnly = false, int? minCommitment}) {
    return Stream<List<Task>>.multi((controller) {
      void emitFiltered() {
        final filtered = _filterTasks(
          twoMinuteOnly: twoMinuteOnly,
          minCommitment: minCommitment,
        );
        controller.add(filtered);
      }

      emitFiltered();
      final sub = _controller.stream.listen((_) => emitFiltered());
      controller.onCancel = () => sub.cancel();
    });
  }

  Future<void> addQuick({
    required String title,
    required int commitment,
    int? estimateMinutes,
  }) async {
    final task = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      commitment: commitment,
      estimateMinutes: estimateMinutes,
    );
    _tasks.add(task);
    _notifyListeners();
  }

  Future<void> toggleComplete(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    _tasks[index] = updated;
    _notifyListeners();
  }

  Future<void> setHighlight(Task task) async {
    for (var i = 0; i < _tasks.length; i++) {
      final current = _tasks[i];
      _tasks[i] = current.copyWith(isHighlight: current.id == task.id);
    }
    _notifyListeners();
  }

  void _seedTasks() {
    _tasks
      ..clear()
      ..addAll([
        const Task(
          id: 'highlight',
          title: 'Ship today\'s highlight project',
          commitment: 3,
          estimateMinutes: 45,
          isHighlight: true,
        ),
        const Task(
          id: 'write',
          title: 'Draft outline for newsletter',
          commitment: 2,
          estimateMinutes: 25,
        ),
        const Task(
          id: 'study',
          title: 'Review research notes',
          commitment: 1,
          estimateMinutes: 15,
        ),
        const Task(
          id: 'two-minute',
          title: 'Send project update',
          commitment: 2,
          estimateMinutes: 2,
        ),
      ]);
    _notifyListeners();
  }

  void _notifyListeners() {
    _controller.add(List.unmodifiable(_tasks));
  }

  List<Task> _filterTasks({bool twoMinuteOnly = false, int? minCommitment}) {
    final filtered = _tasks.where((task) {
      if (twoMinuteOnly && !task.isTwoMinute) return false;
      if (minCommitment != null && task.commitment < minCommitment) return false;
      return true;
    }).toList();
    filtered.sort((a, b) {
      if (a.isHighlight != b.isHighlight) {
        return a.isHighlight ? -1 : 1;
      }
      return b.commitment.compareTo(a.commitment);
    });
    return filtered;
  }
}
