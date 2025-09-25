import 'package:flutter/widgets.dart';

import 'types.dart';

/// Mutable implementation of [DraftModeEntityAttributeI] used to back simple
/// form fields. A single optional [validator] runs before any validators added
/// at runtime, and errors are stored directly on the attribute instance.
class DraftModeEntityAttribute<T> implements DraftModeEntityAttributeI<T> {
  @override
  final String? debugName;

  @override
  T? value;

  @override
  String? error;

  final DraftModeEntityValidator? validator;
  final List<DraftModeEntityValidator> validators;

  /// Creates a new attribute with an optional [debugName], [value], and
  /// initial [validator] list.
  DraftModeEntityAttribute({
    this.debugName,
    this.value,
    this.validator,
    List<DraftModeEntityValidator>? validators,
  }) : validators = validators != null
           ? List.of(validators)
           : <DraftModeEntityValidator>[];

  @override
  /// Registers an additional validator that runs after the optional
  /// constructor-provided [validator].
  void addValidator(DraftModeEntityValidator validator) {
    validators.add(validator);
  }

  @override
  /// Runs the primary [validator] (if present) and any additional validators
  /// until one returns a message. When all validators pass, [error] is cleared
  /// and `null` is returned.
  String? validate(BuildContext context, DraftModeFormContext? form, T? v) {
    if (validator != null) {
      final msg = validator!(context, form, v);
      if (msg != null) {
        error = msg;
        return error;
      }
    }
    for (final validator in validators) {
      final msg = validator(context, form, v);
      if (msg != null) {
        error = msg;
        return error;
      }
    }
    error = null;
    return null;
  }
}
