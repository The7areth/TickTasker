import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/task_repo.dart';
import '../../models/task.dart';
import 'task_editor.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key, required this.repo});
  final TaskRepo repo;
  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> with WidgetsBindingObserver {
  final search = TextEditingController();
  bool twoMinuteOnly = false;
  bool completed = false;
  int minCommitment = 0;
  bool busy = false;
  Timer? refresh;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Re-evaluate the daily highlight when the app stays open overnight.
    refresh = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) setState(() {});
  }

  @override
  void dispose() {
    refresh?.cancel();
    search.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> run(Future<void> Function() action) async {
    if (busy) return false;
    setState(() => busy = true);
    try {
      await action();
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save the change. Please try again.'),
          ),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> edit([Task? task, bool duplicate = false]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          TaskEditor(repo: widget.repo, task: task, duplicate: duplicate),
    );
    if (saved == true && duplicate && mounted) {
      setState(() {
        completed = false;
        search.clear();
        twoMinuteOnly = false;
        minCommitment = 0;
      });
    }
  }

  Future<void> remove(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('“${task.title}” will be removed from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final deleted = await run(() => widget.repo.delete(task.id));
      if (deleted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task deleted'),
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => restoreDeleted(task),
            ),
          ),
        );
      }
    }
  }

  Future<void> restoreDeleted(Task task) async {
    final restored = await run(() => widget.repo.restore(task));
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          restored ? 'Task restored' : 'Could not restore the task.',
        ),
        action: restored
            ? null
            : SnackBarAction(
                label: 'Retry',
                onPressed: () => restoreDeleted(task),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.repo,
    builder: (context, _) {
      final repo = widget.repo;
      final tasks = repo.filtered(
        query: search.text,
        twoMinuteOnly: twoMinuteOnly,
        minCommitment: minCommitment,
        completed: completed,
      );
      final activeCount = repo.tasks.where((task) => !task.isCompleted).length;
      final doneCount = repo.tasks.length - activeCount;
      final theme = Theme.of(context);
      final hasFilters =
          search.text.isNotEmpty || twoMinuteOnly || minCommitment != 0;
      return Scaffold(
        appBar: AppBar(
          title: const Text('TickTasker'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                onPressed: busy ? null : () => edit(),
                icon: const Icon(Icons.add),
                label: const Text('Add task'),
              ),
            ),
          ],
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              children: [
                Text(
                  'Make room for what matters.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Choose one highlight. Take the next small step.'),
                const SizedBox(height: 24),
                Card.filled(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$activeCount open · $doneCount completed',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: repo.tasks.isEmpty
                              ? 0
                              : doneCount / repo.tasks.length,
                          semanticsLabel: 'Task completion',
                          semanticsValue:
                              '$doneCount of ${repo.tasks.length} tasks completed',
                        ),
                        const SizedBox(height: 12),
                        Text(
                          repo.tasks.any(
                                (task) => task.isHighlightOn(repo.clock()),
                              )
                              ? 'Your daily highlight is marked with a star.'
                              : 'Star a task to make it today’s highlight.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Search tasks',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() => search.clear()),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('Open ($activeCount)'),
                      selected: !completed,
                      onSelected: (_) => setState(() => completed = false),
                    ),
                    ChoiceChip(
                      label: Text('Completed ($doneCount)'),
                      selected: completed,
                      onSelected: (_) => setState(() => completed = true),
                    ),
                    FilterChip(
                      label: const Text('≤ 2 minutes'),
                      selected: twoMinuteOnly,
                      onSelected: (value) =>
                          setState(() => twoMinuteOnly = value),
                    ),
                    FilterChip(
                      label: const Text('Today + Now'),
                      selected: minCommitment == 2,
                      onSelected: (value) =>
                          setState(() => minCommitment = value ? 2 : 0),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  completed ? 'Completed tasks' : 'Your tasks',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(
                          completed ? Icons.task_alt : Icons.checklist_rounded,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          repo.tasks.isEmpty
                              ? 'A fresh start. Add your first task.'
                              : 'No tasks match this view.',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          repo.tasks.isEmpty
                              ? 'Start small: a title is all you need.'
                              : 'Try another search or change the filters.',
                          textAlign: TextAlign.center,
                        ),
                        if (hasFilters)
                          TextButton(
                            onPressed: () => setState(() {
                              search.clear();
                              twoMinuteOnly = false;
                              minCommitment = 0;
                            }),
                            child: const Text('Clear filters'),
                          ),
                      ],
                    ),
                  ),
                for (final task in tasks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      color: task.isHighlightOn(repo.clock())
                          ? theme.colorScheme.primaryContainer
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Checkbox(
                              value: task.isCompleted,
                              semanticLabel: 'Complete ${task.title}',
                              onChanged: busy
                                  ? null
                                  : (_) =>
                                        run(() => repo.toggleComplete(task.id)),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: busy ? null : () => edit(task),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (task.isHighlightOn(repo.clock()))
                                        Text(
                                          'DAILY HIGHLIGHT',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      Text(
                                        task.title,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              decoration: task.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${commitmentLabels[task.commitment]}${task.estimateMinutes == null ? '' : ' · ${task.estimateMinutes} min'}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: task.isHighlightOn(repo.clock())
                                  ? 'Remove highlight'
                                  : 'Set as daily highlight',
                              icon: Icon(
                                task.isHighlightOn(repo.clock())
                                    ? Icons.star
                                    : Icons.star_border,
                              ),
                              onPressed: busy
                                  ? null
                                  : () => run(
                                      () => repo.toggleHighlight(task.id),
                                    ),
                            ),
                            PopupMenuButton<String>(
                              enabled: !busy,
                              tooltip: 'Task options',
                              onSelected: (value) {
                                if (value == 'edit') {
                                  edit(task);
                                } else if (value == 'duplicate') {
                                  edit(task, true);
                                } else {
                                  remove(task);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'duplicate',
                                  child: Text('Duplicate'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Saved on this device · No account needed',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
