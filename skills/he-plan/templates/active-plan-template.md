---
slug: <slug>
status: active
phase: plan
plan_mode: <lightweight|execution>
priority: <critical|high|medium|low>
owner: <name or team>
---

# <Short, action-oriented description>

This ExecPlan is a living document. Keep `Progress`, `Surprises & Discoveries`, `Decision Log`, `Outcomes & Retrospective`, and `Revision Notes` current as work proceeds.

This plan must be maintained in accordance with `docs/PLANS.md`.

## Purpose / Big Picture

Explain what a user can do after this change that they cannot do now, why it matters, and how they can observe it working.

## Progress

Use timestamped checkboxes with stable IDs. Keep this section aligned with actual state at every stop point.

- [ ] (2026-02-15T00:00:00Z) P1 [M1] <first granular step>
- [ ] (2026-02-15T00:00:00Z) P2 [M1] <second granular step>
- [ ] (2026-02-15T00:00:00Z) P3 [M2] <follow-up step>

## Surprises & Discoveries

Capture unexpected behavior, constraints, bugs, or performance findings with concise evidence.

- Observation: <what was discovered>
  Evidence: <test output, log line, or short transcript>

## Decision Log

Record each material decision and why it was made.

- Decision: <decision>
  Rationale: <why this path was selected>
  Date/Author: <YYYY-MM-DD, name>

## Outcomes & Retrospective

Summarize outcomes, remaining gaps, and lessons at milestones and completion.

- <outcome summary>

## Context and Orientation

Describe the relevant existing system as if the reader has no prior context. Name concrete paths, modules, and functions.

## Milestones

Use narrative milestones with scope, expected results, and proof commands.

### Milestone 1 - <title>

Describe what will exist after this milestone, where changes occur, and how to verify the result.

### Milestone 2 - <title>

Describe incremental value, the edits involved, and the validation signal.

## Plan of Work

Describe the edit sequence in prose with specific file paths and symbols to change.

## Concrete Steps

List exact commands with working directory and expected output snippets.

From repo root:

    cd /path/to/repo
    <command>

Expected:

    <short expected output>

## Validation and Acceptance

Define behavior-level acceptance with exact checks.

- Run: `<project test command>`
- Expect: `<N> passing; specific new/changed test behavior>`
- Exercise: `<manual/e2e scenario with concrete input/output>`

## Idempotence and Recovery

Describe safe re-runs, rollback paths, and cleanup steps for partial failures.

## Artifacts and Notes

Add concise evidence snippets that prove progress and correctness.

    <short transcript, diff excerpt, or log snippet>

## Interfaces and Dependencies

Name interfaces, modules, libraries, and service boundaries affected, including required signatures or contracts.

## Review Findings

Populated by `he-review`.

## Verify/Release Decision

Populated by `he-verify-release`.

- decision: GO | NO-GO
- date:
- open findings by priority (if any):
- evidence:
- rollback:
- post-release checks:
- owner:

## Revision Notes

Append-only notes describing what changed in the plan and why.

- 2026-02-15: Initialized plan from template. Reason: establish PLANS-compliant execution baseline.
