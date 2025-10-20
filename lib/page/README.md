# Page Module

Widgets that provide scaffolding, navigation, and loading affordances for
DraftMode screens:

- `page.dart` – `DraftModePage`, a platform-aware scaffold with top/bottom bars
  and optional save/back wiring. The default back affordance now renders as an
  icon-only control unless `topLeadingText` is supplied, and the automatic save
  action relies on `PlatformButtons.save`, keeping the trailing button icon-only
  by default. When no bottom navigation is present the body is wrapped in a
  `SafeArea` (with `top` disabled) so scroll views can extend under the
  navigation bar without double padding while still respecting bottom insets.
- `navigation/` – shared navigation items plus top/bottom bar implementations.
- `spinner.dart` – minimal activity indicator rendered while loading.

These components are stateless; inject callbacks and stateful content from
feature layers.
