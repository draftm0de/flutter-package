# Form Module

This folder contains Draftmode's adaptive form widgets. They wrap Flutter's
built-in primitives so entity attributes, validators, and localization helpers
stay in sync across iOS and Material surfaces.

Key files:

- `form.dart` - extends `FormState` with draft tracking so widgets can read
  unsaved changes via `DraftModeFormState.read` and validate individual
  attributes.
- `field.dart` - text entry control with optional eye toggle, automatic
  attribute syncing, and support for validator-aware affordances. When an
  attached attribute registers `vMaxLen`, the field clamps `CupertinoTextField`
  input via the validator's payload so UI limits stay in sync with backend
  rules.
- `drop_down.dart` - platform-aware selection field that navigates to a modal
  list using `DraftModePage` scaffolding. Accepts a plain `List` of
  `DraftModeEntityInterface` items so apps can source options from existing
  collections without wrapping them in `DraftModeEntityCollection` first.
- `list.dart` - scrollable list builder that renders `DraftModeEntityInterface`
  implementations with `DraftModeFormListItemWidget` subclasses, optional
  selection handlers, and an `onReload` callback that enables pull-to-refresh
  flows while keeping paddings consistent across platforms. Accepts a
  customizable `emptyPlaceholder` widget for empty states so call sites can
  render richer guidance than a plain string.
- `switch.dart` - boolean toggle wired into the draft map and validation flow.
- `button.dart` / `button_text.dart` - submit buttons that validate associated
  forms before invoking async handlers.
- `date_time.dart` - slim single-attribute picker that wraps the inline iOS
  calendar and time controls without range or duration features. The widget
  hooks a `DraftModeEntityAttribute.addValueMapper` to normalize timestamps (for
  example round to five-minute increments) so any caller that updates the
  attribute or the form state sees consistent values. Attributes remain
  untouched until `FormState.save` runs so flows can distinguish between
  persisted values and draft edits. Configure the minute
  granularity via `hourSteps` using `DraftModeFormCalendarHourSteps` when flows
  require something other than the default five-minute interval.
- `calendar.dart` - couples two date/time pickers for start/end flows. The
  widget seeds missing start values, forwards change handlers for each side,
  and keeps both pickers aligned with the shared `mode` and `hourSteps`
  configuration.
- `interface.dart` - shared form interfaces and enums, including the date-time
  picker mode types (`DraftModeFormCalendar*`) that expose the available
  segments.

Inside the module prefer relative imports so dependencies remain explicit (for
example `import 'button.dart'` instead of using the umbrella
`package:draftmode/form.dart`). Widgets should register with
`DraftModeFormState` so they participate in per-attribute validation and draft
reads.

Refer to the top-level [package README](../../README.md) for setup details.
