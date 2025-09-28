import 'package:flutter/cupertino.dart';

import '../entity/interface.dart';
import '../platform/buttons.dart';
import '../ui/row.dart';
import '../ui/text_error.dart';
import 'form.dart';

/// Adaptive text entry field wired into the Draftmode form infrastructure. It
/// keeps the associated [DraftModeEntityAttributeI] in sync with the UI and
/// exposes Draftmode-specific affordances such as optional eye toggles and
/// validation orchestration.
class DraftModeFormField<T> extends StatefulWidget {
  final DraftModeEntityAttributeI attribute;
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
  final bool clearErrorOnFocus;
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
    this.clearErrorOnFocus = false,
    this.autocorrect = false,
  });

  @override
  State<DraftModeFormField> createState() => DraftModeFormFieldState<T>();
}

class DraftModeFormFieldState<T> extends State<DraftModeFormField> {
  late final TextEditingController _controller;
  final _fieldKey = GlobalKey<FormFieldState<T>>();

  late bool _obscureOn;

  FocusNode? _ownedFocus;
  FocusNode get _focus => _ownedFocus ??= FocusNode();

  DraftModeFormState? _form;

  String get text => _controller.text;
  set text(String? value) {
    final nextValue = value ?? '';
    if (_controller.text != nextValue) {
      _controller.text = nextValue;
      _controller.selection = TextSelection.collapsed(offset: nextValue.length);
      setState(() {});
    }
  }

  String _encodeValue(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value;
    }
    if (value is DateTime) {
      return value.toString();
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = _encodeValue(widget.attribute.value);
    _obscureOn = widget.obscureText;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final form = DraftModeFormState.of(context);
      form?.registerField(widget.attribute, _fieldKey);
    });
  }

  @override
  void dispose() {
    _form?.unregisterField(widget.attribute, _fieldKey);
    _ownedFocus?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _form = DraftModeFormState.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final form = DraftModeFormState.of(context);
    _form = form ?? _form;
    form?.registerProperty(widget.attribute);
    return FormField<T>(
      key: _fieldKey,
      initialValue: widget.attribute.value,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (v) => widget.attribute.validate(context, form, v),
      onSaved: (v) {
        widget.attribute.value = v;
        widget.onSaved?.call(v);
      },
      builder: (field) {
        final bool enableValidation = form?.enableValidation ?? false;
        final bool showError =
            (enableValidation || !_focus.hasFocus) && field.hasError;

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
          focusNode: _focus,
          onFocusChange: (hasFocus) {
            if (hasFocus && widget.clearErrorOnFocus) {
              field.setState(() {});
            }
            if (!hasFocus) {
              field.validate();
            }
            field.setState(() {});
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
              form?.updateProperty(widget.attribute, val);
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
