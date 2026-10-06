# Development and Setup Guide

## Requirements

- Flutter SDK (stable)
- Dart SDK (comes with Flutter)
- Android or iOS toolchain depending on target

## First-time setup

```bash
flutter pub get
flutter doctor
```

## Running locally

```bash
flutter run
```

Use `flutter devices` to select an available simulator/emulator/device.

## Quality checks

```bash
dart format .
flutter analyze
flutter test
```

Run these before opening a pull request.

## Build commands

```bash
flutter build apk
flutter build ios
```

## Contribution flow

1. Branch from `main`.
2. Keep changes focused and update tests/docs when behavior changes.
3. Run quality checks.
4. Open PR with:
   - what changed
   - why it changed
   - how it was tested
