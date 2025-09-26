import 'package:draftmode/entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../platform/styles.dart';
import '../ui.dart';
import '../utils/formatter.dart';
import 'button.dart';
import 'calender/iso.dart';
import 'calender/variables.dart';

/// Identifies which half of the date-range picker currently owns the inline
/// calendar controls.
enum DraftModeFormCalendarPicker { none, from, to }

/// Lightweight trigger passed down from parent widgets to open the picker in a
/// specific mode or seed it with an externally selected value.
class DraftModeFormCalendarTrigger {
  final DraftModeFormCalendarPicker mode;
  final DateTime? value;
  const DraftModeFormCalendarTrigger(this.mode, this.value);
}

/// Composite widget that renders Draftmode's bespoke calendar/date-time picker.
/// It keeps entity attributes in sync, supports optional "to" ranges and can
/// surface a derived duration label when required.
class DraftModeFormCalendar extends StatefulWidget {
  static const Object _notSpecified = Object();

  final DraftModeEntityAttribute<DateTime> from;
  final String? fromLabel;
  final ValueChanged<DateTime>? fromOnChange;

  final bool toEnabled;
  final DraftModeEntityAttribute<DateTime>? to;
  final String? toLabel;
  final ValueChanged<DateTime>? toOnChange;

  final DraftModeFormCalendarMode mode;
  final DraftModeFormCalendarMode toMode;
  final DraftModeFormCalendarDurationMode durationMode;
  final String? durationLabel;
  final DraftModeFormCalendarTrigger? formTrigger;

  const DraftModeFormCalendar({
    super.key,
    required this.from,
    this.fromLabel,
    this.fromOnChange,
    Object? to = _notSpecified,
    this.toLabel,
    this.toOnChange,
    this.mode = DraftModeFormCalendarMode.datetime,
    DraftModeFormCalendarMode? toMode,
    DraftModeFormCalendarDurationMode? durationMode,
    this.durationLabel,
    this.formTrigger,
  }) : to = identical(to, _notSpecified)
           ? null
           : to as DraftModeEntityAttribute<DateTime>?,
       toEnabled = !identical(to, _notSpecified),
       durationMode = durationMode ?? DraftModeFormCalendarDurationMode.none,
       toMode = toMode ?? mode;

  @override
  State<DraftModeFormCalendar> createState() => _DraftModeFormCalendarState();
}

class _DraftModeFormCalendarState extends State<DraftModeFormCalendar> {
  DraftModeFormCalendarPicker _owner = DraftModeFormCalendarPicker.none;
  DraftModeFormCalendarPickerMode _mode =
      DraftModeFormCalendarPickerMode.closed;

  String? _duration;
  late DateTime _selectedFrom;
  DateTime? _selectedTo;

  late String fromLabel;
  late String toLabel;
  late String durationLabel;

  bool _labelsInit = false;

