import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'interface.dart';

/// Secure implementation backed by [FlutterSecureStorage], suited for secrets
/// or tokens that require OS-level protection.
class DraftModeStorageSecure implements DraftModeStorage {
  DraftModeStorageSecure(Type type, {FlutterSecureStorage? secureStorage})
    : _store = secureStorage ?? const FlutterSecureStorage(),
      _key = type.toString();

  final FlutterSecureStorage _store;
  final String _key;

  @override
  String get key => _key;

  @override
  Future<String?> read() => _store.read(key: _key);

  @override
  Future<void> write(String value) => _store.write(key: _key, value: value);

  @override
  Future<void> delete() => _store.delete(key: _key);
}
