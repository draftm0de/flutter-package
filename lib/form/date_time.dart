import 'package:flutter/widgets.dart';

import '../entity/attribute.dart';
import '../ui/date_time.dart';
import 'calender/variables.dart';

/// Slim date/time picker that focuses on a single [DraftModeEntityAttribute].
/// Ideal for forms that only need one timestamp without range selection or
/// duration handling.
class DraftModeFormDateTime extends StatefulWidget {
  final DraftModeEntityAttribute<DateTime> attribute;
  final String? label;
  final DraftModeFormCalendarMode mode;
  final ValueChanged<DateTime>? onChanged;

  const DraftModeFormDateTime({
    super.key,
    required this.attribute,
    this.label,
    this.mode = DraftModeFormCalendarMode.datetime,
    this.onChanged,
  });

  @override
  State<DraftModeFormDateTime> createState() => _DraftModeFormDateTimeState();
}

class _DraftModeFormDateTimeState extends State<DraftModeFormDateTime> {
  DraftModeFormCalendarPickerMode _mode =
      DraftModeFormCalendarPickerMode.closed;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = _normalize(widget.attribute.value ?? DateTime.now());
  }

  DateTime _normalize(DateTime value) {
    const step = 5;
    final remainder = value.minute % step;
    final delta = remainder == 0 ? 0 : -remainder;
    return DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute + delta,
    );
  }

  void _toggle(DraftModeFormCalendarPickerMode mode) {
    setState(() {
      _mode = _mode == mode ? DraftModeFormCalendarPickerMode.closed : mode;
    });
  }

  void _toggleMonthYear() {
    setState(() {
      _mode = _mode == DraftModeFormCalendarPickerMode.monthYear
          ? DraftModeFormCalendarPickerMode.day
          : DraftModeFormCalendarPickerMode.monthYear;
    });
  }

  void _update(DateTime value) {
    setState(() => _selected = value);
    widget.attribute.value = value;
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return DraftModeUIDateTimeField(
      label: (widget.label?.isEmpty ?? true) ? null : widget.label,
      mode: widget.mode,
      pickerMode: _mode,
      value: _selected,
      onToggleMonthYear: _toggleMonthYear,
      onPickerModeChanged: _toggle,
      onChanged: (value) => _update(_normalize(value)),
    );
  }
}
