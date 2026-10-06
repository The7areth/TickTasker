# Architecture Notes

## Current architecture

The project is currently a focused MVP shell:

- `lib/main.dart` contains app bootstrapping, home page layout, and small in-memory interaction state.
- Widget composition is split into page-level state and reusable section card UI.
- Tests (`test/widget_test.dart`) cover core home rendering and interactions.

## State and persistence

Current state management:

- Uses local `StatefulWidget` state for commitment level and two-minute filter.

Dependency signals for planned architecture:

- `flutter_riverpod` (state management)
- `isar` and `isar_flutter_libs` (local database)
- `path_provider` (filesystem paths)

These dependencies are declared but not wired into the current runtime flow yet.

## Proposed incremental direction

1. Introduce domain models for highlight, tasks, and pipeline items.
2. Add repository interfaces for persistence.
3. Move UI state to Riverpod providers.
4. Wire Isar-backed storage while preserving deterministic widget tests.

## Non-goals for current MVP

- Cloud sync
- Authentication
- Analytics
- Multi-device real-time collaboration
