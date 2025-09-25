import 'package:draftmode/entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../platform/config.dart';
import '../utils/formatter.dart';
import '../l10n/app_localizations.dart';
import '../form.dart';
import '../ui.dart';
import 'calender/iso.dart';

enum DraftModeFormCalenderPicker { none, from, to }

class DraftModeFormCalenderTigger {
  final DraftModeFormCalenderPicker mode;
  final DateTime? value;
  const DraftModeFormCalenderTigger(this.mode, this.value);
}

class DraftModeFormCalender extends StatefulWidget {
  static const Object _notSpecified = Object();
  final DraftModeEntityAttribute<DateTime> from;
  final String? fromLabel;
  final ValueChanged<DateTime>? fromOnChange;
  final bool toEnabled;
  final DraftModeEntityAttribute<DateTime>? to;
  final String? toLabel;
  final ValueChanged<DateTime>? toOnChange;
  final DraftModeFormCalenderMode mode;
  final DraftModeFormCalenderMode toMode;
  final DraftModeFormCalenderDurationMode durationMode;
  final String? durationLabel;
  final DraftModeFormCalenderTigger? formTrigger;

  const DraftModeFormCalender({
    super.key,
    required this.from,
    this.fromLabel,
    this.fromOnChange,
    Object? to = _notSpecified,
    this.toLabel,
    this.toOnChange,
    this.mode = DraftModeFormCalenderMode.datetime,
    DraftModeFormCalenderMode? toMode,
    DraftModeFormCalenderDurationMode? durationMode,
    this.durationLabel,
    this.formTrigger,
  }) : to = identical(to, _notSpecified)
           ? null
           : to as DraftModeEntityAttribute<DateTime>?,
       toEnabled = !identical(to, _notSpecified),
       durationMode = durationMode ?? DraftModeFormCalenderDurationMode.none,
       toMode = toMode ?? mode;

  @override
  State<DraftModeFormCalender> createState() => _DraftModeFormCalenderState();
}

class _DraftModeFormCalenderState extends State<DraftModeFormCalender> {
  DraftModeFormCalenderPicker _owner = DraftModeFormCalenderPicker.none;
  DraftModeFormCalenderPickerMode _mode =
      DraftModeFormCalenderPickerMode.closed;
  String? _duration;
  late DateTime _selectedFrom;
  late DateTime _selectedTo;
  late String fromLabel;
  late String toLabel;
  late String durationLabel;
  bool _isLoading = true;
  bool _labelsInit = false;

  @override
  void initState() {
    super.initState();

    _selectedFrom =
        correctDateTime(
              widget.from.value ?? DateTime.now(),
              DraftModeFormCalenderPicker.from,
            )
            as DateTime;
    _selectedTo =
        correctDateTime(
              widget.to!.value ?? DateTime.now(),
              DraftModeFormCalenderPicker.to,
            )
            as DateTime;

    _isLoading = false;
    _duration = DraftModeDateTime.getDurationHourMinutes(
      _selectedFrom,
      _selectedTo,
    );
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

  DateTime? correctDateTime(DateTime? v, DraftModeFormCalenderPicker owner) {
    if (v == null) return null;
    final int minute = v.minute;
    final int minuteSteps = 5;
    late int modifyMinutes;
    if (owner == DraftModeFormCalenderPicker.from) {
      modifyMinutes = (minute % minuteSteps) * -1;
    } else {
      modifyMinutes = minuteSteps - (minute % minuteSteps);
    }
    return DateTime(v.year, v.month, v.day, v.hour, minute + modifyMinutes, 0);
  }

  // ------------------------------------------------------------------------
  // observer parent value changes
  // ------------------------------------------------------------------------
  @override
  void didUpdateWidget(covariant DraftModeFormCalender oldWidget) {
    super.didUpdateWidget(oldWidget);
    final DraftModeFormCalenderTigger? pageTrigger = widget.formTrigger;
    final DraftModeFormCalenderTigger? oldPageTrigger = oldWidget.formTrigger;

    if (pageTrigger?.mode == oldPageTrigger?.mode &&
        pageTrigger?.value == oldPageTrigger?.value) {
      return; // nothing to do; don't close the picker needlessly
    }

    final DateTime? selectedFrom =
        (pageTrigger?.mode == DraftModeFormCalenderPicker.from)
        ? correctDateTime(pageTrigger!.value, DraftModeFormCalenderPicker.from)
        : null;
    final DateTime? selectedTo =
        (pageTrigger?.mode == DraftModeFormCalenderPicker.to)
        ? correctDateTime(pageTrigger!.value, DraftModeFormCalenderPicker.to)
        : null;

    // Defer updates so we don't call setState during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        if (selectedFrom != null) {
          _updateDateTimes(selectedFrom, DraftModeFormCalenderPicker.from);
        } else {
          if (selectedTo != null) {
            _updateDateTimes(selectedTo, DraftModeFormCalenderPicker.to);
          }
        }
        _mode = DraftModeFormCalenderPickerMode.closed;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? SizedBox.shrink()
        : Column(
            children: [
              buildDateTimePicker(
                owner: DraftModeFormCalenderPicker.from,
                label: fromLabel,
                element: widget.from,
                dateTime: _selectedFrom,
                onChange: (DateTime v) {
                  _updateDateTimes(v, DraftModeFormCalenderPicker.from);
                  widget.fromOnChange?.call(v);
                },
              ),
              if (widget.toEnabled)
                buildDateTimePicker(
                  owner: DraftModeFormCalenderPicker.to,
                  label: toLabel,
                  element: widget.to,
                  dateTime: _selectedTo,
                  onChange: (DateTime v) {
                    _updateDateTimes(v, DraftModeFormCalenderPicker.to);
                    widget.toOnChange?.call(v);
                  },
                ),
              if (widget.durationMode ==
                  DraftModeFormCalenderDurationMode.hours)
                DraftModeUIRow(
                  alignment: AlignmentGeometry.centerRight,
                  label: durationLabel,
                  verticalDoubled: true,
                  child: Text(_duration ?? "-"),
                ),
            ],
          );
  }

