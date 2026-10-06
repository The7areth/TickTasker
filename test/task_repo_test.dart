import 'package:flutter_test/flutter_test.dart';
import 'package:ticktasker/data/task_repo.dart';
import 'package:ticktasker/data/task_store.dart';
import 'package:ticktasker/models/task.dart';

class MemoryStore implements TaskStore {
  String? value;
  bool fail = false;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String next) async {
    if (fail) throw StateError('Storage unavailable');
    value = next;
  }
}

void main() {
  late MemoryStore store;
  late TaskRepo repo;
  late DateTime day;
  setUp(() async {
    day = DateTime(2026, 10, 6);
    store = MemoryStore();
    repo = TaskRepo(store, clock: () => day);
    await repo.load();
  });
  tearDown(() => repo.dispose());

  test('add, edit, complete and delete survive repository reloads', () async {
    await repo.save(
      title: '  Write outline  ',
      commitment: 2,
      estimateMinutes: 20,
    );
    final id = repo.tasks.single.id;
    await repo.save(id: id, title: 'Write introduction', commitment: 3);
    await repo.toggleComplete(id);
    final restored = TaskRepo(store);
    addTearDown(restored.dispose);
    await restored.load();
    expect(restored.tasks.single.title, 'Write introduction');
    expect(restored.tasks.single.estimateMinutes, isNull);
    expect(restored.tasks.single.isCompleted, isTrue);
    await restored.delete(id);
    await repo.load();
    expect(repo.tasks, isEmpty);
  });
  test('invalid input never writes to storage', () {
    for (final minutes in [0, -1, 1441]) {
      expect(
        () => repo.save(title: 'Task', commitment: 2, estimateMinutes: minutes),
        throwsArgumentError,
      );
    }
    expect(() => repo.save(title: ' ', commitment: 2), throwsArgumentError);
    expect(() => repo.save(title: 'Task', commitment: 4), throwsArgumentError);
    expect(store.value, isNull);
  });
  test(
    'one highlight per day, with unpinning and completion supported',
    () async {
      await repo.save(title: 'One', commitment: 2);
      await repo.save(title: 'Two', commitment: 2);
      await repo.toggleHighlight(repo.tasks.first.id);
      await repo.toggleHighlight(repo.tasks.last.id);
      expect(repo.tasks.where((task) => task.isHighlightOn(day)).length, 1);
      await repo.toggleComplete(repo.tasks.last.id);
      expect(repo.tasks.last.isCompleted, isTrue);
      await repo.toggleHighlight(repo.tasks.last.id);
      expect(repo.tasks.any((task) => task.isHighlightOn(day)), isFalse);
      await repo.toggleHighlight(repo.tasks.first.id);
      day = DateTime(2026, 10, 7);
      expect(repo.tasks.any((task) => task.isHighlightOn(day)), isFalse);
      expect(repo.tasks.length, 2);
    },
  );
  test(
    'combined filters, case-insensitive search and completion views',
    () async {
      await repo.save(title: 'Email Sam', commitment: 3, estimateMinutes: 2);
      await repo.save(title: 'Email notes', commitment: 1, estimateMinutes: 1);
      await repo.save(title: 'Write', commitment: 3, estimateMinutes: 30);
      expect(
        repo
            .filtered(query: ' EMAIL ', twoMinuteOnly: true, minCommitment: 2)
            .single
            .title,
        'Email Sam',
      );
      await repo.toggleComplete(repo.tasks.first.id);
      expect(repo.filtered(completed: true).single.title, 'Email Sam');
      expect(repo.filtered().length, 2);
    },
  );
  test('failed save preserves state; later saves can recover', () async {
    await repo.save(title: 'Keep me', commitment: 2);
    final before = store.value;
    store.fail = true;
    await expectLater(repo.delete(repo.tasks.first.id), throwsStateError);
    expect(repo.tasks.single.title, 'Keep me');
    expect(store.value, before);
    store.fail = false;
    await repo.save(title: 'Recovered', commitment: 1);
    expect(repo.tasks.length, 2);
  });
  test('concurrent writes and toggles use the latest state', () async {
    await Future.wait(
      List.generate(
        12,
        (index) => repo.save(title: 'Task $index', commitment: 2),
      ),
    );
    expect(repo.tasks.length, 12);
    expect(repo.tasks.map((task) => task.id).toSet().length, 12);
    final id = repo.tasks.first.id;
    await Future.wait([repo.toggleComplete(id), repo.toggleComplete(id)]);
    expect(repo.tasks.first.isCompleted, isFalse);
    await repo.load();
    expect(repo.tasks.length, 12);
  });
  test('corrupt and unsupported data are not silently replaced', () async {
    for (final value in [
      'not json',
      '{"version":2,"tasks":[]}',
      '{"version":1,"tasks":[{}]}',
    ]) {
      store.value = value;
      final fresh = TaskRepo(store);
      await expectLater(fresh.load(), throwsA(anything));
      await expectLater(
        fresh.save(title: 'New', commitment: 2),
        throwsStateError,
      );
      expect(store.value, value);
      fresh.dispose();
    }
  });
  test('task serialization preserves all fields', () {
    final task = Task(
      id: 'abc',
      title: 'Test',
      commitment: 3,
      estimateMinutes: 2,
      highlightDay: '2026-10-06',
      isCompleted: true,
    );
    expect(Task.fromJson(task.toJson()).toJson(), task.toJson());
  });
  test(
    'undo preserves later tasks and newer highlight; repeated restore is safe',
    () async {
      await repo.save(title: 'Original', commitment: 3, estimateMinutes: 2);
      await repo.toggleHighlight(repo.tasks.single.id);
      final deleted = repo.tasks.single;
      await repo.delete(deleted.id);
      await repo.save(title: 'New highlight', commitment: 2);
      await repo.toggleHighlight(repo.tasks.single.id);
      await repo.restore(deleted);
      await repo.restore(deleted);
      expect(repo.tasks.length, 2);
      expect(
        repo.tasks.where((task) => task.isHighlightOn(day)).single.title,
        'New highlight',
      );
      await repo.load();
      expect(repo.tasks.last.title, 'Original');
      expect(repo.tasks.last.estimateMinutes, 2);
    },
  );

  test(
    'undo restores completed highlight and can retry after storage failure',
    () async {
      await repo.save(title: 'Original', commitment: 2);
      await repo.toggleHighlight(repo.tasks.single.id);
      await repo.toggleComplete(repo.tasks.single.id);
      final deleted = repo.tasks.single;
      await repo.delete(deleted.id);
      store.fail = true;
      await expectLater(repo.restore(deleted), throwsStateError);
      expect(repo.tasks, isEmpty);
      store.fail = false;
      await repo.restore(deleted);
      expect(repo.tasks.single.isCompleted, isTrue);
      expect(repo.tasks.single.isHighlightOn(day), isTrue);
    },
  );
}
