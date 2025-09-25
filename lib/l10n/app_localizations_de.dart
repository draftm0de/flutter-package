// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class DraftModeLocalizationsDe extends DraftModeLocalizations {
  DraftModeLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get navigationBtnSave => 'Fertig';

  @override
  String get navigationBtnBack => 'Zurück';

  @override
  String get navigationBtnCancel => 'Abbrechen';

  @override
  String get dialogBtnConfirm => 'OK';

  @override
  String get dialogBtnCancel => 'Abbrechen';

  @override
  String get calendarStart => 'Beginn';

  @override
  String get calendarEnd => 'Ende';

  @override
  String get calendarDuration => 'Dauer';

  @override
  String calenderEndBeforeFailure({
    required Object startLabel,
    required Object endLabel,
  }) {
    return '$endLabel kann nicht kleiner als $startLabel sein.';
  }

  @override
  String get validationRequired => 'Eingabe erforderlich';

  @override
  String validationLessThan({required Object expected}) {
    return 'Muss kleiner sein als $expected';
  }

  @override
  String validationGreaterThan({required Object expected}) {
    return 'Muss größer sein als $expected';
  }

  @override
  String validationFormat({required Object expected}) {
    return 'Ungültiges Format ($expected)';
  }
}