  // ------------------------------------------------------------------------
  // buildDateTimePicker
  // ------------------------------------------------------------------------
  String _getDateLabel(DateTime d) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DraftModeDateTime.yMMdd(locale).format(d);
  }

  String _getTimeLabel(DateTime d) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.Hm(locale).format(d);
  }

  void _toggleMonthDropDown() {
    setState(() {
      _mode = (_mode == DraftModeFormCalenderPickerMode.day)
          ? DraftModeFormCalenderPickerMode.monthYear
          : DraftModeFormCalenderPickerMode.day;
    });
  }

  Future<void> _toggleOwner(
    DraftModeFormCalenderPicker owner,
    DraftModeFormCalenderPickerMode mode,
  ) async {
    setState(() {
      if (_owner == owner && _mode == mode) {
        _owner = DraftModeFormCalenderPicker.none;
        _mode = DraftModeFormCalenderPickerMode.closed;
      } else {
        _owner = owner;
        _mode = mode;
      }
    });
  }

  void _updateDateTimes(DateTime v, DraftModeFormCalenderPicker owner) {
    final isFrom = (DraftModeFormCalenderPicker.from == owner);

    if (isFrom) {
      v = correctDateTime(v, owner) as DateTime;
      final Duration diff = v.difference(_selectedFrom);
      setState(() {
        _selectedFrom = v;
        _selectedTo = _selectedTo.add(diff);
      });
    } else {
      setState(() => _selectedTo = v);
    }
    _duration = DraftModeDateTime.getDurationHourMinutes(
      _selectedFrom,
      _selectedTo,
    );
  }

  Widget buildDateTimePicker({
    required DateTime dateTime,
    required DraftModeEntityAttribute<DateTime>? element,
    required DraftModeFormCalenderPicker owner,
    required String label,
    required ValueChanged<DateTime> onChange,
  }) {
    // ----------------------------------------------------------------------
    // only the selected Pickers will be visible
    // ----------------------------------------------------------------------
    final bool isActive =
        (_owner == owner && _mode != DraftModeFormCalenderPickerMode.closed);
    final dateLabel = _getDateLabel(dateTime);
    final String timeLabel = _getTimeLabel(dateTime);
    final bool endDateInvalid =
        (owner == DraftModeFormCalenderPicker.to &&
        _selectedFrom.difference(_selectedTo).inMinutes > 0);

    Widget showDateTime(
      BuildContext context,
      String text, {
      required double width,
      required Future<void> Function() onPressed,
      bool isActive = false,
    }) {
      return DraftModeFormButton(
        styleSize: DraftModeFromButtonSize.medium,
        styleColor: DraftModeFromButtonColor.dateTime,
        content: SizedBox(
          width: width,
          child: Text(
            textAlign: TextAlign.center,
            text,
            style: isActive
                ? PlatformConfig.labelStyleActive(
                    context,
                    strike: endDateInvalid,
                  )
                : PlatformConfig.labelStyle(context, strike: endDateInvalid),
          ),
        ),
        onPressed: onPressed,
      );
    }

    // ----------------------------------------------------------------------
    // Row(s)
    // ----------------------------------------------------------------------
    return FormField<DateTime>(
      initialValue: dateTime,
      autovalidateMode: AutovalidateMode.always,
      validator: (v) {
        if (owner == DraftModeFormCalenderPicker.to &&
            _selectedFrom.difference(_selectedTo).inMinutes > 0) {
          return DraftModeLocalizations.of(
            context,
          )!.calenderEndBeforeFailure(startLabel: fromLabel, endLabel: toLabel);
        }
        return null;
      },
      onSaved: (v) {
        element?.value = v;
      },
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
                  if (widget.mode == DraftModeFormCalenderMode.date ||
                      widget.mode == DraftModeFormCalenderMode.datetime)
                    showDateTime(
                      context,
                      dateLabel,
                      isActive:
                          (_owner == owner &&
                          _mode != DraftModeFormCalenderPickerMode.closed),
                      onPressed: () => _toggleOwner(
                        owner,
                        DraftModeFormCalenderPickerMode.day,
                      ),
                      width: 105,
                    ),
                  if (widget.mode == DraftModeFormCalenderMode.datetime)
                    const SizedBox(width: 8),
                  if (widget.mode == DraftModeFormCalenderMode.time ||
                      widget.mode == DraftModeFormCalenderMode.datetime)
                    showDateTime(
                      context,
                      timeLabel,
                      isActive:
                          (_owner == owner &&
                          _mode != DraftModeFormCalenderPickerMode.closed),
                      onPressed: () => _toggleOwner(
                        owner,
                        DraftModeFormCalenderPickerMode.hourMinute,
                      ),
                      width: 63,
                    ),
                ],
              ),
            ),
            if (isActive)
              DraftModeCalenderIOS(
                mode: _mode,
                dateTime: dateTime,
                onPressed: _toggleMonthDropDown,
                onChange: (DateTime v) {
                  field.didChange(v);
                  onChange(v);
                },
              ),
          ],
        );
      },
    );
  }
}
