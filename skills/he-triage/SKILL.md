---
name: he-triage
description: Deep-analyzes accumulated tech-debt tracker items with scoring and context, then presents prioritized recommendations for the user to triage interactively.
argument-hint: "[optional: area filter or 'wont_fix' to focus on cleanup]"
---

# HE Triage

Deep analysis of the tech-debt tracker, then interactive prioritization. Phases 0–1 are autonomous (analysis, scoring, context gathering). Phase 2 presents findings to the human for decisions. Phase 3 applies the confirmed decisions.

## When to Use

- Monthly (or on-demand) to review accumulated tracker items
- When capacity opens up between initiatives
- When `he-doc-gardening` flags high tracker volume (> 10 `new` items)

## Key Principles

1. **Analyze deeply, then present** — Phases 0–1 are autonomous: score, investigate, and prepare recommendations. Phase 2 is where the human sees results and makes decisions.
2. **Batch related items** — group items that share an area or slug so the human can evaluate them together.
3. **Recommend, don't dictate** — every item gets a scored recommendation with rationale, but the human's call overrides.
4. **`wont_fix` is a valid outcome** — not everything needs fixing. Proactively recommend it for stale low-value items.
5. **Triage is fast** — spend time on prioritization and context, not deep solution analysis (that's what specs are for).
6. **Runbooks are additive only** — apply any runbook whose frontmatter `called_from` matches this skill (`bash scripts/runbooks/select-runbooks.sh --skill he-triage`), but never waive/override anything codified here.

## Workflow

### Phase 0: Load Context

1. Read `docs/plans/tech-debt-tracker.md`.
2. Gather any active plans in `docs/plans/active/` for overlap detection.
3. Run `bash scripts/runbooks/select-runbooks.sh --skill he-triage` and read any returned runbooks. Apply their additions throughout — they must not waive or override gates codified here.

### Phase 1: Deep Analysis

Perform thorough analysis before presenting anything to the human. Use subagents in parallel to investigate multiple items/areas concurrently.

#### 1a. Filter and Group

1. Filter tracker for `new` and `queued` items.
2. Group related items by area, originating slug, or reviewer dimension.
3. Check each item/group against active plans in `docs/plans/active/` for overlap.

#### 1b. Score Each Item

Score every item on a **0–100 composite scale**. Higher score = should be prioritized first.

| Factor | Weight | How to Score |
|---|---|---|
| **Severity** | 35% | `critical` = 100, `high` = 75, `medium` = 50, `low` = 25 |
| **Age** | 20% | Days since creation, normalized: 90+ days = 100, 60 = 75, 30 = 50, < 14 = 25 |
| **Blast radius** | 20% | How many areas/files/consumers are affected. Use code search to assess. Wide impact = 100, single file = 25 |
| **Clustering** | 15% | Number of related tracker items in the same area. 4+ = 100, 3 = 75, 2 = 50, 1 = 25 |
| **Trend** | 10% | Is this area generating new findings? Growing = 100, stable = 50, shrinking = 25 |

Composite score = weighted sum of all factors.

#### 1c. Investigate Context

For each item/group, gather enough context to present a useful recommendation:

- Read the originating review findings or doc-gardening output
- Check the affected code area (file count, recent churn, ownership)
- Identify if a fix would be isolated or cross-cutting
- Note any dependencies between items (fixing A may resolve B)

#### 1d. Prepare Recommendations

For each item/group, prepare:

- **Composite score** with per-factor breakdown
- **Recommendation**: `promote`, `defer`, or `wont_fix`
- **Rationale**: one-line reason tied to the scoring factors
- **Proposed slug name** (if recommending `promote`)
- **Effort estimate**: `small` (< 1 day), `medium` (1–3 days), `large` (3+ days)

Flag `wont_fix` candidates: items `new` for 3+ months with `low` priority and no clustering signal.

Sort all items/groups by composite score, descending.

### Phase 2: Interactive Triage

Present results to the human in score order — highest score first, so the most impactful items get attention first.

#### Opening Summary

Present a **triage overview** before walking through items:

- Total items, grouped count, score range, priority distribution
- Items already covered by active plans (recommend linking, not duplicating)
- Top-3 highest-scoring groups at a glance

#### Walk-Through (Highest Score First)

For each group, present:

1. **Score** — composite score with per-factor breakdown (e.g., "Score: 78 — severity 75, age 90, blast radius 60, clustering 75, trend 50")
2. **Items** — tracker IDs, summaries, originating slugs, priorities, and age
3. **Context** — affected code areas, cross-cutting dependencies, overlap with active plans
4. **Effort estimate** — `small` / `medium` / `large`
5. **Recommendation** — `promote` / `defer` / `wont_fix` with rationale

Use interactive question tool (`AskUserQuestion` in Claude Code, `request_user_input` in Codex Plan mode, or equivalent) for each group. Offer:

- **Promote** — convert to spec and queue for the next cycle
- **Defer** — keep as `new`, revisit next triage
- **Won't fix** — close with rationale
- **Split** — break the group apart for individual decisions
- **Regroup** — merge with another group

Accept the human's decision and move to the next group. If the human wants to change a previous decision, accommodate it.

#### Decision Summary

After all groups are triaged, present a **decision summary** showing the full set of decisions ordered by score, and ask for final confirmation before applying changes.

### Phase 3: Apply Decisions

Only after the human confirms the decision summary:

**Promoted items:**
1. Update tracker status from `new` → `queued`.
2. Create a lightweight spec at `docs/specs/<slug>.md` that references the tracker IDs.
3. The spec feeds into the normal `he-spec → he-plan → he-implement` flow.

**Won't-fix items:**
1. Update tracker status to `wont_fix`.
2. Add rationale in the detail entry (use the rationale confirmed during the interactive session).

**Deferred items:**
- Stay as `new`. No changes needed.

**Overlap items:**
- Mark as `queued` and link to the existing active plan instead of creating a duplicate spec.

## Output

- Updated `docs/plans/tech-debt-tracker.md` with status changes
- Lightweight specs at `docs/specs/<slug>.md` for promoted groups
- Decision summary: promoted count, deferred count, wont_fix count, overlap count

## Exit Gate

- Every `new`/`queued` item in the tracker has been presented to the human
- Each decision was explicitly confirmed (no silent batch-decisions)
- Promoted items have status `queued` and a corresponding spec
- `wont_fix` items have rationale recorded in the detail entry
- Final decision summary was confirmed before changes were applied
- Docs commit gate passes

## When Things Go Wrong

- **Tracker doesn't exist or is empty** — nothing to triage; inform the human and exit cleanly.
- **Too many items to triage in one session** — ask the human whether to filter by priority (critical/high first), by area, or by age. Triage the selected subset and defer the rest.
- **Active plan already covers a tracker item** — present the overlap and recommend linking instead of creating a duplicate spec.
- **Human disagrees with scoring** — scoring is advisory; adjust the recommendation and proceed with the human's call.
- **Human wants to re-triage a previous group** — backtrack and re-present it.
- **All items are `wont_fix` candidates** — this is valid; present the analysis and let the human confirm.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|---|---|
| Making decisions without presenting them | Every item gets presented with a recommendation; human decides |
| Dumping a wall of items without grouping | Group related items and walk through one group at a time |
| Deep-diving into solutions during triage | Triage is for prioritization; specs are for analysis |
| Ignoring `wont_fix` as an option | Proactively recommend it for stale low-value items |
| Applying changes before final confirmation | Present decision summary and wait for explicit go-ahead |
| Skipping the analysis phase to save time | The deep analysis is the value; shortcuts produce bad recommendations |
| Running Phase 2–3 autonomously | Analysis is autonomous, but decisions require the human |

## Transition Points

Always use interactive question tool at transitions (`AskUserQuestion` in Claude Code, `request_user_input` in Codex Plan mode, or equivalent). Offer:

1. Continue to `he-spec` for the highest-priority promoted slug (recommended)
2. Run one more triage round for items that were deferred or skipped
3. Handoff/pause with status and explicit next action

Phases 0–1 run autonomously. If no interactive tool is available for Phase 2, stop after analysis and log the scored recommendations — do not apply changes without human decisions.
