# Storage Module

This directory hosts persistence backends that plug into `DraftModeStorage`:

- `interface.dart` defines the shared storage contract consumed by repositories.
- `shared.dart` stores JSON payloads using `SharedPreferences` for non-sensitive data.
- `secure.dart` wraps `FlutterSecureStorage` for credentials or other secrets.

Concrete repositories in `lib/entity/repository.dart` depend on these adapters. Inject the appropriate implementation for your entity type based on its security and portability requirements.
