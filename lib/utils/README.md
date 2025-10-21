# Utils Module

Utility helpers reused across the package:

- `formatter.dart` extends `DateFormat` with padded date patterns, start/end of
  day helpers, and duration helpers, and exposes tolerant coercion utilities
  such as
  `DraftModeFormatter.parseInt`, `DraftModeFormatter.parseBool`,
  `DraftModeFormatter.parseHtmlToPlainText` for quick-and-dirty HTML cleanup,
  and `DraftModeFormatter().decodedQueryParameters` for typed querystring
  parsing.
- `serializer.dart` provides `DraftModeSerializer.decodeObject` to safely turn
  JSON object strings into strongly typed models.
- `logger.dart` wraps Flutter's `debugPrint` so call sites can opt-in to verbose
  logging without sprinkling conditional checks throughout the codebase.

Each helper is intentionally small and fully covered by tests in
`test/utils/`.
