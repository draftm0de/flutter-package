import 'package:flutter/cupertino.dart';
//
import 'form.dart';
import '../ui/text_error.dart';
import '../ui/row.dart';
import '../platform/buttons.dart';
import '../entity/types.dart';

class DraftModeFormField<T> extends StatefulWidget {
  final DraftModeEntityAttributeI element;
  final String? label;
  final String? placeholder;
  final bool obscureText;
  final bool obscureEye;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<T>? onSaved;
  final Widget? prefix;
  final Widget? suffix;
  final bool enabled;
  final bool clearErrorOnFocus;
  final bool autocorrect;

  const DraftModeFormField({
    super.key,
    required this.element,
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

  String get text => _controller.text;
  set text(String? value) {
    if (_controller.text != value) {
      _controller.text = value!;
      _controller.selection = TextSelection.collapsed(offset: value.length);
      setState(() {});
    }
  }

  String encodeValue(dynamic value) {
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
    _controller.text = encodeValue(widget.element.value);
    _obscureOn = widget.obscureText;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final form = DraftModeFormState.of(context);
      form?.registerField(widget.element, _fieldKey);
    });
  }

  @override
  void dispose() {
    _ownedFocus?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = DraftModeFormState.of(context);
    form?.registerProperty(widget.element);
    return FormField<T>(
      key: _fieldKey,
      initialValue: widget.element.value,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (v) => widget.element.validate(context, form, v),
      onSaved: (v) {
        widget.element.value = v as T;
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
              field.didChange(val as T);
              form?.updateProperty(widget.element, val);
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
