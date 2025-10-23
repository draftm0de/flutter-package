import 'package:draftmode/platform/config.dart';
import 'package:draftmode/platform/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlatformStyles', () {
    late ForcedPlatform previousMode;

    setUp(() {
      previousMode = PlatformConfig.mode;
    });

    tearDown(() {
      PlatformConfig.mode = previousMode;
    });

    testWidgets('returns iOS background and button styles', (tester) async {
      PlatformConfig.mode = ForcedPlatform.ios;
      BuildContext? capturedContext;
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final context = capturedContext!;
      expect(
        PlatformStyles.containerBackgroundColor(context),
        CupertinoColors.systemGroupedBackground,
      );

      final style = PlatformStyles.buttonTextStyle(context);
      expect(style.color, CupertinoColors.white);
      expect(style.fontSize, 18);
      expect(style.fontWeight, FontWeight.w500);
    });

    testWidgets('returns Material background and button styles', (
      tester,
    ) async {
      PlatformConfig.mode = ForcedPlatform.android;
      BuildContext? capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(scaffoldBackgroundColor: Colors.purpleAccent),
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const Scaffold(body: SizedBox.shrink());
            },
          ),
        ),
      );

      final context = capturedContext!;
      expect(
        PlatformStyles.containerBackgroundColor(context),
        Colors.purpleAccent,
      );

      final style = PlatformStyles.buttonTextStyle(context);
      expect(style.fontSize, 16);
      expect(style.fontWeight, FontWeight.w600);
    });

    test('exposes shared sizing constants', () {
      expect(PlatformStyles.labelWidth, 100);
      expect(PlatformStyles.verticalContainerPadding, 8);
      expect(PlatformStyles.buttonSizeSmall, 18);

      expect(DraftModeStyleFontSize.primary, 17);
      expect(DraftModeStyleFontWeight.secondary, FontWeight.w500);
      expect(DraftModeStylePadding.tertiary, 10);
    });
  });
}
