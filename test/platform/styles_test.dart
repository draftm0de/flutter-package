import 'package:draftmode/platform/config.dart';
import 'package:draftmode/platform/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  group('PlatformStyles', () {
    testWidgets('container background mirrors active platform', (tester) async {
      PlatformConfig.mode = ForcedPlatform.ios;
      late Color iosColor;
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              iosColor = PlatformStyles.containerBackgroundColor(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(iosColor, CupertinoColors.systemGroupedBackground);

      PlatformConfig.mode = ForcedPlatform.android;
      late Color materialColor;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF101010)),
          home: Builder(
            builder: (context) {
              materialColor = PlatformStyles.containerBackgroundColor(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(materialColor, const Color(0xFF101010));
    });

    testWidgets('label styles adapt typography per platform', (tester) async {
      PlatformConfig.mode = ForcedPlatform.ios;
      late BuildContext iosContext;
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              iosContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final iosLabel = PlatformStyles.labelStyle(iosContext, strike: true);
      expect(iosLabel.decoration, TextDecoration.lineThrough);
      expect(iosLabel.color, CupertinoColors.label);

      PlatformConfig.mode = ForcedPlatform.android;
      late BuildContext androidContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            textTheme: const TextTheme(
              bodySmall: TextStyle(fontSize: 13, color: Colors.green),
            ),
          ),
          home: Builder(
            builder: (context) {
              androidContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final androidLabel = PlatformStyles.labelStyle(androidContext);
      expect(androidLabel.color, Colors.grey);

      late BuildContext fallbackContext;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Theme(
            data: ThemeData(),
            child: Builder(
              builder: (outer) {
                return Theme(
                  data: Theme.of(outer).copyWith(textTheme: const TextTheme()),
                  child: Builder(
                    builder: (context) {
                      fallbackContext = context;
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      final fallbackLabel = PlatformStyles.labelStyle(fallbackContext);
      expect(fallbackLabel.color, Colors.grey);
    });

    testWidgets('labelStyleActive uses accent colours', (tester) async {
      PlatformConfig.mode = ForcedPlatform.ios;
      late BuildContext iosContext;
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              iosContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final iosActive = PlatformStyles.labelStyleActive(iosContext);
      expect(iosActive.color, CupertinoColors.activeBlue);

      PlatformConfig.mode = ForcedPlatform.android;
      late BuildContext materialContext;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Theme(
            data: ThemeData(),
            child: Builder(
              builder: (outer) {
                return Theme(
                  data: Theme.of(outer).copyWith(textTheme: const TextTheme()),
                  child: Builder(
                    builder: (context) {
                      materialContext = context;
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      final materialActive = PlatformStyles.labelStyleActive(materialContext);
      expect(materialActive.color, Colors.blue);
    });

    testWidgets('placeholder style honours hint styles', (tester) async {
      PlatformConfig.mode = ForcedPlatform.ios;
      late BuildContext iosContext;
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              iosContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      final iosPlaceholder = PlatformStyles.placeHolderStyle(iosContext);
      expect(iosPlaceholder.color, CupertinoColors.placeholderText);

      PlatformConfig.mode = ForcedPlatform.android;
      late BuildContext hintContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            inputDecorationTheme: const InputDecorationTheme(
              hintStyle: TextStyle(color: Colors.orange),
            ),
          ),
          home: Builder(
            builder: (context) {
              hintContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final materialPlaceholder = PlatformStyles.placeHolderStyle(hintContext);
      expect(materialPlaceholder.color, Colors.orange);

      late BuildContext fallbackContext;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Theme(
            data: ThemeData(
              inputDecorationTheme: const InputDecorationTheme(),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.black),
              ),
            ),
            child: Builder(
              builder: (outer) {
                return Theme(
                  data: Theme.of(outer).copyWith(
                    textTheme: const TextTheme(
                      bodyMedium: TextStyle(color: Colors.black),
                    ),
                  ),
                  child: Builder(
                    builder: (context) {
                      fallbackContext = context;
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      final fallbackPlaceholder = PlatformStyles.placeHolderStyle(
        fallbackContext,
      );
      expect(fallbackPlaceholder.color, Colors.grey);
    });

    testWidgets('button text style mirrors platform defaults', (tester) async {
      PlatformConfig.mode = ForcedPlatform.ios;
      late BuildContext iosContext;
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              iosContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      final iosStyle = PlatformStyles.buttonTextStyle(iosContext);
      expect(iosStyle.fontSize, 18);
      expect(iosStyle.color, CupertinoColors.white);

      PlatformConfig.mode = ForcedPlatform.android;
      late BuildContext androidContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              androidContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      final androidStyle = PlatformStyles.buttonTextStyle(androidContext);
      expect(androidStyle.fontSize, 16);
      expect(androidStyle.fontWeight, FontWeight.w600);
    });
  });
}
