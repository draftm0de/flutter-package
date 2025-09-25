# Draftmode Flutter Wrappers

Draftmode bundles the form widgets, entity abstractions, and storage adapters we
reach for in every app so teams can assemble native experiences faster. The
package focuses on opinionated defaults that stay flexible enough to integrate
with existing projects, from validation and draft handling to secure storage.

## Highlights
- Ready-to-use Cupertino form elements with validation and draft state support.
- Shared entity contracts that insulate domain logic from UI concerns.
- Pluggable storage backends (shared preferences or secure keychain) behind a
  single interface.
- Built-in localization strings for English (`en`) and German (`de`).

## Module Map
- [Entity](lib/entity/README.md): attribute interfaces, collections, repositories,
  validators.
- [Form](lib/form/interface.dart): form state contract consumed by the widget
  layer (`lib/form/*`).
- [Storage](lib/storage/README.md): persistence contracts plus shared/secure
  implementations.
- [Utils](lib/utils/README.md): date/time formatters, tolerant parsers, and
  lightweight serialization helpers.

Each module exposes its public API through an `interface.dart` file, keeping the
pieces composable without circular imports.

## Getting Started
Add Draftmode localization delegates where you build your root app widget:

```
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:draftmode/localizations.dart';

@override
Widget build(BuildContext context) {
  return PlatformProvider(
    builder: (context) => PlatformApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        DraftModeLocalizations.delegate,
        AppLocalizations.delegate,
      ],
    ),
  );
}
```

From there wire up the pieces you need:
- use `DraftModeForm` and the widgets under `lib/form/` to render inputs,
- model state with `DraftModeEntityAttribute` and the helpers in
  `lib/entity/`,
- persist data through `DraftModeStorageShared` or `DraftModeStorageSecure`.
