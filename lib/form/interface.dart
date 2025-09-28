import 'package:flutter/widgets.dart';

import '../entity/interface.dart';

/// Public interface implemented by the concrete form state so widgets can
/// interact with it without creating tight coupling.
abstract class DraftModeFormStateI implements DraftModeFormDependencyContext {
  void registerProperty(
    DraftModeEntityAttributeI attribute, {
    String? debugName,
  });

  void updateProperty<T>(DraftModeEntityAttributeI attribute, T? value);

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

@Deprecated('Use DraftModeFormCalendarMode instead')
typedef DraftModeFormCalenderMode = DraftModeFormCalendarMode;

@Deprecated('Use DraftModeFormCalendarPickerMode instead')
typedef DraftModeFormCalenderPickerMode = DraftModeFormCalendarPickerMode;

@Deprecated('Use DraftModeFormCalendarDurationMode instead')
typedef DraftModeFormCalenderDurationMode = DraftModeFormCalendarDurationMode;
