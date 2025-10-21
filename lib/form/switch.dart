import 'package:flutter/widgets.dart';

import '../entity/attribute.dart';
import '../ui/row.dart';
import '../ui/switch.dart';
import '../ui/error_text.dart';
import 'form.dart';

/// Toggle control bound to a [DraftModeEntityAttribute]. Mirrors the behaviour
/// of other form inputs by participating in validation cycles and exposing the
/// latest draft value through [DraftModeFormState].
class DraftModeFormSwitch extends StatefulWidget {
  final DraftModeEntityAttribute<bool> attribute;
  final bool enabled;
  final AutovalidateMode autovalidateMode;
  final FormFieldSetter<bool>? onSaved;
  final FormFieldValidator<bool>? validator;
  final ValueChanged<bool>? onChanged;
  final String? label;

  const DraftModeFormSwitch({
    super.key,
    required this.attribute,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onSaved,
    this.validator,
    this.onChanged,
    this.label,
  });

  @override
  State<DraftModeFormSwitch> createState() => _DraftModeFormSwitchState();
}

class _DraftModeFormSwitchState extends State<DraftModeFormSwitch> {
  final _fieldKey = GlobalKey<FormFieldState<bool>>();
  DraftModeFormState? _form;
  bool _fieldRegistered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncFormAssociation();
    });
  }

  void _syncFormAssociation() {
    final candidate = DraftModeFormState.of(context);
    if (!identical(candidate, _form)) {
      _detachFromForm();
      _form = candidate;
    }
    final form = _form;
    if (form != null && !_fieldRegistered) {
      form.registerField(widget.attribute, _fieldKey);
      _fieldRegistered = true;
    }
  }

  void _detachFromForm({DraftModeEntityAttribute<bool>? attribute}) {
    if (_form == null || !_fieldRegistered) return;
    _form?.unregisterField(attribute ?? widget.attribute, _fieldKey);
    _fieldRegistered = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFormAssociation();
  }

  @override
  void didUpdateWidget(covariant DraftModeFormSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.attribute, widget.attribute)) {
      _detachFromForm(attribute: oldWidget.attribute);
      _syncFormAssociation();
    }
  }

  @override
  void dispose() {
    _detachFromForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _syncFormAssociation();
    _form?.registerProperty(widget.attribute);

    return FormField<bool>(
      key: _fieldKey,
      initialValue: widget.attribute.value ?? false,
      enabled: widget.enabled,
      autovalidateMode: widget.autovalidateMode,
      validator:
          widget.validator ??
          (v) => widget.attribute.validate(context, _form, v),
      onSaved: (value) {
        final nextValue = value ?? false;
        widget.attribute.value = nextValue;
        widget.onSaved?.call(nextValue);
      },
      builder: (field) {
        final enableValidation = _form?.enableValidation ?? false;
        final showError = enableValidation && field.hasError;

        return Column(
          children: [
            DraftModeUIRow(
              label: widget.label,
              alignment: Alignment.centerRight,
              child: DraftModeUISwitch(
                value: field.value ?? false,
                onChanged: widget.enabled
                    ? (bool? value) {
                        final resolved = value ?? false;
                        field.didChange(resolved);
                        (_form ?? DraftModeFormState.of(context))
                            ?.updateProperty(widget.attribute, resolved);
                        widget.onChanged?.call(resolved);
                      }
                    : null,
              ),
            ),
            DraftModeUIErrorText(text: field.errorText, visible: showError),
          ],
        );
      },
    );
  }
}
