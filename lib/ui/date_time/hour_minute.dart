import 'package:flutter/cupertino.dart';

/// Cupertino-styled time picker tuned for DraftMode date-time flows.
class DraftModeUIDateTimeHourMinute extends StatelessWidget {
  final DateTime dateTime;
  final double height;
  final void Function(int hour, int minute) onChanged;

  const DraftModeUIDateTimeHourMinute({
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
    final hourLabels = List<String>.generate(
      24,
      (i) => i.toString().padLeft(2, '0'),
    );
    final minutes = List<int>.generate(12, (i) => i * 5);
    final minuteLabels = List<String>.generate(
      12,
      (i) => (i * 5).toString().padLeft(2, '0'),
    );

    int roundToStep(int value) => (value / 5).round() * 5 % 60;

    const double itemHeight = 28;
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
                    initialItem: minutes.indexOf(roundToStep(minute)),
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
