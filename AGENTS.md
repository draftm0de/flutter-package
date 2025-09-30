# Agent Guide

This file captures conventions and guardrails for automated contributors.

## Workflow Expectations
- Agents may modify any source file within this package directory and its
  subfolders without requesting additional approval. Running tooling such as
  `dart format`, `dart analyze`, and `flutter test` is always permitted when it
  helps complete a task.
- Run `dart format --output=write .` only after `dart analyze` and the test
  suites succeed. After formatting, rerun `flutter test` to confirm nothing
  regressed.
- Running any `dart format` command is pre-approved; feel free to use more
  granular invocations when useful.
- Ensure `dart analyze` passes with zero warnings.
- Flutter SDK tooling (e.g. `flutter test`, `flutter analyze`, `flutter format`)
  is pre-approved—run whatever commands are needed to validate changes.
- Execute the full test suite (`flutter test`) after changes. The pre-commit
  hook already runs format + tests; confirm it stays executable (`chmod +x
  .git/hooks/pre-commit`).
- Avoid committing artefacts such as `coverage/` outputs.
- Never commit directly to the `main` branch; if a session starts on `main`,
  create a feature branch automatically before staging changes. When in doubt,
  prefer creating a new branch before making edits.

## Code Organization
- Shared interfaces live in `interface.dart` under each module (entity, form,
  etc.).
- Styling constants reside in `lib/platform/styles.dart`; platform detection is
  handled by `PlatformConfig`.
- Module READMEs document public APIs - update them when functionality moves.
- Within modules prefer relative imports so dependencies remain explicit (avoid
  `package:draftmode/...` for internals), while tests should import via the
  public `package:draftmode/...` surface to mirror consumer usage.
- Form layer must not emit console output directly; surface user-facing
  messaging through components in `lib/ui` instead.
- UI modules receive arguments and own platform-specific visualization for iOS
  and Android.

## Testing Patterns
- Unit tests are colocated under `test/<module>/`. Prefer targeted files over
  monolithic suites.
- When simulating platforms, use `PlatformConfig.mode` to force iOS/Android.
- For widget tests, wrap content in `CupertinoApp` or `MaterialApp` with the
  correct localization delegates.
- Strive for 100% code coverage; it is an aspirational target even if not a
  hard requirement.
- When renaming or adding small files, regenerate coverage reports so cached
  artifacts do not point at stale paths before committing.

## Naming & Docs
- Keep inline documentation concise and focused on intent, especially for
  public APIs.
- Use `PlatformStyles` for shared padding/typography rather than hard-coded
  values.
- Prefer the canonical `DraftModeFormCalendar*` names in the form module; the
  legacy `Calender` identifiers are temporary aliases for backwards
  compatibility.

# User interactions
- The user is allowed to modify source code, which can influent the tests. 
- In case of recognizing modifications ask before reverting to match the current cached sources.

Update this guide whenever new conventions emerge so automated agents stay in
sync.
