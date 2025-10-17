import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../platform/buttons.dart';
import '../../platform/styles.dart';
import '../../utils/formatter.dart';
import '../../ui/grid_text.dart';

class DraftModeElementDateTimeMonthGrid extends StatelessWidget {
  final DateTime dateTime;
  final VoidCallback onHeaderTap;
  final ValueChanged<DateTime> onSelect;
  final double height;

  const DraftModeElementDateTimeMonthGrid({
    super.key,
    required this.dateTime,
    required this.onHeaderTap,
    required this.onSelect,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    DateTime monthStart = dateTime;

    const int anchorPage = 12000;
    final DateTime anchorMonth = DateTime(2000, 1, 1);

    int pageFromDate(DateTime value) {
      final months =
          (value.year - anchorMonth.year) * 12 +
          (value.month - anchorMonth.month);
      return anchorPage + months;
    }

    DateTime dateFromPage(int index) {
      final monthsFromAnchor = index - anchorPage;
      return DateTime(
        anchorMonth.year,
        anchorMonth.month + monthsFromAnchor,
        1,
      );
    }

    final controller = PageController(initialPage: pageFromDate(dateTime));

    void goPrevious() {
      if (!controller.hasClients) return;
      controller.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    void goNext() {
      if (!controller.hasClients) return;
      controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    void handlePageChanged(int targetIndex) {
      final month = dateFromPage(targetIndex);
      final maxDay = DraftModeDateTime.getDaysInMonth(month.year, month.month);
      final clampedDay = dateTime.day > maxDay ? maxDay : dateTime.day;
      onSelect(
        DateTime(
          month.year,
          month.month,
          clampedDay,
          dateTime.hour,
          dateTime.minute,
        ),
      );
    }

    final monthLabel = DateFormat.yMMMM(locale).format(dateTime);

    List<String> weekdayShort(String locale) {
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

    final weekdays = weekdayShort(locale);

    return Column(
      key: const ValueKey('day'),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DraftModeStylePadding.primary,
          ),
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onHeaderTap,
                child: Row(
                  children: [
                    Text(monthLabel, style: DraftModeStyleText.primary),
                    const SizedBox(width: 6),
                    Icon(
                      PlatformButtons.arrowDown,
                      size: PlatformStyles.buttonSizeSmall,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: goPrevious,
                child: Icon(PlatformButtons.arrowLeft),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: goNext,
                child: Icon(PlatformButtons.arrowRight),
              ),
            ],
          ),
        ),
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: controller,
            onPageChanged: handlePageChanged,
            itemBuilder: (_, index) {
              monthStart = dateFromPage(index);

              final year = monthStart.year;
              final month = monthStart.month;
              final daysInMonth = DraftModeDateTime.getDaysInMonth(year, month);
              final DateTime firstDay = DateTime(year, month, 1);

              final int shift = (firstDay.weekday + 6) % 7;
              final totalCells = daysInMonth + shift;
              final rows = (totalCells / 7).ceil();

              return Column(
                children: [
                  DraftModeUIGridText<String>(
                    values: weekdays,
                    onPressed: null,
                    variant: DraftModeUIGridTextVariant.chip,
                    itemHeight: 20,
                    itemWidth: 36,
                    labelBuilder: (value, _) => value,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final rowHeight = constraints.maxHeight / rows;
                        final dayDiameter = math.max(28.0, rowHeight - 8);

                        return Column(
                          children: List.generate(rows, (row) {
                            final rowValues = List<DateTime?>.generate(7, (
                              col,
                            ) {
                              final index = row * 7 + col;
                              final dayNumber = index - shift + 1;
                              if (dayNumber < 1 || dayNumber > daysInMonth) {
                                return null;
                              }
                              return DateTime(year, month, dayNumber);
                            });

                            return SizedBox(
                              height: rowHeight,
                              child: DraftModeUIGridText<DateTime?>(
                                values: rowValues,
                                onPressed: (day) {
                                  if (day != null) {
                                    onSelect(day);
                                  }
                                },
                                variant: DraftModeUIGridTextVariant.calendar,
                                itemHeight: rowHeight,
                                itemWidth: dayDiameter,
                                labelBuilder: (day, _) => '${day!.day}',
                                isSelected: (day, _) =>
                                    day != null &&
                                    day.year == dateTime.year &&
                                    day.month == dateTime.month &&
                                    day.day == dateTime.day,
                                isActive: (day, _) =>
                                    day != null &&
                                    DraftModeDateTime.isSameDate(
                                      day,
                                      DateTime.now(),
                                    ),
                                keyBuilder: (day, index) => day == null
                                    ? ValueKey<String>(
                                        'calendar-placeholder-$row-$index',
                                      )
                                    : ValueKey<DateTime>(day),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
