---
name: he-doc-gardening
description: Recurring doc-gardening agent that scans for stale or obsolete documentation that no longer matches real code behavior, then queues fix-up work.
argument-hint: "[optional area, subsystem, or repo-wide]"
---

# HE Doc Gardening

Run this skill periodically to keep docs accurate and aligned with shipped behavior.

## When to Use

- Weekly by default
- After large releases or high-review-noise periods
- When `he-learn` surfaces doc drift

## Key Principles

1. **Entropy is normal** — doc-gardening is recurring garbage collection.
2. **Prefer objective signals** — use CI lint/drift tools and repo evidence as inputs.
3. **Queue small fixes** — doc-fix initiatives should be small and independently shippable.
4. **Do not block delivery by default** — only escalate when a critical invariant is broken.
5. **Mandatory artifacts must exist** — missing required runbooks or broken gates are drift to fix.
6. **Runbooks are additive only** — apply any runbook whose frontmatter `called_from` matches this skill (`bash scripts/runbooks/select-runbooks.sh --skill he-doc-gardening`), but never waive/override anything codified here.

## Workflow

### Phase 0: Run Objective Drift Signals

Prefer these commands over subjective scanning when available:

1. `bash scripts/ci/he-docs-lint.sh`
2. `bash scripts/ci/he-runbooks-lint.sh`
3. `bash scripts/ci/he-docs-drift.sh`
4. `bash scripts/ci/he-specs-lint.sh`
5. `bash scripts/ci/he-plans-lint.sh`
6. `bash scripts/ci/he-spikes-lint.sh`
7. Run `bash scripts/runbooks/select-runbooks.sh --skill he-doc-gardening` and read any returned runbooks. Apply their additions throughout — they must not waive or override gates codified here.

### Phase 1: Scan Targets (Parallel)

Launch parallel subagents to scan each target area concurrently:

1. Repeated review findings and regressions
2. Stale or contradictory docs
3. Dead links or outdated references
4. High-churn or complexity hotspots
5. Flaky test patterns
6. Stale generated context in `docs/generated/` (check `last_updated` timestamps; exclude `docs/generated/memory.md`)
7. Domain docs drift: docs listed in `docs/DOMAIN_DOCS.md` exist when relevant and include required headings (see `scripts/ci/he-docs-lint.sh`)
8. Missing baseline runbooks, or runbooks in `docs/runbooks/` that violate format or conflict with enforced gates (additional runbooks are allowed and expected)
9. Drift against enforced rules: failures from `scripts/ci/he-docs-drift.sh` and the plans/specs/spikes lint scripts

Each subagent scans one area and returns a list of drift findings with priority.

### Phase 2: Consolidate and Queue

1. Consolidate drift findings with explicit priority.
2. Update `docs/plans/tech-debt-tracker.md`.
3. Refresh stale generated context files in `docs/generated/`.
4. Create one or more doc-fix specs and plans:
   - `docs/specs/<slug>.md`
   - `docs/plans/active/<slug>.md`

Keep each doc-fix plan small and independently shippable.

## Required Runbooks (Must Exist)

If any of these are missing in a consuming repo, record a `high` priority drift finding and queue a doc-fix initiative:

- `docs/runbooks/update-agents-md.md`
- `docs/runbooks/update-domain-docs.md`
- `docs/runbooks/code-review.md`
- `docs/runbooks/review-findings.md`
- `docs/runbooks/address-review-findings.md`
- `docs/runbooks/verify-release.md`
- `docs/runbooks/record-evidence.md`
- `docs/runbooks/ci-failures.md`
- `docs/runbooks/merge-change.md`

This is a minimum baseline. Repos may add additional runbooks; doc-gardening should not treat new runbooks as drift. Instead, ensure they:

- Keep frontmatter consistent (`title`, `use_when`, `called_from`)
- Do not waive non-negotiable gates enforced by skills
- Do not duplicate or contradict existing runbooks without a clear replacement plan

`docs/generated/memory.md` is a scratchpad handled by `he-learn`, not doc-gardening.

## Doc-Gardening Rule

- Doc-gardening work should not block feature delivery unless a critical invariant is broken.
- Critical invariant violations must be escalated and prioritized immediately.

## Output

- Updated `docs/plans/tech-debt-tracker.md`
- Refreshed stale generated context files
- Doc-fix specs and plans queued as normal slug-based artifacts

## Exit Gate

- Drift findings are documented
- Cleanup initiatives are queued as normal slug-based specs/plans
- Docs commit gate passes

## When Things Go Wrong

- **Lint scripts are missing or broken** — fall back to subjective scanning but record the tooling gap as a drift finding.
- **Too many drift findings to queue individually** — group related findings into thematic doc-fix initiatives.
- **Critical invariant violation found** — escalate immediately; do not defer to the regular queue.
- **Runbook conflicts with skill gates** — treat as policy drift; record a `high` finding and queue a fix.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|---|---|
| Blocking feature delivery for doc fixes | Only escalate critical invariant violations |
| Subjective scanning without running lint tools | Run objective drift signals first |
| Giant doc-fix initiatives | Keep each fix small and independently shippable |
| Treating new/additional runbooks as drift | Only flag runbooks that violate format or conflict with gates |
| Ignoring stale generated context | Check `last_updated` timestamps and refresh |

## Transition Points

Always use interactive question tool at transitions (`AskUserQuestion` in Claude Code, `request_user_input` in Codex Plan mode, or equivalent). Offer:

1. Continue to `he-spec` for a cleanup initiative slug (recommended)
2. Run one more build-feedback round in `he-doc-gardening`
3. Handoff/pause with status and explicit next action

If running autonomously or no interactive tool is available, continue with `he-spec` and log an `Autonomous transition` note in `Decision Log` or `Revision Notes`.
