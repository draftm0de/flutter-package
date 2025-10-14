import 'dart:convert';

import 'package:draftmode/storage/http.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

class _MockEntity {
  const _MockEntity(this.id);

  final int id;
}

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
    test('returns mapped results from a top-level list', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), 'https://api.example.com/items');
        return http.Response(
          jsonEncode([
            {'id': 1},
            {'id': 2},
          ]),
          200,
          headers: const {'content-type': 'application/json'},
        );
      });
      final storage = DraftModeStorageHttp(client: client);
      addTearDown(storage.close);

      final results = await storage.fetchAll<_MockEntity>(
        'https://api.example.com/items',
        fromJson: (json) => _MockEntity(json['id'] as int),
      );

      expect(results.map((entity) => entity.id), [1, 2]);
    });

    test('extracts items from the requested node', () async {
      final client = MockClient((request) async {
        expect(request.url.queryParameters, {'page': '1'});
        expect(request.headers['x-user'], 'alice');
        return http.Response(
          jsonEncode({
            'data': [
              {'id': 7},
            ],
          }),
          200,
          headers: const {'content-type': 'application/json'},
        );
      });
      final storage = DraftModeStorageHttp(client: client);
      addTearDown(storage.close);

      final results = await storage.fetchAll<_MockEntity>(
        'https://api.example.com/items',
        nodeItem: 'data',
        queryParameters: const {'page': '1'},
        headers: const {'x-user': 'alice'},
        fromJson: (json) => _MockEntity(json['id'] as int),
      );

      expect(results.single.id, 7);
    });

    test('returns empty list when the payload is empty', () async {
      final client = MockClient((request) async {
        return http.Response('', 200);
      });
      final storage = DraftModeStorageHttp(client: client);
      addTearDown(storage.close);

      final results = await storage.fetchAll<_MockEntity>(
        'https://api.example.com/items',
        fromJson: (json) => _MockEntity(json['id'] as int),
      );

      expect(results, isEmpty);
    });

    test('returns empty list when the requested node is missing', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({}), 200);
      });
      final storage = DraftModeStorageHttp(client: client);
      addTearDown(storage.close);

      final results = await storage.fetchAll<_MockEntity>(
        'https://api.example.com/items',
        nodeItem: 'data',
        fromJson: (json) => _MockEntity(json['id'] as int),
      );

      expect(results, isEmpty);
    });

    test('converts single objects into a one-item list', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'id': 42}),
          200,
          headers: const {'content-type': 'application/json'},
        );
      });
      final storage = DraftModeStorageHttp(client: client);
      addTearDown(storage.close);

      final results = await storage.fetchAll<_MockEntity>(
        'https://api.example.com/item',
        fromJson: (json) => _MockEntity(json['id'] as int),
      );

      expect(results.map((entity) => entity.id), [42]);
    });

    test('throws http.ClientException when the response is not successful', () {
      final client = MockClient((request) async {
        return http.Response('oops', 404);
      });
      final storage = DraftModeStorageHttp(client: client);
      addTearDown(storage.close);

      expect(
        storage.fetchAll<_MockEntity>(
          'https://api.example.com/items',
          fromJson: (json) => _MockEntity(json['id'] as int),
        ),
        throwsA(isA<http.ClientException>()),
      );
    });

    test('throws FormatException for unexpected payload shapes', () {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'data': 5}), 200);
      });
      final storage = DraftModeStorageHttp(client: client);
      addTearDown(storage.close);

      expect(
        storage.fetchAll<_MockEntity>(
          'https://api.example.com/items',
          nodeItem: 'data',
          fromJson: (json) => _MockEntity(json['id'] as int),
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('DraftModeStorageHttp.delete', () {
    test('returns true for any 2xx status code', () async {
      final client = MockClient((request) async {
        return http.Response('', 204);
      });
      final storage = DraftModeStorageHttp(client: client);
      addTearDown(storage.close);

      final result = await storage.delete('https://api.example.com/items/1');

      expect(result, isTrue);
    });

    test('returns false when the response is not successful', () async {
      final client = MockClient((request) async {
        return http.Response('', 404);
      });
      final storage = DraftModeStorageHttp(client: client);
      addTearDown(storage.close);

      final result = await storage.delete('https://api.example.com/items/1');

      expect(result, isFalse);
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
