# TickTasker

TickTasker is a minimalist productivity app centered on one idea: **finish one meaningful thing per day**.

It combines simple planning concepts (Daily Highlight, Commitment Slider, Two-Day Rule, and fast-task filtering) with a calm interface that can grow into a practical personal workflow tool.

## Product positioning

Many to-do apps optimize for collecting tasks. TickTasker optimizes for finishing meaningful work consistently, with low mental overhead.

## Features at a glance

The concepts below describe the intended product direction. Status is split into **Implemented** and **Planned** to avoid overstating current functionality.

- **Daily Highlight**
  - Implemented: home card with a single focus statement.
  - Planned: editable highlight, completion tracking, and day history.
- **Commitment Slider (0–3)**
  - Implemented: interactive slider with visible level state.
  - Planned: tie slider level to suggested scope and reminders.
- **Two-Day Rule**
  - Implemented: principle explained in UI copy.
  - Planned: streak/missed-day detection and nudges.
- **Two-Minute Tasks filter**
  - Implemented: toggle that filters the sample task list.
  - Planned: user-defined tasks and automatic “quick task” tagging.
- **Study → Write pipeline**
  - Implemented: structure shown in home experience.
  - Planned: capture, promotion, and workflow state transitions.

## Current status and roadmap

### Implemented now (MVP shell)

- Flutter app with a TickTasker-branded home/landing experience
- Accessibility-conscious section headings and meaningful copy
- Basic local state interactions (commitment slider + quick-task filter)
- Widget tests for core home behavior

### Planned next

- Real domain models and persistence wiring
- Daily highlight editing and completion flow
- Actual task CRUD and pipeline state management
- History and habit feedback loops

## Screenshots

No screenshots are committed yet.

If you want to contribute screenshots:

1. Run the app on your target platform.
2. Capture screens showing the current UI.
3. Open a PR adding images under `docs/images/` and update this section with relative links.

## Supported platforms

Based on repository platform folders, this project is currently configured for:

- Android (`android/`)
- iOS (`ios/`)

Desktop and web folders are not present yet.

## Prerequisites

- Flutter SDK (stable channel)
- Dart SDK (bundled with Flutter)
- Xcode (for iOS builds on macOS)
- Android SDK / Android Studio (for Android builds)

## Setup and common commands

From the repository root:

```bash
flutter pub get
flutter run
```

Quality and verification:

```bash
dart format .
flutter analyze
flutter test
```

Build examples:

```bash
flutter build apk
flutter build ios
```

## Project structure

```text
lib/
  main.dart                # TickTasker MVP app shell and home UI

test/
  widget_test.dart         # Widget tests for home experience

docs/
  product-principles.md    # Product behavior and roadmap notes
  development-guide.md     # Setup and development workflow
  architecture.md          # Current architecture and persistence notes
```

## Architecture and persistence notes

- Current UI and local interaction state are implemented in `lib/main.dart`.
- The app currently uses in-memory widget state for MVP behavior.
- `pubspec.yaml` includes dependencies (`isar`, `isar_flutter_libs`, `path_provider`, `flutter_riverpod`) that support planned local-first architecture, but persistence is not wired into runtime behavior yet.

See `docs/architecture.md` for a more explicit current-vs-planned breakdown.

## Development workflow

1. Create a branch.
2. Make focused changes with tests.
3. Run format, analyze, and tests.
4. Open a pull request with a concise summary and verification notes.

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

For bugs and ideas, use the issue templates in `.github/ISSUE_TEMPLATE/`.

## License status

This repository currently does **not** include a license file. That means reuse rights are not yet explicitly granted. A license should be added by the repository owner before external reuse assumptions are made.

## Troubleshooting / FAQ

- **`flutter` command not found**
  - Ensure Flutter is installed and added to your `PATH`.
- **iOS build fails on CocoaPods or signing**
  - Run `flutter doctor`, verify Xcode tooling, and confirm signing/team settings.
- **Android build fails due to SDK mismatch**
  - Accept Android licenses (`flutter doctor --android-licenses`) and install required SDK versions.
- **`flutter test` fails after dependency changes**
  - Run `flutter pub get` again and retry tests.

For broader environment diagnostics, run:

```bash
flutter doctor -v
```
