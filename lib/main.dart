import 'package:flutter/material.dart';
import 'data/task_repo.dart';
import 'data/task_store.dart';
import 'features/today/today_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TickTaskerApp());
}

class TickTaskerApp extends StatefulWidget {
  const TickTaskerApp({super.key, this.repository});
  final TaskRepo? repository;
  @override
  State<TickTaskerApp> createState() => _TickTaskerAppState();
}

class _TickTaskerAppState extends State<TickTaskerApp> {
  late final TaskRepo repo =
      widget.repository ?? TaskRepo(PreferencesTaskStore());
  late Future<void> loading = repo.load();

  @override
  void dispose() {
    if (widget.repository == null) repo.dispose();
    super.dispose();
  }

  ThemeData theme(Brightness brightness) => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF286859),
      brightness: brightness,
    ),
    scaffoldBackgroundColor: brightness == Brightness.light
        ? const Color(0xFFF5F7F5)
        : null,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TickTasker',
    debugShowCheckedModeBanner: false,
    theme: theme(Brightness.light),
    darkTheme: theme(Brightness.dark),
    home: FutureBuilder<void>(
      future: loading,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Your tasks could not be loaded.',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your saved data has been kept. Retry to open your workspace.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => setState(() {
                        loading = repo.load();
                      }),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return TodayPage(repo: repo);
      },
    ),
  );
}
