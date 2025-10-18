# Entity Module

Utilities in this folder power Draftmode's entity abstraction layer:

- `interface.dart` declares the shared attribute/validator contracts consumed
  by both form and entity layers, including the storage list interface used to
  deserialize API payloads into strongly typed collections.
- `attribute.dart` defines `DraftModeEntityAttribute`, which stores values,
  orchestrates validation, exposes `validatorByType` / `validatorsByType`, and
  supports `addValueMapper` so callers can register normalization functions
  that run whenever the attribute changes.
- `collection.dart` contains helpers for grouping entity types and mapping them to runtime implementations.
- `repository.dart` provides persistence helpers backed by the secure and shared storage adapters.
- `validator.dart` exposes reusable validation functions shared across forms
  and entities, such as:
  - `vRequired` for null/empty checks.
  - `vMaxLen` for enforcing string length constraints (also advertises the
    chosen length via `validatorByType`).
  - `vRequiredOn` to conditionally require a value based on another attribute.
  - `vGreaterThan` to assert a `DateTime` or `int` does not fall below a
    comparison attribute or literal.

Refer back to the top-level [package README](../../README.md) for getting-started steps and high-level concepts. Update both files together to keep the documentation in sync.
