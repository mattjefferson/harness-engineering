---
name: he-review
description: Runs agent-first review fanout across correctness, architecture, security, data, and simplicity, then enforces priority gates before release verification.
argument-hint: "[slug or docs/plans/active/<slug>.md]"
---

# HE Review

Run structured, parallel code review before verify/release.

## When to Use

- After `he-implement` when code is ready for quality gate
- After addressing review findings when material behavior changes occurred (re-review gate)

## Key Principles

1. **Security and data reviews are mandatory** — even for trivial changes.
2. **The priority gate is real** — unresolved `critical`/`high` blocks progression.
3. **Findings must be actionable** — file/symbol + required action + owner.
4. **Escalate on judgment** — unclear risk, ambiguous behavior, or flaky failures.
5. **Runbooks are additive only** — apply any runbook whose frontmatter `called_from` matches this skill (`bash scripts/runbooks/select-runbooks.sh --skill he-review`), but never waive/override any gates codified here.

## Workflow

### Phase 0: Load Context

1. Read `docs/plans/active/<slug>.md`.
2. Gather implementation evidence from diffs/tests and generated reference context in `docs/generated/`.
3. Refresh generated context before review if stale (`db-schema.md`, `api-schema.md`, `component-tree.md`, `dependency-graph.md`, etc.).
4. Run `bash scripts/runbooks/select-runbooks.sh --skill he-review` and read any returned runbooks. Apply their additions throughout — they must not waive or override gates codified here.

### Phase 1: Review Fanout (Parallel)

**For `plan_mode: trivial` (fast-track):**

- Run **correctness reviewer**, **security reviewer**, and **data reviewer** only.
- Skip architecture and simplicity reviewers (trivial criteria guarantee low risk and single-file scope).

**For `plan_mode: lightweight` or `execution`:**

Launch one subagent per reviewer and run concurrently:

1. Correctness reviewer
2. Architecture / invariants reviewer
3. Security reviewer
4. Data integrity / privacy reviewer
5. Simplicity reviewer

Each subagent receives the active plan, diffs, and generated context.

**Shared baseline** — every reviewer checks against:

- `Purpose / Big Picture` and `Validation and Acceptance` in the active plan
- Completed vs. open `Progress` items
- Golden principles defined in AGENTS.md
- Testing philosophy: mock-based tests are a `high` priority finding

**Dimension-specific checklists** — each reviewer reads and executes its reference checklist:

| Reviewer | Reference | Owns |
|---|---|---|
| Correctness | `references/correctness-checklist.md` | Plan fidelity, behavioral correctness, test verification, regression risk |
| Architecture / invariants | `references/architecture-checklist.md` | Structural integrity, design principles, invariant preservation, dependency management, pattern consistency |
| Security | `references/security-checklist.md` | Input handling, auth/authz, secrets, injection prevention, dependency security |
| Data integrity / privacy | `references/data-checklist.md` | Data integrity, transactions, migrations, privacy, retention, persistence-layer correctness |
| Simplicity | `references/simplicity-checklist.md` | YAGNI violations, complexity, redundancy, readability, change proportionality |

Each subagent must evaluate every item in its checklist against the diff. Items that do not apply should be marked N/A with a one-line rationale, not silently skipped.

### Phase 2: Consolidate

Write consolidated findings into `## Review Findings` in the active plan using the format defined in `references/review-output-template.md`.

**Tech-debt routing** — medium and low findings that do not block the gate are appended to `docs/plans/tech-debt-tracker.md` with status `new`. Each entry references the originating slug and reviewer dimension. These items are reviewed during `he-triage` (monthly or on-demand) or next planning round.

### Phase 3: Priority Gate

- Any unresolved `critical` or `high` finding blocks progression.
- `medium` and `low` findings are routed to `docs/plans/tech-debt-tracker.md` with status `new`.

## Non-Negotiable Gates

Runbooks may add repo-specific checks but must not remove or relax these:

