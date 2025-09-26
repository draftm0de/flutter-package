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
  });
}
