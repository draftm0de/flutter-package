import 'package:flutter/services.dart';
import '../interface.dart';

class DraftModeFormTypeNumber<T extends num> extends TextInputFormatter
    implements DraftModerFormFormatterInterface<T> {
  final int digits;
  final String? digitDelimiter;
  final String? thousandDelimiter;
  final bool signed;

  DraftModeFormTypeNumber({
    this.digits = 0,
    this.digitDelimiter,
    this.thousandDelimiter,
    this.signed = false,
  }) : assert(
         digits == 0 || digitDelimiter != null,
         'When digits > 0, digitDelimiter must be provided',
       ) {}

  TextInputType getTextInputType() {
    final bool hasDecimal = (digits > 0);
    return TextInputType.numberWithOptions(decimal: hasDecimal, signed: signed);
  }

  /// Convert user input (formatted string) → int or double
  T? decode(String? input) {
    if (input == null) return null;
    final s = _normalizeForParse(input);
    if (s.isEmpty) return null;
    if (T == int) return int.tryParse(s) as T?;
    if (T == double) return double.tryParse(s) as T?;
    return null;
  }

  /// Format a double → display string
  String encode(T? value) {
    if (value == null) return '';
    final fixed = value.toStringAsFixed(digits);
    final dotParts = fixed.split('.'); // always '.' from toStringAsFixed
    final intPart = _group(dotParts[0]);
    final sign = value.isNegative ? '-' : '';
    if (digits == 0) return '$sign$intPart';
    final fracPart = dotParts.length > 1 ? dotParts[1] : '';
    return '$sign$intPart$digitDelimiter$fracPart';
  }

  // ---------- Internals ----------
  // Insert thousandDelimiter every 3 digits from the right.
  String _group(String input) {
    if (input.isEmpty) return '';
    if (thousandDelimiter == null) return input;

    // 1️⃣ Extract sign if present
    final negative = input.startsWith('-');
    var digits = negative ? input.substring(1) : input;

    // 2️⃣ Remove any old thousand delimiters
    digits = digits.replaceAll(thousandDelimiter!, '');

    // 3️⃣ Group from right to left
    final buf = StringBuffer();
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      buf.write(digits[i]);
      count++;
      if (i > 0 && count % 3 == 0) {
        buf.write(thousandDelimiter);
      }
    }

    // 4️⃣ Reverse the result back
    final grouped = buf.toString().split('').reversed.join('');

    // 5️⃣ Add sign back
    return negative ? '-$grouped' : grouped;
  }

  // Convert a display string to something double.parse can handle
  String _normalizeForParse(String input) {
    String s = input.trim();
    if (s.isEmpty) return '';
    if (thousandDelimiter != null) {
      s = s.replaceAll(thousandDelimiter!, '');
    }
    if (digitDelimiter != null) {
      final altDecimal = digitDelimiter == ',' ? '.' : ',';
      s = s.replaceAll(altDecimal, digitDelimiter!);
      // Replace configured decimal with '.' for parse
      s = s.replaceAll(digitDelimiter!, '.');
    }
    return s;
  }

  /// Input restriction logic
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Always allow empty result (fixes: “last char stays”)
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Prepare: remove all thousand delimiters; normalize alternate decimal to the configured one
    String raw = newValue.text;
    if (thousandDelimiter != null) {
      raw = raw.replaceAll(thousandDelimiter!, '');
    }

    if (digitDelimiter != null) {
      final altDecimal = digitDelimiter == ',' ? '.' : ',';
      raw = raw.replaceAll(altDecimal, digitDelimiter!);
    }

    // Keep only digits, one optional leading sign, and at most one digitDelimiter
    // 1) Handle sign
    bool negative = false;
    if (raw.startsWith('-')) {
      if (!signed) return oldValue; // no sign allowed
      negative = true;
      raw = raw.substring(1);
    }

    // 2) Split on first decimal delimiter occurrence
    String intPart = raw;
    String fracPart = "";
    if (digitDelimiter != null) {
      final parts = raw.split(digitDelimiter!);
      intPart = parts.isNotEmpty ? parts[0] : '';
      fracPart = parts.length > 1 ? parts.sublist(1).join() : '';
    }

    // Filter non-digits
    intPart = intPart.replaceAll(RegExp(r'[^0-9]'), '');
    fracPart = fracPart.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit fraction length
    if (digits == 0) {
      fracPart = '';
    } else if (fracPart.length > digits) {
      // If user typed beyond allowed, reject this edit gracefully
      return oldValue;
    }

    // Group thousands on integer part (right to left)
    final groupedInt = _group(intPart);

    // Rebuild display
    final sign = negative ? '-' : '';
    final display = (digits > 0 && fracPart.isNotEmpty)
        ? '$sign$groupedInt$digitDelimiter$fracPart'
        : '$sign$groupedInt';

    // Place caret at the end (simple + robust). If you want smarter caret preservation,
    // add delta-based caret math here.
    return TextEditingValue(
      text: display,
      selection: TextSelection.collapsed(offset: display.length),
    );
  }
}
