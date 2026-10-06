import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticktasker/main.dart';
import 'package:ticktasker/data/task_repo.dart';
import 'task_repo_test.dart' show MemoryStore;

void main() {
  testWidgets('add validation, save, highlight, complete and reopen', (
    tester,
  ) async {
    final repo = TaskRepo(MemoryStore());
    addTearDown(repo.dispose);
    await tester.pumpWidget(TickTaskerApp(repository: repo));
    await tester.pumpAndSettle();
    expect(find.text('A fresh start. Add your first task.'), findsOneWidget);
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save task'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a task title.'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Task title'),
      'Prepare demo',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Estimated minutes (optional)'),
      '-1',
    );
    await tester.tap(find.text('Save task'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a whole number from 1 to 1440.'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Estimated minutes (optional)'),
      '2',
    );
    await tester.tap(find.text('Save task'));
    await tester.pumpAndSettle();
    expect(find.text('Prepare demo'), findsOneWidget);
    await tester.tap(find.byTooltip('Set as daily highlight'));
    await tester.pumpAndSettle();
    expect(find.text('DAILY HIGHLIGHT'), findsOneWidget);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('Prepare demo'), findsNothing);
    await tester.ensureVisible(find.text('Completed (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Completed (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Prepare demo'), findsOneWidget);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(repo.tasks.single.isCompleted, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('save failure keeps editor open and retry succeeds', (
    tester,
  ) async {
    final store = MemoryStore();
    final repo = TaskRepo(store);
    addTearDown(repo.dispose);
    await tester.pumpWidget(TickTaskerApp(repository: repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Task title'),
      'Keep draft',
    );
    store.fail = true;
    await tester.tap(find.text('Save task'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not save this task. Please try again.'),
      findsOneWidget,
    );
    expect(repo.tasks, isEmpty);
    store.fail = false;
    await tester.tap(find.text('Save task'));
    await tester.pumpAndSettle();
    expect(repo.tasks.single.title, 'Keep draft');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('corrupt storage shows retry without discarding data', (
    tester,
  ) async {
    final store = MemoryStore()..value = 'broken';
    final repo = TaskRepo(store);
    addTearDown(repo.dispose);
    await tester.pumpWidget(TickTaskerApp(repository: repo));
    await tester.pumpAndSettle();
    expect(find.text('Your tasks could not be loaded.'), findsOneWidget);
    expect(store.value, 'broken');
    store.value = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Add task'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('small phone layout and long title have no overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = TaskRepo(MemoryStore());
    addTearDown(repo.dispose);
    await repo.load();
    await repo.save(
      title: List.filled(15, 'A long task').join(' '),
      commitment: 3,
    );
    await tester.pumpWidget(TickTaskerApp(repository: repo));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('editing clears estimate and deletion requires confirmation', (
    tester,
  ) async {
    final repo = TaskRepo(MemoryStore());
    addTearDown(repo.dispose);
    await repo.load();
    await repo.save(title: 'Original', commitment: 2, estimateMinutes: 5);
    await tester.pumpWidget(TickTaskerApp(repository: repo));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Original'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Original'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Task title'),
      'Revised',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Estimated minutes (optional)'),
      '',
    );
    await tester.tap(find.text('Save task'));
    await tester.pumpAndSettle();
    expect(repo.tasks.single.title, 'Revised');
    expect(repo.tasks.single.estimateMinutes, isNull);
    await tester.ensureVisible(find.byTooltip('Task options'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Task options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repo.tasks.length, 1);
    await tester.tap(find.byTooltip('Task options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(repo.tasks, isEmpty);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(repo.tasks.single.title, 'Revised');
    expect(find.text('Task restored'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'duplicate opens editable draft and starts incomplete without a highlight',
    (tester) async {
      final repo = TaskRepo(MemoryStore());
      addTearDown(repo.dispose);
      await repo.load();
      await repo.save(
        title: 'Weekly review',
        commitment: 2,
        estimateMinutes: 15,
      );
      await repo.toggleComplete(repo.tasks.single.id);
      await repo.toggleHighlight(repo.tasks.single.id);
      await tester.pumpWidget(TickTaskerApp(repository: repo));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Completed (1)'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Task options'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Task options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Duplicate'));
      await tester.pumpAndSettle();
      expect(find.text('Duplicate task'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Task title'),
        'Next weekly review',
      );
      await tester.tap(find.text('Save task'));
      await tester.pumpAndSettle();
      expect(repo.tasks.length, 2);
      final copy = repo.tasks.last;
      expect(copy.title, 'Next weekly review');
      expect(find.text('Next weekly review'), findsOneWidget);
      expect(find.text('Your tasks'), findsOneWidget);
      expect(copy.estimateMinutes, 15);
      expect(copy.commitment, 2);
      expect(copy.isCompleted, isFalse);
      expect(copy.highlightDay, isNull);
      expect(copy.id, isNot(repo.tasks.first.id));
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'clear filters resets search and filters within the selected view',
    (tester) async {
      final repo = TaskRepo(MemoryStore());
      addTearDown(repo.dispose);
      await repo.load();
      await repo.save(title: 'Research', commitment: 1, estimateMinutes: 20);
      await repo.toggleComplete(repo.tasks.single.id);
      await tester.pumpWidget(TickTaskerApp(repository: repo));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Completed (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('≤ 2 minutes'));
      await tester.tap(find.text('Today + Now'));
      await tester.enterText(
        find.widgetWithText(TextField, 'Search tasks'),
        'missing',
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Clear filters'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();
      expect(find.text('Research'), findsOneWidget);
      expect(find.text('Completed tasks'), findsOneWidget);
      expect(find.text('Clear filters'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
