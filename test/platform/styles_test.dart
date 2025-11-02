import 'package:draftmode/platform/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DraftMode style constants', () {
    test('exposes shared layout and typography roles', () {
      expect(PlatformStyles.labelWidth, 100);
      expect(DraftModeStyleFontSize.primary, 17);
      expect(DraftModeStyleFontWeight.secondary, FontWeight.w500);
      expect(DraftModeStylePadding.tertiary, 10);
      expect(
        DraftModeStyleColor.tertiary.background,
        CupertinoColors.systemGroupedBackground,
      );
    });

    test('defines button sizing presets', () {
      expect(DraftModeStyleButtonSize.large.height, 48);
      expect(DraftModeStyleButtonSize.large.fontSize, 18);
      expect(DraftModeStyleButtonSize.medium.height, 40);
      expect(DraftModeStyleButtonSize.small.fontSize, 14);
    });

    test('maps submit and date-time button palettes', () {
      expect(
        DraftModeStyleButtonColor.submit.background,
        DraftModeStyleColorTint.primary.background,
      );
      expect(
        DraftModeStyleButtonColor.submit.font,
        DraftModeStyleColorTint.primary.text,
      );
      expect(
        DraftModeStyleButtonColor.dateTime.background,
        CupertinoColors.systemGrey5,
      );
      expect(DraftModeStyleButtonColor.dateTime.font, Colors.black);
    });

    test('exposes icon sizing shortcuts', () {
      expect(DraftModeStyleIconSize.large, 22);
      expect(DraftModeStyleIconSize.medium, 18);
      expect(DraftModeStyleIconSize.small, 16);
    });
  });
}
