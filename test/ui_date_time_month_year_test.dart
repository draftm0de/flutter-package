import 'package:draftmode/form/interface.dart';
import 'package:draftmode/ui/date_time/month_year.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    Intl.defaultLocale = 'en';
  });

  testWidgets(
    'DraftModeUIDateTimeMonthYear renders header and reacts to pickers',
    (tester) async {
      final date = DateTime(2025, 5, 20);
      int? monthChanged;
      int? yearChanged;
      bool backTapped = false;

      await tester.pumpWidget(
        CupertinoApp(
          locale: const Locale('en'),
          home: DraftModeUIDateTimeMonthYear(
            dateTime: date,
            height: 200,
            onBackToDay: () => backTapped = true,
            onChanged: (month, year) {
              monthChanged = month;
              yearChanged = year;
            },
          ),
        ),
      );

      expect(find.text('May 2025'), findsOneWidget);
      await tester.tap(find.byType(CupertinoButton));
      await tester.pump();
      expect(backTapped, isTrue);

      final monthPicker = tester.widget<CupertinoPicker>(
        find.byType(CupertinoPicker).first,
      );
      monthPicker.onSelectedItemChanged?.call(6);
      expect(monthChanged, 7);
      expect(yearChanged, date.year);

      final yearPicker = tester.widget<CupertinoPicker>(
        find.byType(CupertinoPicker).at(1),
      );
      yearPicker.onSelectedItemChanged?.call(55);
      expect(yearChanged, DateTime.now().year - 50 + 55);
    },
  );
}
