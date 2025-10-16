import 'package:flutter/cupertino.dart';

import '../entity/interface.dart';
import '../platform/buttons.dart';
import '../ui/row.dart';
import '../ui/text_error.dart';
import 'form.dart';

/// Adaptive text entry field wired into the Draftmode form infrastructure. It
/// keeps the associated [DraftModeEntityAttributeInterface] in sync with the UI and
/// exposes Draftmode-specific affordances such as optional eye toggles and
/// validation orchestration.
class DraftModeFormField<T> extends StatefulWidget {
  final DraftModeEntityAttributeInterface<T> attribute;
  final String? label;
  final String? placeholder;
  final bool obscureText;
  final bool obscureEye;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<T?>? onSaved;
  final Widget? prefix;
  final Widget? suffix;
  final bool enabled;
  final bool autocorrect;

  const DraftModeFormField({
    super.key,
    required this.attribute,
    this.label,
    this.placeholder,
    this.obscureText = false,
    this.obscureEye = false,
    this.keyboardType,
    this.textInputAction,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.onSaved,
    this.autocorrect = false,
  });

  @override
  State<DraftModeFormField> createState() => DraftModeFormFieldState<T>();
}

class DraftModeFormFieldState<T> extends State<DraftModeFormField> {
  late final TextEditingController _controller;
  final _fieldKey = GlobalKey<FormFieldState<T>>();

  late bool _obscureOn;

  late final FocusNode _focusNode = FocusNode(debugLabel: 'DraftModeFormField');
  DraftModeFormState? _form;
  bool _fieldRegistered = false;
  bool _showErrorOnBlur = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = widget.attribute.value?.toString() ?? '';
    _obscureOn = widget.obscureText;
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

  void _detachFromForm({DraftModeEntityAttributeInterface? attribute}) {
    if (_form == null || !_fieldRegistered) return;
    _form?.unregisterField(attribute ?? widget.attribute, _fieldKey);
    _fieldRegistered = false;
  }

  @override
  void dispose() {
    _detachFromForm();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFormAssociation();
  }

  @override
  void didUpdateWidget(covariant DraftModeFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.attribute, widget.attribute)) {
      _detachFromForm(attribute: oldWidget.attribute);
      _syncFormAssociation();
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncFormAssociation();
    _form?.registerProperty(widget.attribute);
    return FormField<T>(
      key: _fieldKey,
      initialValue: widget.attribute.value,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value) => widget.attribute.validate(context, _form, value),
      onSaved: (value) {
        widget.attribute.value = value;
        widget.onSaved?.call(value);
      },
      builder: (field) {
        final bool enableValidation = _form?.enableValidation ?? false;
        final bool showError =
            field.hasError &&
            !_focusNode.hasFocus &&
            (enableValidation || _showErrorOnBlur);

        final Widget? suffix = widget.obscureEye
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureOn = !_obscureOn;
                  });
                },
                child: Icon(
                  _obscureOn ? PlatformButtons.eyeSlash : PlatformButtons.eye,
                  size: 20,
                  color: CupertinoColors.inactiveGray,
                ),
              )
            : widget.suffix;

        Widget child = Focus(
          focusNode: _focusNode,
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              setState(() => _showErrorOnBlur = false);
            } else {
              final isValid = field.validate();
              setState(() => _showErrorOnBlur = !isValid);
            }
          },
          child: CupertinoTextField(
            padding: EdgeInsets.zero,
            controller: _controller,
            enabled: widget.enabled,
            placeholder: widget.placeholder,
            obscureText: _obscureOn,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            prefix: widget.prefix,
            autocorrect: widget.autocorrect,
            suffix: suffix,
            onChanged: (val) {
              // `T` defaults to `dynamic`, but explicit cast keeps type
              // inference stable when callers opt into a concrete type.
              // ignore: unnecessary_cast
              field.didChange(val as T);
              _form?.updateProperty(widget.attribute, val);
            },
            decoration: null,
          ),
        );

        return Column(
          children: [
            DraftModeUIRow(label: widget.label, child: child),
            DraftModeUITextError(text: field.errorText, visible: showError),
          ],
        );
      },
    );
  }
}
