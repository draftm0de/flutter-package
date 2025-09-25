import 'package:draftmode/l10n/app_localizations.dart';
import 'package:draftmode/l10n/app_localizations_en.dart';
import 'package:flutter/widgets.dart';

class _TestDraftModeLocalizationsDelegate
    extends LocalizationsDelegate<DraftModeLocalizations> {
  const _TestDraftModeLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<DraftModeLocalizations> load(Locale locale) async {
    return DraftModeLocalizationsEn(locale.languageCode);
  }

  @override
  bool shouldReload(LocalizationsDelegate<DraftModeLocalizations> old) => false;
}

Widget wrapWithLoc(Widget child) {
  return Localizations(
    locale: const Locale('en'),
    delegates: const [
      DefaultWidgetsLocalizations.delegate,
      _TestDraftModeLocalizationsDelegate(),
    ],
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    ),
  );
}

class SimpleContext extends StatelessWidget {
  const SimpleContext({super.key});
  static BuildContext? lastContext;

  @override
  Widget build(BuildContext context) {
    lastContext = context;
    return const SizedBox.shrink();
  }
}
