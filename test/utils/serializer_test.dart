import 'package:draftmode/utils/serializer.dart';
import 'package:test/test.dart';

class _User {
  _User(this.id, this.name);
  final int id;
  final String name;

  static _User fromJson(Map<String, dynamic> json) =>
      _User(json['id'] as int, json['name'] as String);
}

void main() {
  group('DraftModeSerializer', () {
    test('decodes JSON objects into models', () {
      const json = '{"id": 7, "name": "Alice"}';
      final serializer = DraftModeSerializer();
      final user = serializer.decodeObject(json, _User.fromJson);

      expect(user.id, 7);
      expect(user.name, 'Alice');
    });

    test('throws FormatException for invalid JSON object', () {
      const json = '[1, 2, 3]';
      final serializer = DraftModeSerializer();

      expect(
        () => serializer.decodeObject(json, _User.fromJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for malformed JSON', () {
      const json = '{"id": }';
      final serializer = DraftModeSerializer();

      expect(
        () => serializer.decodeObject(json, _User.fromJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('wraps unexpected errors in FormatException', () {
      const json = '{"id": 1}';
      final serializer = DraftModeSerializer();

      expect(
        () => serializer.decodeObject(json, (map) => throw StateError('nope')),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('nope'),
          ),
        ),
      );
    });

    test('decodes JSON array into list of models', () {
      const json = '[{"id": 1, "name": "Alice"}, {"id": 2, "name": "Bob"}]';
      final serializer = DraftModeSerializer();
      final users = serializer.decodeObjectList(json, _User.fromJson);

      expect(users, hasLength(2));
      expect(users.first.id, 1);
      expect(users.first.name, 'Alice');
      expect(users.last.id, 2);
      expect(users.last.name, 'Bob');
    });

    test('returns empty list when JSON string is empty', () {
      const json = '   ';
      final serializer = DraftModeSerializer();
      final users = serializer.decodeObjectList(json, _User.fromJson);

      expect(users, isEmpty);
    });

    test('returns empty list when payload is json null', () {
      const json = 'null';
      final serializer = DraftModeSerializer();
      final users = serializer.decodeObjectList(json, _User.fromJson);

      expect(users, isEmpty);
    });

    test('returns empty list when JSON string is null', () {
      final serializer = DraftModeSerializer();
      final users = serializer.decodeObjectList(null, _User.fromJson);

      expect(users, isEmpty);
    });

    test('follows route to decode nested list', () {
      const json = '{"payload": {"results": [{"id": 3, "name": "Carol"}]}}';
      final serializer = DraftModeSerializer();
      final users = serializer.decodeObjectList(
        json,
        _User.fromJson,
        nodeRoute: const ['payload', 'results'],
      );

      expect(users.single.id, 3);
      expect(users.single.name, 'Carol');
    });

    test('returns empty list when route segment is missing', () {
      const json = '{"payload": {"other": []}}';
      final serializer = DraftModeSerializer();
      final users = serializer.decodeObjectList(
        json,
        _User.fromJson,
        nodeRoute: const ['payload', 'results'],
      );

      expect(users, isEmpty);
    });

    test('throws FormatException when route encounters non-object', () {
      const json = '{"payload": []}';
      final serializer = DraftModeSerializer();

      expect(
        () => serializer.decodeObjectList(
          json,
          _User.fromJson,
          nodeRoute: const ['payload', 'results'],
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when routed value is not an array', () {
      const json = '{"payload": {"result": {"id": 8, "name": "Eve"}}}';
      final serializer = DraftModeSerializer();

      expect(
        () => serializer.decodeObjectList(
          json,
          _User.fromJson,
          nodeRoute: const ['payload', 'result'],
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when JSON array contains non-objects', () {
      const json = '[{"id": 1}, 42]';
      final serializer = DraftModeSerializer();

      expect(
        () => serializer.decodeObjectList(json, _User.fromJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when JSON is not an array', () {
      const json = '{"users": []}';
      final serializer = DraftModeSerializer();

      expect(
        () => serializer.decodeObjectList(json, _User.fromJson),
        throwsA(isA<FormatException>()),
      );
    });

    test(
      'wraps unexpected errors from decodeObjectList in FormatException',
      () {
        const json = '[{"id": 1}]';
        final serializer = DraftModeSerializer();

        expect(
          () => serializer.decodeObjectList(
            json,
            (map) => throw StateError('nope'),
          ),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              contains('nope'),
            ),
          ),
        );
      },
    );
  });
}
