import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../platform/buttons.dart';
import '../../platform/styles.dart';
import '../../utils/formatter.dart';

class DraftModeUIDateTimeMonthGrid extends StatelessWidget {
  final DateTime dateTime;
  final VoidCallback onHeaderTap;
  final ValueChanged<DateTime> onSelect;
  final double height;
  const DraftModeUIDateTimeMonthGrid({
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
            horizontal: PlatformStyles.horizontalContainerPadding,
          ),
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onHeaderTap,
                child: Row(
                  children: [
                    Text(monthLabel, style: PlatformStyles.labelStyle(context)),
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

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: List.generate(7, (index) {
                          return Expanded(
                            child: Center(
                              child: Text(
                                weekdays[index],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.secondaryLabel,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final rowHeight = constraints.maxHeight / rows;
                          final dayDiameter = math.max(28.0, rowHeight - 8);

                          return Column(
                            children: List.generate(rows, (row) {
                              return SizedBox(
                                height: rowHeight,
                                child: Row(
                                  children: List.generate(7, (col) {
                                    final index = row * 7 + col;
                                    final dayNumber = index - shift + 1;
                                    if (dayNumber < 1 ||
                                        dayNumber > daysInMonth) {
                                      return const Expanded(child: SizedBox());
                                    }

                                    final day = DateTime(
                                      year,
                                      month,
                                      dayNumber,
                                    );
                                    final isSelected =
                                        day.year == dateTime.year &&
                                        day.month == dateTime.month &&
                                        day.day == dateTime.day;

                                    return Expanded(
                                      child: CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () => onSelect(day),
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: dayDiameter,
                                          width: dayDiameter,
                                          decoration: isSelected
                                              ? const BoxDecoration(
                                                  color: CupertinoColors
                                                      .activeBlue,
                                                  shape: BoxShape.circle,
                                                )
                                              : null,
                                          child: Text(
                                            '$dayNumber',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              color: isSelected
                                                  ? CupertinoColors.white
                                                  : CupertinoColors.label,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
