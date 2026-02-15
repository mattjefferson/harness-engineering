# harness-engineering

## Philosophy

Ultimate philosophy:

Turn software delivery into a versioned, evidence-backed control system that both humans and agents can run reliably.

How this is different:

- Artifact-first, not meeting-first: the source of truth is committed specs, plans, logs, and decisions, not standups or tribal memory.
- Three planning modes by intent: trivial for single-file fixes, lightweight for small work, execution for complex work.
- Progressive disclosure: small stable entry point, then deeper context only when needed.
- Gate-driven flow: movement across phases requires explicit evidence, not subjective "looks good."
- Agent-native by design: tasks are structured so parallel agents can execute, review, and verify consistently.
- Compounding learning loop: failures become permanent guardrails (docs, tests, principles), so the system improves over time.

In short: most methodologies optimize coordination; this optimizes reproducible execution with durable context.

This approach is influenced by:

- OpenAI Harness Engineering: https://openai.com/index/harness-engineering/
- Every Compound Engineering Plugin: https://github.com/EveryInc/compound-engineering-plugin
- TMC Iterative Engineering Plugin: https://github.com/tmchow/tmc-marketplace/tree/main/plugins/iterative-engineering

## Table of Contents

- [Philosophy](#philosophy)
- [What This Repo Provides](#what-this-repo-provides)
- [Tech Stack](#tech-stack)
- [Repository Layout](#repository-layout)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Install Script Reference](#install-script-reference)
- [Skill Catalog](#skill-catalog)
- [Harness Workflow Model](#harness-workflow-model)
- [Using The Skills In A Project](#using-the-skills-in-a-project)
- [Development Guide](#development-guide)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Deployment And Distribution](#deployment-and-distribution)

## What This Repo Provides

- A complete `he-*` skill set for harness-oriented delivery:
  - `he-bootstrap`
  - `he-spec`
  - `he-spike`
  - `he-plan`
  - `he-implement`
  - `he-review`
  - `he-verify-release`
  - `he-learn`
  - `he-doc-gardening`
  - `he-workflow` (orchestrator)
- `agent-browser`: browser automation CLI skill for agentic E2E verification (snapshots, clicks, form fills, screenshots, recordings).
- Template documents for specs, plans, learnings, and verify/release decisions.
- `scripts/install.sh` to copy these skills into `.agents` and sync into Claude/extra skill directories.

## Tech Stack

- **Language**: Bash + Markdown
- **Packaging Model**: File-system skill packs (`SKILL.md` + templates)
- **Install Targets**:
  - `~/.agents/skills` (source-of-truth staging, used by Codex)
  - `~/.claude/skills` (default extra target)
- **Workflow Artifacts**: Markdown docs for specs/plans and generated reference context

## Repository Layout

```text
.
├── README.md
├── scripts/
│   └── install.sh
└── skills/
    ├── agent-browser/
    │   ├── SKILL.md
    │   ├── references/
    │   └── templates/
    ├── he-bootstrap/
    │   ├── SKILL.md
    │   └── templates/
    │       ├── AGENTS.md
    │       ├── ARCHITECTURE.md
    │       └── bootstrap.sh
    ├── he-doc-gardening/SKILL.md
    ├── he-implement/SKILL.md
    ├── he-spec/
    │   ├── SKILL.md
    │   └── templates/spec-template.md
    ├── he-learn/
    │   ├── SKILL.md
    │   └── templates/learning-entry-template.md
    ├── he-plan/
    │   ├── SKILL.md
    │   └── templates/active-plan-template.md
    ├── he-review/SKILL.md
    ├── he-spike/
    │   ├── SKILL.md
    │   ├── references/spec-update-guide.md
    │   └── templates/spike-template.md
    ├── he-verify-release/SKILL.md
    └── he-workflow/SKILL.md
```

## Prerequisites

- macOS/Linux shell environment
- Bash (used by `scripts/install.sh` and bootstrap template script)
- Write access to:
  - `~/.agents/skills`
  - `~/.claude/skills` (if enabled)

Optional but recommended:
- `git`
- An installed agent runtime that reads skills from one or more target directories

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/mattjefferson/harness-engineering.git
cd harness-engineering
```

### 2. Preview install actions (safe)

```bash
./scripts/install.sh --dry-run
```

### 3. Install skills

```bash
./scripts/install.sh
```

By default this does all of the following:
- Copies local `skills/*` into `~/.agents/skills`
- Copies those installed skills into `~/.claude/skills`
- Removes legacy `~/.codex/skills` (Codex now reads `~/.agents/skills`)

### 4. Verify installed skills exist

```bash
ls -1 ~/.agents/skills | rg '^he-'
ls -1 ~/.claude/skills | rg '^he-'
test ! -d ~/.codex/skills
```

### 5. Use in a target project

In the project where you want to run the workflow, start with `he-bootstrap`, then proceed through the lifecycle.

## Install Script Reference

Script: `scripts/install.sh`

### Command

```bash
./scripts/install.sh [options]
```

### Options

| Option | Description | Default |
|---|---|---|
| `--source <dir>` | Source skills directory | `<repo>/skills` |
| `--agents-home <dir>` | Base `.agents` path | `~/.agents` |
| `--target <dir>` | Extra install target (repeatable) | none |
| `--no-claude` | Skip sync to `~/.claude/skills` | disabled |
| `--dry-run` | Print copy operations only | off |
| `-h`, `--help` | Show help | n/a |

### Usage examples

Install to all defaults:

```bash
./scripts/install.sh
```

Install only to `.agents` (skip Claude sync):

```bash
./scripts/install.sh --no-claude
```

Install to defaults plus an additional target:

```bash
./scripts/install.sh --target ~/.config/my-agent/skills
```

Use custom source and agents home:

```bash
./scripts/install.sh --source ./skills --agents-home ~/.agents
```

## Skill Catalog

| Skill | Primary Purpose | Key Output / Gate |
|---|---|---|
| `agent-browser` | Agentic browser automation for E2E verification | Screenshots/recordings/text extraction as evidence |
| `he-bootstrap` | Initialize workflow docs structure in a project | Creates `docs/specs`, `docs/spikes`, `docs/plans`, and `docs/generated` |
| `he-spec` | Convert request into a concrete initiative spec | `docs/specs/<slug>.md` |
| `he-spike` | Time-boxed investigation for unclear/high-risk work | `docs/spikes/<slug>-spike.md` |
| `he-plan` | Convert spec into a PLANS.md-compliant ExecPlan | `docs/plans/active/<slug>.md` |
| `he-implement` | Execute milestones from Progress checkboxes | Updates living plan sections and uses `docs/generated/*` context |
| `he-review` | Run parallel review fanout + priority gating | Review findings in active plan |
| `he-verify-release` | Check release readiness and record GO/NO-GO | Verify/release decision section in plan |
| `he-learn` | Capture post-release lessons + archive plan | Move plan to `docs/plans/completed/<slug>.md` |
| `he-doc-gardening` | Periodic doc-gardening for stale/obsolete docs | New doc-fix specs/plans + tracker updates |
| `he-workflow` | End-to-end orchestrator across all phases | Enforces phase order + gates |

## Harness Workflow Model

### Slug convention

All initiative artifacts share one slug:

```text
YYYY-MM-DD-kebab-topic
```

Example:

```text
2026-02-14-install-skill-sync
```

### Phase order

1. intake
2. spike (optional — for unclear or high-risk work)
3. plan
4. implement
5. review
6. verify-release
7. learn

`doc-gardening` is periodic/optional.

### Plan modes

- `trivial`: single-file, low-risk changes that skip `he-plan` entirely — goes straight from spec to implement with single-reviewer review and abbreviated learn
- `lightweight`: small, low-complexity work captured with fewer milestones and concise prose
- `execution`: complex work captured with deeper context, milestones, and richer evidence

### Source of truth hierarchy (in consuming repos)

1. Human intent: `docs/specs/<slug>.md`
2. Spike findings: `docs/spikes/<slug>-spike.md` (if a spike was run)
3. Execution plan: `docs/plans/active/<slug>.md` (`plan_mode: trivial|lightweight|execution`)
4. Generated context: `docs/generated/` (for example `docs/generated/db-schema.md`)

### Hard gates

- **Doc commit gate** between phase transitions
- **Priority gate**: unresolved `critical`/`high` findings block progression
- **Progress gate**: `## Progress` is the single checklist section and must be timestamped with stable IDs
- **Section gate**: active plans include all required PLANS sections (`Purpose`, `Progress`, `Surprises`, `Decision Log`, `Outcomes`, `Context`, `Milestones`, `Plan of Work`, `Concrete Steps`, `Validation`, `Idempotence`, `Artifacts`, `Interfaces`, `Revision Notes`)
- **Validation gate**: plans include concrete commands and observable acceptance outcomes
- **Testing gate**: verification uses unit/e2e evidence only — no mocks
- **Living-plan gate**: `Surprises & Discoveries`, `Decision Log`, `Outcomes & Retrospective`, and `Revision Notes` are append-only and current

### Generated context files

- `docs/generated/db-schema.md`
- `docs/generated/api-schema.md`
- `docs/generated/component-tree.md`
- `docs/generated/dependency-graph.md`
- Each generated file includes a `last_updated` timestamp

## Using The Skills In A Project

### Step 1: Bootstrap a target repo

From the target repo root:

```bash
bash path/to/harness-engineering/skills/he-bootstrap/templates/bootstrap.sh
```

With architecture template:

```bash
bash path/to/harness-engineering/skills/he-bootstrap/templates/bootstrap.sh --with-architecture
```

### Step 2: Validate bootstrap

```bash
test -d docs/specs &&
test -d docs/spikes &&
test -d docs/plans/active &&
test -d docs/plans/completed &&
test -d docs/design-docs &&
test -d docs/generated &&
test -f AGENTS.md &&
test -f docs/plans/tech-debt-tracker.md &&
test -f docs/generated/db-schema.md &&
test -f docs/design-docs/core-beliefs.md
```

### Step 3: Run an initiative

- Use `he-spec` to create the spec.
- If feasibility is unclear, use `he-spike` for a time-boxed investigation.
- Set `plan_mode` in the spec (`trivial`, `lightweight`, or `execution`).
- Use `he-plan` to create the matching active plan file.
- Use `he-implement` for execution batches.
- Use `he-review` and resolve blocking findings.
- Use `he-verify-release` for GO/NO-GO.
- Use `he-learn` to capture lessons and archive the plan.

Or use `he-workflow` to orchestrate this lifecycle end-to-end.

## Development Guide

### Add a new skill

1. Create a new directory under `skills/<skill-name>/`.
2. Add `SKILL.md` with frontmatter and explicit workflow.
3. Add any `templates/` files referenced by the skill.
4. Dry-run the installer.
5. Reinstall and validate in your local agent environment.

### Update existing skill behavior

1. Edit `skills/<skill-name>/SKILL.md`.
2. Keep phase order and gate semantics consistent with `he-workflow`.
3. Update related templates if output contracts changed.
4. Reinstall with `./scripts/install.sh`.

### Keep changes minimal and explicit

- Prefer small skill changes over broad rewrites.
- Treat template files as API contracts for downstream repos.

## Verification

Recommended checks before committing:

```bash
# Shell syntax
bash -n scripts/install.sh

# Installer safety preview
./scripts/install.sh --dry-run

# Bootstrap script usage smoke check
bash skills/he-bootstrap/templates/bootstrap.sh --help
```

## Troubleshooting

### `Error: Source directory not found`

Cause: wrong `--source` path or running script from unexpected location.

Fix:

```bash
./scripts/install.sh --source /absolute/path/to/skills --dry-run
```

### Skills not appearing in Codex/Claude

Cause: target directories skipped or runtime not reading expected path.

Fix:

```bash
./scripts/install.sh
ls -la ~/.agents/skills
ls -la ~/.claude/skills
```

Note: `~/.codex/skills` is legacy and is removed by the installer.

If needed, add an explicit target:

```bash
./scripts/install.sh --target ~/.config/<tool>/skills
```

### `No installable skills found`

Cause: source subdirectories missing `SKILL.md`.

Fix: ensure each skill folder has a valid `SKILL.md` at the top level.

### Bootstrap created only part of docs structure

Cause: running bootstrap from the wrong current directory.

Fix: `cd` to target repo root and rerun bootstrap script.

## Deployment and Distribution

This repository has no runtime service to deploy. Distribution is file-based:

1. Update `skills/` and `scripts/install.sh` in this repo.
2. Pull latest changes where needed.
3. Re-run installer to propagate skills to local agent directories.

For team rollout, pin to a commit/tag and have each developer run:

```bash
git pull
./scripts/install.sh
```
