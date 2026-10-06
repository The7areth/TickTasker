import 'package:flutter/material.dart';

void main() {
  runApp(const TickTaskerApp());
}

class TickTaskerApp extends StatelessWidget {
  const TickTaskerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TickTasker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2A9D8F)),
      ),
      home: const TickTaskerHomePage(),
    );
  }
}

class TickTaskerHomePage extends StatefulWidget {
  const TickTaskerHomePage({super.key});

  @override
  State<TickTaskerHomePage> createState() => _TickTaskerHomePageState();
}

class _TickTaskerHomePageState extends State<TickTaskerHomePage> {
  int _commitmentLevel = 1;
  bool _showTwoMinuteOnly = false;

  static const List<_TaskItem> _tasks = [
    _TaskItem(title: 'Reply to the design question', isTwoMinuteTask: true),
    _TaskItem(title: 'Outline weekly report (15 min)', isTwoMinuteTask: false),
    _TaskItem(title: 'Schedule one focus block', isTwoMinuteTask: true),
  ];

  @override
  Widget build(BuildContext context) {
    final tasksToDisplay = _showTwoMinuteOnly
        ? _tasks.where((task) => task.isTwoMinuteTask).toList()
        : _tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TickTasker'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Finish one meaningful thing today.',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'A calm MVP shell for Daily Highlight planning and lightweight momentum tracking.',
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Daily Highlight',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Today\'s highlight: Ship the first TickTasker polish PR.'),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Text('Keep this as today\'s focus'),
                ),
              ],
            ),
          ),
          _SectionCard(
            title: 'Commitment Slider (0–3)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Commitment level: $_commitmentLevel / 3'),
                Slider(
                  value: _commitmentLevel.toDouble(),
                  min: 0,
                  max: 3,
                  divisions: 3,
                  label: '$_commitmentLevel',
                  onChanged: (value) {
                    setState(() {
                      _commitmentLevel = value.round();
                    });
                  },
                ),
              ],
            ),
          ),
          _SectionCard(
            title: 'Two-Day Rule',
            child: const Text(
              'Missing one day is normal. Missing two in a row is the line to protect. '
              'Use this reminder to restart quickly without guilt.',
            ),
          ),
          _SectionCard(
            title: 'Two-Minute Tasks',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _showTwoMinuteOnly,
                  onChanged: (value) {
                    setState(() {
                      _showTwoMinuteOnly = value;
                    });
                  },
                  title: const Text('Show only two-minute tasks'),
                ),
                const SizedBox(height: 8),
                for (final task in tasksToDisplay)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(task.title),
                    subtitle: Text(
                      task.isTwoMinuteTask ? 'Two-minute task' : 'Longer task',
                    ),
                    leading: const Icon(Icons.check_box_outline_blank),
                  ),
              ],
            ),
          ),
          _SectionCard(
            title: 'Study → Write Pipeline',
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Study inbox'),
                  subtitle: Text('Capture ideas, excerpts, and references.'),
                  leading: Icon(Icons.menu_book_outlined),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Write queue'),
                  subtitle: Text('Promote clarified notes into shippable writing tasks.'),
                  leading: Icon(Icons.edit_note_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _TaskItem {
  const _TaskItem({required this.title, required this.isTwoMinuteTask});

  final String title;
  final bool isTwoMinuteTask;
}
