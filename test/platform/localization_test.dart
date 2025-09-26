import 'package:draftmode/l10n/app_localizations.dart';
import 'package:draftmode/l10n/app_localizations_en.dart';
import 'package:draftmode/platform/localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _Delegate extends LocalizationsDelegate<DraftModeLocalizations> {
  const _Delegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<DraftModeLocalizations> load(Locale locale) async {
    return DraftModeLocalizationsEn(locale.languageCode);
  }

  @override
  bool shouldReload(LocalizationsDelegate<DraftModeLocalizations> old) => false;
}

void main() {
  testWidgets('falls back to manual localisation when none provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('en'),
        delegates: const [GlobalWidgetsLocalizations.delegate],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(),
        ),
      ),
    );

    final loc = PlatformLocalization.of(tester.element(find.byType(SizedBox)));
    expect(loc.navigationBtnBack, 'Back');
  });

  testWidgets('uses provided localisation delegate when available', (
    tester,
  ) async {
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('en'),
        delegates: const [GlobalWidgetsLocalizations.delegate, _Delegate()],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(),
        ),
      ),
    );

    final loc = PlatformLocalization.of(tester.element(find.byType(SizedBox)));
    expect(loc.navigationBtnBack, 'Back');
  });

  test('fallback propagates noSuchMethod for missing getters', () {
    final fallback = PlatformLocalization.debugFallback;

    expect(() => fallback.dialogBtnConfirm, throwsNoSuchMethodError);
  });
}
