import 'package:draftmode/l10n/app_localizations.dart';
import 'package:draftmode/l10n/app_localizations_de.dart';
import 'package:draftmode/l10n/app_localizations_en.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('DraftModeLocalizations', () {
    test('delegate loads German localisation', () async {
      final delegate = DraftModeLocalizations.delegate;
      final loaded = await delegate.load(const Locale('de'));

      expect(loaded, isA<DraftModeLocalizationsDe>());
      expect(loaded.navigationBtnSave, 'Fertig');
      expect(loaded.navigationBtnBack, 'Zurück');
      expect(loaded.navigationBtnCancel, 'Abbrechen');
      expect(loaded.dialogBtnConfirm, 'OK');
      expect(loaded.dialogBtnCancel, 'Abbrechen');
      expect(loaded.calendarStart, 'Beginn');
      expect(loaded.calendarEnd, 'Ende');
      expect(loaded.calendarDuration, 'Dauer');
      expect(
        loaded.calenderEndBeforeFailure(startLabel: 'Start', endLabel: 'Ende'),
        'Ende kann nicht kleiner als Start sein.',
      );
      expect(loaded.validationRequired, 'Eingabe erforderlich');
      expect(loaded.validationLessThan(expected: 3), 'Muss kleiner sein als 3');
      expect(
        loaded.validationGreaterThan(expected: 5),
        'Muss größer sein als 5',
      );
      expect(loaded.validationFormat(expected: '#'), 'Ungültiges Format (#)');
    });

    test('delegate loads English localisation', () async {
      final delegate = DraftModeLocalizations.delegate;
      final loaded = await delegate.load(const Locale('en'));

      expect(loaded, isA<DraftModeLocalizationsEn>());
      expect(loaded.navigationBtnSave, 'Ready');
      expect(loaded.navigationBtnBack, 'Back');
      expect(loaded.navigationBtnCancel, 'Cancel');
      expect(loaded.dialogBtnConfirm, 'OK');
      expect(loaded.dialogBtnCancel, 'Cancel');
      expect(loaded.calendarStart, 'Begin');
      expect(loaded.calendarEnd, 'End');
      expect(loaded.calendarDuration, 'Duration');
      expect(
        loaded.calenderEndBeforeFailure(startLabel: 'Start', endLabel: 'End'),
        'End cannot be lower than Start.',
      );
      expect(loaded.validationRequired, 'Eingabe erforderlich');
      expect(loaded.validationLessThan(expected: 3), 'Muss kleiner sein als 3');
      expect(
        loaded.validationGreaterThan(expected: 5),
        'Muss größer sein als 5',
      );
      expect(loaded.validationFormat(expected: '#'), 'Ungültiges Format (#)');
    });

    test(
      'delegate reports supported locales and throws for unsupported ones',
      () {
        final delegate = DraftModeLocalizations.delegate;
        expect(delegate.isSupported(const Locale('de')), isTrue);
        expect(delegate.isSupported(const Locale('en')), isTrue);
        expect(delegate.isSupported(const Locale('fr')), isFalse);
        expect(delegate.shouldReload(delegate), isFalse);

        expect(
          () => lookupDraftModeLocalizations(const Locale('fr')),
          throwsA(isA<FlutterError>()),
        );

        expect(DraftModeLocalizations.supportedLocales.length, 2);
        expect(DraftModeLocalizations.localizationsDelegates.length, 4);
      },
    );
  });
}
