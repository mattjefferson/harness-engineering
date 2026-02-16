---
name: he-video
description: Captures paired browser bug evidence videos using agent-browser (`failure` before fix and `resolution` after fix), stores raw captures in `tmp/artifacts`, and supports minimal manual promotion for durable review evidence. Use for browser/UI bug fixes and release evidence.
argument-hint: "--slug <slug> --scenario <scenario-id> --phase <failure|resolution> --flow-script <path>"
---

# HE Browser Evidence

Capture browser bug evidence as a durable before/after pair:

- `failure` video: reproduces current broken behavior before the fix
- `resolution` video: shows behavior after the fix on the same scenario

This skill is first-party and uses `agent-browser` as the execution engine.

## When to Use

- Browser/UI bug fixes requiring visual evidence
- Release evidence for user-visible behavior changes
- Before/after proof for `he-verify-release` gates

## Key Principles

1. **Same scenario before/after** — `failure` and `resolution` must represent the same flow.
2. **Tmp-first artifacts** — store raw captures in `tmp/artifacts` by default; promote only minimal evidence when durable sharing is needed.
3. **Keep clips reviewable** — short, focused captures beat long walkthroughs.
4. **Do not "fix the repro" silently** — any changes to the flow must be explicit and explained.
5. **Evidence is a gate** — missing paired videos for a UI bug fix implies `NO-GO`.
6. **Runbooks are additive only** — apply any runbook whose frontmatter `called_from` matches this skill (`bash scripts/runbooks/select-runbooks.sh --skill he-video`), but never waive/override anything codified here.

## Workflow

### Phase 0: Load Inputs

1. `slug`: initiative slug (`YYYY-MM-DD-<type>-<description>`)
2. `scenario`: short scenario ID (`login-timeout`, `checkout-coupon`, etc.)
3. `phase`: `failure` or `resolution`
4. `flow-script`: script that runs the browser flow with `agent-browser` (Python preferred)
5. Run `bash scripts/runbooks/select-runbooks.sh --skill he-video` and read any returned runbooks. Apply their additions throughout — they must not waive or override gates codified here.

### Phase 1: Capture Evidence

Record pre-fix failure evidence:

```bash
bash skills/he-video/scripts/record-browser-evidence.sh \
  --slug 2026-02-15-login-timeout \
  --scenario login-timeout \
  --phase failure \
  --flow-script ./scripts/e2e/login-timeout-flow.py
```

Record post-fix resolution evidence:

```bash
bash skills/he-video/scripts/record-browser-evidence.sh \
  --slug 2026-02-15-login-timeout \
  --scenario login-timeout \
  --phase resolution \
  --flow-script ./scripts/e2e/login-timeout-flow.py
```

### Phase 2: Link Artifacts

1. Add raw artifact paths from `tmp/artifacts/...` to plan `Artifacts and Notes`.
2. Include evidence references in `Verify/Release Decision`.
3. Use `templates/evidence-entry-template.md` as the plan snippet format.

### Phase 2.5: Promote Minimal Committed Evidence (Optional)

When durable/committed evidence is needed for PR or release review, promote only the minimal set:

```bash
bash skills/he-video/scripts/promote-browser-evidence.sh \
  --slug 2026-02-15-login-timeout \
  --scenario login-timeout \
  --phase resolution
```

This copies only:

- latest `<phase>-final-<timestamp>.png`
- `manifest.tsv`

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
4. Add raw artifact paths to plan `Artifacts and Notes`.
5. If durable shared evidence is needed, run minimal promotion and add promoted paths.

## Output

Raw artifacts written to:

- `tmp/artifacts/<slug>/browser/<scenario>/failure-<timestamp>.webm`
- `tmp/artifacts/<slug>/browser/<scenario>/resolution-<timestamp>.webm`
- `tmp/artifacts/<slug>/browser/<scenario>/<phase>-final-<timestamp>.png`
- `tmp/artifacts/<slug>/browser/<scenario>/<phase>-<timestamp>.log`
- `tmp/artifacts/<slug>/browser/<scenario>/manifest.tsv`

Optional promoted minimal set (committed when needed):

- `docs/artifacts/<slug>/browser/<scenario>/<phase>-final-<timestamp>.png`
- `docs/artifacts/<slug>/browser/<scenario>/manifest.tsv`

`manifest.tsv` is append-only and tracks each capture.

## Exit Gate

- Both `failure` and `resolution` videos exist and are non-empty
- Scenario IDs match across both captures
- Plan artifact references are updated (raw and, if applicable, promoted paths)
- If this is a browser bug fix and paired videos are missing, release decision should be `NO-GO`

## When Things Go Wrong

- **Flow script fails during `resolution` capture** — this means the fix didn't work. Investigate before re-capturing.
- **Flow script fails during `failure` capture** — allowed and logged, but verify the failure is the expected bug, not a script error.
- **Scenario IDs don't match between captures** — re-capture with consistent IDs; evidence must be paired.
- **`agent-browser` is unavailable** — escalate; do not substitute with manual screenshots for gate evidence.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|---|---|
| Changing the flow script between failure and resolution | Same scenario, same flow — only the fix changes |
| Long, unfocused capture walkthroughs | Short, focused clips that demonstrate the specific behavior |
| Missing artifact links in the plan | Always update `Artifacts and Notes` and `Verify/Release Decision` |
| Skipping failure capture ("we know it's broken") | Evidence is a gate; capture both sides |
| Manual screenshots instead of automated evidence | Use `agent-browser` for reproducible, durable artifacts |
| Committing full raw recordings by default | Keep raw captures in `tmp/artifacts`; promote only minimal set when needed |
