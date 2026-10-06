import 'package:shared_preferences/shared_preferences.dart';

abstract interface class TaskStore {
  Future<String?> read();
  Future<void> write(String value);
}

/// One versioned JSON snapshot, stored on the current device/browser profile.
class PreferencesTaskStore implements TaskStore {
  static const key = 'ticktasker.tasks.v1';

  @override
  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(key);

  @override
  Future<void> write(String value) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(key, value)) {
      throw StateError('Task storage could not be updated.');
    }
  }
}
