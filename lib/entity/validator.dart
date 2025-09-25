import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import 'types.dart';

/// Creates a validator that fails when [v] is null or, for strings, empty.
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
    //debugPrint("vRequiredOn for ${compare.debugName ?? "-"}");
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
