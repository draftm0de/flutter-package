import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';

/// Strategy for determining which platform styles to use.
enum ForcedPlatform { auto, ios, android }

/// Centralised platform look-and-feel settings consumed by DraftMode widgets.
class PlatformConfig {
  /// Allows forcing a specific platform during tests or previews.
  static ForcedPlatform mode = ForcedPlatform.auto;

  /// Default width reserved for labels in form rows.
  static double labelWidth = 100;

  /// Default horizontal padding around content containers.
  static double horizontalContainerPadding = 16;

  /// Default vertical padding around content containers.
  static double verticalContainerPadding = 8;

  /// Default size for small icon-only buttons.
  static double buttonSizeSmall = 18;

  /// Icon height used in top navigation bars.
  static double topNavigationBarIconHeight = 20;

  /// Minimum height for the bottom navigation container.
  static double bottomNavigationBarContainerHeight = 52.0;

  /// Height allocated to individual bottom navigation items.
  static double bottomNavigationBarItemHeight = 44.0;

  /// Icon height used in the bottom navigation bar.
  static double bottomNavigationBarIconHeight = 30;

  /// Returns a neutral background colour for page scaffolds.
  static Color containerBackgroundColor(BuildContext context) => isIOS
      ? CupertinoColors.systemGroupedBackground
      : Theme.of(context).scaffoldBackgroundColor;

  /// Typography used for secondary labels within forms.
  static TextStyle labelStyle(BuildContext context, {bool strike = false}) {
    final base = isIOS
        ? CupertinoTheme.of(context).textTheme.textStyle
        : (Theme.of(context).textTheme.bodySmall ??
              DefaultTextStyle.of(context).style);

    final activeColor = isIOS ? CupertinoColors.label : Colors.grey;

    return base.copyWith(
      color: activeColor,
      decoration: strike ? TextDecoration.lineThrough : TextDecoration.none,
    );
  }

  /// Convenience getter for active accent colours.
  final Color active = isIOS ? CupertinoColors.activeBlue : Colors.blue;

  /// Variant of [labelStyle] using the active accent colour.
  static TextStyle labelStyleActive(
    BuildContext context, {
    bool strike = false,
  }) {
    final base = isIOS
        ? CupertinoTheme.of(context).textTheme.textStyle
        : (Theme.of(context).textTheme.bodySmall ??
              DefaultTextStyle.of(context).style);

    final activeColor = isIOS ? CupertinoColors.activeBlue : Colors.blue;

    return base.copyWith(
      color: activeColor,
      decoration: strike ? TextDecoration.lineThrough : TextDecoration.none,
    );
  }

  /// Typography used for placeholder text in inputs.
  static TextStyle placeHolderStyle(BuildContext context) {
    if (isIOS) {
      return CupertinoTheme.of(
        context,
      ).textTheme.textStyle.copyWith(color: CupertinoColors.placeholderText);
    } else {
      final hintStyle = Theme.of(context).inputDecorationTheme.hintStyle;
      if (hintStyle != null) return hintStyle;
      return Theme.of(
        context,
      ).textTheme.bodyMedium!.copyWith(color: Colors.grey);
    }
  }

  /// Platform-specific button text style used across DraftMode components.
  static TextStyle buttonTextStyle(BuildContext context) {
    if (isIOS) {
      return TextStyle(
        color: CupertinoColors.white,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      );
    } else {
      return TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    }
  }

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
