import 'package:draftmode/entity/interface.dart';
import 'package:draftmode/entity/validator.dart';
import 'package:draftmode/form/interface.dart';
import 'package:draftmode/l10n/app_localizations.dart';
import 'package:draftmode/utils/formatter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../test_utils.dart';

class _FakeAttribute<T> implements DraftModeEntityAttributeI<T> {
  _FakeAttribute({this.debugName});

  @override
  final String? debugName;

  @override
  T? value;

  @override
  String? error;

  final List<T Function(T value)> _mappers = <T Function(T value)>[];

  @override
  void addValidator(DraftModeEntityValidator validator) {
    // Not needed for tests.
    throw UnimplementedError();
  }

  @override
  void addValueMapper(T Function(T value) mapper) {
    _mappers.add(mapper);
  }

  @override
  T? mapValue(T? v) {
    if (v == null || _mappers.isEmpty) {
      return v;
    }
    var result = v;
    for (final mapper in _mappers) {
      result = mapper(result);
    }
    return result;
  }

  @override
  String? validate(BuildContext context, DraftModeFormContext? form, T? v) {
    throw UnimplementedError();
  }
}

class _FakeFormState implements DraftModeFormStateI {
  _FakeFormState(this._values);

  final Map<dynamic, dynamic> _values;

  @override
  void registerProperty(
    DraftModeEntityAttributeI attribute, {
    String? debugName,
  }) {
    throw UnimplementedError();
  }

  @override
  void updateProperty<T>(DraftModeEntityAttributeI<T> attribute, T? value) {
    throw UnimplementedError();
  }

  @override
  void registerField(
    DraftModeEntityAttributeI attribute,
    GlobalKey<FormFieldState> key,
  ) {
    throw UnimplementedError();
  }

  @override
  void unregisterField(
    DraftModeEntityAttributeI attribute,
    GlobalKey<FormFieldState> key,
  ) {
    throw UnimplementedError();
  }

  @override
  void validateAttribute(DraftModeEntityAttributeI attribute) {
    throw UnimplementedError();
  }

  @override
  V? read<V>(dynamic attribute) {
    return _values[attribute] as V?;
  }

  @override
  void beginAttributeValidation(DraftModeEntityAttributeI attribute) {}

  @override
  void endAttributeValidation(DraftModeEntityAttributeI attribute) {}

  @override
  void registerDependency(DraftModeEntityAttributeI dependency) {}
}

