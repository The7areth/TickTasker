import 'package:flutter/widgets.dart';

/// Prepares the Flutter application for execution and returns the
/// widget tree that should be mounted.
///
/// Keeping the function async lets us easily add initialization logic
/// (e.g. reading from disk or Firebase) without touching `main.dart`
/// again. For now it simply ensures that Flutter bindings are ready
/// before returning the provided [root] widget.
Future<Widget> bootstrap(Widget root) async {
  WidgetsFlutterBinding.ensureInitialized();
  return root;
}
