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
}
