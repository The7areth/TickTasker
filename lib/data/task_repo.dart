import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import 'task_store.dart';

class TaskRepo extends ChangeNotifier {
  TaskRepo(this.store, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now;

  final TaskStore store;
  final DateTime Function() clock;
  List<Task> _tasks = [];
  bool _loaded = false;
  bool _disposed = false;
  Future<void> _queue = Future.value();
  List<Task> get tasks => List.unmodifiable(_tasks);

  Future<void> load() async {
    final raw = await store.read();
    final decoded = raw == null
        ? <String, dynamic>{'version': 1, 'tasks': []}
        : jsonDecode(raw) as Map<String, dynamic>;
    if (decoded['version'] != 1) {
      throw const FormatException('Unsupported data version.');
    }
    final loaded = (decoded['tasks'] as List)
        .map((entry) => Task.fromJson(entry as Map<String, dynamic>))
        .toList();
    if (loaded.map((task) => task.id).toSet().length != loaded.length) {
      throw const FormatException('Duplicate task IDs.');
    }
    _tasks = loaded;
    _loaded = true;
    if (!_disposed) notifyListeners();
  }

  /// Serialize writes; publish state only after storage acknowledges success.
  /// A failed write leaves the current list intact and does not block later writes.
  Future<void> _commit(List<Task> Function() update) {
    final operation = _queue.then((_) async {
      if (!_loaded) throw StateError('Load tasks before editing.');
      final next = update();
      await store.write(
        jsonEncode({
          'version': 1,
          'tasks': next.map((task) => task.toJson()).toList(),
        }),
      );
      _tasks = next;
      if (!_disposed) notifyListeners();
    });
    _queue = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return operation;
  }

  Future<void> save({
    String? id,
    required String title,
    required int commitment,
    int? estimateMinutes,
  }) {
    // Validate before entering the write queue.
    final candidate = Task(
      id: id ?? const Uuid().v4(),
      title: title,
      commitment: commitment,
      estimateMinutes: estimateMinutes,
    );
    return _commit(() {
      if (id == null) return [..._tasks, candidate];
      final current = _tasks.firstWhere((task) => task.id == id);
      final updated = candidate.copyWith(
        isCompleted: current.isCompleted,
        highlightDay: current.highlightDay,
      );
      return [
        for (final task in _tasks)
          if (task.id == id) updated else task,
      ];
    });
  }

  Future<void> toggleComplete(String id) => _commit(
    () => [
      for (final task in _tasks)
        if (task.id == id)
          task.copyWith(isCompleted: !task.isCompleted)
        else
          task,
    ],
  );

  Future<void> toggleHighlight(String id) => _commit(() {
    final target = _tasks.firstWhere((task) => task.id == id);
    final clear = target.isHighlightOn(clock());
    return [
      for (final task in _tasks)
        if (task.id == id && !clear)
          task.copyWith(highlightDay: Task.dayKey(clock()))
        else
          task.copyWith(clearHighlight: true),
    ];
  });

  Future<void> delete(String id) =>
      _commit(() => _tasks.where((task) => task.id != id).toList());

  /// Restore a deleted task without overwriting subsequent edits or a new highlight.
  Future<void> restore(Task task) => _commit(() {
    if (_tasks.any((current) => current.id == task.id)) return [..._tasks];
    final hasHighlight = _tasks.any(
      (current) => current.isHighlightOn(clock()),
    );
    final restored = hasHighlight && task.isHighlightOn(clock())
        ? task.copyWith(clearHighlight: true)
        : task;
    return [..._tasks, restored];
  });

  List<Task> filtered({
    String query = '',
    bool twoMinuteOnly = false,
    int minCommitment = 0,
    bool completed = false,
  }) {
    final result = _tasks
        .where(
          (task) =>
              task.isCompleted == completed &&
              task.title.toLowerCase().contains(query.trim().toLowerCase()) &&
              (!twoMinuteOnly || task.isTwoMinute) &&
              task.commitment >= minCommitment,
        )
        .toList();
    result.sort((a, b) {
      final pinned = (b.isHighlightOn(clock()) ? 1 : 0).compareTo(
        a.isHighlightOn(clock()) ? 1 : 0,
      );
      if (pinned != 0) return pinned;
      final priority = b.commitment.compareTo(a.commitment);
      return priority != 0 ? priority : a.title.compareTo(b.title);
    });
    return result;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
