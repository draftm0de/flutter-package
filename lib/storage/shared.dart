import 'entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DraftModeSharedStorage implements DraftModeEntityStorage {
  final String _key;
  DraftModeSharedStorage(Type type) :
    _key = type.toString();

  @override
  String get key => _key;

  @override
  Future<String?> read() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    return storage.getString(_key);
  }

  @override
  Future<bool> write(String value) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setString(_key, value);
    return true;
  }

  @override
  Future<bool> delete() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.remove(_key);
    return true;
  }

}
