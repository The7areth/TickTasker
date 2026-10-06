import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticktasker/data/task_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'preferences adapter reads and writes the versioned storage key',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = PreferencesTaskStore();
      expect(await store.read(), isNull);
      await store.write('{"version":1,"tasks":[]}');
      expect(await PreferencesTaskStore().read(), '{"version":1,"tasks":[]}');
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString(PreferencesTaskStore.key),
        '{"version":1,"tasks":[]}',
      );
    },
  );
}
