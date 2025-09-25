import 'package:flutter/widgets.dart';

typedef DraftModeEntityValidator =
    String? Function(
      BuildContext context,
      DraftModeFormStateI? form,
      dynamic v,
    );

abstract class DraftModeEntityAttributeI<T> {
  T? get value;
  set value(T? v);

  String? get debugName;

  String? get error;
  set error(String? v);

  void addValidator(DraftModeEntityValidator validator);
  String? validate(BuildContext context, DraftModeFormStateI? form, T? v);
}

abstract class DraftModeFormStateI {
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
  V? read<V>(dynamic attribute);
}
