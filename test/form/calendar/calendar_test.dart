import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:draftmode/entity.dart';
import 'package:draftmode/form.dart';
import 'package:draftmode/form/calender/ios.dart';
import 'package:draftmode/platform/config.dart';

void main() {
  setUp(() {
    PlatformConfig.mode = ForcedPlatform.ios;
  });

  tearDown(() {
    PlatformConfig.mode = ForcedPlatform.auto;
  });

  testWidgets('rounds selections to five minute increments', (tester) async {
    final fromAttr = DraftModeEntityAttribute<DateTime>(
      value: DateTime(2024, 1, 1, 10, 3),
    );

    await tester.pumpWidget(
      CupertinoApp(home: DraftModeFormCalendar(from: fromAttr)),
    );

    expect(find.text('10:00'), findsOneWidget);

    await tester.tap(find.text('10:00'));
    await tester.pump();
    expect(find.byType(DraftModeCalendarIOS), findsOneWidget);
  });

  testWidgets('displays duration when range is enabled', (tester) async {
    final fromAttr = DraftModeEntityAttribute<DateTime>(
      value: DateTime(2024, 1, 1, 9, 15),
    );
    final toAttr = DraftModeEntityAttribute<DateTime>(
      value: DateTime(2024, 1, 1, 11, 0),
    );

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeFormCalendar(
          from: fromAttr,
          to: toAttr,
          durationMode: DraftModeFormCalendarDurationMode.hours,
          durationLabel: 'Duration',
        ),
      ),
    );

    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('1:45'), findsOneWidget);
  });

  testWidgets('switches between day and month/year pickers', (tester) async {
    final formKey = GlobalKey<DraftModeFormState>();
    final fromAttr = DraftModeEntityAttribute<DateTime>(
      value: DateTime(2024, 1, 15, 9, 0),
    );

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          key: formKey,
          child: DraftModeFormCalendar(from: fromAttr),
        ),
      ),
    );

    expect(find.text('01/15/2024'), findsOneWidget);

    await tester.tap(find.textContaining('2024').first);
    await tester.pumpAndSettle();

    expect(find.byType(DraftModeCalendarMonthGrid), findsOneWidget);
    expect(find.text('January 2024'), findsOneWidget);

    await tester.tap(find.text('January 2024'));
    await tester.pumpAndSettle();

    expect(find.byType(DraftModeCalendarMonthYearInlinePicker), findsOneWidget);

    await tester.drag(find.byType(CupertinoPicker).first, const Offset(0, -50));
    await tester.pumpAndSettle();

    expect(find.text('February 2024'), findsOneWidget);

    await tester.tap(find.text('February 2024'));
    await tester.pumpAndSettle();

    expect(find.byType(DraftModeCalendarMonthGrid), findsOneWidget);
    expect(find.text('02/15/2024'), findsOneWidget);

    await tester.tap(find.text('09:00'));
    await tester.pump();
    expect(
      find.byType(DraftModeCalendarHourMinuteInlinePicker),
      findsOneWidget,
    );

    expect(find.text('02/15/2024'), findsOneWidget);
  });
}
