import 'package:flutter/cupertino.dart';

import '../../form/interface.dart';

/// Cupertino-styled time picker tuned for DraftMode date-time flows.
class DraftModeUIDateTimeHourMinute extends StatelessWidget {
  final DateTime dateTime;
  final double height;
  final void Function(int hour, int minute) onChanged;
  final DraftModeFormCalendarHourSteps hourSteps;

  const DraftModeUIDateTimeHourMinute({
    super.key,
    required this.dateTime,
    required this.onChanged,
    required this.height,
    required this.hourSteps,
  });

  @override
  Widget build(BuildContext context) {
    final int hour = dateTime.hour;
    final int minute = dateTime.minute;

    final hours = List<int>.generate(24, (i) => i);
    final hourLabels = List<String>.generate(
      24,
      (i) => i.toString().padLeft(2, '0'),
    );
    final int minuteStep = hourSteps.minutes;
    final minutes = List<int>.generate(60 ~/ minuteStep, (i) => i * minuteStep);
    final minuteLabels = minutes
        .map((value) => value.toString().padLeft(2, '0'))
        .toList(growable: false);

    int roundToStep(int value) {
      final rounded = ((value / minuteStep).round() * minuteStep);
      if (rounded >= 60) {
        return rounded - 60;
      }
      if (rounded < 0) {
        return 0;
      }
      return rounded;
    }

    const double itemHeight = 28;
    final initialMinute = roundToStep(minute);
    final initialMinuteIndex = minutes.indexOf(initialMinute);
    final resolvedMinuteIndex = initialMinuteIndex >= 0
        ? initialMinuteIndex
        : 0;
    return Column(
      key: const ValueKey('hourMinute'),
      children: [
        SizedBox(
          height: height,
          child: Row(
            children: [
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: hours.indexOf(hour),
                  ),
                  itemExtent: itemHeight,
                  useMagnifier: true,
                  onSelectedItemChanged: (index) =>
                      onChanged(hours[index], minute),
                  looping: true,
                  children: hourLabels.map(Text.new).toList(),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: resolvedMinuteIndex,
                  ),
                  itemExtent: itemHeight,
                  useMagnifier: true,
                  onSelectedItemChanged: (index) =>
                      onChanged(hour, minutes[index]),
                  looping: true,
                  children: minuteLabels.map(Text.new).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
