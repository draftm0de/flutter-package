import 'package:intl/intl.dart';

extension DraftModeDateTime on DateFormat {
  /// Locale-aware yMd but with month and day always padded to two digits.
  static DateFormat yMMdd([String? locale]) {
    final base = DateFormat.yMd(locale);
    final pattern = base.pattern ?? 'yMd'; // fallback, should never hit
    final patched = pattern
        .replaceAll(RegExp(r'M+'), 'MM')
        .replaceAll(RegExp(r'd+'), 'dd');
    return DateFormat(patched, locale);
  }

  /// Parses ISO-8601 strings, returning `null` when the input is empty, not a
  /// string, or malformed.
  static DateTime? parse(dynamic value) {
    if (value is! String) return null;
    if (value.trim().isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  /// Returns the number of days in the provided [month] and [year].
  static int getDaysInMonth(int year, int month) {
    final beginningNextMonth = (month < 12)
        ? DateTime(year, month + 1, 1)
        : DateTime(year + 1, 1, 1);
    return beginningNextMonth.subtract(const Duration(days: 1)).day;
  }

  static bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Returns a `hh:mm` duration string representing the difference between [from]
  /// and [to]. Negative durations are normalised to their absolute value.
  static String getDurationHourMinutes(DateTime from, DateTime to) {
    final Duration diff = to.difference(from);
    final Duration positive = diff.isNegative
        ? Duration(microseconds: -diff.inMicroseconds)
        : diff;
    final int hours = positive.inHours;
    final int minutes = positive.inMinutes % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }
}

class DraftModeFormatter {
  /// Attempts to coerce [value] into an `int`, accepting `String` inputs.
  static int? parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static bool parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return (value == 1);
    if (value is String && value == "true") return true;
    if (value is String && value == "1") return true;
    return false;
  }
}
