# AGENTS.md

## Purpose

This file routes agents to the project's source of truth for harness-engineered execution.

## Core Principles

- Plans are first-class artifacts.
- Use ephemeral lightweight plans for small changes.
- Capture complex work in execution plans with progress logs and decision logs, committed to the repository.
- Keep active plans, completed plans, and technical debt versioned and co-located so agents do not depend on external context.
- Enable progressive disclosure: agents start from a small, stable entry point and follow explicit pointers to deeper context as needed.

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
7. doc-gardening (periodic)

## Conventions

- Slug format: `YYYY-MM-DD-kebab-topic`
- One slug per initiative across specs and plans
- Generated context path: `docs/generated/`

## Gates

1. Doc commit gate between phases
2. Priority gate: unresolved critical/high-priority findings block progression
3. Dependency gate: tasks execute only when dependencies are satisfied

## Paths

- Specs: `docs/specs/`
- Active plans: `docs/plans/active/<slug>.md` (`plan_mode: lightweight|execution`)
- Completed plans: `docs/plans/completed/<slug>.md`
- Debt tracker: `docs/plans/tech-debt-tracker.md`
- Generated context: `docs/generated/`
- Generated schema: `docs/generated/db-schema.md`
- Design docs: `docs/design-docs/`
- Quality docs: `docs/QUALITY_SCORE.md`, `docs/SECURITY.md`, `docs/RELIABILITY.md`, `docs/PRODUCT_SENSE.md`, `docs/DESIGN.md`, `docs/FRONTEND.md`, `docs/PLANS.md`
