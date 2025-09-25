import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of DraftModeLocalizations
/// returned by `DraftModeLocalizations.of(context)`.
///
/// Applications need to include `DraftModeLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: DraftModeLocalizations.localizationsDelegates,
///   supportedLocales: DraftModeLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the DraftModeLocalizations.supportedLocales
/// property.
abstract class DraftModeLocalizations {
  DraftModeLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static DraftModeLocalizations? of(BuildContext context) {
    return Localizations.of<DraftModeLocalizations>(
      context,
      DraftModeLocalizations,
    );
  }

  static const LocalizationsDelegate<DraftModeLocalizations> delegate =
      _DraftModeLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @navigationBtnSave.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get navigationBtnSave;

  /// No description provided for @navigationBtnBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get navigationBtnBack;

  /// No description provided for @navigationBtnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get navigationBtnCancel;

  /// No description provided for @dialogBtnConfirm.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dialogBtnConfirm;

  /// No description provided for @dialogBtnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogBtnCancel;

  /// No description provided for @calendarStart.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get calendarStart;

  /// No description provided for @calendarEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get calendarEnd;

  /// No description provided for @calendarDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get calendarDuration;

  /// No description provided for @calenderEndBeforeFailure.
  ///
  /// In en, this message translates to:
  /// **'{endLabel} cannot be lower than {startLabel}.'**
  String calenderEndBeforeFailure({
    required Object startLabel,
    required Object endLabel,
  });

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'Eingabe erforderlich'**
  String get validationRequired;

  /// No description provided for @validationLessThan.
  ///
  /// In en, this message translates to:
  /// **'Muss kleiner sein als {expected}'**
  String validationLessThan({required Object expected});

  /// No description provided for @validationGreaterThan.
  ///
  /// In en, this message translates to:
  /// **'Muss größer sein als {expected}'**
  String validationGreaterThan({required Object expected});

  /// No description provided for @validationFormat.
  ///
  /// In en, this message translates to:
  /// **'Ungültiges Format ({expected})'**
  String validationFormat({required Object expected});
}

class _DraftModeLocalizationsDelegate
    extends LocalizationsDelegate<DraftModeLocalizations> {
  const _DraftModeLocalizationsDelegate();

  @override
  Future<DraftModeLocalizations> load(Locale locale) {
    return SynchronousFuture<DraftModeLocalizations>(
      lookupDraftModeLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_DraftModeLocalizationsDelegate old) => false;
}

DraftModeLocalizations lookupDraftModeLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return DraftModeLocalizationsDe();
    case 'en':
      return DraftModeLocalizationsEn();
  }

  throw FlutterError(
    'DraftModeLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
