import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../platform/styles.dart';
import '../../ui/grid_text.dart';
import '../../ui/row.dart';
import '../../utils/formatter.dart';

/// Renders a Monday-first strip of days for the week surrounding [dateTime]
/// with a localized header, swipe gestures, and platform-aware selection
/// styling.
class DraftModeElementDateTimeWeekDay extends StatefulWidget {
  final DateTime dateTime;
  final ValueChanged<DateTime> onSelect;

  const DraftModeElementDateTimeWeekDay({
    super.key,
    required this.dateTime,
    required this.onSelect,
  });

  @override
  State<DraftModeElementDateTimeWeekDay> createState() =>
      _DraftModeElementDateTimeWeekDayState();
}

class _DraftModeElementDateTimeWeekDayState
    extends State<DraftModeElementDateTimeWeekDay> {
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
  void didUpdateWidget(covariant DraftModeElementDateTimeWeekDay oldWidget) {
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
              final days = List.generate(7, (dayIndex) {
                return weekStart.add(Duration(days: dayIndex));
              });
              final today = DateTime.now();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DraftModeUIGridText<DateTime>(
                    values: days,
                    onPressed: _onDaySelected,
                    variant: DraftModeUIGridTextVariant.chip,
                    itemHeight: weekDayChipHeight,
                    itemWidth: 36,
                    labelBuilder: (_, dayIndex) => weekdays[dayIndex],
                    isSelected: (day, _) =>
                        DraftModeDateTime.isSameDate(day, _selectedDay),
                    keyBuilder: (day, _) =>
                        ValueKey<String>('chip-${day.toIso8601String()}'),
                  ),
                  DraftModeUIGridText<DateTime>(
                    values: days,
                    onPressed: _onDaySelected,
                    variant: DraftModeUIGridTextVariant.number,
                    itemHeight: weekDayNumberHeight,
                    itemWidth: 32,
                    labelBuilder: (day, _) => '${day.day}',
                    isSelected: (day, _) =>
                        DraftModeDateTime.isSameDate(day, _selectedDay),
                    isActive: (day, _) =>
                        DraftModeDateTime.isSameDate(day, today),
                    keyBuilder: (day, _) => ValueKey<DateTime>(day),
                  ),
                ],
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
    final utcWeekStart = DateTime.utc(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    return utcWeekStart.difference(_anchorMondayUtc).inDays ~/
        DateTime.daysPerWeek;
  }
}
