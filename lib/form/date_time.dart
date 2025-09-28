import 'package:flutter/widgets.dart';

import '../entity/attribute.dart';
import '../ui/date_time.dart';
import '../ui/text_error.dart';
import 'interface.dart';
import 'form.dart';

/// Slim date/time picker that focuses on a single [DraftModeEntityAttribute].
/// Ideal for forms that only need one timestamp without range selection or
/// duration handling.
class DraftModeFormDateTime extends StatefulWidget {
  final DraftModeEntityAttribute<DateTime> attribute;
  final String? label;
  final DraftModeFormCalendarMode mode;
  final ValueChanged<DateTime>? onChanged;
  final ValueChanged<DateTime?>? onSaved;

  const DraftModeFormDateTime({
    super.key,
    required this.attribute,
    this.label,
    this.mode = DraftModeFormCalendarMode.datetime,
    this.onChanged,
    this.onSaved,
  });

  @override
  State<DraftModeFormDateTime> createState() => _DraftModeFormDateTimeState();
}

class _DraftModeFormDateTimeState extends State<DraftModeFormDateTime> {
  final _fieldKey = GlobalKey<FormFieldState<DateTime>>();
  late final FocusNode _focusNode = FocusNode(
    debugLabel: 'DraftModeFormDateTime',
  );
  DraftModeFormCalendarPickerMode _mode =
      DraftModeFormCalendarPickerMode.closed;
  late DateTime _selected;
  DraftModeFormState? _form;
  bool _showErrorOnBlur = false;

  @override
  void initState() {
    super.initState();
    _selected = _normalize(widget.attribute.value ?? DateTime.now());
    widget.attribute.value ??= _selected;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final form = DraftModeFormState.of(context);
      form?.registerField(widget.attribute, _fieldKey);
    });
  }

  DateTime _normalize(DateTime value) {
    const step = 5;
    final remainder = value.minute % step;
    final delta = remainder == 0 ? 0 : -remainder;
    return DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute + delta,
    );
  }

  void _toggle(DraftModeFormCalendarPickerMode mode) {
    setState(() {
      _mode = _mode == mode ? DraftModeFormCalendarPickerMode.closed : mode;
    });
    if (_mode == DraftModeFormCalendarPickerMode.closed) {
      _focusNode.unfocus();
    } else {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  void _toggleMonthYear() {
    setState(() {
      _mode = _mode == DraftModeFormCalendarPickerMode.monthYear
          ? DraftModeFormCalendarPickerMode.day
          : DraftModeFormCalendarPickerMode.monthYear;
    });
  }

  void _update(
    DateTime value, {
    DraftModeFormState? form,
    required bool hasError,
  }) {
    setState(() {
      _selected = value;
      if (!hasError) {
        _showErrorOnBlur = false;
      }
    });
    widget.attribute.value = value;
    widget.onChanged?.call(value);
    (form ?? DraftModeFormState.of(context))?.updateProperty(
      widget.attribute,
      value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = _form ?? DraftModeFormState.of(context);
    form?.registerProperty(widget.attribute);

    return FormField<DateTime>(
      key: _fieldKey,
      initialValue: _selected,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value) => widget.attribute.validate(context, form, value),
      onSaved: (value) {
        final resolved = value ?? _selected;
        widget.attribute.value = resolved;
        widget.onSaved?.call(resolved);
      },
      builder: (field) {
        final hasFocus = _focusNode.hasFocus;
        final enableValidation = form?.enableValidation ?? false;
        final showError =
            field.hasError &&
            !hasFocus &&
            (enableValidation || _showErrorOnBlur);
        final currentValue = field.value ?? _selected;
        final strike = field.hasError;

        return Focus(
          focusNode: _focusNode,
          onFocusChange: (focused) {
            if (!mounted) return;
            if (focused) {
              setState(() => _showErrorOnBlur = false);
            } else {
              final isValid = field.validate();
              setState(() => _showErrorOnBlur = !isValid);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DraftModeUIDateTimeField(
                label: (widget.label?.isEmpty ?? true) ? null : widget.label,
                mode: widget.mode,
                pickerMode: _mode,
                value: currentValue,
                strike: strike,
                onToggleMonthYear: _toggleMonthYear,
                onPickerModeChanged: (mode) {
                  _toggle(mode);
                },
                onChanged: (value) {
                  final resolved = _normalize(value);
                  field.didChange(resolved);
                  final isValid = field.validate();
                  _update(resolved, form: form, hasError: !isValid);
                },
              ),
              DraftModeUITextError(text: field.errorText, visible: showError),
            ],
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _form = DraftModeFormState.of(context);
  }

  @override
  void dispose() {
    _form?.unregisterField(widget.attribute, _fieldKey);
    _focusNode.dispose();
    super.dispose();
  }
}
