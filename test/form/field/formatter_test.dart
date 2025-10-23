import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:draftmode/form.dart';

void main() {
  group('DraftModeFormTypeNumber', () {
    test('encodes and decodes grouped doubles', () {
      final formatter = DraftModeFormTypeDouble();
      expect(formatter.encode(1234567.89), '1.234.567,89');
      expect(formatter.encode(-42.5), '-42,50');
      expect(formatter.decode('1.234.567,89'), 1234567.89);
      expect(formatter.decode('-1.234,5'), -1234.5);
      expect(formatter.decode(''), isNull);
    });

    test('encodes and decodes grouped ints', () {
      final formatter = DraftModeFormTypeInt();
      expect(formatter.encode(1234567), '1.234.567');
      expect(formatter.encode(-42), '-42');
      expect(formatter.decode('1.234.567'), 1234567);
      expect(formatter.decode('-1.234'), -1234);
      expect(formatter.decode(null), isNull);
    });

    test('enforces fraction digit limit', () {
      final formatter = DraftModeFormTypeDouble();
      const oldValue = TextEditingValue(
        text: '1,23',
        selection: TextSelection.collapsed(offset: 4),
      );
      const attempted = TextEditingValue(
        text: '1,234',
        selection: TextSelection.collapsed(offset: 5),
      );
      expect(formatter.formatEditUpdate(oldValue, attempted), oldValue);
    });

    test('groups thousands during free input', () {
      final formatter = DraftModeFormTypeInt();
      const oldValue = TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      const attempted = TextEditingValue(
        text: '1234567',
        selection: TextSelection.collapsed(offset: 7),
      );
      final formatted = formatter.formatEditUpdate(oldValue, attempted);
      expect(formatted.text, '1.234.567');
      expect(formatted.selection.baseOffset, formatted.text.length);
    });

    test(
      'keeps decimal delimiter when user has not entered fraction digits',
      () {
        final formatter = DraftModeFormTypeDouble();
        const oldValue = TextEditingValue(
          text: '12',
          selection: TextSelection.collapsed(offset: 2),
        );
        const attempted = TextEditingValue(
          text: '12,',
          selection: TextSelection.collapsed(offset: 3),
        );
        final formatted = formatter.formatEditUpdate(oldValue, attempted);
        expect(formatted.text, '12,');
      },
    );
  });
}
