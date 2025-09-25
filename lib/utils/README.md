# Utils Module

Utility helpers reused across the package:

- `formatter.dart` extends `DateFormat` with padded date patterns and duration
  helpers, and exposes `DraftModeFormatter.parseInt` for tolerant integer parsing.
- `serializer.dart` provides `DraftModeSerializer.decodeObject` to safely turn
  JSON object strings into strongly typed models.

Each helper is intentionally small and fully covered by tests in
`test/utils/`.
