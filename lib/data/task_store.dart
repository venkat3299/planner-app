import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';

class TaskStore {
  TaskStore(this._prefs);

  static const String _key = 'tasks_v1';
  final SharedPreferences _prefs;

  List<Task> load() {
    final String? raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <Task>[];
    }
    return Task.decodeList(raw);
  }

  Future<void> save(List<Task> tasks) async {
    await _prefs.setString(_key, Task.encodeList(tasks));
  }
}
