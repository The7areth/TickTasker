import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';

/// Shared repository provider so widgets can access and mutate tasks.
final taskRepoProvider = Provider<TaskRepo>((ref) {
  final repo = TaskRepo();
  ref.onDispose(repo.dispose);
  return repo;
});

/// Simple in-memory task repository.
///
/// The production app is expected to replace this with a persistent
/// implementation, but this version keeps the rest of the UI unblocked while
/// providing deterministic behaviour for tests.
class TaskRepo {
  final _tasks = <int, Task>{};
  final _todayController = StreamController<List<Task>>.broadcast();
  int _nextId = 1;

  /// Adds a new task with minimal information for quick entry.
  Future<Task> addQuick({
    required String title,
    int commitment = 0,
    bool isHighlight = false,
    int? estimateMinutes,
    DateTime? scheduledFor,
  }) async {
    final task = Task(
      id: _nextId++,
      title: title.trim(),
      commitment: commitment,
      isHighlight: isHighlight,
      estimateMinutes: estimateMinutes,
      scheduledFor: scheduledFor,
      createdAt: DateTime.now(),
    );
    _tasks[task.id] = task;
    _emitToday();
    return task;
  }

  /// Toggles whether the task has been completed.
  Future<void> toggleComplete(Task task) async {
    final existing = _tasks[task.id];
    if (existing == null) return;
    final now = DateTime.now();
    _tasks[task.id] = existing.copyWith(
      completedAt: existing.completedAt == null ? now : null,
    );
    _emitToday();
  }

  /// Watches tasks considered "today" with optional filters.
  Stream<List<Task>> watchToday({
    bool twoMinuteOnly = false,
    int? minCommitment,
  }) {
    // Emit current state immediately for new subscribers.
    scheduleMicrotask(_emitToday);
    return _todayController.stream.map((tasks) {
      Iterable<Task> result = tasks;
      if (twoMinuteOnly) {
        result = result.where((task) => task.isTwoMinute && !task.isHighlight);
      }
      if (minCommitment != null) {
        result = result.where((task) => task.commitment >= minCommitment);
      }
      final sorted = result.toList()
        ..sort((a, b) {
          if (a.isHighlight == b.isHighlight) {
            return b.commitment.compareTo(a.commitment);
          }
          return a.isHighlight ? -1 : 1;
        });
      return sorted;
    });
  }

  /// Marks the provided task as the single highlight.
  Future<void> setHighlight(Task task) async {
    final existing = _tasks[task.id];
    if (existing == null) return;

    // Clear any existing highlight.
    final highlightedIds = _tasks.values
        .where((t) => t.isHighlight && t.id != task.id)
        .map((t) => t.id)
        .toList();
    for (final id in highlightedIds) {
      final highlighted = _tasks[id];
      if (highlighted == null) continue;
      _tasks[id] = highlighted.copyWith(isHighlight: false);
    }

    _tasks[task.id] = existing.copyWith(isHighlight: true);
    _emitToday();
  }

  void dispose() {
    _todayController.close();
  }

  void _emitToday() {
    if (_todayController.isClosed) return;
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final tasks = _tasks.values.where((task) {
      final scheduled = task.scheduledFor;
      final withinSchedule = scheduled == null ||
          (!scheduled.isBefore(dayStart) && scheduled.isBefore(dayEnd));
      final incomplete = task.completedAt == null;
      return withinSchedule && incomplete;
    }).toList();

    _todayController.add(tasks);
  }
}
