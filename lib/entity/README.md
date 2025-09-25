# Entity Module

Utilities in this folder power Draftmode's entity abstraction layer:

- `interface.dart` declares the shared attribute/validator contracts consumed by both form and entity layers.
- `attribute.dart` defines `DraftModeEntityAttribute`, which stores values and orchestrates validation.
- `collection.dart` contains helpers for grouping entity types and mapping them to runtime implementations.
- `repository.dart` provides persistence helpers backed by the secure and shared storage adapters.
- `validator.dart` exposes reusable validation functions shared across forms and entities.

Refer back to the top-level [package README](../../README.md) for getting-started steps and high-level concepts. Update both files together to keep the documentation in sync.
