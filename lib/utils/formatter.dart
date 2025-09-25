import 'package:intl/intl.dart';

extension DraftModeDateTime on DateFormat {
  /// Locale-aware yMd but with month always 2 digits (MM).
  static DateFormat yMMdd([String? locale]) {
    final base = DateFormat.yMd(locale);
    final pattern = base.pattern ?? 'yMd'; // fallback, should never hit
    final patched = pattern
        .replaceAll(RegExp(r'M+'), 'MM')
        .replaceAll(RegExp(r'd+'), 'dd');
    return DateFormat(patched, locale);
  }

  static DateTime? parse(String? value) {
    if (value == null || value.trim().isNotEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  static int getDaysInMonth(int year, int month) {
    final beginningNextMonth = (month < 12)
        ? DateTime(year, month + 1, 1)
        : DateTime(year + 1, 1, 1);
    return beginningNextMonth.subtract(const Duration(days: 1)).day;
  }

  static String getDurationHourMinutes(DateTime from, DateTime to) {
    final Duration diff = to.difference(from);
    final int hours = diff.inHours;
    final int minutes = diff.inMinutes % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }
}

class DraftModeFormatter {
  static int? parseInt(dynamic v) =>
      v is int ? v : (v is String ? int.tryParse(v) : null);
}