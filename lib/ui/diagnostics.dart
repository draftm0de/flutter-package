import 'package:flutter/foundation.dart';

/// Centralized diagnostics entry point so non-UI layers avoid direct logging.
///
/// UI owns the actual presentation of messages (currently forwarding to
/// [debugPrint]) to keep platform-specific surface decisions in a single
/// module.
class DraftModeUIDiagnostics {
  const DraftModeUIDiagnostics._();

  /// Emits a developer-facing log when [enabled] is `true`.
  static void debug(String message, {bool enabled = true}) {
    if (!enabled) return;
    debugPrint(message);
  }
}
