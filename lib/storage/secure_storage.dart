import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  SecureStorage();

  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  Future<void> write(String key, String? value) async {
    if (value == null) {
      await delete(key);
    } else {
      _storage.write(key: key, value: value);
    }
  }

  Future<void> delete(String key) async {
    _storage.delete(key: key);
  }
}
