import 'package:draftmode/form.dart';
import 'package:draftmode/form/calender/ios.dart';
import 'package:draftmode/platform/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => PlatformConfig.mode = ForcedPlatform.ios);
  tearDown(() => PlatformConfig.mode = ForcedPlatform.auto);

  testWidgets('DraftModeCalendarIOS renders closed mode', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeCalendarIOS(
          mode: DraftModeFormCalendarPickerMode.closed,
          dateTime: DateTime(2024, 1, 1, 9, 0),
          onPressed: () {},
          onChange: (_) {},
        ),
      ),
    );

    expect(find.byKey(const ValueKey('closed')), findsOneWidget);
  });

  testWidgets('DraftModeCalendarIOS day preserves time', (tester) async {
    DateTime? result;
    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeCalendarIOS(
          mode: DraftModeFormCalendarPickerMode.day,
          dateTime: DateTime(2024, 1, 15, 9, 30),
          onPressed: () {},
          onChange: (value) => result = value,
        ),
      ),
    );

    await tester.tap(find.widgetWithText(CupertinoButton, '16'));
    await tester.pumpAndSettle();

    expect(result, DateTime(2024, 1, 16, 9, 30));
  });

  testWidgets('DraftModeCalendarIOS monthYear triggers callbacks', (
    tester,
  ) async {
    bool pressed = false;
    DateTime? result;
    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeCalendarIOS(
          mode: DraftModeFormCalendarPickerMode.monthYear,
          dateTime: DateTime(2024, 1, 15, 9, 0),
          onPressed: () => pressed = true,
          onChange: (value) => result = value,
        ),
      ),
    );

    await tester.tap(find.text('January 2024'));
    await tester.pump();
    expect(pressed, isTrue);

    await tester.drag(find.byType(CupertinoPicker).first, const Offset(0, -60));
    await tester.pumpAndSettle();

    expect(result?.month, isNotNull);
  });

  testWidgets('DraftModeCalendarIOS hourMinute emits new time', (tester) async {
    DateTime? result;
    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeCalendarIOS(
          mode: DraftModeFormCalendarPickerMode.hourMinute,
          dateTime: DateTime(2024, 1, 15, 9, 0),
          onPressed: () {},
          onChange: (value) => result = value,
        ),
      ),
    );

    await tester.drag(find.byType(CupertinoPicker).last, const Offset(0, -50));
    await tester.pumpAndSettle();

    expect(result?.minute, isNotNull);
  });

  testWidgets('DraftModeCalendarMonthGrid supports navigation', (tester) async {
    bool pressed = false;
    DateTime? selected;
    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeCalendarMonthGrid(
          dateTime: DateTime(2024, 1, 15),
          onPressed: () => pressed = true,
          onSelect: (value) => selected = value,
          height: 6 * 44,
        ),
      ),
    );

    await tester.tap(find.text('January 2024'));
    await tester.pump();
    expect(pressed, isTrue);

    await tester.tap(find.text('14'));
    await tester.pump();
    expect(selected?.day, 14);

    await tester.tap(find.byType(CupertinoButton).at(1));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CupertinoButton).at(2));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-200, 0));
    await tester.pumpAndSettle();
  });
}
