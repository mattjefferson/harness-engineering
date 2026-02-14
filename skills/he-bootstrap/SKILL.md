---
name: he-bootstrap
description: Bootstraps a repository for the harness-engineered workflow by creating AGENTS.md, docs/specs, docs/plans, docs/generated, and baseline tracking files. Use when setting up a new project before running he-intake through he-learn.
argument-hint: "[optional target repo path; defaults to current directory]"
---

# HE Bootstrap

Initialize the docs structure required by the `he-*` workflow while preserving this repo's `docs/specs` and `docs/plans` conventions.

## Inputs

- Optional target path (repo root)
- If omitted, use current directory

## Created Structure

- `docs/specs/`
- `docs/plans/active/`
- `docs/plans/completed/`
- `docs/design-docs/`
- `docs/generated/`
- `docs/references/`

## Baseline Files

Create these only if missing:

- `AGENTS.md`
- `docs/plans/tech-debt-tracker.md`
- `docs/specs/README.md`
- `docs/specs/index.md`
- `docs/plans/README.md`
- `docs/generated/README.md`
- `docs/generated/db-schema.md`
- `docs/generated/api-schema.md`
- `docs/generated/component-tree.md`
- `docs/generated/dependency-graph.md`
- `docs/references/README.md`
- `docs/design-docs/index.md`
- `docs/design-docs/core-beliefs.md`
- `docs/DESIGN.md`
- `docs/FRONTEND.md`
- `docs/PLANS.md`
- `docs/PRODUCT_SENSE.md`
- `docs/QUALITY_SCORE.md`
- `docs/RELIABILITY.md`
- `docs/SECURITY.md`

## Templates

Each created file has a source template in `templates/`:

- `AGENTS.md` <- `templates/AGENTS.md`
- `ARCHITECTURE.md` <- `templates/ARCHITECTURE.md` (optional with `--with-architecture`)
- `docs/plans/tech-debt-tracker.md` <- `templates/docs/plans/tech-debt-tracker.md`
- `docs/specs/README.md` <- `templates/docs/specs/README.md`
- `docs/specs/index.md` <- `templates/docs/specs/index.md`
- `docs/plans/README.md` <- `templates/docs/plans/README.md`
- `docs/generated/README.md` <- `templates/docs/generated/README.md`
- `docs/generated/db-schema.md` <- `templates/docs/generated/db-schema.md`
- `docs/generated/api-schema.md` <- `templates/docs/generated/api-schema.md`
- `docs/generated/component-tree.md` <- `templates/docs/generated/component-tree.md`
- `docs/generated/dependency-graph.md` <- `templates/docs/generated/dependency-graph.md`
- `docs/references/README.md` <- `templates/docs/references/README.md`
- `docs/design-docs/index.md` <- `templates/docs/design-docs/index.md`
- `docs/design-docs/core-beliefs.md` <- `templates/docs/design-docs/core-beliefs.md`
- `docs/DESIGN.md` <- `templates/docs/DESIGN.md`
- `docs/FRONTEND.md` <- `templates/docs/FRONTEND.md`
- `docs/PLANS.md` <- `templates/docs/PLANS.md`
- `docs/PRODUCT_SENSE.md` <- `templates/docs/PRODUCT_SENSE.md`
- `docs/QUALITY_SCORE.md` <- `templates/docs/QUALITY_SCORE.md`
- `docs/RELIABILITY.md` <- `templates/docs/RELIABILITY.md`
- `docs/SECURITY.md` <- `templates/docs/SECURITY.md`

Plan templates provided by this skill set:

- `skills/he-intake/templates/spec-template.md` (intake output)
- `skills/he-plan/templates/active-plan-template.md` (`plan_mode: lightweight|execution`)

Optional reference examples (not auto-created by bootstrap):

- `templates/docs/references/template-llms.txt`

Optional:

