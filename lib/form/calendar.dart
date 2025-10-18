import 'package:draftmode/form.dart';
import 'package:flutter/widgets.dart';
import '../entity/attribute.dart';

class DraftModeFormCalendar extends StatefulWidget {
  final DraftModeEntityAttribute<DateTime> from;
  final String? fromLabel;
  final ValueChanged<DateTime>? fromOnChanged;
  final DraftModeEntityAttribute<DateTime> to;
  final String? toLabel;
  final ValueChanged<DateTime>? toOnChanged;
  final DraftModeFormCalendarMode mode;
  final DraftModeFormCalendarHourSteps hourSteps;
  final ValueChanged<DateTime?>? onSaved;

  const DraftModeFormCalendar({
    super.key,
    required this.from,
    required this.to,
    this.fromLabel,
    this.fromOnChanged,
    this.toLabel,
    this.toOnChanged,
    this.mode = DraftModeFormCalendarMode.datetime,
    this.hourSteps = DraftModeFormCalendarHourSteps.five,
    this.onSaved,
  });

  @override
  State<DraftModeFormCalendar> createState() => _DraftModeFormCalendarState();
}

class _DraftModeFormCalendarState extends State<DraftModeFormCalendar> {
  @override
  void initState() {
    super.initState();
    if (widget.from.value == null) {
      widget.from.value = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DraftModeFormDateTime(
          label: widget.fromLabel,
          attribute: widget.from,
          mode: widget.mode,
          hourSteps: widget.hourSteps,
          onChanged: widget.fromOnChanged,
        ),
        DraftModeFormDateTime(
          label: widget.toLabel,
          attribute: widget.to,
          mode: widget.mode,
          hourSteps: widget.hourSteps,
          onChanged: widget.toOnChanged,
        ),
      ],
    );
  }
}
