# Architecture

## Task flow

1. The app loads a versioned JSON snapshot through `TaskStore`.
2. `Task.fromJson` checks the stored fields using the same model invariants as new tasks.
3. `TaskRepo` exposes an immutable list and notifies the workspace after successful changes.
4. The editor validates title and estimated duration. The model independently enforces these constraints.
5. Repository mutations enter a serial queue. Each operation reads the latest list, persists its replacement, and only then publishes it.
6. A rejected write leaves the in-memory list unchanged; the UI displays an error. Later writes can still succeed.

The task model uses UUIDs instead of timestamps as identifiers. Editing retains completion and highlight state and supports clearing an optional estimate.

## Daily highlight

A highlight stores a local calendar date. Selecting a new highlight clears any previous selection. Pinning it again removes the highlight. Completion does not erase it, so the completed view still identifies the day's achievement. At the next local date, the selection expires without deleting the task.

The workspace re-evaluates the date on resume and every minute while open. A midnight transition therefore updates within one minute. The repository accepts a clock function so date changes can be tested without waiting.

## Storage choice

The original feature branch used an in-memory task repository and a separate unfinished Isar experiment. This release uses a single `shared_preferences` adapter and removes unused database/code-generation dependencies. The `TaskStore` interface allows a later database adapter without changing the task screen.

One JSON snapshot is appropriate for a small personal list. It rewrites the whole list per mutation, is not encrypted application storage, and is not a multi-tab synchronization mechanism. A successful preferences call is not a transactional database durability guarantee. Database storage, migration tooling, and export/import are natural next steps as the data grows.

Unknown schema versions and malformed snapshots lead to a load/retry screen. The app does not silently reset the saved data. No automatic repair or import UI is included in this release.

## UI behavior

- Open and completed tasks are separate views; search and filters combine within the selected view.
- Highlighted tasks sort first, then commitment, then title.
- All figures summarize the entire saved task list, rather than the currently filtered results.
- Add/edit forms remain open on failure, retaining the user's input.
- Delete requires confirmation and offers a brief Undo action. Restoration inserts only the deleted task, preserves newer changes, and yields to any newer daily highlight. Failed restoration offers Retry. Undo history is not persisted across app restarts.
- Duplicate opens a prefilled editor; saving assigns a new ID and resets completion and highlight state. It then opens the unfiltered Open view so the copy is visible.
- Clear filters resets the search, duration, and commitment filters while retaining the selected Open/Completed view.
- Completed tasks can be reopened.
- Material controls provide keyboard focus and accessible labels; layout uses wrapping filters and a bounded, scrollable content area.

## Platform scope

The repository includes Android, iOS, and web targets. Automated verification covers repository behavior, Flutter widgets, static analysis, and the web build. Native device and app-store release verification remain platform-specific steps; web test results do not imply native release certification.
