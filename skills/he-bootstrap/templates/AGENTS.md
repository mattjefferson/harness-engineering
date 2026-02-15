# AGENTS.md

## Start Here

This file is a map, not an encyclopedia.

The system of record is `docs/`. Keep durable knowledge (specs, plans, logs, decisions, checklists) there and link to it from here.

## Session Startup

Before doing any work:

1. Check `docs/plans/active/` for in-progress work.
2. If a plan exists, open it and read `## Progress`; resume from the first incomplete item.
3. If no plan exists, ask what initiative to run and start at `docs/specs/<slug>.md`.

## Source Of Truth (Table Of Contents)

- Plan system + artifact contract: `docs/PLANS.md`
- Architecture (if present): `ARCHITECTURE.md`
- Specs (intent): `docs/specs/`
- Spikes (findings): `docs/spikes/`
- Plans (execution + logs):
  - active: `docs/plans/active/`
  - completed: `docs/plans/completed/`
  - tech debt: `docs/plans/tech-debt-tracker.md`
- Generated context (refresh as needed): `docs/generated/`
- External references: `docs/references/`
- Domain guardrails and standards:
  - `docs/QUALITY_SCORE.md`
  - `docs/SECURITY.md`
  - `docs/RELIABILITY.md`
  - `docs/FRONTEND.md`
  - `docs/DESIGN.md`
  - `docs/PRODUCT_SENSE.md`

## Workflow (Phases)

intake → spike (optional) → plan → implement → review → verify-release → learn

## Conventions

- Slug format: `YYYY-MM-DD-kebab-topic`
- One slug per initiative across specs/spikes/plans

## Gates (Reminders)

- Plans follow `docs/PLANS.md` literally.
- `Progress` is the only checklist section and must reflect real current state.
- `Surprises & Discoveries`, `Decision Log`, `Outcomes & Retrospective`, and `Revision Notes` are append-only.
- Testing strategy and guardrails live in `docs/QUALITY_SCORE.md` (default: unit/e2e only; no mocks).
- For UI changes, capture agentic E2E evidence (screenshots/recordings/text) and link it in plan artifacts.

If you find yourself adding paragraphs here, move them into `docs/` and link them from this file.
