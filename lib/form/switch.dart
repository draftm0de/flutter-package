import 'package:flutter/widgets.dart';

import '../entity/attribute.dart';
import '../ui/row.dart';
import '../ui/switch.dart';
import '../ui/text_error.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _form?.registerField(widget.attribute, _fieldKey);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _form = DraftModeFormState.of(context);
  }

  @override
  void dispose() {
    _form?.unregisterField(widget.attribute, _fieldKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = _form ?? DraftModeFormState.of(context);
    form?.registerProperty(widget.attribute);

    return FormField<bool>(
      key: _fieldKey,
      initialValue: widget.attribute.value ?? false,
      enabled: widget.enabled,
      autovalidateMode: widget.autovalidateMode,
      validator:
          widget.validator ??
          (v) => widget.attribute.validate(context, form, v),
      onSaved: (value) {
        final nextValue = value ?? false;
        widget.attribute.value = nextValue;
        widget.onSaved?.call(nextValue);
      },
      builder: (field) {
        final enableValidation = form?.enableValidation ?? false;
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
                        (form ?? DraftModeFormState.of(context))
                            ?.updateProperty(widget.attribute, resolved);
                        widget.onChanged?.call(resolved);
                      }
                    : null,
              ),
            ),
            DraftModeUITextError(text: field.errorText, visible: showError),
          ],
        );
      },
    );
  }
}
