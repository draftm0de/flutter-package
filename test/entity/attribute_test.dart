import 'package:flutter_test/flutter_test.dart';
import 'package:draftmode/entity/attribute.dart';
import 'package:draftmode/types.dart';

import '../test_utils.dart';

void main() {
  group('DraftModeEntityAttribute.validate', () {
    testWidgets('uses primary validator and stops on first error', (tester) async {
      await tester.pumpWidget(wrapWithLoc(const SimpleContext()));
      await tester.pump();
      final context = SimpleContext.lastContext!;

      final attribute = DraftModeEntityAttribute<String>(
        validator: (ctx, form, value) => value == 'invalid' ? 'primary-error' : null,
      );
      attribute.addValidator((ctx, form, value) => 'secondary-error');

      final error = attribute.validate(context, null, 'invalid');

      expect(error, 'primary-error');
      expect(attribute.error, 'primary-error');
    });

    testWidgets('falls back to added validators when primary passes', (tester) async {
      await tester.pumpWidget(wrapWithLoc(const SimpleContext()));
      await tester.pump();
      final context = SimpleContext.lastContext!;

      final attribute = DraftModeEntityAttribute<String>(
        validator: (ctx, form, value) => null,
      );

      attribute
        ..addValidator((ctx, form, value) => value == null ? 'null-error' : null)
        ..addValidator((ctx, form, value) => value.isEmpty ? 'empty-error' : null);

      expect(attribute.validate(context, null, null), 'null-error');
      expect(attribute.error, 'null-error');

      expect(attribute.validate(context, null, ''), 'empty-error');
      expect(attribute.error, 'empty-error');
    });

    testWidgets('returns null and clears previous error when all validators pass', (tester) async {
      await tester.pumpWidget(wrapWithLoc(const SimpleContext()));
      await tester.pump();
      final context = SimpleContext.lastContext!;

      final attribute = DraftModeEntityAttribute<String>(
        validators: <DraftModeEntityValidator>[
          (ctx, form, value) => null,
        ],
      )..error = 'stale';

      final result = attribute.validate(context, null, 'ok');

      expect(result, isNull);
      expect(attribute.error, isNull);
    });
  });
}
