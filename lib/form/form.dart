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
  final Map<int, Set<GlobalKey<FormFieldState>>> _fields =
      <int, Set<GlobalKey<FormFieldState>>>{};

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
    _drafts.putIfAbsent(key, () {
      _log('registerProperty ${debugName ?? attribute.debugName ?? '-'} #$key');
      return null;
    });
  }

  @override
  void updateProperty<T>(DraftModeEntityAttributeI attribute, T? value) {
    final key = identityHashCode(attribute);
    if (!_drafts.containsKey(key)) {
      _log(
        'updateProperty skipped (${attribute.debugName ?? '-'}) not registered #$key',
      );
      return;
    }
    _log('updateProperty ${attribute.debugName ?? '-'} value: $value #$key');
    _drafts[key] = value;
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
      return value;
    }

    final value = attribute.value as V?;
    _log('read attribute ${attribute.debugName ?? '-'} -> $value');
    return value;
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

  static DraftModeFormState? of(BuildContext context) {
    return context.findAncestorStateOfType<DraftModeFormState>();
  }
}
