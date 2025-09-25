import 'package:flutter/widgets.dart';

import '../entity/types.dart';

/// Public interface implemented by the concrete form state so widgets can
/// interact with it without creating tight coupling.
abstract class DraftModeFormStateI implements DraftModeFormContext {
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
