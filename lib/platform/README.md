# Platform Module

Helpers for platform-aware theming and localisation:

- `config.dart` – toggles forced platforms and exposes shared padding, colours,
  and text styles.
- `buttons.dart` – returns platform-appropriate icons for common actions.
- `localization.dart` – wraps `DraftModeLocalizations` with a lightweight API
  and an English fallback.

Use `PlatformConfig.mode` in tests to simulate specific platforms without
conditionally rewriting widget code.