- `ARCHITECTURE.md` (when `--with-architecture` is passed)

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
test -d docs/plans/active &&
test -d docs/plans/completed &&
test -d docs/design-docs &&
test -d docs/generated &&
test -d docs/references &&
test -f AGENTS.md &&
test -f docs/plans/tech-debt-tracker.md &&
test -f docs/generated/db-schema.md &&
test -f docs/design-docs/core-beliefs.md &&
test -f docs/QUALITY_SCORE.md
```

## Seeding Phase

After creating the file structure, seed domain docs with real project context so agents have guidance from the first initiative.

### Step 1: Auto-Detect

Launch subagents to scan the target repo in parallel for:

- **Package manifests** — `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `Gemfile`
- **Framework config** — `next.config.*`, `vite.config.*`, `tsconfig.json`, `angular.json`, etc.
- **Test setup** — `jest.config.*`, `vitest.config.*`, `pytest.ini`, test directories, coverage config
- **CI/CD config** — `.github/workflows/`, `Makefile`, `Dockerfile`, `.gitlab-ci.yml`
- **Auth patterns** — auth-related deps, middleware files, env var references
- **README and existing docs** — `README.md`, `CONTRIBUTING.md`, existing `docs/` content

Compile a detection summary with suggested values for each domain.

### Step 2: Quick Q&A

Before asking, check the target domain doc for existing content beyond the template stub. If a doc already has real content, skip that question — the doc itself is the answer record.

Ask the following questions using `AskUserQuestion` (Claude Code) or `request_user_input` (Codex). Pre-fill suggestions from auto-detection where available.

| # | Domain Doc | Question |
|---|---|---|
| 1 | DESIGN.md | What are your core design principles? (e.g., "mobile-first", "minimalist", "data-dense dashboards") |
| 2 | FRONTEND.md | What's your frontend stack and key conventions? (e.g., React/Next.js, component library, styling approach) |
| 3 | PRODUCT_SENSE.md | Who are your target users and what outcomes matter most? |
| 4 | QUALITY_SCORE.md | What's your current test coverage situation and quality bar? (e.g., CI required, coverage thresholds) |
| 5 | RELIABILITY.md | What are your reliability requirements? (e.g., uptime targets, error budgets, monitoring) |
| 6 | SECURITY.md | What security concerns apply? (e.g., auth model, data sensitivity, compliance requirements) |
| 7 | references | Any reference repos or projects we should learn patterns from? |
| 8 | core-beliefs.md | What are 2-3 non-negotiable engineering beliefs for this project? |

Auto-detected values appear as pre-filled suggestions. The user can accept, modify, or replace them.

### Step 3: Populate Domain Docs

Write answers into the domain doc templates, replacing `<!-- seed: ... -->` markers with real content. Each domain doc has structured sections ready for population.

If reference repos were provided (Q7), use subagents to scan them and enrich the domain docs with relevant patterns.

### Step 4: Populate References

If reference repos/projects were provided:

1. Record them in `docs/references/README.md` with source URL and what to learn from each
2. Use subagents to scan each reference for patterns relevant to the domain docs
3. Incorporate findings into the seeded content

### Seeding Behavior Notes

- **Existing content wins** — if a domain doc already has real content beyond the template stub, skip seeding for that doc
- **Graceful degradation** — if nothing is detected (empty repo), skip auto-detect and rely on Q&A answers alone
- **Additive only** — `he-learn` can update seeded docs without conflict; seed comments get replaced, section structure remains

## Next Step

Start the first initiative with:

1. `he-intake` to create `docs/specs/<slug>.md`
2. `he-plan` to create `docs/plans/active/<slug>.md`

## Transition Options

Present 2-3 explicit next-step options with a recommended default. Use `request_user_input` (Codex) or `AskUserQuestion` (Claude Code) in Plan mode; otherwise ask in chat. Wait for user selection before proceeding.

At least one option must be `Next step: he-intake`.
