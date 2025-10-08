import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../platform/styles.dart';
import '../../utils/formatter.dart';
import '../row.dart';

/// Renders a Monday-first strip of days for the week surrounding [dateTime]
/// with a localized header, swipe gestures, and platform-aware selection
/// styling.
class DraftModeUIDateTimeWeekDay extends StatefulWidget {
  final DateTime dateTime;
  final ValueChanged<DateTime> onSelect;

  const DraftModeUIDateTimeWeekDay({
    super.key,
    required this.dateTime,
    required this.onSelect,
  });

  @override
  State<DraftModeUIDateTimeWeekDay> createState() =>
      _DraftModeUIDateTimeWeekDayState();
}

class _DraftModeUIDateTimeWeekDayState
    extends State<DraftModeUIDateTimeWeekDay> {
  static const int _anchorPage = 12000;
  static final DateTime _anchorMondayUtc = DateTime.utc(2000, 1, 3);

  late DateTime _selectedDay;
  late int _weekdayOffset;
  late int _currentPage;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _selectedDay = _coerceDate(widget.dateTime);
    _weekdayOffset = _weekdayOffsetFor(_selectedDay);
    _currentPage = _pageFromDate(_selectedDay);
    _controller = PageController(initialPage: _currentPage);
  }

  @override
  void didUpdateWidget(covariant DraftModeUIDateTimeWeekDay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = _coerceDate(widget.dateTime);
    final previous = _coerceDate(oldWidget.dateTime);
    final externalUpdate = !DraftModeDateTime.isSameDate(incoming, previous);
    if (externalUpdate &&
        !DraftModeDateTime.isSameDate(incoming, _selectedDay)) {
      setState(() {
        _selectedDay = incoming;
        _weekdayOffset = _weekdayOffsetFor(_selectedDay);
        final page = _pageFromDate(_selectedDay);
        if (page != _currentPage) {
          _currentPage = page;
          if (_controller.hasClients) {
            _controller.jumpToPage(_currentPage);
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _controller.hasClients) {
                _controller.jumpToPage(_currentPage);
              }
            });
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double weekDayChipHeight = 28;
    final double weekDayNumberHeight = 32;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final weekdays = _weekdayShort(locale);
    final headerLabel = DateFormat('d. MMMM y', locale).format(_selectedDay);

    return Column(
      key: const ValueKey('week_day'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DraftModeUIRow(
          child: Text(
            key: const ValueKey('week_day_header'),
            headerLabel,
            style: TextStyle(
              fontSize: DraftModeStyleFontSize.primary,
              color: DraftModeStyleColor.primary.text,
            ),
          ),
        ),
        SizedBox(
          height: weekDayChipHeight + weekDayNumberHeight,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: _handlePageChanged,
            itemBuilder: (_, index) {
              final weekStart = _weekStartFromPage(index);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: List.generate(7, (dayIndex) {
                    final day = weekStart.add(Duration(days: dayIndex));
                    final isSelected = DraftModeDateTime.isSameDate(
                      day,
                      _selectedDay,
                    );
                    final isCurrentDate = DraftModeDateTime.isSameDate(
                      day,
                      DateTime.now(),
                    );
                    return Expanded(
                      child: CupertinoButton(
                        key: ValueKey<DateTime>(day),
                        padding: EdgeInsets.zero,
                        onPressed: () => _onDaySelected(day),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _WeekdayChip(
                              label: weekdays[dayIndex],
                              isSelected: isSelected,
                              height: weekDayChipHeight,
                            ),
                            _WeekdayNumber(
                              value: day.day,
                              isSelected: isSelected,
                              isToday: isCurrentDate,
                              height: weekDayNumberHeight,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onDaySelected(DateTime day) {
    final coerced = _coerceDate(day);
    if (DraftModeDateTime.isSameDate(coerced, _selectedDay)) {
      widget.onSelect(coerced);
      return;
    }

    setState(() {
      _selectedDay = coerced;
      _weekdayOffset = _weekdayOffsetFor(_selectedDay);
      final targetPage = _pageFromDate(_selectedDay);
      if (targetPage != _currentPage) {
        _currentPage = targetPage;
        if (_controller.hasClients) {
          _controller.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _controller.hasClients) {
              _controller.jumpToPage(_currentPage);
            }
          });
        }
      }
    });
    widget.onSelect(coerced);
  }

  void _handlePageChanged(int index) {
    setState(() {
      _currentPage = index;
      final weekStart = _weekStartFromPage(index);
      final updatedSelection = weekStart.add(
        Duration(days: _weekdayOffset.clamp(0, 6)),
      );
      if (!DraftModeDateTime.isSameDate(updatedSelection, _selectedDay)) {
        _selectedDay = updatedSelection;
        widget.onSelect(updatedSelection);
      }
    });
  }

  static DateTime _coerceDate(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static int _weekdayOffsetFor(DateTime value) => (value.weekday + 6) % 7;

  static DateTime _mondayFor(DateTime value) =>
      value.subtract(Duration(days: _weekdayOffsetFor(value)));

  int _pageFromDate(DateTime value) {
    final weekStart = _mondayFor(value);
    final weeksFromAnchor = _weeksFromAnchor(weekStart);
    return _anchorPage + weeksFromAnchor;
  }

  DateTime _weekStartFromPage(int index) {
    final weeksFromAnchor = index - _anchorPage;
    final utcWeek = _anchorMondayUtc.add(Duration(days: weeksFromAnchor * 7));
    return DateTime(utcWeek.year, utcWeek.month, utcWeek.day);
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

  int _weeksFromAnchor(DateTime weekStart) {
    // Convert to UTC so week calculations stay stable across daylight saving
    // shifts; this keeps paging consistent on German locales where October has
    // DST transitions.
    final utcWeekStart = DateTime.utc(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    return utcWeekStart.difference(_anchorMondayUtc).inDays ~/
        DateTime.daysPerWeek;
  }
}

class _WeekdayChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final double height;

  const _WeekdayChip({
    required this.label,
    required this.isSelected,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: DraftModeStyleFontSize.tertiary,
      fontWeight: DraftModeStyleFontWeight.primary,
      color: isSelected
          ? DraftModeStyleColorActive.secondary.text
          : DraftModeStyleColor.primary.text,
    );

    return Container(
      height: height,
      width: 36,
      alignment: Alignment.center,
      decoration: isSelected
          ? BoxDecoration(
              color: DraftModeStyleColorActive.secondary.background,
              borderRadius: BorderRadius.circular(20),
            )
          : null,
      child: Text(label, style: textStyle, textAlign: TextAlign.center),
    );
  }
}

class _WeekdayNumber extends StatelessWidget {
  final int value;
  final bool isSelected;
  final bool isToday;
  final double height;

  const _WeekdayNumber({
    required this.value,
    required this.isSelected,
    required this.isToday,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isToday
        ? DraftModeStyleColorActive.secondary.background
        : DraftModeStyleColor.primary.text;

    final fontWeight = isSelected
        ? DraftModeStyleFontWeight.secondary
        : DraftModeStyleFontWeight.primary;

    return SizedBox(
      height: height,
      width: 32,
      child: Center(
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: DraftModeStyleFontSize.primary,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
