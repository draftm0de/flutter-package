import 'package:draftmode/form/interface.dart';
import 'package:draftmode/ui/date_time/calendar_ios.dart';
import 'package:draftmode/ui/date_time/hour_minute.dart';
import 'package:draftmode/ui/date_time/month_grid.dart';
import 'package:draftmode/ui/date_time/month_year.dart';
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
