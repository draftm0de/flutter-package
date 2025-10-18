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
  Future<http.Response> fetchAll(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(
      url,
    ).replace(queryParameters: _toQueryParameters(queryParameters));

    return await _client.get(uri, headers: headers);
  }

  /// Issues an HTTP DELETE request and returns `true` for any 2xx response.
  Future<http.Response> delete(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(
      url,
    ).replace(queryParameters: _toQueryParameters(queryParameters));

    return await _client.delete(uri, headers: headers);
  }

  /// Issues an HTTP POST request and returns `true` for any 2xx response.
  ///
  /// The provided [body] and [headers] are passed directly to
  /// [http.Client.post], allowing callers to control serialization and
  /// content-type headers explicitly.
  Future<http.Response> post(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);

    return await _client.post(uri, headers: headers, body: body);
  }

  /// Issues an HTTP PUT request and returns the raw [http.Response].
  ///
  /// The provided [body] and [headers] are passed directly to
  /// [http.Client.put], allowing callers to control serialization and
  /// content-type headers explicitly. Optional [queryParameters] are appended
  /// to the request URL before dispatch.
  Future<http.Response> put(
    String url, {
    Map<String, dynamic>? queryParameters,
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(
      url,
    ).replace(queryParameters: _toQueryParameters(queryParameters));

    return await _client.put(uri, headers: headers, body: body);
  }

  /// Closes the underlying [http.Client]. Call when the instance is no longer
  /// needed to dispose of network resources.
  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }

  Map<String, String>? _toQueryParameters(Map<String, dynamic>? source) {
    if (source == null || source.isEmpty) {
      return null;
    }

    final resolved = <String, String>{};
    source.forEach((key, value) {
      if (value == null) {
        resolved[key] = '';
      } else if (value is List) {
        resolved[key] = value.join(',');
      } else {
        resolved[key] = value.toString();
      }
    });
    return resolved;
  }
}
