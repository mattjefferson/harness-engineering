# AGENTS.md

## Core Principles

- Plans are first-class artifacts.
- Use trivial mode (`plan_mode: trivial`) for single-file, low-risk changes — skips planning and runs an abbreviated workflow.
- Use ephemeral lightweight plans for small changes.
- Capture complex work in execution plans with `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective`, committed to the repository.
- Keep active plans, completed plans, and technical debt versioned and co-located so agents do not depend on external context.
- Enable progressive disclosure: agents start from a small, stable entry point and follow explicit pointers to deeper context as needed.

## Skills

| Skill | Purpose |
|---|---|
| `he-bootstrap` | Initialize workflow docs structure |
| `he-spec` | Convert request into spec |
| `he-research` | Investigate open questions before planning |
| `he-spike` | Time-boxed investigation for unclear work |
| `he-plan` | Convert spec into executable plan |
| `he-implement` | Execute tasks in parallel batches |
| `he-review` | Parallel review fanout + priority gating |
| `he-verify-release` | Release readiness GO/NO-GO |
| `he-runbook` | Create/update `docs/runbooks/` entries (frontmatter + additive-only integration) |
| `he-learn` | Capture lessons + archive plan |
| `he-doc-gardening` | Periodic doc maintenance |
| `he-worktree` | Isolated workspace setup via git worktree/branch |
| `he-workflow` | End-to-end orchestrator |

## Runbooks

- `skills/he-bootstrap/templates/docs/runbooks/update-agents-md.md` - Best practices for editing this file without drift
