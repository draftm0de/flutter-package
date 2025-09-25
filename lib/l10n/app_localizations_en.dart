// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class DraftModeLocalizationsEn extends DraftModeLocalizations {
  DraftModeLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navigationBtnSave => 'Ready';

  @override
  String get navigationBtnBack => 'Back';

  @override
  String get navigationBtnCancel => 'Cancel';

  @override
  String get dialogBtnConfirm => 'OK';

  @override
  String get dialogBtnCancel => 'Cancel';

  @override
  String get calendarStart => 'Begin';

  @override
  String get calendarEnd => 'End';

  @override
  String get calendarDuration => 'Duration';

  @override
  String calenderEndBeforeFailure({
    required Object startLabel,
    required Object endLabel,
  }) {
    return '$endLabel cannot be lower than $startLabel.';
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
