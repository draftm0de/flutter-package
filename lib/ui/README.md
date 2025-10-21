# UI Module

Reusable presentation widgets that keep layout concerns separate from form and
entity logic:

- `confirm.dart` – platform-aware confirmation dialog with localization
  fallbacks and a convenience `show` helper.
- `row.dart` – labeled form row shell that applies platform padding and label
  styling.
- `section.dart` – groups rows into platform-appropriate sections and exposes an
  inherited scope for descendants.
- `switch.dart` – adaptive boolean toggle that mirrors the native widget.
- `error_text.dart` – consistent error text styling and spacing for validation
  messages.
- `error_dialog.dart` – one-tap Cupertino alert for surfacing blocking errors
  from form flows.
- `diagnostics.dart` – developer-focused logging surface so other modules avoid
  emitting output directly.
- `date_time.dart` – date/time field layout with platform toggles consumed by
  form components. Supports configurable minute steps via
  `DraftModeFormCalendarHourSteps` so time pickers align with business
  constraints.
- `date_time/week_day.dart` – swipeable week-at-a-glance day picker used when
  forms need a single-day selection surface. Keeps the selected weekday in
  view while paging through weeks and highlights the active day with the
  platform red accent.
- `date_time/time_line.dart` – decorative timeline gutter that mirrors the
  inset grouped lists on iOS so contextual date content has a native anchor.
- `button.dart` – reusable platform-aware button used by higher-level widgets
  such as form actions.

All widgets are stateless; business logic should live in the calling layers.
