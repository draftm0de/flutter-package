import 'package:flutter_test/flutter_test.dart';
import 'package:draftmode/entity/collection.dart';
import 'package:draftmode/entity/repository.dart';

class _TestItem implements DraftModeEntityCollectionItem<int> {
  const _TestItem(this.id, this.label);
  final int id;
  final String label;

  @override
  int getId() => id;
}

class _TestItemMapper extends DraftModeEntityMapper<_TestItem> {
  @override
  Future<_TestItem> empty() async => const _TestItem(-1, 'empty');

  @override
  _TestItem fromMap(Map<String, dynamic> map) {
    return _TestItem(map['id'] as int, map['label'] as String);
  }

  @override
  Map<String, dynamic> toMap(_TestItem value) {
    return <String, dynamic>{
      'id': value.id,
      'label': value.label,
    };
  }
}

void main() {
  group('DraftModeEntityCollectionMapper', () {
    test('fromMap returns empty list when raw is null', () {
      final mapper = DraftModeEntityCollectionMapper<_TestItem>(_TestItemMapper());

      expect(mapper.fromMap(null), isEmpty);
    });

    test('fromMap converts dynamic list using item mapper', () {
      final mapper = DraftModeEntityCollectionMapper<_TestItem>(_TestItemMapper());

      final items = mapper.fromMap(<dynamic>[
        <String, dynamic>{'id': 1, 'label': 'foo'},
        <String, dynamic>{'id': 2, 'label': 'bar'},
      ]);

      expect(items.map((e) => e.label), ['foo', 'bar']);
    });

    test('toMap delegates to item mapper', () {
      final mapper = DraftModeEntityCollectionMapper<_TestItem>(_TestItemMapper());
      final collection = DraftModeEntityCollection<_TestItem>([
        const _TestItem(1, 'foo'),
        const _TestItem(2, 'bar'),
      ]);

      final result = mapper.toMap(collection);

      expect(result, [
        {'id': 1, 'label': 'foo'},
        {'id': 2, 'label': 'bar'},
      ]);
    });
  });

  group('DraftModeEntityCollection', () {
    test('items setter replaces contents without swapping list reference', () {
      final initial = DraftModeEntityCollection<_TestItem>([
        const _TestItem(1, 'a'),
      ]);

      final sameRef = identical(initial.items, initial.items);
      expect(sameRef, isTrue);

      final listRef = initial.items;
      initial.items = [
        const _TestItem(2, 'b'),
      ];

      expect(identical(initial.items, listRef), isTrue);
      expect(initial.items.single.id, 2);
    });

    test('getById finds matching element and returns null otherwise', () {
      final collection = DraftModeEntityCollection<_TestItem>([
        const _TestItem(1, 'a'),
        const _TestItem(2, 'b'),
      ]);

      expect(collection.getById(2)?.label, 'b');
      expect(collection.getById(999), isNull);
    });
  });
}
