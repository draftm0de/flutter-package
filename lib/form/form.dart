import '../types.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

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

class DraftModeFormState extends FormState implements DraftModeFormStateI {
  bool _onSubmit = false;
  bool _enableValidation = false;
  final bool _debugMode = false;
  bool get onSubmit => _onSubmit;
  bool get enableValidation => _enableValidation;

  final Map<int, dynamic> _drafts = {};
  final Map<int, Set<GlobalKey<FormFieldState>>> _fields = {};

  @override
  void registerProperty(DraftModeEntityAttributeI attribute, {String? debugName}) {
    final key = identityHashCode(attribute);
    if (! _drafts.containsKey(key)) {
      _drafts[key] = null;
      if (_debugMode) debugPrint("DraftModeFormState.registerProperty property (${attribute.debugName ?? "-"}) #$key");
    }
  }

  @override
  void updateProperty<T>(DraftModeEntityAttributeI attribute, T? value) {
    final key = identityHashCode(attribute);
    if (_drafts.containsKey(key)) {
      if (_debugMode) debugPrint("DraftModeFormState.updateProperty (${attribute.debugName ?? "-"}) value $value #$key");
      _drafts[key] = value;
      return;
    }
    if (_debugMode) debugPrint("DraftModeFormState.updateProperty (${attribute.debugName ?? "-"}), failure, not registered #$key");
  }

  @override
  void registerField(DraftModeEntityAttributeI attribute, GlobalKey<FormFieldState> key) {
    final attributeKey = identityHashCode(attribute);
    if (_debugMode) debugPrint("DraftModeFormState.registerField: $attributeKey ${attribute.debugName ?? "-"} #$key");
    _fields.putIfAbsent(attributeKey, () => <GlobalKey<FormFieldState>>{}).add(key);
  }

  @override
  void unregisterField(DraftModeEntityAttributeI attribute, GlobalKey<FormFieldState> key) {
    final attributeKey = identityHashCode(attribute);
    final set = _fields[attributeKey];
    if (set == null) return;
    if (_debugMode) debugPrint("DraftModeFormState.unregisterField: $attributeKey ${attribute.debugName ?? "-"} #$key");
    set.remove(key);
    if (set.isEmpty) _fields.remove(attributeKey);
  }

  @override
  void validateAttribute(DraftModeEntityAttributeI attribute) {
    final attributeKey = identityHashCode(attribute);
    final fields = _fields[attributeKey];
    if (fields == null) {
      if (_debugMode) debugPrint("DraftModeFormState.validateAttribute: (${attribute.debugName ?? "-"}) no related field found #$attributeKey");
      return;
    } else {
      for (final key in fields) {
        if (_debugMode) debugPrint("DraftModeFormState.validateAttribute: (${attribute.debugName ?? "-"}) related field found #$key");
        key.currentState?.validate();
      }
    }
  }

  @override
  V? read<V>(dynamic attribute) {
    if (attribute is DraftModeEntityAttributeI) {
      final key = identityHashCode(attribute);
      if (_drafts.containsKey(key)) {
        final value = _drafts[key] as V?;
        if (_debugMode) debugPrint("DraftModeFormState.read (${attribute.debugName ?? "-"}), use draft.value value $value #$key");
        return value;
      } else {
        if (_debugMode) debugPrint("DraftModeFormState.read (${attribute.debugName ?? "-"}), use prop.value (not registered) #$key");
        return attribute.value;
      }
    } else {
      if (_debugMode) debugPrint("DraftModeFormState.read, not a DraftModeEntityAttribute, prop");
      return attribute as V?;
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
    super.reset();
  }

  static DraftModeFormState? of(BuildContext context) {
    return context.findAncestorStateOfType<DraftModeFormState>();
  }
}