  bool get _hasTo => widget.toEnabled && widget.to != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedFrom =
        _normalizeDateTime(
          widget.from.value ?? now,
          DraftModeFormCalendarPicker.from,
        ) ??
        now;
    _selectedTo = _hasTo
        ? _normalizeDateTime(
            widget.to!.value ?? _selectedFrom,
            DraftModeFormCalendarPicker.to,
          )
        : null;
    _recomputeDuration();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_labelsInit) return;

    final loc = DraftModeLocalizations.of(context);
    fromLabel = widget.fromLabel ?? (loc?.calendarStart ?? 'Begin');
    toLabel = widget.toLabel ?? (loc?.calendarEnd ?? 'End');
    durationLabel =
        widget.durationLabel ?? (loc?.calendarDuration ?? 'Duration');
    _labelsInit = true;
  }

  DateTime? _normalizeDateTime(
    DateTime? value,
    DraftModeFormCalendarPicker owner,
  ) {
    if (value == null) return null;
    const minuteSteps = 5;
    final remainder = value.minute % minuteSteps;
    final delta = owner == DraftModeFormCalendarPicker.from
        ? -remainder
        : (remainder == 0 ? 0 : minuteSteps - remainder);
    return DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute + delta,
      0,
    );
  }

  @override
  void didUpdateWidget(covariant DraftModeFormCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final trigger = widget.formTrigger;
    final oldTrigger = oldWidget.formTrigger;

    if (trigger?.mode == oldTrigger?.mode &&
        trigger?.value == oldTrigger?.value) {
      return;
    }

    final selectedFrom = trigger?.mode == DraftModeFormCalendarPicker.from
        ? _normalizeDateTime(trigger?.value, DraftModeFormCalendarPicker.from)
        : null;
    final selectedTo = trigger?.mode == DraftModeFormCalendarPicker.to
        ? _normalizeDateTime(trigger?.value, DraftModeFormCalendarPicker.to)
        : null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        if (selectedFrom != null) {
          _updateDateTimes(selectedFrom, DraftModeFormCalendarPicker.from);
        } else if (selectedTo != null) {
          _updateDateTimes(selectedTo, DraftModeFormCalendarPicker.to);
        }
        _mode = DraftModeFormCalendarPickerMode.closed;
      });
    });
  }

  void _toggleMonthDropDown() {
    setState(() {
      _mode = (_mode == DraftModeFormCalendarPickerMode.day)
          ? DraftModeFormCalendarPickerMode.monthYear
          : DraftModeFormCalendarPickerMode.day;
    });
  }

  Future<void> _toggleOwner(
    DraftModeFormCalendarPicker owner,
    DraftModeFormCalendarPickerMode mode,
  ) async {
    setState(() {
      if (_owner == owner && _mode == mode) {
        _owner = DraftModeFormCalendarPicker.none;
        _mode = DraftModeFormCalendarPickerMode.closed;
      } else {
        _owner = owner;
        _mode = mode;
      }
    });
  }

  void _updateDateTimes(DateTime value, DraftModeFormCalendarPicker owner) {
    setState(() {
      final normalized = _normalizeDateTime(value, owner) ?? value;
      if (owner == DraftModeFormCalendarPicker.from) {
        final previousFrom = _selectedFrom;
        _selectedFrom = normalized;
        if (_selectedTo != null) {
          final diff = normalized.difference(previousFrom);
          _selectedTo = _selectedTo!.add(diff);
        }
      } else {
        _selectedTo = normalized;
      }
      _recomputeDuration();
    });
  }

  void _recomputeDuration() {
    if (widget.durationMode != DraftModeFormCalendarDurationMode.hours ||
        _selectedTo == null) {
      _duration = null;
      return;
    }
    _duration = DraftModeDateTime.getDurationHourMinutes(
      _selectedFrom,
      _selectedTo!,
    );
  }

  String _dateLabel(DateTime value) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DraftModeDateTime.yMMdd(locale).format(value);
  }

  String _timeLabel(DateTime value) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.Hm(locale).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final toValue = _selectedTo ?? _selectedFrom;

    return Column(
      children: [
        _buildDateTimePicker(
          owner: DraftModeFormCalendarPicker.from,
          label: fromLabel,
          element: widget.from,
          dateTime: _selectedFrom,
          onChange: (value) {
            _updateDateTimes(value, DraftModeFormCalendarPicker.from);
            widget.fromOnChange?.call(value);
          },
        ),
        if (_hasTo)
          _buildDateTimePicker(
            owner: DraftModeFormCalendarPicker.to,
            label: toLabel,
            element: widget.to,
            dateTime: toValue,
            onChange: (value) {
              _updateDateTimes(value, DraftModeFormCalendarPicker.to);
              widget.toOnChange?.call(value);
            },
          ),
        if (widget.durationMode == DraftModeFormCalendarDurationMode.hours)
          DraftModeUIRow(
            alignment: Alignment.centerRight,
            verticalDoubled: true,
            label: durationLabel,
            child: Text(_duration ?? '-'),
          ),
      ],
    );
  }

  Widget _buildDateTimePicker({
    required DateTime dateTime,
    required DraftModeEntityAttribute<DateTime>? element,
    required DraftModeFormCalendarPicker owner,
    required String label,
    required ValueChanged<DateTime> onChange,
  }) {
    final isActive =
        _owner == owner && _mode != DraftModeFormCalendarPickerMode.closed;
    final dateLabel = _dateLabel(dateTime);
    final timeLabel = _timeLabel(dateTime);
    final endDateInvalid =
        owner == DraftModeFormCalendarPicker.to &&
        _selectedFrom.difference(_selectedTo ?? _selectedFrom).inMinutes > 0;

    Future<void> Function() _openPicker(DraftModeFormCalendarPickerMode mode) {
      return () => _toggleOwner(owner, mode);
    }

    Widget _pickerButton(
      String text,
      double width,
      bool showActive,
      DraftModeFormCalendarPickerMode mode,
    ) {
      return DraftModeFormButton(
        styleSize: DraftModeFormButtonSize.medium,
        styleColor: DraftModeFormButtonColor.dateTime,
        content: SizedBox(
          width: width,
          child: Text(
            textAlign: TextAlign.center,
            text,
            style: showActive
                ? PlatformStyles.labelStyleActive(
                    context,
                    strike: endDateInvalid,
                  )
                : PlatformStyles.labelStyle(context, strike: endDateInvalid),
          ),
        ),
        onPressed: _openPicker(mode),
      );
    }

    return FormField<DateTime>(
      initialValue: dateTime,
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        if (owner == DraftModeFormCalendarPicker.to &&
            _selectedFrom.difference(_selectedTo ?? _selectedFrom).inMinutes >
                0) {
          final loc = DraftModeLocalizations.of(context);
          return loc?.calenderEndBeforeFailure(
                startLabel: fromLabel,
                endLabel: toLabel,
              ) ??
              'End must be after start';
        }
        return null;
      },
      onSaved: (value) => element?.value = value,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DraftModeUIRow(
              label: label,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.mode == DraftModeFormCalendarMode.date ||
                      widget.mode == DraftModeFormCalendarMode.datetime)
                    _pickerButton(
                      dateLabel,
                      105,
                      isActive,
                      DraftModeFormCalendarPickerMode.day,
                    ),
                  if (widget.mode == DraftModeFormCalendarMode.datetime)
                    const SizedBox(width: 8),
                  if (widget.mode == DraftModeFormCalendarMode.time ||
                      widget.mode == DraftModeFormCalendarMode.datetime)
                    _pickerButton(
                      timeLabel,
                      63,
                      isActive,
                      DraftModeFormCalendarPickerMode.hourMinute,
                    ),
                ],
              ),
            ),
            if (isActive)
              DraftModeCalendarIOS(
                mode: _mode,
                dateTime: dateTime,
                onPressed: _toggleMonthDropDown,
                onChange: (value) {
                  field.didChange(value);
                  onChange(value);
                },
              ),
          ],
        );
      },
    );
  }
}

@Deprecated('Use DraftModeFormCalendarPicker instead')
typedef DraftModeFormCalenderPicker = DraftModeFormCalendarPicker;

@Deprecated('Use DraftModeFormCalendarTrigger instead')
typedef DraftModeFormCalenderTigger = DraftModeFormCalendarTrigger;

@Deprecated('Use DraftModeFormCalendar instead')
typedef DraftModeFormCalender = DraftModeFormCalendar;
