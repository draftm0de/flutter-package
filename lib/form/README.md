# Form Module

This folder contains Draftmode's adaptive form widgets. They wrap Flutter's
built-in primitives so entity attributes, validators, and localization helpers
stay in sync across iOS and Material surfaces.

Key files:

- `form.dart` - extends `FormState` with draft tracking so widgets can read
  unsaved changes via `DraftModeFormState.read` and validate individual
  attributes.
- `field.dart` - text entry control with optional eye toggle and automatic
  attribute syncing.
- `drop_down.dart` - platform-aware selection field that navigates to a modal
  list using `DraftModePage` scaffolding.
- `switch.dart` - boolean toggle wired into the draft map and validation flow.
- `button.dart` / `button_text.dart` - submit buttons that validate associated
  forms before invoking async handlers.
- `date_time.dart` - slim single-attribute picker that wraps the inline iOS
  calendar/time controls without range or duration features. `onChanged` and
  `onSaved` both keep the bound attribute and DraftModeForm draft map in sync.
- `interface.dart` - shared form interfaces and enums, including the date-time
  picker mode types (`DraftModeFormCalendar*`) that expose the available
  segments.

Inside the module prefer relative imports so dependencies remain explicit (for
example `import 'button.dart'` instead of using the umbrella
`package:draftmode/form.dart`). Widgets should register with
`DraftModeFormState` so they participate in per-attribute validation and draft
reads.

Refer to the top-level [package README](../../README.md) for setup details.