void main() {
  group('vRequired()', () {
    testWidgets(
      'returns localized error for null and empty; null for valid values',
      (tester) async {
        await tester.pumpWidget(wrapWithLoc(const SimpleContext()));
        await tester.pump();
        final context = SimpleContext.lastContext!;
        final loc = DraftModeLocalizations.of(context)!;
        final validator = vRequired();

        final errNull = validator(context, null, null);
        final errEmpty = validator(context, null, '');
        final okString = validator(context, null, 'hello');
        final okNonString = validator(context, null, 0);

        expect(errNull, loc.validationRequired);
        expect(errEmpty, loc.validationRequired);
        expect(okString, isNull);
        expect(okNonString, isNull);
      },
    );
  });

  group('vRequiredOn()', () {
    testWidgets('returns error when linked attribute requires value', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithLoc(const SimpleContext()));
      await tester.pump();
      final context = SimpleContext.lastContext!;
      final loc = DraftModeLocalizations.of(context)!;

      final compare = _FakeAttribute<bool>(debugName: 'toggle');
      final form = _FakeFormState(<dynamic, dynamic>{compare: true});
      final validator = vRequiredOn(compare);

      final error = validator(context, form, null);

      expect(error, loc.validationRequired);
    });

    testWidgets('returns null when linked attribute does not require value', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithLoc(const SimpleContext()));
      await tester.pump();
      final context = SimpleContext.lastContext!;

      final compare = _FakeAttribute<bool>(debugName: 'toggle');
      final form = _FakeFormState(<dynamic, dynamic>{compare: false});
      final validator = vRequiredOn(compare);

      final result = validator(context, form, 'value');

      expect(result, isNull);
    });
  });

  group('vGreaterThan()', () {
    testWidgets('returns error when value precedes compared attribute', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithLoc(const SimpleContext()));
      await tester.pump();
      final context = SimpleContext.lastContext!;
      final loc = DraftModeLocalizations.of(context)!;

      final compare = _FakeAttribute<DateTime>(debugName: 'startDate');
      final targetDate = DateTime(2024, 1, 1);
      final form = _FakeFormState(<dynamic, dynamic>{compare: targetDate});
      final validator = vGreaterThan(compare);

      final localeTag = Localizations.localeOf(context).toLanguageTag();
      await initializeDateFormatting(localeTag);

      final error = validator(
        context,
        form,
        targetDate.subtract(const Duration(days: 1)),
      );
      final expected =
          '${DraftModeDateTime.yMMdd(localeTag).format(targetDate)} ${DateFormat.Hm(localeTag).format(targetDate)}';

      expect(error, loc.validationGreaterThan(expected: expected));
    });

    testWidgets('returns error when value equals compared attribute', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithLoc(const SimpleContext()));
      await tester.pump();
      final context = SimpleContext.lastContext!;
      final loc = DraftModeLocalizations.of(context)!;

      final compare = _FakeAttribute<DateTime>(debugName: 'startDate');
      final targetDate = DateTime(2024, 3, 10);
      final form = _FakeFormState(<dynamic, dynamic>{compare: targetDate});
      final validator = vGreaterThan(compare);

      final localeTag = Localizations.localeOf(context).toLanguageTag();
      await initializeDateFormatting(localeTag);

      final sameDay = validator(context, form, targetDate);
      final expected =
          '${DraftModeDateTime.yMMdd(localeTag).format(targetDate)} ${DateFormat.Hm(localeTag).format(targetDate)}';

      expect(sameDay, loc.validationGreaterThan(expected: expected));
    });

    testWidgets('returns null when value exceeds compared attribute', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithLoc(const SimpleContext()));
      await tester.pump();
      final context = SimpleContext.lastContext!;

      final compare = _FakeAttribute<DateTime>(debugName: 'startDate');
      final targetDate = DateTime(2024, 3, 10);
      final form = _FakeFormState(<dynamic, dynamic>{compare: targetDate});
      final validator = vGreaterThan(compare);

      final laterDay = validator(
        context,
        form,
        targetDate.add(const Duration(days: 2)),
      );

      expect(laterDay, isNull);
    });

    testWidgets('returns null when compared attribute is missing', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithLoc(const SimpleContext()));
      await tester.pump();
      final context = SimpleContext.lastContext!;

      final compare = _FakeAttribute<DateTime>(debugName: 'startDate');
      final form = _FakeFormState(const <dynamic, dynamic>{});
      final validator = vGreaterThan(compare);

      final result = validator(context, form, DateTime(2024, 5, 1));

      expect(result, isNull);
    });

    testWidgets('returns error when integer value below comparison attribute', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithLoc(const SimpleContext()));
      await tester.pump();
      final context = SimpleContext.lastContext!;
      final loc = DraftModeLocalizations.of(context)!;

      final compare = _FakeAttribute<int>(debugName: 'minValue');
      final form = _FakeFormState(<dynamic, dynamic>{compare: 10});
      final validator = vGreaterThan(compare);

      final error = validator(context, form, 9);
      final equal = validator(context, form, 10);

      expect(error, loc.validationGreaterThan(expected: 10));
      expect(equal, loc.validationGreaterThan(expected: 10));
    });

    testWidgets('returns null when integer exceeds comparison attribute', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithLoc(const SimpleContext()));
      await tester.pump();
      final context = SimpleContext.lastContext!;

      final compare = _FakeAttribute<int>(debugName: 'minValue');
      final form = _FakeFormState(<dynamic, dynamic>{compare: 10});
      final validator = vGreaterThan(compare);

      final result = validator(context, form, 11);

      expect(result, isNull);
    });

    testWidgets('supports literal integer comparisons when form absent', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithLoc(const SimpleContext()));
      await tester.pump();
      final context = SimpleContext.lastContext!;
      final loc = DraftModeLocalizations.of(context)!;

      final validator = vGreaterThan(25);

      final error = validator(context, null, 25);
      final ok = validator(context, null, 42);

      expect(error, loc.validationGreaterThan(expected: 25));
      expect(ok, isNull);
    });
  });
}
