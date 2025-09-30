import 'package:flutter/widgets.dart';

import '../entity/interface.dart';
import '../ui/diagnostics.dart';
import 'interface.dart';

/// Thin wrapper around Flutter's [Form] that wires in Draftmode specific
/// behaviour such as attribute tracking and deferred validation. Widgets inside
/// the tree should use [DraftModeFormState.of] to access the shared state.
class DraftModeForm extends Form {
  const DraftModeForm({
    super.key,
    required super.child,
    super.autovalidateMode = AutovalidateMode.disabled,
    super.onChanged,
  });

  @override
  DraftModeFormState createState() => DraftModeFormState();
}

/// Concrete [FormState] implementation that keeps a lightweight draft of
/// attribute values and exposes helpers for other widgets in the module. This
/// mirrors the entity layer interfaces so validation remains decoupled from the
/// widget tree.
class DraftModeFormState extends FormState implements DraftModeFormStateI {
  static const bool _debugMode = false;

  bool _onSubmit = false;
  bool _enableValidation = false;

  bool get onSubmit => _onSubmit;
  bool get enableValidation => _enableValidation;

  final Map<int, Object?> _drafts = <int, Object?>{};
  final Map<int, DraftModeEntityAttributeI> _attributes =
      <int, DraftModeEntityAttributeI>{};
  final Map<int, Set<GlobalKey<FormFieldState>>> _fields =
      <int, Set<GlobalKey<FormFieldState>>>{};
  final Map<int, Set<int>> _dependents = <int, Set<int>>{};
  final List<int> _validationStack = <int>[];

  void _log(String message) {
    DraftModeUIDiagnostics.debug(
      'DraftModeFormState: $message',
      enabled: _debugMode,
    );
  }

  @override
  void registerProperty(
    DraftModeEntityAttributeI attribute, {
    String? debugName,
  }) {
    final key = identityHashCode(attribute);
    _attributes[key] = attribute;
    _drafts.putIfAbsent(key, () {
      final initial = attribute.value;
      _log(
        'registerProperty ${debugName ?? attribute.debugName ?? '-'} #$key -> $initial',
      );
      return initial;
    });
  }

  @override
  void updateProperty<T>(DraftModeEntityAttributeI<T> attribute, T? value) {
    final key = identityHashCode(attribute);
    if (!_drafts.containsKey(key)) {
      _log(
        'updateProperty skipped (${attribute.debugName ?? '-'}) not registered #$key',
      );
      return;
    }
    final mapped = attribute.mapValue(value);
    _log(
      'updateProperty ${attribute.debugName ?? '-'} value: $value mapped: $mapped #$key',
    );
    _drafts[key] = mapped;
    _setProperty(attribute, mapped);
    validateAttribute(attribute);
    _triggerDependentValidation(key);
  }

  void _setProperty<T>(DraftModeEntityAttributeI<T> attribute, T? value) {
    final key = identityHashCode(attribute);
    _log('setProperty ${attribute.debugName ?? '-'} value: $value #$key');
    final fields = _fields[key];
    if (fields != null && fields.isNotEmpty) {
      for (final fieldKey in List<GlobalKey<FormFieldState>>.of(fields)) {
        final state = fieldKey.currentState;
        if (state == null) continue;
        _log('setProperty ${attribute.debugName ?? '-'} state.didChange');
        state.didChange(value);
      }
    }
  }

  @override
  void registerField(
    DraftModeEntityAttributeI attribute,
    GlobalKey<FormFieldState> key,
  ) {
    final attributeKey = identityHashCode(attribute);
    _log('registerField ${attribute.debugName ?? '-'} #$attributeKey');
    _fields
        .putIfAbsent(attributeKey, () => <GlobalKey<FormFieldState>>{})
        .add(key);
  }

  @override
  void unregisterField(
    DraftModeEntityAttributeI attribute,
    GlobalKey<FormFieldState> key,
  ) {
    final attributeKey = identityHashCode(attribute);
    final set = _fields[attributeKey];
    if (set == null) return;
    _log('unregisterField ${attribute.debugName ?? '-'} #$attributeKey');
    set.remove(key);
    if (set.isEmpty) _fields.remove(attributeKey);
  }

  @override
  void validateAttribute(DraftModeEntityAttributeI attribute) {
    final attributeKey = identityHashCode(attribute);
    final fields = _fields[attributeKey];
    if (fields == null) {
      _log(
        'validateAttribute no fields ${attribute.debugName ?? '-'} #$attributeKey',
      );
      return;
    }
    for (final key in fields) {
      _log('validateAttribute -> field #${key.hashCode}');
      key.currentState?.validate();
    }
  }

  @override
  V? read<V>(dynamic attribute) {
    if (attribute is! DraftModeEntityAttributeI) {
      _log('read dynamic value (not attribute)');
      return attribute as V?;
    }

    final key = identityHashCode(attribute);
    if (_drafts.containsKey(key)) {
      final value = _drafts[key] as V?;
      _log('read draft ${attribute.debugName ?? '-'} -> $value');
      registerDependency(attribute);
      return value;
    }

    final value = attribute.value as V?;
    _log('read attribute ${attribute.debugName ?? '-'} -> $value');
    registerDependency(attribute);
    return value;
  }

  void _triggerDependentValidation(int dependencyKey) {
    final dependents = _dependents[dependencyKey];
    if (dependents == null || dependents.isEmpty) return;
    for (final dependentKey in dependents) {
      if (dependentKey == dependencyKey) continue;
      final attribute = _attributes[dependentKey];
      if (attribute == null) continue;
      validateAttribute(attribute);
    }
  }

  @override
  bool validate() {
    _enableValidation = true;
    FocusScope.of(context).unfocus();
    return super.validate();
  }

  @override
  void save() {
    _onSubmit = true;
    super.save();
  }

  @override
  void reset() {
    _onSubmit = false;
    _enableValidation = false;
    _drafts.clear();
    super.reset();
  }

  @override
  void beginAttributeValidation(DraftModeEntityAttributeI attribute) {
    final key = identityHashCode(attribute);
    if (_validationStack.isEmpty || _validationStack.last != key) {
      _validationStack.add(key);
    }
    _attributes.putIfAbsent(key, () => attribute);
  }

  @override
  void endAttributeValidation(DraftModeEntityAttributeI attribute) {
    final key = identityHashCode(attribute);
    if (_validationStack.isNotEmpty && _validationStack.last == key) {
      _validationStack.removeLast();
    } else {
      _validationStack.remove(key);
    }
  }

  @override
  void registerDependency(DraftModeEntityAttributeI dependency) {
    if (_validationStack.isEmpty) return;
    final dependentKey = _validationStack.last;
    final dependencyKey = identityHashCode(dependency);
    if (dependentKey == dependencyKey) return;
    _attributes.putIfAbsent(dependencyKey, () => dependency);
    _dependents.putIfAbsent(dependencyKey, () => <int>{}).add(dependentKey);
  }

  static DraftModeFormState? of(BuildContext context) {
    return context.findAncestorStateOfType<DraftModeFormState>();
  }
}
