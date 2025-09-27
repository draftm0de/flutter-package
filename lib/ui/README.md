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
- `text_error.dart` – consistent error text styling and spacing for validation
  messages.
- `diagnostics.dart` – developer-focused logging surface so other modules avoid
  emitting output directly.
- `date_time.dart` – date/time field layout with platform toggles consumed by
  form components.
- `button.dart` – reusable platform-aware button used by higher-level widgets
  such as form actions.

All widgets are stateless; business logic should live in the calling layers.