- Security and data reviews are always performed.
- Unresolved `critical` or `high` findings block progression.
- Mock-based tests remain a `high` priority finding unless the repo explicitly documents an exception.

If a runbook suggests skipping a non-negotiable gate, treat it as policy drift: record a `high` finding and escalate.

## Priority Rubric (Canonical)

These definitions are the system of record. Runbooks may add repo-specific examples but must not redefine severity levels.

- `critical`: data loss/security issue, correctness bug with high blast radius, or unsafe merge risk
- `high`: user-visible bug, missing rollback/evidence for a risky change, or tests that do not prove behavior
- `medium`: maintainability/clarity issues that should be addressed soon, small correctness edge cases
- `low`: nits, stylistic consistency, small refactors that improve readability

### No-Mocks Policy

Mock-based tests are a `high` finding unless the repo explicitly documents an exception. Repos following a "unit or e2e only" philosophy must not use mocks as a substitute for real integration coverage.

### Mandatory Security Coverage

Missing the security review or data review is a `high` finding (non-negotiable gate).

## Escalation

Escalate early when the risk is unclear or when correctness cannot be demonstrated with evidence. Stop and escalate when:

- Expected behavior is ambiguous or disputed
- Risk to users/data is unclear
- Failures are flaky/non-deterministic
- A "fix" would weaken the evidence or remove meaningful assertions

### Escalation Packet

Provide at minimum:

- Current decision request: what you want approved and which re-entry phase
- Evidence: commands run + short outputs + screenshots/recordings if applicable
- Risk assessment: what could break, who is affected, severity
- Rollback plan: what to revert and how to verify recovery
- Open questions: the smallest set of choices needed to proceed

## Re-entry Rules

### Fundamental Design Issues

When review reveals a design-level issue:

- Return to `he-plan`.
- Append a `Decision Log` entry describing the issue and chosen correction.
- Update affected `Progress` items and `Revision Notes`.

### Material Behavior Changes

When addressing review findings materially alters behavior or implementation (not just style/formatting fixes), re-run `he-review` before proceeding to `he-verify-release`. This is a gate, not optional guidance.

## Output

- Consolidated review findings written to `## Review Findings` in `docs/plans/active/<slug>.md`.

## Exit Gate

- Review findings recorded in active plan
- Critical/high findings resolved or explicitly escalated
- No mock-based tests in implementation
- If fundamental design issue found: re-entry to `he-plan` identified
- Docs commit gate passes

## When Things Go Wrong

- **Reviewer subagent returns ambiguous findings** — request clarification with specific file/line references before consolidating.
- **All reviewers surface the same issue** — deduplicate into one finding with the highest applicable priority.
- **Review findings are contested** — escalate with an escalation packet; do not downgrade severity without evidence.
- **Flaky test failures appear during review** — record as a finding and escalate; do not ignore or retry silently.
- **Runbook contradicts a non-negotiable gate** — treat as policy drift, record a `high` finding, and escalate.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|---|---|
| Skipping security or data review for "small changes" | Both reviews are mandatory for all changes |
| Downgrading severity to unblock progression | Escalate honestly; gate is real |
| Accepting mock-based tests as sufficient | Unit or e2e only; mocks are a `high` finding |
| Consolidating findings without actionable detail | Every finding needs file/symbol + required action + owner |
| Silently accepting medium/low findings | Route to `docs/plans/tech-debt-tracker.md` with status `new` |

## Transition Points

Always use interactive question tool at transitions (`AskUserQuestion` in Claude Code, `request_user_input` in Codex Plan mode, or equivalent). Offer:

1. Continue to `he-verify-release` (recommended when not blocked)
2. Run one more build-feedback round in `he-review`
3. Handoff/pause with status and explicit next action

If running autonomously or no interactive tool is available, continue with `he-verify-release` when gates pass; otherwise stop at the gate and log the blocking reason plus required decision.
