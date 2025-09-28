import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../platform/styles.dart';
import '../utils/formatter.dart';
import '../form/interface.dart';
import 'button.dart';
import 'row.dart';
import 'date_time/calendar_ios.dart';

class DraftModeUIDateTimeField extends StatelessWidget {
  final String? label;
  final DraftModeFormCalendarMode mode;
  final DraftModeFormCalendarPickerMode pickerMode;
  final DateTime value;
  final VoidCallback onToggleMonthYear;
  final ValueChanged<DraftModeFormCalendarPickerMode> onPickerModeChanged;
  final ValueChanged<DateTime> onChanged;
  final bool strike;

  const DraftModeUIDateTimeField({
    super.key,
    required this.mode,
    required this.pickerMode,
    required this.value,
    required this.onToggleMonthYear,
    required this.onPickerModeChanged,
    required this.onChanged,
    this.label,
    this.strike = false,
  });

  String _dateLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DraftModeDateTime.yMMdd(locale).format(value);
  }

  String _timeLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.Hm(locale).format(value);
  }

  Widget _buildSegmentButton(
    BuildContext context,
    String text,
    double width,
    DraftModeFormCalendarPickerMode target,
  ) {
    return SizedBox(
      width: width,
      child: DraftModeUIButton(
        stretched: false,
        size: DraftModeUIButtonSize.medium,
        color: DraftModeUIButtonColor.dateTime,
        onPressed: () => onPickerModeChanged(target),
        child: Text(
          textAlign: TextAlign.center,
          text,
          style: PlatformStyles.labelStyle(context, strike: strike),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDate =
        mode == DraftModeFormCalendarMode.date ||
        mode == DraftModeFormCalendarMode.datetime;
    final hasTime =
        mode == DraftModeFormCalendarMode.time ||
        mode == DraftModeFormCalendarMode.datetime;

    final dateLabel = _dateLabel(context);
    final timeLabel = _timeLabel(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DraftModeUIRow(
          label: label,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasDate)
                _buildSegmentButton(
                  context,
                  dateLabel,
                  105,
                  DraftModeFormCalendarPickerMode.day,
                ),
              if (hasDate && hasTime) const SizedBox(width: 8),
              if (hasTime)
                _buildSegmentButton(
                  context,
                  timeLabel,
                  63,
                  DraftModeFormCalendarPickerMode.hourMinute,
                ),
            ],
          ),
        ),
        if (pickerMode != DraftModeFormCalendarPickerMode.closed)
          DraftModeUIDateTimeIOS(
            mode: pickerMode,
            dateTime: value,
            onToggleMonthYear: onToggleMonthYear,
            onChanged: onChanged,
          ),
      ],
    );
  }
}
