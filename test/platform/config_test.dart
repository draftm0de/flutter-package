import 'package:draftmode/platform/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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

  testWidgets('default mode resets after tests', (tester) async {
    PlatformConfig.mode = ForcedPlatform.android;
    expect(PlatformConfig.isIOS, isFalse);

    PlatformConfig.mode = ForcedPlatform.auto;
    await tester.pumpWidget(const CupertinoApp(home: Placeholder()));
    final expectedIOS = defaultTargetPlatform == TargetPlatform.iOS;
    expect(PlatformConfig.isIOS, expectedIOS);
    expect(PlatformConfig.target, defaultTargetPlatform);
  });
}
