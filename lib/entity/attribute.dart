import 'package:flutter/widgets.dart';
import '../types.dart';

class DraftModeEntityAttribute<T> implements DraftModeEntityAttributeI<T> {
  @override
  final String? debugName;

  @override
  T? value;

  @override
  String? error;

  final DraftModeEntityValidator? validator;
  final List<DraftModeEntityValidator> validators;

  DraftModeEntityAttribute({
    this.debugName,
    this.value,
    this.validator,
    List<DraftModeEntityValidator>? validators,
  }) :
    validators = validators != null ? List.of(validators) : <DraftModeEntityValidator>[];

  @override
  void addValidator(DraftModeEntityValidator validator) {
    validators.add(validator);
  }

  @override
  String? validate(BuildContext context, DraftModeFormStateI? form, T? v) {
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
