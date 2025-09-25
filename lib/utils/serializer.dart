import 'dart:convert';

/// Minimal helper for turning JSON objects into strongly typed models.
class DraftModeSerializer {
  const DraftModeSerializer();

  /// Parses [jsonString] and invokes [fromJson] when the payload is a
  /// JSON object. Throws a [FormatException] when the input is not a JSON
  /// object or when parsing fails.
  T decodeObject<T>(
    String jsonString,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }
      return fromJson(Map<String, dynamic>.from(decoded));
    } on FormatException catch (e) {
      throw FormatException('Failed to parse JSON: ${e.message}');
    } catch (e) {
      throw FormatException('Failed to parse JSON: $e');
    }
  }
}
