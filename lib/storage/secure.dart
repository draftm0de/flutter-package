import 'entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DraftModeSecureStorage implements DraftModeEntityStorage {
  final FlutterSecureStorage _ss;
  final String _key;
  DraftModeSecureStorage(Type type) :
    _ss = const FlutterSecureStorage(),
    _key = type.toString();

  @override
  String get key => _key;

  @override
  Future<String?> read() => _ss.read(key: _key);

  @override
  Future<void> write(String value) =>
      _ss.write(key: _key, value: value);

  @override
  Future<void> delete() => _ss.delete(key: _key);
}