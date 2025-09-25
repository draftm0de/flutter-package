# Agent Guide

This file captures conventions and guardrails for automated contributors.

## Workflow Expectations
- Run `dart format --output=write .` before staging files.
- Ensure `dart analyze` passes with zero warnings.
- Execute the full test suite (`flutter test`) after changes. The pre-commit
  hook already runs format + tests; confirm it stays executable (`chmod +x
  .git/hooks/pre-commit`).
- Avoid committing artefacts such as `coverage/` outputs.

## Code Organization
- Shared interfaces live in `interface.dart` under each module (entity, form,
  etc.).
- Styling constants reside in `lib/platform/styles.dart`; platform detection is
  handled by `PlatformConfig`.
- Module READMEs document public APIs—update them when functionality moves.

## Testing Patterns
- Unit tests are colocated under `test/<module>/`. Prefer targeted files over
  monolithic suites.
- When simulating platforms, use `PlatformConfig.mode` to force iOS/Android.
- For widget tests, wrap content in `CupertinoApp` or `MaterialApp` with the
  correct localization delegates.

## Naming & Docs
- Keep inline documentation concise and focused on intent, especially for
  public APIs.
- Use `PlatformStyles` for shared padding/typography rather than hard-coded
  values.

Update this guide whenever new conventions emerge so automated agents stay in
sync.
