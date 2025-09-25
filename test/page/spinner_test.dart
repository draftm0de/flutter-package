import 'package:draftmode/page/spinner.dart';
import 'package:draftmode/platform/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  testWidgets('DraftModePageSpinner shows Cupertino indicator on iOS', (
    tester,
  ) async {
    PlatformConfig.mode = ForcedPlatform.ios;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DraftModePageSpinner(color: Color(0xFF0000FF)),
      ),
    );

    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
  });

  testWidgets('DraftModePageSpinner paints custom arc on Android', (
    tester,
  ) async {
    PlatformConfig.mode = ForcedPlatform.android;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DraftModePageSpinner(color: Color(0xFF0000FF)),
      ),
    );

    final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
    expect(customPaint.painter, isA<DraftModePageSpinnerPainter>());
  });
}
