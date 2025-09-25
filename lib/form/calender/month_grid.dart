import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../utils/formatter.dart';
import '../../platform/config.dart';
import '../../platform/buttons.dart';

class DraftModeCalenderMonthGrid extends StatelessWidget {
  final DateTime dateTime;
  final void Function() onPressed;
  final ValueChanged<DateTime> onSelect;
  final double height;

  const DraftModeCalenderMonthGrid({
    super.key,
    required this.dateTime,
    required this.onPressed,
    required this.onSelect,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    DateTime monthStart = dateTime;

    // PageController
    final int kAnchorPage = 12000;
    final DateTime anchorMonth = DateTime(2000, 1, 1);

    int getIndexFromDateTime(DateTime d) {
      final months =
          (d.year - anchorMonth.year) * 12 + (d.month - anchorMonth.month);
      return kAnchorPage + months;
    }

    DateTime getDateTimeFromIndex(int index) {
      final monthsFromAnchor = index - kAnchorPage;
      return DateTime(
        anchorMonth.year,
        anchorMonth.month + monthsFromAnchor,
        1,
      );
    }

    final PageController pageController = PageController(
      initialPage: getIndexFromDateTime(dateTime),
    );

    // PageNavigation
    void onTapPreviousMonth() {
      if (!pageController.hasClients) return;
      pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    void onTapNextMonth() {
      if (!pageController.hasClients) return;
      pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    void onSwipedMonth(int targetIndex) {
      final DateTime monthDateTime = getDateTimeFromIndex(targetIndex);
      final maxDay = DraftModeDateTime.getDaysInMonth(
        monthDateTime.year,
        monthDateTime.month,
      );
      final sameOrClampedDay = (dateTime.day > maxDay) ? maxDay : dateTime.day;
      final DateTime newDateTime = DateTime(
        monthDateTime.year,
        monthDateTime.month,
        sameOrClampedDay,
        dateTime.hour,
        dateTime.minute,
      );
      onSelect(newDateTime);
    }

    final year = monthStart.year;
    final month = monthStart.month;
    final daysInMonth = DraftModeDateTime.getDaysInMonth(year, month);
    final DateTime firstDayInMonth = DateTime(year, month, 1);

    // Monday=1…Sunday=7 -> shift to Monday=0
    final shift = (firstDayInMonth.weekday + 6) % 7;
    final totalCells = daysInMonth + shift;
    final rows = (totalCells / 7).ceil();

    final monthLabel = DateFormat.yMMMM(locale).format(dateTime);

    // Localized, Monday-first weekday labels
    List<String> weekdayShort(String locale) {
      try {
        final monday = DateTime(2025, 9, 1); // a fixed date for monday
        final fmt = DateFormat.E(locale);
        final list = List.generate(
          7,
          (i) => fmt.format(monday.add(Duration(days: i))),
        );
        return list
            .map((s) => s.characters.take(2).toString().toUpperCase())
            .toList();
      } catch (_) {
        return const ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
      }
    }

    final weekdayList = weekdayShort(locale);

    final Widget dateTimeGrid = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: List.generate(7, (i) {
                return Expanded(
                  child: Center(
                    child: Text(
                      weekdayList[i],
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
          ...List.generate(rows, (row) {
            return SizedBox(
              height: 44,
              child: Row(
                children: List.generate(7, (col) {
                  final cellIndex = row * 7 + col;
                  final dayNum = cellIndex - shift + 1;
                  if (dayNum < 1 || dayNum > daysInMonth) {
                    return const Expanded(child: SizedBox());
                  }
                  final day = DateTime(year, month, dayNum);
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
                        height: 36,
                        width: 36,
                        decoration: isSelected
                            ? BoxDecoration(
                                color: CupertinoColors.activeBlue,
                                shape: BoxShape.circle,
                              )
                            : null,
                        child: Text(
                          '$dayNum',
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
        ],
      ),
    );

    return Column(
      key: const ValueKey('day'),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: PlatformConfig.horizontalContainerPadding,
          ),
          child: Row(
            children: [
              // Month/Year toggle button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onPressed,
                child: Row(
                  children: [
                    Text(monthLabel, style: PlatformConfig.labelStyle(context)),
                    const SizedBox(width: 6),
                    Icon(
                      PlatformButtons.arrowDown,
                      size: PlatformConfig.buttonSizeSmall,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Month navigation arrows
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onTapPreviousMonth,
                child: Icon(PlatformButtons.arrowLeft),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onTapNextMonth,
                child: Icon(PlatformButtons.arrowRight),
              ),
            ],
          ),
        ),
        // Day grid pages
        SizedBox(
          height: height,
          child: PageView.builder(
            key: key,
            controller: pageController,
            onPageChanged: onSwipedMonth,
            itemBuilder: (_, index) {
              monthStart = getDateTimeFromIndex(index);
              return dateTimeGrid;
            },
          ),
        ),
      ],
    );
  }
}
