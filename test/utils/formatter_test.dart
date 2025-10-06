import 'package:draftmode/utils/formatter.dart';
import 'package:test/test.dart';

void main() {
  group('DraftModeDateTime', () {
    test('yMMdd pads month and day values', () {
      final format = DraftModeDateTime.yMMdd('en_US');
      final formatted = format.format(DateTime(2024, 3, 5));
      expect(formatted.contains('03'), isTrue);
      expect(formatted.contains('05'), isTrue);
    });

    test('parse returns null for empty input and parses ISO strings', () {
      expect(DraftModeDateTime.parse(null), isNull);
      expect(DraftModeDateTime.parse('   '), isNull);
      expect(DraftModeDateTime.parse('not-a-date'), isNull);
      final parsed = DraftModeDateTime.parse('2024-03-05T10:15:00.000Z');
      expect(parsed, isNotNull);
      expect(parsed!.year, 2024);
    });

    test('getDaysInMonth respects leap years', () {
      expect(DraftModeDateTime.getDaysInMonth(2024, 2), 29);
      expect(DraftModeDateTime.getDaysInMonth(2023, 2), 28);
    });

    test('getDaysInMonth handles December rollover', () {
      expect(DraftModeDateTime.getDaysInMonth(2024, 12), 31);
    });

    test('getDurationHourMinutes normalises negative durations', () {
      final from = DateTime(2024, 3, 5, 12, 0);
      final to = DateTime(2024, 3, 5, 14, 30);
      expect(DraftModeDateTime.getDurationHourMinutes(from, to), '2:30');
      expect(DraftModeDateTime.getDurationHourMinutes(to, from), '2:30');
    });
  });

  group('DraftModeFormatter', () {
    test('parseInt handles ints and strings gracefully', () {
      expect(DraftModeFormatter.parseInt(42), 42);
      expect(DraftModeFormatter.parseInt(' 17 '), 17);
      expect(DraftModeFormatter.parseInt('foo'), isNull);
      expect(DraftModeFormatter.parseInt(3.14), isNull);
    });

    test('parseBool coerces common truthy and falsy inputs', () {
      expect(DraftModeFormatter.parseBool(true), isTrue);
      expect(DraftModeFormatter.parseBool(false), isFalse);
      expect(DraftModeFormatter.parseBool(1), isTrue);
      expect(DraftModeFormatter.parseBool(0), isFalse);
      expect(DraftModeFormatter.parseBool('true'), isTrue);
      expect(DraftModeFormatter.parseBool('1'), isTrue);
      expect(DraftModeFormatter.parseBool('false'), isFalse);
      expect(DraftModeFormatter.parseBool('0'), isFalse);
      expect(DraftModeFormatter.parseBool(null), isFalse);
    });
  });
}
