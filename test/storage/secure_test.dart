import 'package:draftmode/storage/secure.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _SecureEntity {}

class _FakeFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String?> _values = <String, String?>{};

  @override
  Future<void> write({
    required String key,
    String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _values[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _values.remove(key);
  }
}

void main() {
  group('DraftModeStorageSecure', () {
    late _FakeFlutterSecureStorage fakeStore;
    late DraftModeStorageSecure storage;

    setUp(() {
      fakeStore = _FakeFlutterSecureStorage();
      storage = DraftModeStorageSecure(_SecureEntity, secureStorage: fakeStore);
    });

    test('derives key from type name', () {
      final Type type = _SecureEntity;
      expect(storage.key, equals(type.toString()));
    });

    test('reads and writes values using injected secure storage', () async {
      await storage.write('secret');
      expect(await storage.read(), 'secret');
    });

    test('delete removes stored value', () async {
      await storage.write('secret');
      await storage.delete();

      expect(await storage.read(), isNull);
    });
  });
}
