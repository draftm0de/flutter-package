import 'package:flutter/widgets.dart';

/// Minimal context passed from form-layer code into entity-layer validators.
/// Allows validators to read related attributes without depending on the UI
/// `FormState` implementation.
abstract class DraftModeFormContext {
  V? read<V>(dynamic attribute);
}

/// Signature for entity-level validators that run in the UI layer but should
/// remain agnostic of concrete form implementations.
typedef DraftModeEntityValidator =
    String? Function(
      BuildContext context,
      DraftModeFormContext? form,
      dynamic value,
    );

/// Interface for entity attributes that hold state and run validators.
abstract class DraftModeEntityAttributeI<T> {
  T? get value;
  set value(T? v);

  String? get debugName;

  String? get error;
  set error(String? v);

  void addValidator(DraftModeEntityValidator validator);
  String? validate(BuildContext context, DraftModeFormContext? form, T? v);
}
