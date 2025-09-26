import 'dart:ui' as ui;

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

  testWidgets('DraftModePageSpinner falls back to default color', (
    tester,
  ) async {
    PlatformConfig.mode = ForcedPlatform.ios;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DraftModePageSpinner(),
      ),
    );

    final indicator = tester.widget<CupertinoActivityIndicator>(
      find.byType(CupertinoActivityIndicator),
    );
    expect(indicator.color, const Color(0xFF888888));
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

  test('DraftModePageSpinnerPainter paints without requesting repaint', () {
    final painter = DraftModePageSpinnerPainter(
      strokeWidth: 3,
      color: const Color(0xFF123456),
    );

    final pictureRecorder = ui.PictureRecorder();
    final canvas = ui.Canvas(pictureRecorder);
    painter.paint(canvas, const ui.Size(10, 10));

    expect(
      painter.shouldRepaint(
        DraftModePageSpinnerPainter(
          strokeWidth: 1,
          color: const Color(0xFFFFFFFF),
        ),
      ),
      isFalse,
    );
  });
}
