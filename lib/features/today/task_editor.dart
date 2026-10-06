import 'package:flutter/material.dart';
import '../../data/task_repo.dart';
import '../../models/task.dart';

const commitmentLabels = ['Idea', 'Maybe', 'Today', 'Now'];

class TaskEditor extends StatefulWidget {
  const TaskEditor({super.key, required this.repo, this.task});
  final TaskRepo repo;
  final Task? task;
  @override
  State<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  final form = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.task?.title);
  late final minutes = TextEditingController(
    text: widget.task?.estimateMinutes?.toString(),
  );
  late int commitment = widget.task?.commitment ?? 2;
  bool saving = false;
  String? error;

  @override
  void dispose() {
    title.dispose();
    minutes.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.repo.save(
        id: widget.task?.id,
        title: title.text,
        commitment: commitment,
        estimateMinutes: minutes.text.trim().isEmpty
            ? null
            : int.parse(minutes.text.trim()),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = 'Could not save this task. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving,
    child: AlertDialog(
      title: Text(widget.task == null ? 'Add task' : 'Edit task'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: title,
                  autofocus: true,
                  enabled: !saving,
                  maxLength: 200,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    hintText: 'What would you like to finish?',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a task title.'
                      : null,
                ),
                const SizedBox(height: 16),
                Text('Commitment · ${commitmentLabels[commitment]}'),
                Slider(
                  value: commitment.toDouble(),
                  min: 0,
                  max: 3,
                  divisions: 3,
                  label: commitmentLabels[commitment],
                  semanticFormatterCallback: (value) =>
                      commitmentLabels[value.round()],
                  onChanged: saving
                      ? null
                      : (value) => setState(() => commitment = value.round()),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: minutes,
                  enabled: !saving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Estimated minutes (optional)',
                    hintText: 'e.g. 2',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final number = int.tryParse(value.trim());
                    return number == null || number < 1 || number > 1440
                        ? 'Enter a whole number from 1 to 1440.'
                        : null;
                  },
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: saving ? null : save,
          child: Text(saving ? 'Saving…' : 'Save task'),
        ),
      ],
    ),
  );
}
