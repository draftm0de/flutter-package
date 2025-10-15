import 'package:flutter/widgets.dart';

import 'interface.dart';

/// Mutable implementation of [DraftModeEntityAttributeI] used to back simple
/// form fields. A single optional [validator] runs before any validators added
/// at runtime, and errors are stored directly on the attribute instance.
class DraftModeEntityAttribute<T> implements DraftModeEntityAttributeI<T> {
  @override
  final String? debugName;

  T? _value;

  @override
  String? error;

  final DraftModeEntityValidator? validator;
  final List<DraftModeEntityValidator> validators;

  /// Optional transformers that run before storing or propagating values.
  final List<T Function(T value)> _valueMappers = <T Function(T value)>[];

  /// Creates a new attribute with an optional [debugName], [value], and
  /// initial [validator] list.
  DraftModeEntityAttribute(
    T? value, {
    this.debugName,
    this.validator,
    List<DraftModeEntityValidator>? validators,
  }) : validators = validators != null
           ? List.of(validators)
           : <DraftModeEntityValidator>[] {
    this.value = value;
  }

  @override
  T? get value => _value;

  @override
  set value(T? v) => _value = mapValue(v);

  @override
  /// Registers an additional validator that runs after the optional
  /// constructor-provided [validator].
  void addValidator(DraftModeEntityValidator validator) {
    validators.add(validator);
  }

  @override
  /// Registers a synchronous mapper that runs whenever [value] is set or the
  /// form layer pushes an update through [DraftModeFormState.updateProperty].
  ///
  /// Mappers run in registration order, allowing callers to compose multiple
  /// transformations (for example, rounding to the nearest interval and then
  /// clamping to a minimum bound).
  void addValueMapper(T Function(T value) mapper) {
    _valueMappers.add(mapper);
  }

  @override
  T? mapValue(T? v) {
    if (v == null || _valueMappers.isEmpty) {
      return v;
    }
    var result = v;
    for (final mapper in _valueMappers) {
      result = mapper(result);
    }
    return result;
  }

  @override
  /// Runs the primary [validator] (if present) and any additional validators
  /// until one returns a message. When all validators pass, [error] is cleared
  /// and `null` is returned.
  String? validate(BuildContext context, DraftModeFormContext? form, T? v) {
    DraftModeFormDependencyContext? dependencyContext;
    if (form is DraftModeFormDependencyContext) {
      dependencyContext = form;
      dependencyContext.beginAttributeValidation(this);
    }
    try {
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
    } finally {
      dependencyContext?.endAttributeValidation(this);
    }
  }
}
