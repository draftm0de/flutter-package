# Platform Module

Helpers for platform-aware theming and localisation:

- `config.dart` – toggles the effective target platform (useful in tests).
- `styles.dart` – centralises padding, typography, and colours derived from the
  active platform. Button-specific roles (`DraftModeStyleButtonSize` and
  `DraftModeStyleButtonColor`) plus shared icon sizing helpers live here so UI
  layers can stay consistent across modules.
- `buttons.dart` – returns platform-appropriate icons for common actions,
  mirroring the latest platform glyph choices (for example
  `CupertinoIcons.multiply_circle` for cancel, `CupertinoIcons.play_circle` for
  start, and `CupertinoIcons.square_pencil` for edit).
- `localization.dart` – wraps `DraftModeLocalizations` with a lightweight API
  and an English fallback.

Use `PlatformConfig.mode` in tests to simulate specific platforms without
conditionally rewriting widget code.
