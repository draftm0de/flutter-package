import 'dart:convert';

class DraftModeSerializer {
  Future<T?> serialize<T>(
    String jsonString,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('received data is not a valid json object.');
      }
      return fromJson(decoded);
    } catch (e) {
      throw Exception('failed to parse json, \$e');
    }
  }
}
