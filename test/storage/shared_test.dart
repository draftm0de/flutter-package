import 'package:draftmode/storage/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestEntity {}

class _StoredUser {
  const _StoredUser(this.id, this.name);

  final int id;
  final String name;

  static _StoredUser fromJson(Map<String, dynamic> json) =>
      _StoredUser(json['id'] as int, json['name'] as String);

  static Map<String, dynamic> toJson(_StoredUser user) => <String, dynamic>{
    'id': user.id,
    'name': user.name,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DraftModeStorageShared', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('derives key from type name', () {
      final storage = DraftModeStorageShared(_TestEntity);
      final Type type = _TestEntity;
      expect(storage.key, equals(type.toString()));
    });

    test('reads and writes values through shared preferences', () async {
      final storage = DraftModeStorageShared(_TestEntity);

      await storage.write('payload');
      expect(await storage.read(), 'payload');
    });

    test('delete removes the stored value', () async {
      final storage = DraftModeStorageShared(_TestEntity);

      await storage.write('payload');
      await storage.delete();

      expect(await storage.read(), isNull);
    });
  });

  group('DraftModeStorageEntityShared', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('persists and retrieves typed entities', () async {
      final storage = DraftModeStorageEntityShared<_StoredUser>(
        fromJson: _StoredUser.fromJson,
        toJson: _StoredUser.toJson,
      );

      const user = _StoredUser(7, 'Alice');

      final didWrite = await storage.writeEntity(user);
      expect(didWrite, isTrue);

      final restored = await storage.entityRead<_StoredUser>();
      expect(restored?.id, user.id);
      expect(restored?.name, user.name);
    });

    test('returns null when no entity stored', () async {
      final storage = DraftModeStorageEntityShared<_StoredUser>(
        fromJson: _StoredUser.fromJson,
        toJson: _StoredUser.toJson,
      );

      final restored = await storage.entityRead<_StoredUser>();

      expect(restored, isNull);
    });

    test('deleteEntity clears persisted value', () async {
      final storage = DraftModeStorageEntityShared<_StoredUser>(
        fromJson: _StoredUser.fromJson,
        toJson: _StoredUser.toJson,
      );

      const user = _StoredUser(1, 'Bob');
      await storage.writeEntity(user);

      final didDelete = await storage.deleteEntity();
      expect(didDelete, isTrue);
      expect(await storage.read(), isNull);
    });
  });
}
