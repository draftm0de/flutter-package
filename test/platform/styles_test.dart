import 'package:draftmode/platform/config.dart';
import 'package:draftmode/platform/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  testWidgets('container background mirrors platform defaults', (tester) async {
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

  testWidgets('button text style adapts per platform', (tester) async {
    PlatformConfig.mode = ForcedPlatform.ios;
    await tester.pumpWidget(const CupertinoApp(home: Placeholder()));
    final iosStyle = PlatformStyles.buttonTextStyle(
      tester.element(find.byType(Placeholder)),
    );
    expect(iosStyle.color, CupertinoColors.white);
    expect(iosStyle.fontSize, 18);
    expect(iosStyle.fontWeight, FontWeight.w500);

    PlatformConfig.mode = ForcedPlatform.android;
    await tester.pumpWidget(const MaterialApp(home: Placeholder()));
    final materialStyle = PlatformStyles.buttonTextStyle(
      tester.element(find.byType(Placeholder)),
    );
    expect(materialStyle.fontSize, 16);
    expect(materialStyle.fontWeight, FontWeight.w600);
  });
}
