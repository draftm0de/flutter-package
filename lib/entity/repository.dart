import 'dart:convert';

import '../storage/interface.dart';

/// Translates a value of type [T] between strongly typed objects and raw map
/// representations stored by a [DraftModeEntityRepository]. Implementations are
/// expected to be pure and deterministic.
abstract class DraftModeEntityMapperInterface<T> {
  T fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap(T value);
  Future<T> empty();
}

/// Base class for JSON-backed repositories. Handles encoding/decoding and
/// delegates concrete mapping logic to [DraftModeEntityMapperInterface].
abstract class DraftModeEntityRepository<T>
    implements DraftModeEntityMapperInterface<T> {
  final DraftModeStorage store;

  DraftModeEntityRepository(this.store);

  /// Reads and decodes the JSON value stored under [store]. When no value is
  /// present, or the payload cannot be interpreted as a map, the repository
  /// falls back to [empty].
  Future<T> read() async {
    final raw = await store.read();
    if (raw == null) return empty();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return empty();
    return fromMap(decoded);
  }

  /// Persists [value] by encoding it to JSON via [toMap].
  Future<void> write(T value) async {
    await store.write(jsonEncode(toMap(value)));
  }

  /// Removes the stored value entirely.
  Future<void> delete() => store.delete();
}
