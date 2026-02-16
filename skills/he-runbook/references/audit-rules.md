# Runbook Audit Rules

Rules for validating runbook content during Phase 2 (Write) and Phase 3 (Validate). Runbooks are additive — they extend skills, never weaken them.

## Prohibited Content

### Escalation Weakening

Runbooks must not:

- Redefine escalation triggers (these live in skills)
- Modify the escalation packet format
- Suggest skipping escalation when criteria are met

### Gate Waiving

Runbooks must not:

- Skip, waive, or override security/data review
- Bypass the priority gate (critical/high blocks progression)
- Circumvent verify-release checks
- Weaken any skill-enforced gate

### Priority Redefinition

Runbooks must not:

- Redefine severity levels (`critical`/`high`/`medium`/`low`)
- Change the blocking threshold (critical/high blocks verify-release)

### Evidence Weakening

Runbooks must not:

- Suggest skipping evidence capture
- Accept incomplete evidence as sufficient
- Default to GO without proof

### Mock Allowance

Runbooks must not:

- Permit mock-based tests as a substitute for unit/e2e unless the repo explicitly documents an exception

### Consent Bypass

Runbooks must not:

- Authorize remote operations (push, merge, PR) without explicit user approval

## What Runbooks Should Do

- Add repo-specific steps that complement skill gates
- Provide concrete commands and expected outputs
- Cross-reference skills via `§ <section>` for immutable rules
- Use `called_from` frontmatter accurately
- Start with the standard additive-only statement
- Keep scope tight: one runbook, one job
