# Tech Debt Tracker

Track recurring issues as a lifecycle queue. Treat this file as append-and-update (do not delete historical debt rows unless duplicated by mistake).

## Status Semantics

- `new`: freshly captured, not yet prioritized for execution.
- `queued`: prioritized and waiting for a concrete execution slot.
- `in_progress`: actively being addressed in an open spec/plan.
- `applied`: prevention action implemented, awaiting confirmation over time.
- `verified`: prevention has held across subsequent changes.
- `wont_fix`: consciously accepted with documented rationale.

| first_seen | last_seen | slug | issue_pattern | impact | prevention_action | frequency | priority | lesson_applied | next_slug | owner | status | evidence |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
