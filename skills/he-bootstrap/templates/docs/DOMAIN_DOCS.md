# Domain Docs Registry

Reference for agents: what domain docs exist, how to detect relevant content, and when to create or update them. Domain docs are **not** created at bootstrap — they are created on-demand by whichever skill first has real context to populate them.

## Domain Docs

| Doc | Path | Purpose | Auto-Detect Signals | Seed Question |
|---|---|---|---|---|
| DESIGN.md | `docs/DESIGN.md` | Design principles, visual direction, interaction standards | — | What are your core design principles? |
| DATA.md | `docs/DATA.md` | Data model and data-change safety rules (migrations/backfills/integrity) | `db/`, migrations, ORM schema files, backfill scripts | What are your data model and migration/backfill safety rules? |
| FRONTEND.md | `docs/FRONTEND.md` | Frontend stack, conventions, component architecture | `package.json` (react/vue/angular/svelte), `next.config.*`, `vite.config.*`, `tsconfig.json` | What's your frontend stack and key conventions? |
| PRODUCT_SENSE.md | `docs/PRODUCT_SENSE.md` | Target users, key outcomes, decision heuristics | — | Who are your target users and what outcomes matter most? |
| RELIABILITY.md | `docs/RELIABILITY.md` | Uptime targets, failure modes, operational guardrails | Dockerfile, health check routes, CI config | What are your reliability requirements? |
| SECURITY.md | `docs/SECURITY.md` | Threat model, auth, data sensitivity, compliance | Auth deps, middleware files, env var references | What security concerns apply? |
| OBSERVABILITY.md | `docs/OBSERVABILITY.md` | Logging, metrics, traces, health checks, agent access | Logging libs (winston/pino/structlog/slog), `/metrics`, opentelemetry/jaeger config, `/healthz` | What observability tools do you use? |
| core-beliefs.md | `docs/design-docs/core-beliefs.md` | Non-negotiable engineering beliefs | — | What are 2-3 non-negotiable engineering beliefs? |

## When to Create or Update

- **he-plan**: If domain docs relevant to the plan don't exist or are stubs, create and populate them using auto-detect signals and planning context
- **he-implement**: If implementation reveals a missing, wrong, or incomplete domain doc, create or update it in-place and note in Revision Notes
- **he-learn**: Post-release policy updates from lessons learned
- **he-doc-gardening**: Flag stale domain docs for refresh

## How to Create or Update

1. Check if the domain doc file exists
2. If missing: create the file at the path above with real content — use auto-detect signals and current context to populate it (don't create empty stubs)
3. If exists but still a stub (`<!-- seed: ... -->` markers only): populate with real content
4. If has content: append or revise — never overwrite existing real content
5. Preserve section structure (headers stay, content fills in)
