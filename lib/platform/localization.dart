import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// Convenience wrapper around [DraftModeLocalizations] that exposes defaults.
class PlatformLocalization {
  PlatformLocalization._(this._loc);

  final DraftModeLocalizations _loc;

  /// Returns a [PlatformLocalization] for the current [context], falling back
  /// to a manual English localisation when delegates are missing.
  static PlatformLocalization of(BuildContext context) {
    final DraftModeLocalizations loc =
        Localizations.of<DraftModeLocalizations>(
          context,
          DraftModeLocalizations,
        ) ??
        _fallback;
    return PlatformLocalization._(loc);
  }

  static final DraftModeLocalizations _fallback = _ManualFallback();

  /// Localised label for navigation back buttons.
  String get navigationBtnBack => _loc.navigationBtnBack;
}

class _ManualFallback implements DraftModeLocalizations {
  @override
  String get navigationBtnBack => 'Back';

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
