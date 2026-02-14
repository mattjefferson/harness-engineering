# AGENTS.md

## Purpose

This file routes agents to the project's source of truth for harness-engineered execution.

## Source of Truth Order

1. `AGENTS.md`
2. `ARCHITECTURE.md` (if present)
3. `docs/specs/<slug>.md`
4. `docs/plans/active/<slug>.md`
5. `docs/references/*`

## Workflow

1. intake
2. plan
3. implement
4. review
5. verify/release
6. learn
7. entropy (periodic)

## Conventions

- Slug format: `YYYY-MM-DD-kebab-topic`
- One slug per initiative across specs, plans, and generated state
- Runtime state path: `docs/generated/runs/<slug>/`

## Gates

1. Doc commit gate between phases
2. Severity gate: unresolved critical/high findings block progression
3. Dependency gate: tasks execute only when dependencies are satisfied

## Paths

- Specs: `docs/specs/`
- Active plans: `docs/plans/active/`
- Completed plans: `docs/plans/completed/`
- Debt tracker: `docs/plans/tech-debt-tracker.md`
- Generated state: `docs/generated/runs/`

