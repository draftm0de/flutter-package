import 'package:draftmode/entity/attribute.dart';
import 'package:flutter/widgets.dart';
import '../ui/text_error.dart';
import '../ui/switch.dart';
import '../ui/row.dart';
import 'form.dart';

class DraftModeFormSwitch extends StatelessWidget {
  final DraftModeEntityAttribute<bool> element;
  final bool enabled;
  final AutovalidateMode autovalidateMode;
  final FormFieldSetter<bool>? onSaved;
  final FormFieldValidator<bool>? validator;
  final ValueChanged<bool>? onChanged;
  final String? label;

  const DraftModeFormSwitch({
    super.key,
    required this.element,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onSaved,
    this.validator,
    this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final form = DraftModeFormState.of(context);
    form?.registerProperty(element);
    final bool initialValue = element.value ?? false;

    return FormField<bool>(
      initialValue: initialValue,
      enabled: enabled,
      autovalidateMode: autovalidateMode,
      onSaved: (v) => element.value = v ?? false,
      builder: (field) {
        return Column(
          children: [
            DraftModeUIRow(
              label: label,
              alignment: Alignment.centerRight,
              child: DraftModeUISwitch(
                value: field.value ?? false,
                onChanged: (bool? v) {
                  form?.updateProperty(element, v);
                  field.didChange(v);
                  onChanged?.call(v ?? false);
                }
              ),
            ),
            DraftModeUITextError(
              text: field.errorText,
              visible: true,
            )
          ],
        );
      },
    );
  }
}