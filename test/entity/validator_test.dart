import 'package:flutter_test/flutter_test.dart';
import '../test_utils.dart';
// ⬇️ Adjust these to your actual package paths
import '../../lib/l10n/app_localizations.dart';
import '../../lib/entity/validator.dart';

void main() {
  group('vRequired()', () {
    testWidgets('returns localized error for null and empty; null for valid values', (tester) async {
      String? errNull;
      String? errEmpty;
      String? okString;
      String? okNonString;

      await tester.pumpWidget(wrapWithLoc(const SimpleContext()));

      // Pull the context the probe saved for us.
      final context = SimpleContext.lastContext!;
      final loc = DraftModeLocalizations.of(context)!;
      final validator = vRequired();

      errNull     = validator(context, null, null);
      errEmpty    = validator(context, null, '');
      okString    = validator(context, null, 'hello');
      okNonString = validator(context, null, 0); // any non-null non-empty value

      expect(errNull,  loc.validationRequired);
      expect(errEmpty, loc.validationRequired);
      expect(okString, isNull);
      expect(okNonString, isNull);
    });
  });
}

