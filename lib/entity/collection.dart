import 'package:collection/collection.dart';
import 'package:draftmode/entity.dart';

abstract class DraftModeEntityCollectionItem<KeyType> {
  KeyType getId();
}

class DraftModeEntityCollectionMapper<Item extends DraftModeEntityCollectionItem> {
  final DraftModeEntityMapper itemMapper;
  DraftModeEntityCollectionMapper(this.itemMapper);

  List<Item> fromMap(List<dynamic>? raw) {
    if (raw == null) return [];
    final List<Item> items = raw
        .map<Item>((e) => itemMapper.fromMap((e as Map).cast<String, dynamic>()))
        .toList();
    return items;
  }

  List<Map<String, dynamic>> toMap(DraftModeEntityCollection<Item> collection) {
    return collection.items.map((e) => itemMapper.toMap(e)).toList();
  }
}

class DraftModeEntityCollection<Item extends DraftModeEntityCollectionItem> {
  final List<Item> _items;
  DraftModeEntityCollection([List<Item>? items]) : _items = items ?? [];

  List<Item> get items => _items;
  set items(List<Item> items) {
    _items
      ..clear()
      ..addAll(items);
  }
  Item? getById(dynamic id) => _items.firstWhereOrNull((e) => e.getId() == id);
}
