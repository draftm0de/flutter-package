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

/// Enumerates the known validator families supported by DraftMode.
enum DraftModeValidatorType {
  requiredValue,
  maxLength,
  requiredOn,
  greaterThan,
}

/// Validator wrapper that exposes metadata while remaining callable.
abstract class DraftModeEntityTypedValidator {
  DraftModeValidatorType get type;
  Object? get payload;

  String? call(BuildContext context, DraftModeFormContext? form, dynamic value);
}

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

  /// Returns the first validator matching [type], or `null` when not present.
  ///
  /// The returned instance implements [DraftModeEntityTypedValidator] so callers
  /// can read metadata (for example, the `vMaxLen` payload) without knowing how
  /// the validator was constructed.
  DraftModeEntityTypedValidator? validatorByType(DraftModeValidatorType type);

  /// Returns all validators matching [type], allowing repeated constraints.
  Iterable<DraftModeEntityTypedValidator> validatorsByType(
    DraftModeValidatorType type,
  );
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

abstract class DraftModeStorageEntityListInterface<T> {
  List<T> fromJsonList(dynamic jsonList);
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
