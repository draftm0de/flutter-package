import 'package:intl/intl.dart';

/// Date/time formatting helpers surfaced as an extension on [DateFormat].
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

  /// Returns `true` when [a] and [b] share the same calendar day.
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

/// Collection of tolerant coercion helpers that surface loosely structured data
/// to the rest of the package.
class DraftModeFormatter {
  /// Attempts to coerce [value] into an `int`, accepting [String] inputs.
  static int? parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  /// Interprets [value] as a boolean, handling common `int` and `String`
  /// representations used by REST backends.
  static bool parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return (value == 1);
    if (value is String && value == "true") return true;
    if (value is String && value == "1") return true;
    return false;
  }

  /// Returns [html] stripped of HTML tags and decoded entities.
  ///
  /// When [maxLineBreaks] is greater than zero, consecutive newlines are
  /// collapsed to the specified threshold. Pass `0` to preserve the original
  /// whitespace structure.
  static String? parseHtmlToPlainText(String? html, {int maxLineBreaks = 1}) {
    if (html == null) return null;

    var text = html
        // Normalise paragraph tags into double line breaks
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<p\s*>', caseSensitive: false), '')
        // Convert <br> and <br/> into line breaks
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        // Remove all remaining HTML tags like <b>, <p>, </div> etc.
        .replaceAll(RegExp(r'<[^>]+>'), '')
        // Decode common HTML entities
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(r'\/', '/');

    // Optionally limit multiple consecutive line breaks to one
    if (maxLineBreaks > 0) {
      final pattern = RegExp(r'\n{' + (maxLineBreaks + 1).toString() + r',}');
      final replacement = '\n' * maxLineBreaks;
      text = text.replaceAll(pattern, replacement);
    }

    return text.trim();
  }

  Map<String, dynamic> decodedQueryParameters(String qs) {
    if (qs.startsWith('?')) qs = qs.substring(1);
    final uri = Uri.parse('scheme://host?$qs');
    final all = uri.queryParametersAll; // Map<String, List<String>>

    dynamic _parse(String s) {
      if (s == 'true') return true;
      if (s == 'false') return false;
      final i = int.tryParse(s);
      if (i != null) return i;
      final d = double.tryParse(s);
      if (d != null) return d;
      return s;
    }

    final out = <String, dynamic>{};
    all.forEach((k, list) {
      final parsedList = list.map(_parse).toList();
      out[k] = parsedList.length == 1 ? parsedList.first : parsedList;
    });
    return out;
  }
}
