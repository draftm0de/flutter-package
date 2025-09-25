import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

/// Strategy for determining which platform styles to use.
enum ForcedPlatform { auto, ios, android }

/// Centralised platform look-and-feel settings consumed by DraftMode widgets.
class PlatformConfig {
  /// Allows forcing a specific platform during tests or previews.
  static ForcedPlatform mode = ForcedPlatform.auto;

  /// Returns `true` when the effective platform should mimic iOS.
  static bool get isIOS {
    if (mode == ForcedPlatform.ios) return true;
    if (mode == ForcedPlatform.android) return false;
    // fallback to actual platform
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Translates [isIOS] into a [TargetPlatform] for theme APIs.
  static TargetPlatform get target {
    return isIOS ? TargetPlatform.iOS : TargetPlatform.android;
  }
}
