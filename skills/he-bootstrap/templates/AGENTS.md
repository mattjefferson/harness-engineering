# AGENTS.md

## Purpose

This file routes agents to the project's source of truth for harness-engineered execution.

## Session Startup

At the start of every session, follow these steps before doing any work:

1. Check `docs/plans/active/` for any in-progress plans.
2. Run `git log --oneline -10` to see recent activity.
3. If an active plan exists, read its Progress Log for the last known state.
4. Resume from where the previous session left off.
5. If no active work exists, ask what to work on next.

## Core Principles

- Plans are first-class artifacts.
- Use ephemeral lightweight plans for small changes.
- Capture complex work in execution plans with progress logs and decision logs, committed to the repository.
- Keep active plans, completed plans, and technical debt versioned and co-located so agents do not depend on external context.
- Enable progressive disclosure: agents start from a small, stable entry point and follow explicit pointers to deeper context as needed.

## Golden Principles

Project-specific code quality rules. Violations should be flagged during review.

- Prefer shared utilities over hand-rolled helpers.
- No raw SQL outside the data layer.
- No mock-based tests — use unit tests or e2e tests only.
- Every public API change requires a spec update before implementation.
- Keep functions under 50 lines; extract when logic branches.

Update this section when `he-learn` identifies a recurring pattern that should become a rule.

## Testing Philosophy

- Unit tests or e2e tests only — no mocks.
- Mocks hide real bugs and invent behaviors that never happen in production.
- Plans must specify test type (unit or e2e) per task.
- Review should flag any mock-based tests as a blocking finding.

## Source of Truth Order

1. `AGENTS.md`
2. `ARCHITECTURE.md` (if present)
3. `docs/specs/<slug>.md`
4. `docs/plans/active/<slug>.md`
5. `docs/references/*`

## Workflow

1. intake
2. spike (when needed — for unclear or high-risk work)
3. plan
4. implement
5. review
6. verify/release
7. learn
8. doc-gardening (periodic)

## Conventions

- Slug format: `YYYY-MM-DD-kebab-topic`
- One slug per initiative across specs and plans
- Generated context path: `docs/generated/`

## Gates

1. Doc commit gate between phases
2. Priority gate: unresolved critical/high-priority findings block progression
3. Dependency gate: tasks execute only when dependencies are satisfied
4. Plan state gate: active plans expose completion via Task DAG status (single source of truth) + progress logs

## Paths

- Specs: `docs/specs/`
- Spike findings: `docs/specs/<slug>-spike.md` (if a spike was run)
- Active plans: `docs/plans/active/<slug>.md` (`plan_mode: lightweight|execution`)
- Completed plans: `docs/plans/completed/<slug>.md`
- Debt tracker: `docs/plans/tech-debt-tracker.md`
- Generated context: `docs/generated/`
- Generated schema: `docs/generated/db-schema.md`
- Design docs: `docs/design-docs/`
- Quality docs: `docs/QUALITY_SCORE.md`, `docs/SECURITY.md`, `docs/RELIABILITY.md`, `docs/PRODUCT_SENSE.md`, `docs/DESIGN.md`, `docs/FRONTEND.md`, `docs/PLANS.md`
