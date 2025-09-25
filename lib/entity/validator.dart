import 'package:flutter/widgets.dart';
import '../types.dart';
import '../l10n/app_localizations.dart';

// ----------------------------------------------------------------------
// validations
// ----------------------------------------------------------------------
DraftModeEntityValidator vRequired() {
  return (BuildContext context, DraftModeFormStateI? form, dynamic v) {
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

DraftModeEntityValidator vRequiredOn(DraftModeEntityAttributeI compare) {
  return (BuildContext context, DraftModeFormStateI? form, dynamic v) {
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
