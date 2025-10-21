import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

/// Provides access to the application's [Isar] instance.
///
/// The provider is intended to be overridden at bootstrap time with an
/// initialized database instance. See `main.dart` for an example of how to
/// override it when the app starts.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'The Isar instance has not been initialized. Override isarProvider in '
    'ProviderScope to supply a database.',
  );
});
