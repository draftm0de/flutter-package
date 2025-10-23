import 'package:draftmode/form/form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../entity/interface.dart';
import '../platform/buttons.dart';
import '../ui/error_text.dart';
import '../ui/row.dart';
import 'formatter.dart';
import 'interface.dart';

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
  final DraftModerFormFormatterInterface? formatter;
  final ValueChanged<T?>? onSaved;
  final Widget? prefix;
  final Widget? suffix;
  final bool enabled;
  final bool autocorrect;
  final int? lines;

  const DraftModeFormField({
    super.key,
    required this.attribute,
    this.label,
    this.placeholder,
    this.obscureText = false,
    this.obscureEye = false,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.onSaved,
    this.autocorrect = false,
    this.lines,
    this.formatter,
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
  late DraftModerFormFormatterInterface? _inputFormatter;
  late TextInputType? _keyboardType;

  @override
  void initState() {
    super.initState();
    _inputFormatter = widget.formatter ?? _getInputFormatter<T>();
    _keyboardType = _inputFormatter?.getTextInputType();
    dynamic _value =
        _inputFormatter?.encode(widget.attribute.value) ??
        widget.attribute.value;

    _controller = TextEditingController(text: _value.toString());
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
    if (!_focusNode.hasFocus) {
      String? _value = (_inputFormatter != null)
          ? _inputFormatter?.encode(widget.attribute.value)
          : widget.attribute.value;
      _applyFormattedText(_value ?? "");
    }
  }

  void _applyFormattedText(String next) {
    if (_controller.text == next) {
      return;
    }
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  DraftModerFormFormatterInterface? _getInputFormatter<T>() {
    switch (T) {
      case int:
        return DraftModeFormTypeInt();
      case double:
        return DraftModeFormTypeDouble();
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncFormAssociation();
    _form?.registerProperty(widget.attribute);
    final bool _keyboardTypeDecimal = _keyboardType?.decimal ?? false;
    final bool _keyboardTypeSigned = _keyboardType?.signed ?? false;
    final useKeyboardType = (_keyboardTypeSigned)
        ? TextInputType.numberWithOptions(
            decimal: _keyboardTypeDecimal,
            signed: false,
          )
        : _keyboardType;
    final List<TextInputFormatter>? inputFormatter = (_inputFormatter != null)
        ? [_inputFormatter!]
        : null;

    Widget child = FormField<T>(
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

        final bool obscured = _obscureOn;
        final int? lineCount = widget.lines;
        final int? minLines = obscured ? 1 : lineCount;
        final int? maxLines = obscured ? 1 : lineCount;
        final maxLengthValidator = widget.attribute.validatorByType(
          DraftModeValidatorType.maxLength,
        );
        final int? maxLength = maxLengthValidator?.payload is int
            ? maxLengthValidator?.payload as int
            : null;

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
            obscureText: obscured,
            keyboardType: useKeyboardType,
            inputFormatters: inputFormatter,
            prefix: widget.prefix,
            autocorrect: widget.autocorrect,
            minLines: minLines,
            maxLines: maxLines,
            maxLength: maxLength,
            suffix: suffix,
            onChanged: (val) {
              // Convert the localized input back into the widget's generic type
              // so form consumers never see the grouped string representation.
              final typed = (_inputFormatter != null)
                  ? _inputFormatter?.decode(val)
                  : val;
              // `T` defaults to `dynamic`, but explicit cast keeps type
              // inference stable when callers opt into a concrete type.
              // ignore: unnecessary_cast
              field.didChange(typed);
              _form?.updateProperty(widget.attribute, typed);
            },
            decoration: null,
          ),
        );

        Widget content = _keyboardTypeSigned
            ? DraftModeFormKeyBoardSigned(
                focusNode: _focusNode,
                child: child,
                onToggleSign: () {
                  final t = _controller.text;
                  _controller.text = t.startsWith('-') ? t.substring(1) : '-$t';
                  _controller.selection = TextSelection.collapsed(
                    offset: _controller.text.length,
                  );
                  final value = _inputFormatter?.decode(_controller.text) as T?;
                  _fieldKey.currentState?.didChange(value);
                },
              )
            : child;

        return Column(
          children: [
            DraftModeUIRow(label: widget.label, child: content),
            DraftModeUIErrorText(text: field.errorText, visible: showError),
          ],
        );
      },
    );
    return child;
  }
}
