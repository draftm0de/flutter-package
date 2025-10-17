import 'package:flutter/foundation.dart' as foundation;

/// Lightweight wrapper around Flutter's [foundation.debugPrint] that only logs
/// when the instance is created in debug mode. Useful for sprinkling verbose
/// diagnostics without guarding every call site.
class DraftModeLogger {
  /// Creates a logger that emits messages when [debugMode] is true.
  const DraftModeLogger({this.debugMode = false});

  /// Whether verbose logging should be emitted.
  final bool debugMode;

  /// Prints [message] via [foundation.debugPrint] when [debugMode] is true.
  ///
  /// Optionally accepts [payload], which is appended to the message using its
  /// `toString` representation. When [message] is `null` or empty, only the
  /// payload is printed.
  void debug(String? message, [Object? payload]) {
    if (!debugMode) return;
    if (payload == null) {
      foundation.debugPrint(message);
      return;
    }
    if (message == null || message.isEmpty) {
      foundation.debugPrint('$payload');
      return;
    }
    foundation.debugPrint('$message: $payload');
  }
}
