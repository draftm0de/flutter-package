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
  rules. Keyboard configuration flows from the field's generic type or any
  explicit `keyboardType` override so call sites stay in control while still
  getting numeric affordances by default. Callers
  can also provide a `DraftModerFormFormatterInterface` to opt into localized
  number formatting (grouped thousands, decimal separators, signed toggles) or
  inject custom formatters. Input is coerced back into `int`/`double` values on
  every change so form consumers never have to strip formatting themselves.
- `formatter/` - numeric input formatters that localize grouping, enforce digit
  counts, surface signed variants, and expose predictable keyboard
  recommendations to the text field.
- `drop_down.dart` - platform-aware selection field that navigates to a modal
  list using `DraftModePage` scaffolding. Supply a
  `DraftModeFormListItemBuilder` so both the field and the pushed selection list
  render with the same `DraftModeFormListItemWidget` subclass, guaranteeing
  consistent visuals and selection hints. Accepts a plain `List` of
  `DraftModeEntityInterface` items so apps can source options from existing
  collections without wrapping them in `DraftModeEntityCollection` first. The
  modal now relies on the default icon-only back affordance from
  `DraftModePage`, keeping selection flows visually consistent with the rest of
  the package.
- `list.dart` - scrollable list builder that renders
  `DraftModeEntityInterface` implementations with `DraftModeFormListItemWidget`
  subclasses, optional selection handlers, and an `onReload` callback that
  enables pull-to-refresh flows while keeping paddings consistent across
  platforms. The required `renderItem` callback returns a
  `DraftModeFormListItemWidget`, allowing the list to add the platform
  checkmark indicator automatically when the item is selected. Accepts a
  customizable `emptyPlaceholder` widget for empty states so call sites can
  render richer guidance than a plain string.
- `switch.dart` - boolean toggle wired into the draft map and validation flow.
- `button.dart` / `button_text.dart` / `button_submit.dart` - submit buttons
  that validate associated forms before invoking async handlers. The submit
  wrapper stretches to the container width and applies the primary color
  palette by default.
- `date_time.dart` - slim single-attribute picker that wraps the inline iOS
  calendar and time controls without range or duration features. The widget
  hooks a `DraftModeEntityAttribute.addValueMapper` to normalize timestamps (for
  example round to five-minute increments) so any caller that updates the
  attribute or the form state sees consistent values. It tracks the latest
  validated selection so `FormState.save` persists either the untouched initial
  value or the most recent change that cleared validation, preventing partially
  edited timestamps from overwriting the attribute. Configure the minute
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
