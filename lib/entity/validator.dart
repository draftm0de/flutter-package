import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import 'interface.dart';

/// Creates a validator that fails when the inspected value is null or, for strings, empty.
/// The returned message is localized using [DraftModeLocalizations].
DraftModeEntityValidator vRequired() {
  return (BuildContext context, DraftModeFormContext? form, dynamic v) {
    final loc = DraftModeLocalizations.of(context);
    if (v == null) {
      return loc!.validationRequired;
    }
    if (v is String && v.isEmpty) {
      return loc!.validationRequired;
    }
    return null;
  };
}

/// Creates a validator that enforces a value only when [compare] evaluates to
/// a truthy boolean within the surrounding form state.
DraftModeEntityValidator vRequiredOn(DraftModeEntityAttributeI compare) {
  return (BuildContext context, DraftModeFormContext? form, dynamic v) {
    final cv = form!.read(compare);
    bool required = false;
    if (v == null) {
      if (cv is bool && cv == true) {
        required = true;
      }
    }
    final loc = DraftModeLocalizations.of(context);
    return (v == null && required) ? loc!.validationRequired : null;
  };
}

/// Creates a validator that ensures [v] does not fall below the value resolved
/// from [compare]. Accepts either another attribute or a literal `DateTime` or
/// `int` and surfaces [DraftModeLocalizations.validationGreaterThan] when the
/// inspected value is earlier (dates) or smaller/equal (ints) than the
/// comparison.
DraftModeEntityValidator vGreaterThan(dynamic compare) {
  return (BuildContext context, DraftModeFormContext? form, dynamic v) {
    final cv = (compare is DraftModeEntityAttributeI)
        ? form!.read(compare)
        : compare;
    if (cv == null) return null;
    final loc = DraftModeLocalizations.of(context);
    if (v is DateTime && cv is DateTime && !v.isAfter(cv)) {
      return loc!.validationGreaterThan(expected: cv.toIso8601String());
    }
    if (v is int && cv is int && v <= cv) {
      return loc!.validationGreaterThan(expected: cv);
    }
    return null;
  };
}
