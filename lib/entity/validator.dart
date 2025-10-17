import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import 'interface.dart';
import '../utils/formatter.dart';

/// Associates a [DraftModeEntityValidator] closure with the typed metadata it
/// was created from. Using an [Expando] keeps the validator signature unchanged
/// while still allowing downstream consumers to recover the originating
/// [DraftModeEntityTypedValidator].
final Expando<DraftModeEntityTypedValidator> _typedValidatorLookup =
    Expando<DraftModeEntityTypedValidator>('draftmode_typed_validator');

/// Internal helper that wraps [delegate] and tags the resulting callable with
/// its [DraftModeValidatorType] and optional [payload].
DraftModeEntityValidator _typedValidator({
  required DraftModeValidatorType type,
  Object? payload,
  required DraftModeEntityValidator delegate,
}) {
  final DraftModeEntityValidator validator =
      (BuildContext context, DraftModeFormContext? form, dynamic value) {
        return delegate(context, form, value);
      };

  _typedValidatorLookup[validator] = _DraftModeTypedValidator(
    type: type,
    payload: payload,
    delegate: delegate,
  );
  return validator;
}

/// Resolves the metadata wrapper associated with [validator], or `null` when
/// the validator does not originate from [_typedValidator].
DraftModeEntityTypedValidator? lookupTypedValidator(
  DraftModeEntityValidator validator,
) {
  return _typedValidatorLookup[validator];
}

class _DraftModeTypedValidator implements DraftModeEntityTypedValidator {
  const _DraftModeTypedValidator({
    required this.type,
    required this.delegate,
    this.payload,
  });

  @override
  final DraftModeValidatorType type;

  @override
  final Object? payload;

  final DraftModeEntityValidator delegate;

  @override
  String? call(
    BuildContext context,
    DraftModeFormContext? form,
    dynamic value,
  ) {
    return delegate(context, form, value);
  }
}

/// Creates a validator that fails when the inspected value is null or, for
/// strings, empty. The returned message is localized using
/// [DraftModeLocalizations].
DraftModeEntityValidator vRequired() {
  return _typedValidator(
    type: DraftModeValidatorType.requiredValue,
    delegate: (BuildContext context, DraftModeFormContext? form, dynamic v) {
      final loc = DraftModeLocalizations.of(context);
      if (v == null) {
        return loc!.validationRequired;
      }
      if (v is String && v.isEmpty) {
        return loc!.validationRequired;
      }
      return null;
    },
  );
}

/// Creates a validator that surfaces an error when the input string exceeds
/// [length] characters. The associated [DraftModeValidatorType.maxLength]
/// metadata allows widgets (for example `DraftModeFormField`) to clamp their UI
/// to the same limit without duplicating business logic.
DraftModeEntityValidator vMaxLen(int length) {
  return _typedValidator(
    type: DraftModeValidatorType.maxLength,
    payload: length,
    delegate: (BuildContext context, DraftModeFormContext? form, dynamic v) {
      final loc = DraftModeLocalizations.of(context);
      if (v is String && v.length > length) {
        return loc!.validationMaxLen(expected: length.toString());
      }
      return null;
    },
  );
}

/// Creates a validator that enforces a value only when [compare] evaluates to
/// a truthy boolean within the surrounding form state.
DraftModeEntityValidator vRequiredOn(
  DraftModeEntityAttributeInterface compare,
) {
  return _typedValidator(
    type: DraftModeValidatorType.requiredOn,
    payload: compare,
    delegate: (BuildContext context, DraftModeFormContext? form, dynamic v) {
      final cv = form!.read(compare);
      bool required = false;
      if (v == null) {
        if (cv is bool && cv == true) {
          required = true;
        }
      }
      final loc = DraftModeLocalizations.of(context);
      return (v == null && required) ? loc!.validationRequired : null;
    },
  );
}

/// Creates a validator that ensures [v] does not fall below the value resolved
/// from [compare]. Accepts either another attribute or a literal `DateTime` or
/// `int` and surfaces [DraftModeLocalizations.validationGreaterThan] when the
/// inspected value is earlier (dates) or smaller/equal (ints) than the
/// comparison.
DraftModeEntityValidator vGreaterThan(dynamic compare) {
  return _typedValidator(
    type: DraftModeValidatorType.greaterThan,
    payload: compare,
    delegate: (BuildContext context, DraftModeFormContext? form, dynamic v) {
      final cv = (compare is DraftModeEntityAttributeInterface)
          ? form!.read(compare)
          : compare;
      if (cv == null) return null;
      final loc = DraftModeLocalizations.of(context);
      if (v is DateTime && cv is DateTime && !v.isAfter(cv)) {
        final localeTag = Localizations.localeOf(context).toLanguageTag();
        final expected =
            '${DraftModeDateTime.yMMdd(localeTag).format(cv)} ${DateFormat.Hm(localeTag).format(cv)}';
        return loc!.validationGreaterThan(expected: expected);
      }
      if (v is int && cv is int && v <= cv) {
        return loc!.validationGreaterThan(expected: cv);
      }
      return null;
    },
  );
}
