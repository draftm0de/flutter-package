import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

class PlatformLocalization {
  final DraftModeLocalizations _loc;

  PlatformLocalization._(this._loc);

  static PlatformLocalization of(BuildContext context) {
    final loc = Localizations.of<DraftModeLocalizations>(
      context,
      DraftModeLocalizations,
    ) ??
        _fallback;

    return PlatformLocalization._(loc);
  }

  static final DraftModeLocalizations _fallback = _ManualFallback();

  String get navigationBtnBack => _loc.navigationBtnBack;
}

class _ManualFallback implements DraftModeLocalizations {
  @override String get navigationBtnBack => 'xZurück';

  @override noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
