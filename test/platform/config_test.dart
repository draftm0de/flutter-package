import 'package:draftmode/platform/config.dart';
import 'package:draftmode/platform/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  testWidgets(
    'isIOS respects forced mode and target returns matching platform',
    (tester) async {
      PlatformConfig.mode = ForcedPlatform.ios;
      expect(PlatformConfig.isIOS, isTrue);
      expect(PlatformConfig.target, TargetPlatform.iOS);

      PlatformConfig.mode = ForcedPlatform.android;
      expect(PlatformConfig.isIOS, isFalse);
      expect(PlatformConfig.target, TargetPlatform.android);
    },
  );

  testWidgets('label styles pick appropriate colours', (tester) async {
    PlatformConfig.mode = ForcedPlatform.ios;
    await tester.pumpWidget(const CupertinoApp(home: Placeholder()));
    final iosStyle = PlatformStyles.labelStyle(
      tester.element(find.byType(Placeholder)),
    );
    expect(iosStyle.color, CupertinoColors.label);

    PlatformConfig.mode = ForcedPlatform.android;
    await tester.pumpWidget(const MaterialApp(home: Placeholder()));
    final androidStyle = PlatformStyles.labelStyle(
      tester.element(find.byType(Placeholder)),
    );
    expect(androidStyle.color, Colors.grey);
  });

  testWidgets('placeholder style honours platform defaults', (tester) async {
    PlatformConfig.mode = ForcedPlatform.ios;
    await tester.pumpWidget(const CupertinoApp(home: Placeholder()));
    final iosStyle = PlatformStyles.placeHolderStyle(
      tester.element(find.byType(Placeholder)),
    );
    expect(iosStyle.color, CupertinoColors.placeholderText);

    PlatformConfig.mode = ForcedPlatform.android;
    await tester.pumpWidget(const MaterialApp(home: Placeholder()));
    final androidStyle = PlatformStyles.placeHolderStyle(
      tester.element(find.byType(Placeholder)),
    );
    expect(androidStyle.color, isNotNull);
  });
}
