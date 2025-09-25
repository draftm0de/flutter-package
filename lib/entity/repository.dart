import 'dart:convert';
import '../storage/entity.dart';

abstract class DraftModeEntityMapper<T> {
  T fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap(T value);
  Future<T> empty();
}

abstract class DraftModeEntityRepository<T> implements DraftModeEntityMapper<T> {
  final DraftModeEntityStorage store;

  DraftModeEntityRepository(this.store);

  Future<T> read() async {
    final raw = await store.read();
    if (raw == null) return empty();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return empty();
    return fromMap(decoded);
  }

  Future<void> write(T value) async {
    await store.write(jsonEncode(toMap(value)));
  }

  Future<void> delete() => store.delete();
}