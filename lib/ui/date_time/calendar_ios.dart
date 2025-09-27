import 'package:flutter/cupertino.dart';

import '../../form/calender/variables.dart';
import 'hour_minute.dart';
import 'month_grid.dart';
import 'month_year.dart';

class DraftModeUIDateTimeIOS extends StatelessWidget {
  final DraftModeFormCalendarPickerMode mode;
  final DateTime dateTime;
  final VoidCallback onToggleMonthYear;
  final ValueChanged<DateTime> onChanged;

  const DraftModeUIDateTimeIOS({
    super.key,
    required this.mode,
    required this.dateTime,
    required this.onToggleMonthYear,
    required this.onChanged,
  });

  static const double _gridPanelHeight = 6 * 44;
  static const double _timePanelHeight = 6 * 44;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: () {
        switch (mode) {
          case DraftModeFormCalendarPickerMode.closed:
            return const SizedBox(key: ValueKey('closed'), height: 0);

          case DraftModeFormCalendarPickerMode.day:
            return DraftModeUIDateTimeMonthGrid(
              key: const ValueKey('month_grid'),
              dateTime: dateTime,
              onHeaderTap: onToggleMonthYear,
              onSelect: (day) {
                onChanged(
                  DateTime(
                    day.year,
                    day.month,
                    day.day,
                    dateTime.hour,
                    dateTime.minute,
                  ),
                );
              },
              height: _gridPanelHeight,
            );

          case DraftModeFormCalendarPickerMode.monthYear:
            return DraftModeUIDateTimeMonthYear(
              key: const ValueKey('month_year'),
              dateTime: dateTime,
              onBackToDay: onToggleMonthYear,
              onChanged: (month, year) {
                onChanged(
                  DateTime(
                    year,
                    month,
                    dateTime.day,
                    dateTime.hour,
                    dateTime.minute,
                  ),
                );
              },
              height: _timePanelHeight,
            );

          case DraftModeFormCalendarPickerMode.hourMinute:
            return DraftModeUIDateTimeHourMinute(
              key: const ValueKey('hour_minute'),
              dateTime: dateTime,
              onChanged: (hour, minute) {
                onChanged(
                  DateTime(
                    dateTime.year,
                    dateTime.month,
                    dateTime.day,
                    hour,
                    minute,
                  ),
                );
              },
              height: _timePanelHeight,
            );
        }
      }(),
    );
  }
}
