import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thin wrapper around [http.Client] used by repositories that need to fetch
/// collections from REST endpoints.
class DraftModeStorageHttp {
  DraftModeStorageHttp({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;

  /// Fetches all entities from the provided REST [url].
  ///
  /// When [nodeItem] is provided the response is expected to be a JSON object and
  /// the list is read from that property. Otherwise the payload can be either a
  /// JSON list or a single object which will be coerced into a single-item
  /// collection.
  Future<List<T>> fetchAll<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    String? nodeItem,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParameters);

    final response = await _client.get(uri, headers: headers);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'HTTP ${response.statusCode}: ${response.reasonPhrase ?? 'Unknown error'}',
        uri,
      );
    }

    final dynamic decoded = response.body.isEmpty
        ? null
        : jsonDecode(response.body);

    if (decoded == null) {
      return <T>[];
    }

    final dynamic payload;
    if (nodeItem != null) {
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected JSON object when reading node');
      }
      payload = decoded[nodeItem];
    } else {
      payload = decoded;
    }

    if (payload == null) {
      return <T>[];
    }

    if (payload is List) {
      return payload.map<T>((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Expected JSON objects inside array');
        }
        return fromJson(item);
      }).toList();
    }

    if (payload is Map<String, dynamic>) {
      return <T>[fromJson(payload)];
    }

    throw const FormatException('Unsupported JSON structure for fetchAll');
  }

  /// Issues an HTTP DELETE request and returns `true` for any 2xx response.
  Future<bool> delete(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParameters);

    final response = await _client.delete(uri, headers: headers);

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// Closes the underlying [http.Client]. Call when the instance is no longer
  /// needed to dispose of network resources.
  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
