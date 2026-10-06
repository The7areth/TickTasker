# Product Principles and Feature Behavior

TickTasker is designed to keep productivity simple and intentional.

## Core principles

1. **One meaningful thing per day**
   - The app should keep a clear daily focus, not an overwhelming backlog-first experience.
2. **Commitment over perfection**
   - A small commitment scale (0–3) should help users size effort realistically.
3. **Never miss twice**
   - The Two-Day Rule exists to prevent drift, not punish missed days.
4. **Momentum through small wins**
   - Two-minute actions should be easy to find and execute quickly.
5. **From learning to output**
   - Study notes should eventually flow into writing/public output.

## Current implementation status

Implemented in UI today:

- Daily Highlight section (fixed sample focus text)
- Commitment Slider (0–3) with visible level updates
- Two-Day Rule explanatory section
- Two-Minute Tasks toggle that filters sample tasks
- Study → Write pipeline section labels

Not implemented yet:

- User-editable highlight and completion persistence
- Task creation/editing/deletion
- Habit history, streaks, or reminders
- Data persistence for highlights/tasks/pipeline entries

## Behavior expectations for future work

- New features should reinforce daily focus rather than adding complexity.
- Any automation or reminders should remain optional and low-friction.
- Product copy should remain plain-language and guilt-free.
