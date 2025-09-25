# Page Module

Widgets that provide scaffolding, navigation, and loading affordances for
DraftMode screens:

- `page.dart` – `DraftModePage`, a platform-aware scaffold with top/bottom bars
  and optional save/back wiring.
- `navigation/` – shared navigation items plus top/bottom bar implementations.
- `spinner.dart` – minimal activity indicator rendered while loading.

These components are stateless; inject callbacks and stateful content from
feature layers.
