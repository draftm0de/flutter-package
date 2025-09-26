import 'package:flutter/cupertino.dart';
import 'hour_minute.dart';
import 'month_grid.dart';
import 'month_year.dart';
import 'variables.dart';

class DraftModeCalendarIOS extends StatelessWidget {
  final DraftModeFormCalendarPickerMode mode;
  final DateTime dateTime;
  final void Function() onPressed;
  final void Function(DateTime v) onChange;
  // box height for all types
  final double height = 6 * 44;

  const DraftModeCalendarIOS({
    super.key,
    required this.mode,
    required this.dateTime,
    required this.onPressed,
    required this.onChange,
  });

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
            return DraftModeCalendarMonthGrid(
              key: ValueKey('month_grid'),
              dateTime: dateTime,
              onPressed: onPressed,
              onSelect: (DateTime day) {
                onChange(
                  DateTime(
                    day.year,
                    day.month,
                    day.day,
                    dateTime.hour,
                    dateTime.minute,
                  ),
                );
              },
              height: height,
            );

          case DraftModeFormCalendarPickerMode.monthYear:
            return DraftModeCalendarMonthYearInlinePicker(
              key: ValueKey('month_year'),
              dateTime: dateTime,
              onPressed: onPressed,
              onChanged: (m, y) {
                onChange(
                  DateTime(y, m, dateTime.day, dateTime.hour, dateTime.minute),
                );
              },
              height: height,
            );

          case DraftModeFormCalendarPickerMode.hourMinute:
            return DraftModeCalendarHourMinuteInlinePicker(
              key: ValueKey('hour_minute'),
              dateTime: dateTime,
              onChanged: (h, m) {
                onChange(
                  DateTime(dateTime.year, dateTime.month, dateTime.day, h, m),
                );
              },
              height: height,
            );
        }
      }(),
    );
  }
}

@Deprecated('Use DraftModeCalendarIOS instead')
typedef DraftModeCalenderIOS = DraftModeCalendarIOS;
