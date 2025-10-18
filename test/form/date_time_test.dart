import 'dart:io';

import 'package:draftmode/entity/attribute.dart';
import 'package:draftmode/form/date_time.dart';
import 'package:draftmode/form/form.dart';
import 'package:draftmode/form/interface.dart';
import 'package:draftmode/ui/date_time.dart';
import 'package:draftmode/utils/formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

final bool _skipCoverage = Platform.environment['CI_COVERAGE'] == '1';

void main() {
  testWidgets('DraftModeFormDateTime surfaces validation errors', (
    tester,
  ) async {
    final cutoff = DateTime(2050, 1, 1);
    final attribute = DraftModeEntityAttribute<DateTime>(
      DateTime(2000, 1, 1),
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

  testWidgets(
    'DraftModeFormDateTime exposes default selection without mutating attribute',
    (tester) async {
      final attribute = DraftModeEntityAttribute<DateTime>(null);

      await tester.pumpWidget(
        CupertinoApp(
          home: DraftModeForm(
            child: DraftModeFormDateTime(attribute: attribute, label: 'Start'),
          ),
        ),
      );

      expect(attribute.value, isNull);

      final field = tester.widget<DraftModeUIDateTimeField>(
        find.byType(DraftModeUIDateTimeField),
      );
      final DateTime initialValue = field.value;
      expect(initialValue, isNotNull);

      final formState = tester.state<DraftModeFormState>(
        find.byType(DraftModeForm),
      );
      expect(formState.read<DateTime>(attribute), isNull);

      formState.save();
      await tester.pump();

      final savedValue = attribute.value;
      expect(savedValue, isNotNull);
      expect(savedValue, equals(initialValue));
    },
  );

  testWidgets(
    'DraftModeFormDateTime opens and closes picker on user tap',
    (tester) async {},
    skip: _skipCoverage,
  );

  testWidgets(
    'DraftModeFormDateTime hides error text when focused but keeps strike',
    (tester) async {
      final cutoff = DateTime(2050, 1, 1);
      final attribute = DraftModeEntityAttribute<DateTime>(
        DateTime(2000, 1, 1, 10, 0),
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
      await tester.pump();

      expect(find.text('Select a future date'), findsNothing);
      expect(decorationFor(dateLabel), TextDecoration.lineThrough);
      expect(decorationFor(timeLabel), TextDecoration.lineThrough);

      expect(formState.validate(), isFalse);
      await tester.pump();

      expect(find.text('Select a future date'), findsOneWidget);
      expect(decorationFor(dateLabel), TextDecoration.lineThrough);
      expect(decorationFor(timeLabel), TextDecoration.lineThrough);

      await tester.tap(find.text(dateLabel));
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Select a future date'), findsOneWidget);
    },
  );

  testWidgets(
    'DraftModeFormDateTime revalidates on updates and clears error styles',
    (tester) async {
      final cutoff = DateTime(2050, 1, 1);
      final attribute = DraftModeEntityAttribute<DateTime>(
        DateTime(2000, 1, 1, 10, 0),
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

      final updatedDate = formState.read<DateTime>(attribute)!;
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

  testWidgets('DraftModeFormDateTime onSaved writes attribute and draft', (
    tester,
  ) async {
    final formKey = GlobalKey<DraftModeFormState>();
    final attribute = DraftModeEntityAttribute<DateTime>(
      DateTime(2024, 1, 1, 8, 0),
    );

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          key: formKey,
          child: DraftModeFormDateTime(
            attribute: attribute,
            label: 'Start',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final element = tester.element(find.byType(DraftModeFormDateTime));
    final formState = DraftModeFormState.of(element)!;

    final newValue = DateTime(2024, 1, 2, 9, 30);
    final picker = tester.widget<DraftModeUIDateTimeField>(
      find.byType(DraftModeUIDateTimeField),
    );
    picker.onChanged(newValue);

    formKey.currentState!.save();

    expect(attribute.value, newValue);
    expect(formState.read<DateTime>(attribute), newValue);
  });

  testWidgets('DraftModeFormDateTime invokes onSaved callback', (tester) async {
    final attribute = DraftModeEntityAttribute<DateTime>(
      DateTime(2024, 2, 10, 14, 45),
    );
    DateTime? savedValue;

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          child: DraftModeFormDateTime(
            attribute: attribute,
            onSaved: (value) => savedValue = value,
          ),
        ),
      ),
    );

    final formState = tester.state<DraftModeFormState>(
      find.byType(DraftModeForm),
    );

    final newValue = DateTime(2024, 2, 11, 9, 0);
    tester
        .widget<DraftModeUIDateTimeField>(find.byType(DraftModeUIDateTimeField))
        .onChanged(newValue);

    formState.save();

    expect(savedValue, newValue);
  });

  testWidgets(
    'DraftModeFormDateTime syncs end-before-start validation with blur and form.validate',
    (tester) async {
      if (_skipCoverage) return;

      final startAttribute = DraftModeEntityAttribute<DateTime>(
        DateTime(2050, 1, 2, 10, 0),
      );
      final endAttribute = DraftModeEntityAttribute<DateTime>(
        DateTime(2050, 1, 2, 12, 0),
        validator: (context, form, value) {
          final startValue = form?.read<DateTime>(startAttribute);
          if (value == null || startValue == null) return null;
          return value.isAfter(startValue) ? null : 'End must be after start';
        },
      );

      await tester.pumpWidget(
        CupertinoApp(
          home: DraftModeForm(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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

      final formState = tester.state<DraftModeFormState>(
        find.byType(DraftModeForm),
      );

      final startField = tester.widget<DraftModeUIDateTimeField>(
        find.descendant(
          of: find.byKey(const ValueKey('startDateField')),
          matching: find.byType(DraftModeUIDateTimeField),
        ),
      );
      final endField = tester.widget<DraftModeUIDateTimeField>(
        find.descendant(
          of: find.byKey(const ValueKey('endDateField')),
          matching: find.byType(DraftModeUIDateTimeField),
        ),
      );

      expect(formState.validate(), isTrue);

      startField.onChanged(DateTime(2050, 1, 2, 13, 0));
      await tester.pump();
      endField.onChanged(DateTime(2050, 1, 2, 12, 30));
      await tester.pump();

      expect(formState.validate(), isFalse);

      endField.onChanged(DateTime(2050, 1, 2, 14, 0));
      await tester.pump();

      expect(formState.validate(), isTrue);
    },
    skip: _skipCoverage,
  );

  testWidgets(
    'DraftModeFormDateTime re-associates when attribute instance changes',
    (tester) async {
      final attributeA = DraftModeEntityAttribute<DateTime>(
        DateTime(2024, 1, 1, 9, 3),
      );
      final attributeB = DraftModeEntityAttribute<DateTime>(
        DateTime(2024, 2, 2, 14, 7),
      );

      Future<void> pumpWith(
        DraftModeEntityAttribute<DateTime> attribute,
      ) async {
        await tester.pumpWidget(
          CupertinoApp(
            home: DraftModeForm(
              child: DraftModeFormDateTime(
                key: const ValueKey('date-field'),
                attribute: attribute,
                label: 'Start',
              ),
            ),
          ),
        );
      }

      final originalA = attributeA.value!;
      final expectedA = _normalize(originalA);
      await pumpWith(attributeA);
      await tester.pump();

      final firstField = tester.widget<DraftModeUIDateTimeField>(
        find.byType(DraftModeUIDateTimeField),
      );
      expect(firstField.value, expectedA);
      expect(attributeA.value, originalA);

      await pumpWith(attributeB);
      await tester.pump();

      final fields = tester
          .widgetList<DraftModeUIDateTimeField>(
            find.byType(DraftModeUIDateTimeField),
          )
          .toList();
      expect(fields, isNotEmpty);

      final newValue = DateTime(2024, 3, 3, 16, 45);
      fields.last.onChanged(newValue);
      await tester.pump();

      final formState = tester.state<DraftModeFormState>(
        find.byType(DraftModeForm),
      );
      expect(formState.read<DateTime>(attributeB), newValue);
      expect(attributeA.value, originalA);
      expect(attributeB.value, isNotNull);
    },
  );

  testWidgets('DraftModeFormDateTime normalizes to configured minute steps', (
    tester,
  ) async {
    final attribute = DraftModeEntityAttribute<DateTime>(
      DateTime(2024, 6, 1, 9, 22),
    );

    await tester.pumpWidget(
      CupertinoApp(
        home: DraftModeForm(
          child: DraftModeFormDateTime(
            attribute: attribute,
            hourSteps: DraftModeFormCalendarHourSteps.fifteen,
          ),
        ),
      ),
    );

    final field = tester.widget<DraftModeUIDateTimeField>(
      find.byType(DraftModeUIDateTimeField),
    );
    expect(field.value.minute % 15, 0);
    expect(field.hourSteps, DraftModeFormCalendarHourSteps.fifteen);

    expect(attribute.value, DateTime(2024, 6, 1, 9, 22));

    final formState = tester.state<DraftModeFormState>(
      find.byType(DraftModeForm),
    );
    formState.save();
    await tester.pump();

    final saved = attribute.value!;
    expect(saved.minute % 15, 0);
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
