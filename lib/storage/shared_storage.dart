import 'package:shared_preferences/shared_preferences.dart';

class SharedStorage {
  Future<String?> read(String key) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    return storage.getString(key);
  }

  Future<void> write(String key, String? value) async {
    if (value == null) {
      await delete(key);
    } else {
      final SharedPreferences storage = await SharedPreferences.getInstance();
      await storage.setString(key, value);
    }
  }

  Future<void> delete(String key) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.remove(key);
  }
}
