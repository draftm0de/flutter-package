import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../platform/buttons.dart';
import '../../platform/styles.dart';

class DraftModeCalendarMonthYearInlinePicker extends StatelessWidget {
  final DateTime dateTime;
  final double height;
  final void Function() onPressed;
  final void Function(int m, int y) onChanged;

  const DraftModeCalendarMonthYearInlinePicker({
    super.key,
    required this.dateTime,
    required this.onChanged,
    required this.onPressed,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final monthNames = List.generate(
      12,
      (i) => DateFormat.MMMM(locale).format(DateTime(2025, i + 1, 1)),
    );

    final int year = dateTime.year;
    final int month = dateTime.month;

    final now = DateTime.now().year;
    final years = List<int>.generate(101, (i) => now - 50 + i);

    final monthLabel = DateFormat.yMMMM(locale).format(dateTime);
    const double itemHeight = 28;
    return Column(
      key: const ValueKey('monthYear'),
      children: [
        // Optional small toolbar to go back to day view
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: PlatformStyles.horizontalContainerPadding,
          ),
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onPressed, // back to day
                child: Row(
                  children: [
                    Text(
                      monthLabel,
                      style: PlatformStyles.labelStyleActive(context),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      PlatformButtons.arrowUp,
                      size: PlatformStyles.buttonSizeSmall,
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        SizedBox(
          height: height,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: month - 1,
                  ),
                  itemExtent: itemHeight,
                  useMagnifier: true,
                  looping: true,
                  onSelectedItemChanged: (i) => onChanged(i + 1, year),
                  children: monthNames
                      .map((m) => Center(child: Text(m)))
                      .toList(),
                ),
              ),
              Expanded(
                flex: 1,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: years.indexOf(year),
                  ),
                  itemExtent: itemHeight,
                  useMagnifier: true,
                  looping: true,
                  onSelectedItemChanged: (i) => onChanged(month, years[i]),
                  children: years
                      .map((y) => Center(child: Text('$y')))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

@Deprecated('Use DraftModeCalendarMonthYearInlinePicker instead')
typedef DraftModeCalenderMonthYearInlinePicker =
    DraftModeCalendarMonthYearInlinePicker;
