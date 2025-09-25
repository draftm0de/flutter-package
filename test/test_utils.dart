import 'package:flutter/widgets.dart';
import '../lib/l10n/app_localizations.dart';

Widget wrapWithLoc(Widget child) {
  return Localizations(
    locale: const Locale('en'),
    delegates: const [
      DefaultWidgetsLocalizations.delegate,
      DraftModeLocalizations.delegate,
    ],
    child: Directionality(textDirection: TextDirection.ltr, child: child),
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
