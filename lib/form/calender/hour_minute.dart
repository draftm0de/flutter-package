import 'package:flutter/cupertino.dart';

class DraftModeCalendarHourMinuteInlinePicker extends StatelessWidget {
  final DateTime dateTime;
  final double height;
  final void Function(int h, int m) onChanged;

  const DraftModeCalendarHourMinuteInlinePicker({
    super.key,
    required this.dateTime,
    required this.onChanged,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final int hour = dateTime.hour;
    final int minute = dateTime.minute;

    final hours = List<int>.generate(24, (i) => i);
    final hourNames = List<String>.generate(
      24,
      (i) => i.toString().padLeft(2, '0'),
    );
    final minutes = List<int>.generate(12, (i) => i * 5);
    final minuteNames = List<String>.generate(
      12,
      (i) => (i * 5).toString().padLeft(2, '0'),
    );
    int roundTo5(int minute) {
      return (minute / 5).round() * 5 % 60;
    }

    const double itemHeight = 28;
    return Column(
      key: const ValueKey('hourMinute'),
      children: [
        SizedBox(
          height: height,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: hours.indexOf(hour),
                  ),
                  itemExtent: itemHeight,
                  useMagnifier: true,
                  onSelectedItemChanged: (i) => onChanged(hours[i], minute),
                  looping: true,
                  children: hourNames.map((m) => Text(m)).toList(),
                ),
              ),
              Expanded(
                flex: 1,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: minutes.indexOf(roundTo5(minute)),
                  ),
                  itemExtent: itemHeight,
                  useMagnifier: true,
                  onSelectedItemChanged: (i) => onChanged(hour, minutes[i]),
                  looping: true,
                  children: minuteNames.map((y) => Text(y)).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

@Deprecated('Use DraftModeCalendarHourMinuteInlinePicker instead')
typedef DraftModeCalenderHourMinuteInlinePicker =
    DraftModeCalendarHourMinuteInlinePicker;
