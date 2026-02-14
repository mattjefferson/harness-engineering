# harness-engineering

Harness Engineering skills for running a spec-to-release workflow with phase gates, slug-based artifacts, and generated runtime state.

This repository packages reusable `he-*` skills and templates that can be installed into local agent environments (via `.agents`) and used across projects.

This project is based on the article and learnings from:
- https://openai.com/index/harness-engineering/

It is also based on ideas from:
- https://github.com/EveryInc/compound-engineering-plugin

## Table of Contents

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
  - `he-intake`
  - `he-plan`
  - `he-implement`
  - `he-review`
  - `he-verify-release`
  - `he-learn`
  - `he-entropy`
  - `he-workflow` (orchestrator)
- Template documents for specs, plans, learnings, and verify/release decisions.
- `scripts/install.sh` to copy these skills into `.agents` and sync into Codex/Claude skill directories.

## Tech Stack

- **Language**: Bash + Markdown
- **Packaging Model**: File-system skill packs (`SKILL.md` + templates)
- **Install Targets**:
  - `~/.agents/skills` (source-of-truth staging)
  - `~/.codex/skills` (default target)
  - `~/.claude/skills` (default target)
- **Workflow Artifacts**: Markdown docs + JSON/NDJSON generated run state in consuming repos

## Repository Layout

```text
.
├── README.md
├── scripts/
│   └── install.sh
└── skills/
    ├── he-bootstrap/
    │   ├── SKILL.md
    │   └── templates/
    │       ├── AGENTS.md
    │       ├── ARCHITECTURE.md
    │       └── bootstrap.sh
    ├── he-entropy/SKILL.md
    ├── he-implement/SKILL.md
    ├── he-intake/
    │   ├── SKILL.md
    │   └── templates/spec-template.md
    ├── he-learn/
    │   ├── SKILL.md
    │   └── templates/learning-entry-template.md
    ├── he-plan/
    │   ├── SKILL.md
    │   └── templates/active-plan-template.md
    ├── he-review/SKILL.md
    ├── he-verify-release/
    │   ├── SKILL.md
    │   └── templates/verify-release-decision-section.md
    └── he-workflow/SKILL.md
```

## Prerequisites

- macOS/Linux shell environment
- Bash (used by `scripts/install.sh` and bootstrap template script)
- Write access to:
  - `~/.agents/skills`
  - `~/.codex/skills` (if enabled)
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

By default this does all three:
- Copies local `skills/*` into `~/.agents/skills`
- Copies those installed skills into `~/.codex/skills`
- Copies those installed skills into `~/.claude/skills`

### 4. Verify installed skills exist

```bash
ls -1 ~/.agents/skills | rg '^he-'
ls -1 ~/.codex/skills | rg '^he-'
ls -1 ~/.claude/skills | rg '^he-'
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
| `--no-codex` | Skip sync to `~/.codex/skills` | disabled |
| `--no-claude` | Skip sync to `~/.claude/skills` | disabled |
| `--dry-run` | Print copy operations only | off |
| `-h`, `--help` | Show help | n/a |

### Usage examples

Install to all defaults:

```bash
./scripts/install.sh
```

Install only to `.agents` + Claude (skip Codex):

```bash
./scripts/install.sh --no-codex
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
| `he-bootstrap` | Initialize workflow docs structure in a project | Creates `docs/specs`, `docs/plans`, `docs/generated`, `docs/references` |
| `he-intake` | Convert request into a concrete initiative spec | `docs/specs/<slug>.md` |
| `he-plan` | Convert spec into executable active plan with DAG | `docs/plans/active/<slug>.md` |
| `he-implement` | Execute tasks in dependency-aware parallel batches | Updates `docs/generated/runs/<slug>/...` |
| `he-review` | Run parallel review fanout + severity gating | Review findings in active plan |
| `he-verify-release` | Check release readiness and record GO/NO-GO | Verify/release decision section in plan |
| `he-learn` | Capture post-release lessons + archive plan | Move plan to `docs/plans/completed/<slug>.md` |
| `he-entropy` | Periodic drift/debt cleanup initiatives | New cleanup specs/plans + tracker updates |
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
2. plan
3. implement
4. review
5. verify-release
6. learn

`entropy` is periodic/optional.

### Source of truth hierarchy (in consuming repos)

1. Human intent: `docs/specs/<slug>.md`
2. Execution plan: `docs/plans/active/<slug>.md`
3. Runtime state: `docs/generated/runs/<slug>/`

### Hard gates

- **Doc commit gate** between phase transitions
- **Severity gate**: unresolved `critical`/`high` blocks progression
- **Dependency gate**: tasks run only when dependencies are satisfied

### Runtime state files

- `docs/generated/runs/<slug>/run.json`
- `docs/generated/runs/<slug>/tasks/<task-id>.json`
- `docs/generated/runs/<slug>/events.ndjson`

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
test -d docs/plans/active &&
test -d docs/plans/completed &&
test -d docs/generated/runs &&
test -d docs/references &&
test -f AGENTS.md &&
test -f docs/plans/tech-debt-tracker.md
```

### Step 3: Run an initiative

- Use `he-intake` to create the spec.
- Use `he-plan` to create the active plan.
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
ls -la ~/.codex/skills
ls -la ~/.claude/skills
```

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

