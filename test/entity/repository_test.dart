import 'package:draftmode/entity/repository.dart';
import 'package:draftmode/storage/entity.dart';
import 'package:flutter_test/flutter_test.dart';

class _Entity {
  const _Entity(this.value);
  final int value;
}

class _FakeStorage implements DraftModeEntityStorage {
  _FakeStorage({this.readResponse});

  String? readResponse;
  String? writtenValue;
  bool deleteCalled = false;

  @override
  Future<void> delete() async {
    deleteCalled = true;
  }

  @override
  String get key => 'fake';

  @override
  Future<String?> read() async => readResponse;

  @override
  Future<void> write(String value) async {
    writtenValue = value;
  }
}

class _TestRepository extends DraftModeEntityRepository<_Entity> {
  _TestRepository(super.store);

  int emptyCalls = 0;

  @override
  Future<_Entity> empty() async {
    emptyCalls++;
    return const _Entity(-1);
  }

  @override
  _Entity fromMap(Map<String, dynamic> map) {
    return _Entity(map['value'] as int);
  }

  @override
  Map<String, dynamic> toMap(_Entity value) {
    return <String, dynamic>{'value': value.value};
  }
}

void main() {
  group('DraftModeEntityRepository.read', () {
    test('returns empty when storage value is null', () async {
      final store = _FakeStorage(readResponse: null);
      final repo = _TestRepository(store);

      final entity = await repo.read();

      expect(entity.value, -1);
      expect(repo.emptyCalls, 1);
    });

    test('returns empty when decoded payload is not a map', () async {
      final store = _FakeStorage(readResponse: '[]');
      final repo = _TestRepository(store);

      final entity = await repo.read();

      expect(entity.value, -1);
      expect(repo.emptyCalls, 1);
    });

    test('decodes JSON into entity using mapper', () async {
      final store = _FakeStorage(readResponse: '{"value": 42}');
      final repo = _TestRepository(store);

      final entity = await repo.read();

      expect(entity.value, 42);
      expect(repo.emptyCalls, 0);
    });
  });

  group('DraftModeEntityRepository write/delete', () {
    test('write encodes entity into storage', () async {
      final store = _FakeStorage();
      final repo = _TestRepository(store);

      await repo.write(const _Entity(5));

      expect(store.writtenValue, '{"value":5}');
    });

    test('delete delegates to storage', () async {
      final store = _FakeStorage();
      final repo = _TestRepository(store);

      await repo.delete();

      expect(store.deleteCalled, isTrue);
    });
  });
}
