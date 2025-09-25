import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ForcedPlatform { auto, ios, android }

class PlatformConfig {
  static ForcedPlatform mode = ForcedPlatform.auto;

  static double labelWidth = 100;
  static double horizontalContainerPadding = 16;
  static double verticalContainerPadding = 8;

  static double buttonSizeSmall = 18;

  static double topNavigationBarIconHeight = 20;
  static double bottomNavigationBarContainerHeight = 52.0;
  static double bottomNavigationBarItemHeight = 44.0;
  static double bottomNavigationBarIconHeight = 30;

  static Color containerBackgroundColor(BuildContext context) => isIOS
      ? CupertinoColors.systemGroupedBackground
      : Theme.of(context).scaffoldBackgroundColor;

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

  final Color active = isIOS ? CupertinoColors.activeBlue : Colors.blue;

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

  static bool get isIOS {
    if (mode == ForcedPlatform.ios) return true;
    if (mode == ForcedPlatform.android) return false;
    // fallback to actual platform
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  static TargetPlatform get target {
    return isIOS ? TargetPlatform.iOS : TargetPlatform.android;
  }
}
