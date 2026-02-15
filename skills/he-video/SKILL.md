---
name: he-video
description: Captures paired browser bug evidence videos using agent-browser (`failure` before fix and `resolution` after fix), then records durable artifact paths for implement and verify-release gates. Use for browser/UI bug fixes and release evidence.
argument-hint: "--slug <slug> --scenario <scenario-id> --phase <failure|resolution> --flow-script <path>"
---

# HE Browser Evidence

Capture browser bug evidence as a durable before/after pair:

- `failure` video: reproduces current broken behavior before the fix
- `resolution` video: shows behavior after the fix on the same scenario

This skill is first-party and uses `agent-browser` as the execution engine.

## Inputs

- `slug`: initiative slug (`YYYY-MM-DD-kebab-topic`)
- `scenario`: short scenario ID (`login-timeout`, `checkout-coupon`, etc.)
- `phase`: `failure` or `resolution`
- `flow-script`: bash script that runs the browser flow with `agent-browser`

## Output Contract

Artifacts are written to:

- `docs/artifacts/<slug>/browser/<scenario>/failure-<timestamp>.webm`
- `docs/artifacts/<slug>/browser/<scenario>/resolution-<timestamp>.webm`
- `docs/artifacts/<slug>/browser/<scenario>/<phase>-final-<timestamp>.png`
- `docs/artifacts/<slug>/browser/<scenario>/<phase>-<timestamp>.log`
- `docs/artifacts/<slug>/browser/<scenario>/manifest.tsv`

`manifest.tsv` is append-only and tracks each capture.

## Quick Start

Record pre-fix failure evidence:

```bash
bash skills/he-video/scripts/record-browser-evidence.sh \
  --slug 2026-02-15-login-timeout \
  --scenario login-timeout \
  --phase failure \
  --flow-script ./scripts/e2e/login-timeout-flow.sh
```

Record post-fix resolution evidence:

```bash
bash skills/he-video/scripts/record-browser-evidence.sh \
  --slug 2026-02-15-login-timeout \
  --scenario login-timeout \
  --phase resolution \
  --flow-script ./scripts/e2e/login-timeout-flow.sh
```

## Flow Script Contract

`flow-script` must:

1. Use `agent-browser` commands for navigation/interactions/assertions.
2. Avoid `agent-browser record start/stop` (the wrapper handles recording).
3. Apply the same journey for failure and resolution phases.
4. Exit non-zero when assertions fail.

For `resolution`, non-zero exit is treated as capture failure.
For `failure`, non-zero exit is allowed and logged.

## Process Contract

1. Capture `failure` before changing code.
2. Implement fix.
3. Capture `resolution` using the same flow.
4. Add both artifact paths to plan `Artifacts and Notes`.
5. Include both artifact paths in `Verify/Release Decision` `evidence`.

Use `templates/evidence-entry-template.md` as the plan snippet format.

## Exit Gate

- Both `failure` and `resolution` videos exist and are non-empty.
- Scenario IDs match across both captures.
- Plan artifact references are updated.
- If this is a browser bug fix and paired videos are missing, release decision should be `NO-GO`.
