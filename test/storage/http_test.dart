import 'package:draftmode/storage/http.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

class _TrackingClient extends http.BaseClient {
  bool didClose = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw UnimplementedError('send should not be called during this test');
  }

  @override
  void close() {
    didClose = true;
  }
}

void main() {
  group('DraftModeStorageHttp.fetchAll', () {
    test('performs GET with headers and query parameters', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'https://api.example.com/items?page=1');
        expect(request.headers['x-user'], 'alice');
        return http.Response('[]', 200);
      });
      final storage = DraftModeStorageHttp(client: client);
      addTearDown(storage.close);

      final response = await storage.fetchAll(
        'https://api.example.com/items',
        queryParameters: const {'page': '1'},
        headers: const {'x-user': 'alice'},
      );

      expect(response.statusCode, 200);
      expect(response.body, '[]');
    });

    test('propagates non-success responses unchanged', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        return http.Response('oops', 503);
      });
      final storage = DraftModeStorageHttp(client: client);
      addTearDown(storage.close);

      final response = await storage.fetchAll('https://api.example.com/items');

      expect(response.statusCode, 503);
      expect(response.body, 'oops');
    });
  });

  group('DraftModeStorageHttp.delete', () {
    test('performs DELETE request and returns response', () async {
      final client = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.toString(), 'https://api.example.com/items/1');
        expect(request.headers['x-api-key'], 'secret');
        return http.Response('', 204);
      });
      final storage = DraftModeStorageHttp(client: client);
      addTearDown(storage.close);

      final response = await storage.delete(
        'https://api.example.com/items/1',
        headers: const {'x-api-key': 'secret'},
      );

      expect(response.statusCode, 204);
    });

    test('propagates non-success responses', () async {
      final client = MockClient((request) async {
        expect(request.method, 'DELETE');
        return http.Response('', 404);
      });
      final storage = DraftModeStorageHttp(client: client);
      addTearDown(storage.close);

      final response = await storage.delete('https://api.example.com/items/1');

      expect(response.statusCode, 404);
    });
  });

  group('DraftModeStorageHttp.post', () {
    test('performs POST request with body and headers', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), 'https://api.example.com/items');
        expect(request.bodyFields, {'name': 'draft'});
        expect(request.headers['x-api-key'], 'secret');
        return http.Response('', 201);
      });
      final storage = DraftModeStorageHttp(client: client);
      addTearDown(storage.close);

      final response = await storage.post(
        'https://api.example.com/items',
        body: const {'name': 'draft'},
        headers: const {'x-api-key': 'secret'},
      );

      expect(response.statusCode, 201);
    });

    test('propagates non-success responses', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        return http.Response('', 409);
      });
      final storage = DraftModeStorageHttp(client: client);
      addTearDown(storage.close);

      final response = await storage.post('https://api.example.com/items');

      expect(response.statusCode, 409);
    });
  });

  group('DraftModeStorageHttp.close', () {
    test('disposes the owned client', () {
      final storage = DraftModeStorageHttp();

      expect(storage.close, returnsNormally);
    });

    test('does not close injected client', () {
      final client = _TrackingClient();
      final storage = DraftModeStorageHttp(client: client);

      storage.close();

      expect(client.didClose, isFalse);
    });
  });
}
