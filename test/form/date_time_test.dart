import 'package:draftmode/entity/attribute.dart';
import 'package:draftmode/form/date_time.dart';
import 'package:draftmode/form/form.dart';
import 'package:draftmode/ui/date_time.dart';
import 'package:draftmode/utils/formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets('DraftModeFormDateTime surfaces validation errors', (
    tester,
  ) async {
    final cutoff = DateTime(2050, 1, 1);
    final attribute = DraftModeEntityAttribute<DateTime>(
      value: DateTime(2000, 1, 1),
      validator: (context, form, value) {
        if (value == null || value.isBefore(cutoff)) {
          return 'Select a future date';
        }
        return null;
      },
    );

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          child: DraftModeFormDateTime(attribute: attribute, label: 'Start'),
        ),
      ),
    );

    expect(find.text('Select a future date'), findsNothing);

    final formState = tester.state<DraftModeFormState>(
      find.byType(DraftModeForm),
    );
    expect(formState.validate(), isFalse);
    await tester.pump();

    expect(find.text('Select a future date'), findsOneWidget);
  });

  testWidgets('DraftModeFormDateTime seeds attribute when missing', (
    tester,
  ) async {
    final attribute = DraftModeEntityAttribute<DateTime>();

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          child: DraftModeFormDateTime(attribute: attribute, label: 'Start'),
        ),
      ),
    );

    expect(attribute.value, isNotNull);

    final state =
        tester.state(find.byType(DraftModeFormDateTime))
            as dynamic; // ignore: avoid_dynamic_calls
    expect(attribute.value, state._selected);
  });

  testWidgets(
    'DraftModeFormDateTime hides error text when focused but keeps strike',
    (tester) async {
      final cutoff = DateTime(2050, 1, 1);
      final attribute = DraftModeEntityAttribute<DateTime>(
        value: DateTime(2000, 1, 1, 10, 0),
        validator: (context, form, value) {
          if (value == null || value.isBefore(cutoff)) {
            return 'Select a future date';
          }
          return null;
        },
      );

      await tester.pumpWidget(
        CupertinoApp(
          home: DraftModeForm(
            child: DraftModeFormDateTime(attribute: attribute, label: 'Start'),
          ),
        ),
      );

      await tester.pump();

      final formState = tester.state<DraftModeFormState>(
        find.byType(DraftModeForm),
      );
      formState.validateAttribute(attribute);
      await tester.pump();

      expect(find.text('Select a future date'), findsNothing);

      final locale = tester.binding.platformDispatcher.locale;
      final localeTag = locale.toLanguageTag();
      final selected = _normalize(attribute.value!);
      final dateLabel = DraftModeDateTime.yMMdd(localeTag).format(selected);
      final timeLabel = DateFormat.Hm(localeTag).format(selected);

      TextDecoration? decorationFor(String label) {
        final text = tester.widget<Text>(find.text(label));
        return text.style?.decoration;
      }

      expect(decorationFor(dateLabel), TextDecoration.lineThrough);
      expect(decorationFor(timeLabel), TextDecoration.lineThrough);

      await tester.tap(find.text(dateLabel));
      await tester.pumpAndSettle(const Duration(milliseconds: 250));

      expect(find.text('Select a future date'), findsNothing);
      expect(decorationFor(dateLabel), TextDecoration.lineThrough);
      expect(decorationFor(timeLabel), TextDecoration.lineThrough);

      expect(formState.validate(), isFalse);
      await tester.pump();

      expect(find.text('Select a future date'), findsOneWidget);
      expect(decorationFor(dateLabel), TextDecoration.lineThrough);
      expect(decorationFor(timeLabel), TextDecoration.lineThrough);

      await tester.tap(find.text(dateLabel));
      await tester.pumpAndSettle(const Duration(milliseconds: 250));

      expect(find.text('Select a future date'), findsOneWidget);
    },
  );

  testWidgets(
    'DraftModeFormDateTime revalidates on updates and clears error styles',
    (tester) async {
      final cutoff = DateTime(2050, 1, 1);
      final attribute = DraftModeEntityAttribute<DateTime>(
        value: DateTime(2000, 1, 1, 10, 0),
        validator: (context, form, value) {
          if (value == null || value.isBefore(cutoff)) {
            return 'Select a future date';
          }
          return null;
        },
      );

      await tester.pumpWidget(
        CupertinoApp(
          home: DraftModeForm(
            child: DraftModeFormDateTime(attribute: attribute, label: 'Start'),
          ),
        ),
      );

      final formState = tester.state<DraftModeFormState>(
        find.byType(DraftModeForm),
      );
      expect(formState.validate(), isFalse);
      await tester.pump();

      final locale = tester.binding.platformDispatcher.locale;
      final localeTag = locale.toLanguageTag();
      final initialDateLabel = DraftModeDateTime.yMMdd(
        localeTag,
      ).format(_normalize(attribute.value!));

      expect(
        tester.widget<Text>(find.text(initialDateLabel)).style?.decoration,
        TextDecoration.lineThrough,
      );

      final DraftModeUIDateTimeField dateTimeField = tester
          .widget<DraftModeUIDateTimeField>(
            find.byType(DraftModeUIDateTimeField),
          );
      final DateTime newValue = DateTime(2050, 1, 2, 10, 0);
      dateTimeField.onChanged(newValue);
      await tester.pump();

      expect(find.text('Select a future date'), findsNothing);

      final updatedDate = _normalize(attribute.value!);
      final updatedDateLabel = DraftModeDateTime.yMMdd(
        localeTag,
      ).format(updatedDate);

      expect(
        tester.widget<Text>(find.text(updatedDateLabel)).style?.decoration,
        TextDecoration.none,
      );

      final updatedTimeLabel = DateFormat.Hm(localeTag).format(updatedDate);

      expect(
        tester.widget<Text>(find.text(updatedTimeLabel)).style?.decoration,
        TextDecoration.none,
      );
    },
  );

  testWidgets(
    'DraftModeFormDateTime syncs end-before-start validation with blur and form.validate',
    (tester) async {
      final startAttribute = DraftModeEntityAttribute<DateTime>(
        value: DateTime(2050, 1, 2, 10, 0),
      );
      final endAttribute = DraftModeEntityAttribute<DateTime>(
        value: DateTime(2050, 1, 2, 12, 0),
        validator: (context, form, value) {
          final startValue = form?.read<DateTime>(startAttribute);
          if (value == null || startValue == null) return null;
          if (!value.isAfter(startValue)) {
            return 'End must be after start';
          }
          return null;
        },
      );

      await tester.pumpWidget(
        CupertinoApp(
          home: DraftModeForm(
            child: Column(
              children: [
                DraftModeFormDateTime(
                  key: const ValueKey('startDateField'),
                  attribute: startAttribute,
                  label: 'Start',
                ),
                DraftModeFormDateTime(
                  key: const ValueKey('endDateField'),
                  attribute: endAttribute,
                  label: 'End',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      final formState = tester.state<DraftModeFormState>(
        find.byType(DraftModeForm),
      );

      final localeTag = tester.binding.platformDispatcher.locale
          .toLanguageTag();
      DateTime normalized(DateTime value) => _normalize(value);

      DateTime endValue() => normalized(endAttribute.value!);

      final endFieldFinder = find.byKey(const ValueKey('endDateField'));
      final endDisplayFinder = find.descendant(
        of: endFieldFinder,
        matching: find.byType(DraftModeUIDateTimeField),
      );
      final FormFieldState<DateTime> endFormFieldState = tester.state(
        find.descendant(
          of: endFieldFinder,
          matching: find.byWidgetPredicate(
            (widget) => widget is FormField<DateTime>,
          ),
        ),
      );

      String endDateLabel() =>
          DraftModeDateTime.yMMdd(localeTag).format(endValue());
      String endTimeLabel() => DateFormat.Hm(localeTag).format(endValue());

      await tester.tap(
        find.descendant(
          of: endFieldFinder,
          matching: find.text(endDateLabel()),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 250));

      final DraftModeUIDateTimeField endField = tester
          .widget<DraftModeUIDateTimeField>(endDisplayFinder);
      final DateTime earlierEnd = startAttribute.value!.subtract(
        const Duration(hours: 2),
      );
      endField.onChanged(earlierEnd);
      await tester.pump();

      TextDecoration? decorationFor(String label) {
        final element = find
            .descendant(of: endFieldFinder, matching: find.text(label))
            .evaluate()
            .single;
        final text = element.widget as Text;
        return text.style?.decoration;
      }

      expect(decorationFor(endDateLabel()), TextDecoration.lineThrough);
      expect(decorationFor(endTimeLabel()), TextDecoration.lineThrough);

      // Bring the end date back into a valid range.
      endField.onChanged(startAttribute.value!.add(const Duration(hours: 2)));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(formState.validate(), isTrue);
      await tester.pump();

      expect(
        find.descendant(
          of: endFieldFinder,
          matching: find.text('End must be after start'),
        ),
        findsNothing,
      );
      expect(decorationFor(endDateLabel()), TextDecoration.none);
      expect(decorationFor(endTimeLabel()), TextDecoration.none);
      expect(endFormFieldState.hasError, isFalse);

      // Changing the start date to a later time should invalidate the end date
      // automatically because of the registered dependency.
      final startFieldFinder = find.byKey(const ValueKey('startDateField'));
      final startDisplayFinder = find.descendant(
        of: startFieldFinder,
        matching: find.byType(DraftModeUIDateTimeField),
      );
      final DraftModeUIDateTimeField startField = tester
          .widget<DraftModeUIDateTimeField>(startDisplayFinder);

      startField.onChanged(endAttribute.value!.add(const Duration(hours: 1)));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(decorationFor(endDateLabel()), TextDecoration.lineThrough);
      expect(decorationFor(endTimeLabel()), TextDecoration.lineThrough);
      expect(
        find.descendant(
          of: endFieldFinder,
          matching: find.text('End must be after start'),
        ),
        findsOneWidget,
      );
      expect(endFormFieldState.hasError, isTrue);

      expect(formState.validate(), isFalse);
      await tester.pump();

      expect(
        find.descendant(
          of: endFieldFinder,
          matching: find.text('End must be after start'),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(
          of: endFieldFinder,
          matching: find.text(endDateLabel()),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 250));

      expect(
        find.descendant(
          of: endFieldFinder,
          matching: find.text('End must be after start'),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(
          of: endFieldFinder,
          matching: find.text(endDateLabel()),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 250));

      expect(
        find.descendant(
          of: endFieldFinder,
          matching: find.text('End must be after start'),
        ),
        findsNothing,
      );

      expect(formState.validate(), isFalse);
      await tester.pump();

      expect(
        find.descendant(
          of: endFieldFinder,
          matching: find.text('End must be after start'),
        ),
        findsOneWidget,
      );
      expect(decorationFor(endDateLabel()), TextDecoration.lineThrough);
      expect(decorationFor(endTimeLabel()), TextDecoration.lineThrough);
      expect(endFormFieldState.hasError, isTrue);
    },
  );
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
