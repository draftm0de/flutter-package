import 'package:flutter/foundation.dart';
import 'shared_storage.dart';
import 'secure_storage.dart';

class SecretStorage {
  late final dynamic _repo;

  SecretStorage() {
    if (kIsWeb) {
      _repo = SharedStorage();
    } else {
      _repo = SecureStorage();
    }
  }

  Future<String?> read(String key) => _repo.read(key);

  Future<void> write(String key, String? value) => _repo.write(key, value);

  Future<void> delete(String key) => _repo.delete(key);
}
