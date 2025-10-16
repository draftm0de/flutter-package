import 'package:flutter/widgets.dart';

/// Minimal context passed from form-layer code into entity-layer validators.
/// Allows validators to read related attributes without depending on the UI
/// `FormState` implementation.
abstract class DraftModeFormContext {
  V? read<V>(dynamic attribute);
}

/// Extended form context that tracks cross-field dependencies during
/// validation so linked attributes can re-validate when their source changes.
abstract class DraftModeFormDependencyContext extends DraftModeFormContext {
  void beginAttributeValidation(DraftModeEntityAttributeInterface attribute);
  void endAttributeValidation(DraftModeEntityAttributeInterface attribute);
  void registerDependency(DraftModeEntityAttributeInterface dependency);
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
/// Interface for entity attributes that hold state and run validators.
abstract class DraftModeEntityAttributeInterface<T> {
  T? get value;
  set value(T? v);

  String? get debugName;

  String? get error;
  set error(String? v);

  void addValidator(DraftModeEntityValidator validator);

  /// Registers a synchronous transformation that should run before persisting
  /// or broadcasting updates to this attribute.
  void addValueMapper(T Function(T value) mapper);

  /// Applies all registered mappers to [value] and returns the transformed
  /// result. Implementations should be null-safe and treat `null` as pass-through.
  T? mapValue(T? value);
  String? validate(BuildContext context, DraftModeFormContext? form, T? v);
}

/// Contract for domain objects that expose a stable identifier used by form and
/// list widgets to track selection state.
abstract class DraftModeEntityInterface<T> {
  T getId();
}

abstract class DraftModeStorageEntityInterface<T> {
  List<String> get keys;
  Map<String, dynamic> toJson(T entity, bool? keyLess);
  Map<String, dynamic> toJsonKeyless(
    Map<String, dynamic> data,
    List<String> keys,
  );
  T fromJson(Map<String, dynamic> json);
}

class DraftModeStorageEntity {
  Map<String, dynamic> toJsonKeyless(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    data.removeWhere((key, value) => keys.contains(key));
    return data;
  }
}
