import 'package:draftmode/form/interface.dart';
import 'package:draftmode/platform/styles.dart';
import 'package:draftmode/ui/date_time/calendar_ios.dart';
import 'package:draftmode/ui/date_time/hour_minute.dart';
import 'package:draftmode/ui/date_time/month_grid.dart';
import 'package:draftmode/ui/date_time/month_year.dart';
import 'package:draftmode/utils/formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    Intl.defaultLocale = 'en';
  });

  Widget _wrap(Widget child) =>
      CupertinoApp(locale: const Locale('en'), home: child);

  testWidgets('DraftModeUIDateTimeIOS renders day picker', (tester) async {
    await tester.pumpWidget(
      _wrap(
        DraftModeUIDateTimeIOS(
          mode: DraftModeFormCalendarPickerMode.day,
          dateTime: DateTime(2024, 3, 15, 10, 30),
          onToggleMonthYear: () {},
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(DraftModeUIDateTimeMonthGrid), findsOneWidget);
  });

  testWidgets('DraftModeUIDateTimeIOS renders month/year picker', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        DraftModeUIDateTimeIOS(
          mode: DraftModeFormCalendarPickerMode.monthYear,
          dateTime: DateTime(2024, 3, 15, 10, 30),
          onToggleMonthYear: () {},
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(DraftModeUIDateTimeMonthYear), findsOneWidget);
  });

  testWidgets('DraftModeUIDateTimeIOS renders hour minute picker', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        DraftModeUIDateTimeIOS(
          mode: DraftModeFormCalendarPickerMode.hourMinute,
          dateTime: DateTime(2024, 3, 15, 10, 30),
          onToggleMonthYear: () {},
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(DraftModeUIDateTimeHourMinute), findsOneWidget);
  });

  testWidgets('DraftModeUIDateTimeIOS respects configured minute steps', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        DraftModeUIDateTimeIOS(
          mode: DraftModeFormCalendarPickerMode.hourMinute,
          dateTime: DateTime(2024, 3, 15, 10, 30),
          hourSteps: DraftModeFormCalendarHourSteps.fifteen,
          onToggleMonthYear: () {},
          onChanged: (_) {},
        ),
      ),
    );

    final minutePicker = find
        .byType(CupertinoPicker)
        .at(1); // second picker renders minutes
    final labels = tester.widgetList<Text>(
      find.descendant(of: minutePicker, matching: find.byType(Text)),
    );
    final values = labels.map((text) => text.data).whereType<String>().toSet();

    expect(values.contains('05'), isFalse);
    expect(values, containsAll(<String>['00', '15', '30', '45']));
  });

  testWidgets('Month grid highlights non-today selection with tertiary badge', (
    tester,
  ) async {
    final selected = DateTime(2030, 3, 15, 10, 30);

    await tester.pumpWidget(
      _wrap(
        DraftModeUIDateTimeMonthGrid(
          dateTime: selected,
          onHeaderTap: () {},
          onSelect: (_) {},
          height: 320,
        ),
      ),
    );

    final buttonFinder = find.widgetWithText(CupertinoButton, '15');
    expect(buttonFinder, findsOneWidget);
    final dayText = tester.widget<Text>(
      find.descendant(of: buttonFinder, matching: find.text('15')).first,
    );
    expect(dayText.style?.color, DraftModeStyleColorActive.tertiary.text);

    final container = tester
        .widgetList<Container>(
          find.descendant(of: buttonFinder, matching: find.byType(Container)),
        )
        .firstWhere(
          (candidate) =>
              candidate.decoration is BoxDecoration &&
              (candidate.decoration as BoxDecoration?)?.shape ==
                  BoxShape.circle,
        );
    final decoration = container.decoration as BoxDecoration?;
    expect(decoration?.color, DraftModeStyleColorActive.tertiary.background);
  });

  testWidgets('Month grid uses red badge when selected day is today', (
    tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 9, 0);

    await tester.pumpWidget(
      _wrap(
        DraftModeUIDateTimeMonthGrid(
          dateTime: today,
          onHeaderTap: () {},
          onSelect: (_) {},
          height: 320,
        ),
      ),
    );

    final buttonFinder = find.widgetWithText(CupertinoButton, '${today.day}');
    expect(buttonFinder, findsOneWidget);
    final dayText = tester.widget<Text>(
      find
          .descendant(of: buttonFinder, matching: find.text('${today.day}'))
          .first,
    );
    expect(dayText.style?.color, DraftModeStyleColorActive.secondary.text);

    final container = tester
        .widgetList<Container>(
          find.descendant(of: buttonFinder, matching: find.byType(Container)),
        )
        .firstWhere(
          (candidate) =>
              candidate.decoration is BoxDecoration &&
              (candidate.decoration as BoxDecoration?)?.shape ==
                  BoxShape.circle,
        );
    final decoration = container.decoration as BoxDecoration?;
    expect(decoration?.color, DraftModeStyleColorActive.secondary.background);
  });

  testWidgets('Month grid marks today in red without selection badge', (
    tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 10, 30);
    final daysInMonth = DraftModeDateTime.getDaysInMonth(now.year, now.month);
    final alternateDay = (today.day < daysInMonth)
        ? today.add(const Duration(days: 1))
        : today.subtract(const Duration(days: 1));

    await tester.pumpWidget(
      _wrap(
        DraftModeUIDateTimeMonthGrid(
          dateTime: alternateDay,
          onHeaderTap: () {},
          onSelect: (_) {},
          height: 320,
        ),
      ),
    );

    final todayButtonFinder = find.widgetWithText(
      CupertinoButton,
      '${today.day}',
    );
    expect(todayButtonFinder, findsOneWidget);

    final todayText = tester.widget<Text>(
      find
          .descendant(
            of: todayButtonFinder,
            matching: find.text('${today.day}'),
          )
          .first,
    );
    expect(
      todayText.style?.color,
      DraftModeStyleColorActive.secondary.background,
    );

    final decoratedContainers = tester
        .widgetList<Container>(
          find.descendant(
            of: todayButtonFinder,
            matching: find.byType(Container),
          ),
        )
        .where(
          (container) =>
              container.decoration is BoxDecoration &&
              (container.decoration as BoxDecoration).shape == BoxShape.circle,
        );
    expect(decoratedContainers, isEmpty);
  });

  testWidgets('DraftModeUIDateTimeIOS renders empty when closed', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        DraftModeUIDateTimeIOS(
          mode: DraftModeFormCalendarPickerMode.closed,
          dateTime: DateTime(2024, 3, 15, 10, 30),
          onToggleMonthYear: () {},
          onChanged: (_) {},
        ),
      ),
    );

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(sizedBox.height, 0);
  });
}
