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
  bool _fieldRegistered = false;
  bool _showErrorOnBlur = false;

  @override
  void initState() {
    super.initState();
    widget.attribute.addValueMapper(_normalize);
    final initial = widget.attribute.value ?? DateTime.now();
    final normalized = widget.attribute.mapValue(initial) ?? initial;
    _selected = normalized;
    widget.attribute.value = normalized;
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

  void _detachFromForm({DraftModeEntityAttribute<DateTime>? attribute}) {
    if (_form == null || !_fieldRegistered) return;
    _form?.unregisterField(attribute ?? widget.attribute, _fieldKey);
    _fieldRegistered = false;
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
    if (_mode != DraftModeFormCalendarPickerMode.closed) {
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

  void _update(DateTime value, {required bool hasError}) {
    final normalized = widget.attribute.mapValue(value) ?? value;
    setState(() {
      _selected = normalized;
      if (!hasError) {
        _showErrorOnBlur = false;
      }
    });
    widget.attribute.value = normalized;
    widget.onChanged?.call(normalized);
    _form?.updateProperty(widget.attribute, normalized);
  }

  @override
  Widget build(BuildContext context) {
    _syncFormAssociation();
    _form?.registerProperty(widget.attribute);

    return FormField<DateTime>(
      key: _fieldKey,
      initialValue: _selected,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value) => widget.attribute.validate(context, _form, value),
      onSaved: (value) {
        final resolved = value ?? _selected;
        widget.attribute.value = resolved;
        widget.onSaved?.call(resolved);
      },
      builder: (field) {
        final hasFocus = _focusNode.hasFocus;
        final enableValidation = _form?.enableValidation ?? false;
        final showError =
            field.hasError &&
            !hasFocus &&
            (enableValidation || _showErrorOnBlur);
        final currentValue = field.value ?? _selected;
        final strike = field.hasError;

        return TapRegion(
          onTapOutside: (_) {
            if (!mounted) return;
            if (_mode != DraftModeFormCalendarPickerMode.closed) {
              setState(() => _mode = DraftModeFormCalendarPickerMode.closed);
            }
            if (_focusNode.hasFocus) {
              _focusNode.unfocus();
            }
          },
          child: Focus(
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
                    final resolved = widget.attribute.mapValue(value) ?? value;
                    field.didChange(resolved);
                    final isValid = field.validate();
                    _update(resolved, hasError: !isValid);
                  },
                ),
                DraftModeUITextError(text: field.errorText, visible: showError),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFormAssociation();
  }

  @override
  void didUpdateWidget(covariant DraftModeFormDateTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.attribute, widget.attribute)) {
      _detachFromForm(attribute: oldWidget.attribute);
      widget.attribute.addValueMapper(_normalize);
      final initial = widget.attribute.value ?? _selected;
      final normalized = widget.attribute.mapValue(initial) ?? initial;
      setState(() {
        _selected = normalized;
      });
      widget.attribute.value = normalized;
      _syncFormAssociation();
    }
  }

  @override
  void dispose() {
    _detachFromForm();
    _focusNode.dispose();
    super.dispose();
  }
}
