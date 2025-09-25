import 'package:draftmode/entity/validator.dart';
import 'package:draftmode/types.dart';
import 'package:draftmode/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils.dart';

class _FakeAttribute<T> implements DraftModeEntityAttributeI<T> {
  _FakeAttribute({this.debugName});

  @override
  final String? debugName;

  @override
  T? value;

  @override
  String? error;

  @override
  void addValidator(DraftModeEntityValidator validator) {
    // Not needed for tests.
    throw UnimplementedError();
  }

  @override
  String? validate(BuildContext context, DraftModeFormStateI? form, T? v) {
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
  void updateProperty<T>(DraftModeEntityAttributeI attribute, T? value) {
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
}
