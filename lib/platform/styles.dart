import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'config.dart';

class DraftModeStyleColorRole {
  final Color background;
  final Color text;
  const DraftModeStyleColorRole({required this.background, required this.text});
}

class DraftModeStyleColorInverse {
  final DraftModeStyleColorRole role;
  const DraftModeStyleColorInverse(this.role);
  get background => this.role.text;
  get text => this.role.background;
}

class DraftModeStyleColor {
  static DraftModeStyleColorRole get primary => const DraftModeStyleColorRole(
    background: CupertinoColors.systemBackground,
    text: CupertinoColors.label,
  );
  static DraftModeStyleColorRole get secondary => const DraftModeStyleColorRole(
    background: CupertinoColors.secondarySystemBackground,
    text: CupertinoColors.secondaryLabel,
  );
}

class DraftModeStyleColorTint {
  static DraftModeStyleColorRole get primary => const DraftModeStyleColorRole(
    background: CupertinoColors.systemBlue,
    text: CupertinoColors.white,
  );
  static DraftModeStyleColorRole get secondary => const DraftModeStyleColorRole(
    background: CupertinoColors.systemRed,
    text: CupertinoColors.white,
  );
  static DraftModeStyleColorRole get tertiary => const DraftModeStyleColorRole(
    background: CupertinoColors.activeGreen,
    text: CupertinoColors.black,
  );
  static DraftModeStyleColorRole get quaternary =>
      const DraftModeStyleColorRole(
        background: CupertinoColors.black,
        text: CupertinoColors.white,
      );
}

class DraftModeStyleColorActive {
  static DraftModeStyleColorRole get primary => DraftModeStyleColorRole(
    background: DraftModeStyleColorTint.primary.background,
    text: DraftModeStyleColorTint.primary.text,
  );
  static DraftModeStyleColorRole get secondary => DraftModeStyleColorRole(
    background: DraftModeStyleColorTint.secondary.background,
    text: DraftModeStyleColorTint.secondary.text,
  );
  static DraftModeStyleColorRole get tertiary => DraftModeStyleColorRole(
    background: DraftModeStyleColorTint.tertiary.background,
    text: DraftModeStyleColorTint.tertiary.text,
  );
  static DraftModeStyleColorRole get quaternary => DraftModeStyleColorRole(
    background: DraftModeStyleColorTint.quaternary.background,
    text: DraftModeStyleColorTint.quaternary.text,
  );
}

class DraftModeStyleText {
  static TextStyle get primary => TextStyle(
    color: DraftModeStyleColor.primary.text,
    fontSize: DraftModeStyleFontSize.primary,
  );
  static TextStyle get tertiary => TextStyle(
    color: DraftModeStyleColor.primary.text,
    fontSize: DraftModeStyleFontSize.tertiary,
  );
}

class DraftModeStyleFontSize {
  static double get primary => 17;
  static double get secondary => 15;
  static double get tertiary => 12;
}

class DraftModeStyleFontWeight {
  static FontWeight get primary => FontWeight.normal;
  static FontWeight get secondary => FontWeight.w500;
  static FontWeight get tertiary => FontWeight.bold;
}

class DraftModeStylePadding {
  static double get primary => 16;
  static double get secondary => 14;
  static double get tertiary => 10;
}

/// Shared layout constants and typography helpers used across DraftMode widgets.
class PlatformStyles {
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
  static Color containerBackgroundColor(BuildContext context) =>
      PlatformConfig.isIOS
      ? CupertinoColors.systemGroupedBackground
      : Theme.of(context).scaffoldBackgroundColor;

  /// Platform-specific button text style used across DraftMode components.
  static TextStyle buttonTextStyle(BuildContext context) {
    if (PlatformConfig.isIOS) {
      return const TextStyle(
        color: CupertinoColors.white,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      );
    }
    return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  }
}
