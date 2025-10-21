import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/task_repo.dart';
import '../../models/task.dart';

class TodayPage extends ConsumerStatefulWidget {
  const TodayPage({super.key});

  @override
  ConsumerState<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends ConsumerState<TodayPage> {
  bool twoMinuteOnly = false;
  int? minCommitment;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(taskRepoProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('TickTasker')),
      body: StreamBuilder<List<Task>>(
        stream: repo.watchToday(
          twoMinuteOnly: twoMinuteOnly,
          minCommitment: minCommitment,
        ),
        builder: (context, snap) {
          final tasks = snap.data ?? const <Task>[];
          final highlight = tasks.where((t) => t.isHighlight).toList();
          final rest = tasks.where((t) => !t.isHighlight).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (highlight.isNotEmpty) _HighlightCard(task: highlight.first),
              if (highlight.isNotEmpty) const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('≤ 2 min'),
                    selected: twoMinuteOnly,
                    onSelected: (v) => setState(() => twoMinuteOnly = v),
                  ),
                  ChoiceChip(
                    label: const Text('Commitment ≥ 2'),
                    selected: minCommitment == 2,
                    onSelected: (v) =>
                        setState(() => minCommitment = v ? 2 : null),
                  ),
                  ChoiceChip(
                    label: const Text('Commitment ≥ 3'),
                    selected: minCommitment == 3,
                    onSelected: (v) =>
                        setState(() => minCommitment = v ? 3 : null),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final t in rest) _TaskTile(task: t),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickAdd,
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showQuickAdd() async {
    final titleCtrl = TextEditingController();
    int commitment = 0;
    int? estimate;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(builder: (ctx, setM) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(hintText: 'Quick task…'),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Commitment'),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: commitment,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('0 Idea')),
                        DropdownMenuItem(value: 1, child: Text('1 Maybe')),
                        DropdownMenuItem(value: 2, child: Text('2 Today')),
                        DropdownMenuItem(value: 3, child: Text('3 Now')),
                      ],
                      onChanged: (v) => setM(() => commitment = v ?? 0),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 90,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: '~min'),
                        onChanged: (v) => estimate = int.tryParse(v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final repo = ref.read(taskRepoProvider);
                    await repo.addQuick(
                      title: titleCtrl.text,
                      commitment: commitment,
                      estimateMinutes: estimate,
                    );
                    if (context.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Add task'),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
        );
      },
    );
    titleCtrl.dispose();
  }
}

class _HighlightCard extends ConsumerWidget {
  const _HighlightCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.star, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _CommitmentPill(commitment: task.commitment),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(taskRepoProvider);
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (_) => repo.toggleComplete(task),
      ),
      title: Text(task.title),
      subtitle: Row(
        children: [
          _CommitmentPill(commitment: task.commitment),
          if (task.isTwoMinute) const SizedBox(width: 8),
          if (task.isTwoMinute)
            const Text('≤2m', style: TextStyle(fontSize: 12)),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.push_pin_outlined),
        tooltip: 'Set as Highlight',
        onPressed: () => repo.setHighlight(task),
      ),
    );
  }
}

class _CommitmentPill extends StatelessWidget {
  const _CommitmentPill({required this.commitment});

  final int commitment;

  @override
  Widget build(BuildContext context) {
    final labels = ['0', '1', '2', '3'];
    final index = commitment.clamp(0, labels.length - 1).toInt();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        'C${labels[index]}',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
