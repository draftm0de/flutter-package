import 'package:flutter/foundation.dart' show ValueChanged;

import '../../element/date_time/week_day.dart'
    show DraftModeElementDateTimeWeekDay;

export '../../element/date_time/week_day.dart'
    show DraftModeElementDateTimeWeekDay;

class DraftModeUIDateTimeWeekDay extends DraftModeElementDateTimeWeekDay {
  const DraftModeUIDateTimeWeekDay({
    super.key,
    required DateTime dateTime,
    required ValueChanged<DateTime> onSelect,
  }) : super(dateTime: dateTime, onSelect: onSelect);
}
