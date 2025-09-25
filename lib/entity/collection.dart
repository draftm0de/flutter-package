import 'package:collection/collection.dart';
import 'package:draftmode/entity.dart';

/// Contract describing items that can live inside a
/// [DraftModeEntityCollection]. Implementations must expose a stable
/// identifier via [getId] so lookups can operate without scanning the whole
/// collection.
abstract class DraftModeEntityCollectionItem<KeyType> {
  KeyType getId();
}

/// Serializes a [DraftModeEntityCollection] by delegating to an injected
/// [DraftModeEntityMapper] for individual items.
class DraftModeEntityCollectionMapper<
  Item extends DraftModeEntityCollectionItem
> {
  final DraftModeEntityMapper itemMapper;
  DraftModeEntityCollectionMapper(this.itemMapper);

  List<Item> fromMap(List<dynamic>? raw) {
    if (raw == null) return [];
    final List<Item> items = raw
        .map<Item>(
          (e) => itemMapper.fromMap((e as Map).cast<String, dynamic>()),
        )
        .toList();
    return items;
  }

  List<Map<String, dynamic>> toMap(DraftModeEntityCollection<Item> collection) {
    return collection.items.map((e) => itemMapper.toMap(e)).toList();
  }
}

/// Mutable wrapper around a list of entity [Item]s that keeps the underlying
/// list instance stable so widgets depending on identity do not rebuild.
class DraftModeEntityCollection<Item extends DraftModeEntityCollectionItem> {
  final List<Item> _items;
  DraftModeEntityCollection([List<Item>? items]) : _items = items ?? [];

  List<Item> get items => _items;

  /// Replaces the collection contents while keeping the backing list instance
  /// alive, which helps list-based widgets maintain element identity.
  set items(List<Item> items) {
    _items
      ..clear()
      ..addAll(items);
  }

  /// Returns the first element whose [DraftModeEntityCollectionItem.getId]
  /// matches [id], or `null` when no match is found.
  Item? getById(dynamic id) => _items.firstWhereOrNull((e) => e.getId() == id);
}
