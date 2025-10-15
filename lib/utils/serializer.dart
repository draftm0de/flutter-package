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

  /// Parses [jsonString] and invokes [fromJson] for every entry in the payload
  /// when the input is a JSON array of objects. When [nodeRoute] is provided the
  /// decoded payload must be a JSON object and its nested value is resolved by
  /// following the segments in [nodeRoute]. Throws a [FormatException] when the
  /// resulting payload is not a JSON array, when an entry is not a JSON object,
  /// or when parsing fails.
  List<T> decodeObjectList<T>(
    String? jsonString,
    T Function(Map<String, dynamic>) fromJson, {
    List<String>? nodeRoute,
  }) {
    try {
      if (jsonString == null || jsonString.trim().isEmpty) {
        return const [];
      }

      final dynamic decoded = jsonDecode(jsonString);
      if (decoded == null) {
        return const [];
      }
      dynamic payload = decoded;

      if (nodeRoute != null && nodeRoute.isNotEmpty) {
        if (payload is! Map) {
          throw const FormatException('Expected a JSON object.');
        }
        payload = Map<String, dynamic>.from(payload);

        for (final segment in nodeRoute) {
          if (payload is! Map<String, dynamic>) {
            throw const FormatException('Expected a JSON object.');
          }
          if (!payload.containsKey(segment)) {
            return const [];
          }
          final dynamic next = payload[segment];
          if (next == null) {
            return const [];
          }
          if (next is Map) {
            payload = Map<String, dynamic>.from(next);
          } else {
            payload = next;
          }
        }
      }

      if (payload == null) {
        return const [];
      }
      if (payload is Map) {
        throw const FormatException('Expected a JSON array.');
      }
      if (payload is! List) {
        throw const FormatException('Expected a JSON array.');
      }

      return List<T>.generate(payload.length, (index) {
        final dynamic entry = payload[index];
        if (entry is! Map<String, dynamic>) {
          throw const FormatException('Expected a JSON object.');
        }
        return fromJson(Map<String, dynamic>.from(entry));
      }, growable: false);
    } on FormatException catch (e) {
      throw FormatException('Failed to parse JSON: ${e.message}');
    } catch (e) {
      throw FormatException('Failed to parse JSON: $e');
    }
  }
}
