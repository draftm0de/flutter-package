import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:draftmode/form.dart';
import 'package:draftmode/platform/config.dart';
import 'package:draftmode/platform/styles.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.ios;
  });

  tearDown(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  testWidgets('applies contextual text styling overrides', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeFormButtonText(
          text: 'Pick time',
          styleColor: DraftModeStyleButtonColor.dateTime,
          styleSize: DraftModeStyleButtonSize.large,
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.text('Pick time'));
    expect(textWidget.style?.color, DraftModeStyleButtonColor.dateTime.font);
    expect(textWidget.style?.fontSize, DraftModeStyleButtonSize.large.fontSize);
    expect(
      textWidget.style?.fontWeight,
      DraftModeStyleButtonSize.large.fontWeight,
    );
  });

  testWidgets('defaults to submit styling', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(home: DraftModeFormButtonText(text: 'Submit')),
    );

    final textWidget = tester.widget<Text>(find.text('Submit'));
    expect(textWidget.style?.color, DraftModeStyleButtonColor.submit.font);
    expect(textWidget.style?.fontSize, DraftModeStyleButtonSize.large.fontSize);
    expect(
      textWidget.style?.fontWeight,
      DraftModeStyleButtonSize.large.fontWeight,
    );
  });
}
