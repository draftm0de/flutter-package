import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../platform/styles.dart';

/// Renders a Monday-first strip of days for the week surrounding [dateTime]
/// with a localized header and platform-aware selection styling.
class DraftModeUIDateTimeWeekDay extends StatelessWidget {
  final DateTime dateTime;
  final ValueChanged<DateTime> onSelect;

  const DraftModeUIDateTimeWeekDay({
    super.key,
    required this.dateTime,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final selectedDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final startOfWeek = selectedDay.subtract(
      Duration(days: (selectedDay.weekday + 6) % 7),
    );
    final days = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );
    final weekdays = _weekdayShort(locale);
    final headerLabel = DateFormat('d. MMMM y', locale).format(selectedDay);

    return Column(
      key: const ValueKey('week_day'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: PlatformStyles.horizontalContainerPadding,
          ),
          child: Text(
            key: const ValueKey('week_day_header'),
            headerLabel,
            style: PlatformStyles.labelStyle(context),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: List.generate(7, (index) {
              final day = days[index];
              final isSelected =
                  day.year == selectedDay.year &&
                  day.month == selectedDay.month &&
                  day.day == selectedDay.day;

              return Expanded(
                child: CupertinoButton(
                  key: ValueKey<DateTime>(day),
                  padding: EdgeInsets.zero,
                  onPressed: () => onSelect(day),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _WeekdayChip(
                        label: weekdays[index],
                        isSelected: isSelected,
                      ),
                      const SizedBox(height: 6),
                      _WeekdayNumber(value: day.day, isSelected: isSelected),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  List<String> _weekdayShort(String locale) {
    try {
      final monday = DateTime(2025, 9, 1);
      final fmt = DateFormat.E(locale);
      return List.generate(
        7,
        (i) => fmt
            .format(monday.add(Duration(days: i)))
            .characters
            .take(2)
            .toString()
            .toUpperCase(),
      );
    } catch (_) {
      return const ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
    }
  }
}

class _WeekdayChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _WeekdayChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final Color textColor = isSelected
        ? CupertinoColors.white
        : CupertinoColors.secondaryLabel;

    const baseStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);

    return Container(
      height: 28,
      width: 36,
      alignment: Alignment.center,
      decoration: isSelected
          ? BoxDecoration(
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(14),
            )
          : null,
      child: Text(
        label,
        style: baseStyle.copyWith(color: textColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _WeekdayNumber extends StatelessWidget {
  final int value;
  final bool isSelected;

  const _WeekdayNumber({required this.value, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 17,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      color: isSelected ? CupertinoColors.white : CupertinoColors.label,
    );

    return Container(
      height: 32,
      width: 32,
      alignment: Alignment.center,
      decoration: isSelected
          ? const BoxDecoration(
              color: CupertinoColors.activeBlue,
              shape: BoxShape.circle,
            )
          : null,
      child: Text('$value', style: textStyle),
    );
  }
}
