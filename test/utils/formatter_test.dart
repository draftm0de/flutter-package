import 'package:draftmode/utils/formatter.dart';
import 'package:test/test.dart';

void main() {
  group('DraftModeDateTime', () {
    test('beginDay clamps to start of day', () {
      final original = DateTime(2024, 5, 20, 13, 45, 30);

      final result = DraftModeDateTime.beginDay(original);

      expect(result, DateTime(2024, 5, 20));
    });

    test('endDay clamps to end of day', () {
      final original = DateTime(2024, 5, 20, 7, 12, 1);

      final result = DraftModeDateTime.endDay(original);

      expect(result, DateTime(2024, 5, 20, 23, 59, 59));
    });

    test('yMMdd pads month and day components', () {
      final formatter = DraftModeDateTime.yMMdd('en_US');

      final output = formatter.format(DateTime(2024, 1, 5));

      expect(output, '01/05/2024');
    });

    test('parse returns parsed DateTime or null on invalid input', () {
      expect(DraftModeDateTime.parse('2024-06-01T10:30:00Z'), isNotNull);
      expect(DraftModeDateTime.parse(''), isNull);
      expect(DraftModeDateTime.parse(123), isNull);
    });

    test('getDaysInMonth handles leap years', () {
      expect(DraftModeDateTime.getDaysInMonth(2024, 2), 29);
      expect(DraftModeDateTime.getDaysInMonth(2023, 4), 30);
      expect(DraftModeDateTime.getDaysInMonth(2025, 12), 31);
    });

    test('isSameDate ignores time components', () {
      final a = DateTime(2024, 7, 10, 9, 30);
      final b = DateTime(2024, 7, 10, 23, 59);

      expect(DraftModeDateTime.isSameDate(a, b), isTrue);
    });

    test('getDurationHourMinutes normalises negative durations', () {
      final from = DateTime(2024, 7, 10, 8, 45);
      final to = DateTime(2024, 7, 10, 10, 5);

      expect(DraftModeDateTime.getDurationHourMinutes(from, to), '1:20');
      expect(DraftModeDateTime.getDurationHourMinutes(to, from), '1:20');
    });
  });

  group('DraftModeFormatter.parseHtmlToPlainText', () {
    test('returns null when input is null', () {
      expect(DraftModeFormatter.parseHtmlToPlainText(null), isNull);
    });

    test('strips tags and decodes entities', () {
      const html = '<p>Hello&nbsp;<strong>World</strong>&amp;friends</p>';

      final result = DraftModeFormatter.parseHtmlToPlainText(html);

      expect(result, 'Hello World&friends');
    });

    test('converts paragraphs and breaks into line breaks', () {
      const html = '<p>First</p><p>Second<br/>Line</p>';

      final result = DraftModeFormatter.parseHtmlToPlainText(html);

      expect(result, 'First\nSecond\nLine');
    });

    test('limits consecutive line breaks using maxLineBreaks', () {
      const html = '<p>First</p><p>Second</p><p>Third</p>';

      final result = DraftModeFormatter.parseHtmlToPlainText(
        html,
        maxLineBreaks: 1,
      );

      expect(result, 'First\nSecond\nThird');
    });

    test('preserves multiple line breaks when allowed', () {
      const html = '<p>First</p><p>Second</p>';

      final result = DraftModeFormatter.parseHtmlToPlainText(
        html,
        maxLineBreaks: 2,
      );

      expect(result, 'First\n\nSecond');
    });
  });

  group('DraftModeFormatter.decodedQueryParameters', () {
    test('coerces primitive types and trims leading question mark', () {
      final formatter = DraftModeFormatter();

      final result = formatter.decodedQueryParameters(
        '?count=5&flag=true&price=42.5&name=alice+bob',
      );

      expect(result['count'], 5);
      expect(result['flag'], isTrue);
      expect(result['price'], 42.5);
      expect(result['name'], 'alice bob');
    });

    test('returns lists when parameters repeat', () {
      final formatter = DraftModeFormatter();

      final result = formatter.decodedQueryParameters(
        'tag=design&tag=ux&empty=',
      );

      expect(result['tag'], ['design', 'ux']);
      expect(result['empty'], '');
    });
  });

  group('DraftModeFormatter.parseInt', () {
    test('parses ints and numeric strings', () {
      expect(DraftModeFormatter.parseInt(42), 42);
      expect(DraftModeFormatter.parseInt('17'), 17);
      expect(DraftModeFormatter.parseInt(' 9 '), 9);
    });

    test('returns null for non-numeric input', () {
      expect(DraftModeFormatter.parseInt('abc'), isNull);
      expect(DraftModeFormatter.parseInt(true), isNull);
    });
  });

  group('DraftModeFormatter.parseBool', () {
    test('interprets booleans, ints, and common strings', () {
      expect(DraftModeFormatter.parseBool(true), isTrue);
      expect(DraftModeFormatter.parseBool(false), isFalse);
      expect(DraftModeFormatter.parseBool(1), isTrue);
      expect(DraftModeFormatter.parseBool(0), isFalse);
      expect(DraftModeFormatter.parseBool('true'), isTrue);
      expect(DraftModeFormatter.parseBool('false'), isFalse);
      expect(DraftModeFormatter.parseBool('1'), isTrue);
    });

    test('defaults to false for other inputs', () {
      expect(DraftModeFormatter.parseBool('nope'), isFalse);
      expect(DraftModeFormatter.parseBool(null), isFalse);
    });
  });
}
