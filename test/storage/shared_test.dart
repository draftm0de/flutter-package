import 'package:draftmode/storage/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestEntity {}

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
}
