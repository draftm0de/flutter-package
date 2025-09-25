import 'package:shared_preferences/shared_preferences.dart';

import 'interface.dart';

typedef _PreferencesFactory = Future<SharedPreferences> Function();

/// [DraftModeStorage] backed by `SharedPreferences`, primarily for
/// lightweight non-sensitive data persisted on device.
class DraftModeStorageShared implements DraftModeStorage {
  DraftModeStorageShared(Type type, {_PreferencesFactory? preferencesFactory})
    : _key = type.toString(),
      _preferencesFactory = preferencesFactory ?? SharedPreferences.getInstance;

  final String _key;
  final _PreferencesFactory _preferencesFactory;

  @override
  String get key => _key;

  Future<SharedPreferences> _prefs() => _preferencesFactory();

  @override
  Future<String?> read() async {
    final prefs = await _prefs();
    return prefs.getString(_key);
  }

  @override
  Future<void> write(String value) async {
    final prefs = await _prefs();
    await prefs.setString(_key, value);
  }

  @override
  Future<void> delete() async {
    final prefs = await _prefs();
    await prefs.remove(_key);
  }
}
