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
| `he-spike` | Time-boxed investigation for unclear work |
| `he-plan` | Convert spec into executable plan |
| `he-implement` | Execute tasks in parallel batches |
| `he-review` | Parallel review fanout + priority gating |
| `he-verify-release` | Release readiness GO/NO-GO |
| `he-learn` | Capture lessons + archive plan |
| `he-doc-gardening` | Periodic doc maintenance |
| `he-workflow` | End-to-end orchestrator |
