import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../platform/buttons.dart';
import '../../platform/styles.dart';

class DraftModeUIDateTimeMonthYear extends StatelessWidget {
  final DateTime dateTime;
  final double height;
  final VoidCallback onBackToDay;
  final void Function(int month, int year) onChanged;

  const DraftModeUIDateTimeMonthYear({
    super.key,
    required this.dateTime,
    required this.onChanged,
    required this.onBackToDay,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final monthNames = List.generate(
      12,
      (index) => DateFormat.MMMM(locale).format(DateTime(2025, index + 1, 1)),
    );

    final int year = dateTime.year;
    final int month = dateTime.month;
    final now = DateTime.now().year;
    final years = List<int>.generate(101, (i) => now - 50 + i);

    final label = DateFormat.yMMMM(locale).format(dateTime);
    const double itemHeight = 28;

    return Column(
      key: const ValueKey('monthYear'),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DraftModeStylePadding.primary,
          ),
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onBackToDay,
                child: Row(
                  children: [
                    Text(label, style: DraftModeStyleText.primary),
                    const SizedBox(width: 6),
                    Icon(
                      PlatformButtons.arrowUp,
                      size: DraftModeStyleIconSize.medium,
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
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: month - 1,
                  ),
                  itemExtent: itemHeight,
                  useMagnifier: true,
                  looping: true,
                  onSelectedItemChanged: (index) => onChanged(index + 1, year),
                  children: monthNames
                      .map((name) => Center(child: Text(name)))
                      .toList(),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: years.indexOf(year),
                  ),
                  itemExtent: itemHeight,
                  useMagnifier: true,
                  looping: true,
                  onSelectedItemChanged: (index) =>
                      onChanged(month, years[index]),
                  children: years
                      .map((value) => Center(child: Text('$value')))
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
