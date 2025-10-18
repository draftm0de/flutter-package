import 'package:draftmode/entity/attribute.dart';
import 'package:draftmode/form.dart';
import 'package:draftmode/ui/date_time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DraftModeFormCalendar seeds missing start attribute', (
    tester,
  ) async {
    final fromAttribute = DraftModeEntityAttribute<DateTime>(null);
    final toSeed = DateTime(2024, 6, 10, 12, 0);
    final toAttribute = DraftModeEntityAttribute<DateTime>(toSeed);

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          child: DraftModeFormCalendar(
            from: fromAttribute,
            to: toAttribute,
            fromLabel: 'From',
            toLabel: 'To',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(fromAttribute.value, isNotNull);
    expect(toAttribute.value, toSeed);

    final fields = tester
        .widgetList<DraftModeUIDateTimeField>(
          find.byType(DraftModeUIDateTimeField),
        )
        .toList();
    expect(fields, hasLength(2));
    expect(fields.first.label, 'From');
    expect(fields.last.label, 'To');
  });

  testWidgets('DraftModeFormCalendar forwards change handlers', (tester) async {
    final fromAttribute = DraftModeEntityAttribute<DateTime>(
      DateTime(2024, 1, 1, 9, 0),
    );
    final toAttribute = DraftModeEntityAttribute<DateTime>(
      DateTime(2024, 1, 2, 17, 30),
    );
    DateTime? fromChanged;
    DateTime? toChanged;

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          child: DraftModeFormCalendar(
            from: fromAttribute,
            to: toAttribute,
            mode: DraftModeFormCalendarMode.datetime,
            hourSteps: DraftModeFormCalendarHourSteps.ten,
            fromOnChanged: (value) => fromChanged = value,
            toOnChanged: (value) => toChanged = value,
          ),
        ),
      ),
    );

    final fields = tester
        .widgetList<DraftModeUIDateTimeField>(
          find.byType(DraftModeUIDateTimeField),
        )
        .toList();
    expect(fields.first.hourSteps, DraftModeFormCalendarHourSteps.ten);
    expect(fields.last.hourSteps, DraftModeFormCalendarHourSteps.ten);

    final newFrom = DateTime(2024, 2, 3, 11, 0);
    final newTo = DateTime(2024, 2, 4, 12, 30);

    fields.first.onChanged(newFrom);
    await tester.pump();
    fields.last.onChanged(newTo);
    await tester.pump();

    expect(fromChanged, newFrom);
    expect(toChanged, newTo);

    final formState = tester.state<DraftModeFormState>(
      find.byType(DraftModeForm),
    );
    expect(formState.read<DateTime>(fromAttribute), newFrom);
    expect(formState.read<DateTime>(toAttribute), newTo);
  });
}
