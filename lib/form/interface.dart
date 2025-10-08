import 'package:flutter/widgets.dart';

import '../entity/interface.dart';

/// Public interface implemented by the concrete form state so widgets can
/// interact with it without creating tight coupling.
abstract class DraftModeFormStateI implements DraftModeFormDependencyContext {
  void registerProperty(
    DraftModeEntityAttributeI attribute, {
    String? debugName,
  });

  void updateProperty<T>(DraftModeEntityAttributeI<T> attribute, T? value);

  void registerField(
    DraftModeEntityAttributeI attribute,
    GlobalKey<FormFieldState> key,
  );

  void unregisterField(
    DraftModeEntityAttributeI attribute,
    GlobalKey<FormFieldState> key,
  );

  void validateAttribute(DraftModeEntityAttributeI attribute);
}

enum DraftModeFormCalendarMode { date, time, datetime }

enum DraftModeFormCalendarPickerMode { closed, day, hourMinute, monthYear }

enum DraftModeFormCalendarDurationMode { none, hours }

enum DraftModeDurationMode { hour_minute }

/// Granularity used by time pickers when rendering minute selections.
///
/// Values represent the number of minutes between individual options within
/// the hour wheel.
enum DraftModeFormCalendarHourSteps {
  one(1),
  five(5),
  ten(10),
  fifteen(15),
  thirty(30);

  const DraftModeFormCalendarHourSteps(this.minutes);

  /// Number of minutes between entries rendered in the picker.
  final int minutes;
}

@Deprecated('Use DraftModeFormCalendarMode instead')
typedef DraftModeFormCalenderMode = DraftModeFormCalendarMode;

@Deprecated('Use DraftModeFormCalendarPickerMode instead')
typedef DraftModeFormCalenderPickerMode = DraftModeFormCalendarPickerMode;

@Deprecated('Use DraftModeFormCalendarDurationMode instead')
typedef DraftModeFormCalenderDurationMode = DraftModeFormCalendarDurationMode;
