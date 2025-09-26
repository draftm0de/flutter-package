import 'package:draftmode/form.dart';
import 'package:draftmode/platform/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.ios;
  });

  tearDown(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  testWidgets('applies contextual text styling overrides', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: DraftModeFormButtonText(
          text: 'Pick time',
          styleColor: DraftModeFormButtonColor.dateTime,
          styleSize: DraftModeFormButtonSize.large,
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.text('Pick time'));
    expect(textWidget.style?.color, CupertinoColors.black);
    expect(textWidget.style?.fontSize, 16);
  });
}
