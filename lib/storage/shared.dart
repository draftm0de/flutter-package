import 'dart:convert';

import 'package:draftmode/utils/serializer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'interface.dart';

typedef _PreferencesFactory = Future<SharedPreferences> Function();

class DraftModeStorageEntityShared<T> extends DraftModeStorageShared {
  final Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  final serializer = DraftModeSerializer();

  DraftModeStorageEntityShared({
    required this.fromJson,
    required this.toJson,
    _PreferencesFactory? preferencesFactory,
  }) : super(T, preferencesFactory: preferencesFactory);

  Future<T?> entityRead<T>() async {
    final jsonData = await super.read();
    return serializer.decodeObject(jsonData, (e) => fromJson(e));
  }

  Future<bool> writeEntity(T entity) async {
    final jsonString = jsonEncode(toJson(entity));
    return await super.write(jsonString);
  }

  Future<void> deleteEntity() async => await super.delete();
}

/// [DraftModeStorage] backed by `SharedPreferences`, primarily for
/// lightweight non-sensitive data persisted on device.
class DraftModeStorageShared {
  final String _key;
  final _PreferencesFactory _preferencesFactory;

  DraftModeStorageShared(Type type, {_PreferencesFactory? preferencesFactory})
    : _key = type.toString(),
      _preferencesFactory = preferencesFactory ?? SharedPreferences.getInstance;

  String get key => _key;

  Future<SharedPreferences> _prefs() => _preferencesFactory();

  Future<bool> write(String value) async {
    final prefs = await _prefs();
    return await prefs.setString(_key, value);
  }

  Future<void> delete() async {
    final prefs = await _prefs();
    await prefs.remove(_key);
  }

  Future<String?> read() async {
    final prefs = await _prefs();
    return prefs.getString(_key);
  }
}
