import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../entity/attribute.dart';
import '../platform/styles.dart';
import '../ui/row.dart';
import '../utils/formatter.dart';
import 'button.dart';
import 'calender/ios.dart';
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

  String _dateLabel(DateTime value) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DraftModeDateTime.yMMdd(locale).format(value);
  }

  String _timeLabel(DateTime value) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.Hm(locale).format(value);
  }

  Future<void> _toggle(DraftModeFormCalendarPickerMode mode) async {
    setState(() {
      _mode = _mode == mode ? DraftModeFormCalendarPickerMode.closed : mode;
    });
  }

  void _update(DateTime value) {
    setState(() => _selected = value);
    widget.attribute.value = value;
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label ?? '';
    final dateLabel = _dateLabel(_selected);
    final timeLabel = _timeLabel(_selected);

    Widget buildButton(
      String text,
      double width,
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
            style: PlatformStyles.labelStyle(context),
          ),
        ),
        onPressed: () => _toggle(mode),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DraftModeUIRow(
          label: label.isNotEmpty ? label : null,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.mode == DraftModeFormCalendarMode.date ||
                  widget.mode == DraftModeFormCalendarMode.datetime)
                buildButton(
                  dateLabel,
                  105,
                  DraftModeFormCalendarPickerMode.day,
                ),
              if (widget.mode == DraftModeFormCalendarMode.datetime)
                const SizedBox(width: 8),
              if (widget.mode == DraftModeFormCalendarMode.time ||
                  widget.mode == DraftModeFormCalendarMode.datetime)
                buildButton(
                  timeLabel,
                  63,
                  DraftModeFormCalendarPickerMode.hourMinute,
                ),
            ],
          ),
        ),
        if (_mode != DraftModeFormCalendarPickerMode.closed)
          DraftModeCalendarIOS(
            mode: _mode,
            dateTime: _selected,
            onPressed: () {
              setState(() {
                _mode = DraftModeFormCalendarPickerMode.monthYear;
              });
            },
            onChange: (value) {
              _update(_normalize(value));
            },
          ),
      ],
    );
  }
}
