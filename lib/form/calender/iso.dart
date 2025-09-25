import 'package:flutter/cupertino.dart';
import 'variables.dart';
import 'month_grid.dart';
import 'month_year.dart';
import 'hour_minute.dart';

class DraftModeCalenderIOS extends StatelessWidget {
  final DraftModeFormCalenderPickerMode mode;
  final DateTime dateTime;
  final void Function() onPressed;
  final void Function(DateTime v) onChange;
  // box height for all types
  final double height = 6 * 44;

  const DraftModeCalenderIOS({
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
          case DraftModeFormCalenderPickerMode.closed:
            return const SizedBox(key: ValueKey('closed'), height: 0);

          case DraftModeFormCalenderPickerMode.day:
            return DraftModeCalenderMonthGrid(
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

          case DraftModeFormCalenderPickerMode.monthYear:
            return DraftModeCalenderMonthYearInlinePicker(
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

          case DraftModeFormCalenderPickerMode.hourMinute:
            return DraftModeCalenderHourMinuteInlinePicker(
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
