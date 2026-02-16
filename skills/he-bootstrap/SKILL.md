---
name: he-bootstrap
description: Bootstraps a repository for the harness-engineered workflow by creating AGENTS.md, docs/specs, docs/spikes, docs/plans, docs/generated, and baseline tracking files aligned to the PLANS.md contract.
argument-hint: "[optional target repo path; defaults to current directory]"
---

# HE Bootstrap

Initialize the docs structure required by the `he-*` workflow while preserving this repo's docs conventions.

## Key Principles

1. Minimal impact: create files only if missing; for existing `AGENTS.md`, append a small managed block once; never overwrite user-authored content.
2. Templates are contracts: treat `skills/he-bootstrap/templates/**` as API-like surfaces.
3. Domain docs are on-demand: downstream skills populate them when real context exists.
4. Structure first: if the docs/workflow layout is wrong, fix it before execution.
5. Verify bootstrap: run the post-bootstrap validation checks.
6. All runbooks are copied: every runbook template is installed to the target repo. No selector filtering at bootstrap time.

## Inputs

- Optional target path (repo root)
- If omitted, use current directory

## Created Structure

- `docs/specs/`
- `docs/spikes/`
- `docs/plans/active/`
- `docs/plans/completed/`
- `docs/design-docs/`
- `docs/generated/`

## Baseline Files

Create these only if missing:

- `AGENTS.md`
- `docs/plans/tech-debt-tracker.md`
- `docs/specs/README.md`
- `docs/specs/index.md`
- `docs/spikes/README.md`
- `docs/plans/README.md`
- `docs/generated/README.md`
- `docs/design-docs/index.md`
- `docs/PLANS.md`
- `docs/DOMAIN_DOCS.md`

## Templates

Each created file has a source template in `templates/`:

- `AGENTS.md` <- `templates/AGENTS.md`
- `ARCHITECTURE.md` <- `templates/ARCHITECTURE.md` (optional with `--with-architecture`)
- `docs/plans/tech-debt-tracker.md` <- `templates/docs/plans/tech-debt-tracker.md`
- `docs/specs/README.md` <- `templates/docs/specs/README.md`
- `docs/specs/index.md` <- `templates/docs/specs/index.md`
- `docs/spikes/README.md` <- `templates/docs/spikes/README.md`
- `docs/plans/README.md` <- `templates/docs/plans/README.md`
- `docs/generated/README.md` <- `templates/docs/generated/README.md`
- `docs/design-docs/index.md` <- `templates/docs/design-docs/index.md`
- `docs/PLANS.md` <- `templates/docs/PLANS.md`
- `docs/DOMAIN_DOCS.md` <- `templates/docs/DOMAIN_DOCS.md`

## AGENTS.md Behavior

- If `AGENTS.md` is missing: create from `templates/AGENTS.md`.
- If `AGENTS.md` already exists: append one managed block delimited by:
  - `<!-- he-bootstrap:start -->`
  - `<!-- he-bootstrap:end -->`
- Re-running bootstrap is idempotent and must not duplicate the managed block.

Plan templates provided by this skill set:

- `skills/he-spec/templates/spec-template.md` (spec output)
- `skills/he-plan/templates/plan-template.md` (`plan_mode: trivial|lightweight|execution`)

Optional:

- `ARCHITECTURE.md` (when `--with-architecture` is passed)
  - Compact contract: `Purpose`, `Codemap`, `Invariants`, `Details Live Elsewhere`
  - Keep content map-level and stable to minimize agent context usage

## Bootstrap Commands

Run `templates/bootstrap.sh` from the target repo root.

Example:

```bash
bash skills/he-bootstrap/templates/bootstrap.sh
```

With architecture template:

```bash
bash skills/he-bootstrap/templates/bootstrap.sh --with-architecture
```

## Post-Bootstrap Validation

```bash
test -d docs/specs &&
test -d docs/spikes &&
test -d docs/plans/active &&
test -d docs/plans/completed &&
test -d docs/design-docs &&
test -d docs/generated &&
test -f AGENTS.md &&
test -f docs/plans/tech-debt-tracker.md &&
test -f docs/generated/README.md &&
test -f docs/DOMAIN_DOCS.md
```

## Domain Docs

Domain docs (DESIGN.md, FRONTEND.md, SECURITY.md, etc.) are **not** created at bootstrap. They are created on-demand by downstream skills (`he-plan`, `he-implement`, `he-learn`) when they have real context to populate them. For `he-plan`, population happens at end-of-plan after final approval and before transition. See `docs/DOMAIN_DOCS.md` for the full registry, auto-detect signals, and seed questions.

## Next Step

Start the first initiative with:

1. `he-spec` to create `docs/specs/<slug>-spec.md`
2. `he-plan` to create `docs/plans/active/<slug>-plan.md`

## Transition

Default next phase is `he-spec`.
