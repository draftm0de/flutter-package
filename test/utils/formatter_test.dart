import 'package:draftmode/utils/formatter.dart';
import 'package:test/test.dart';

void main() {
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
}
