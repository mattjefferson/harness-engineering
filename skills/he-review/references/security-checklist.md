# Security Reviewer Checklist

Owns: input handling, auth/authz, secrets, injection prevention, dependency security. **This review is mandatory for all changes** — skipping it is a `high` finding (non-negotiable gate).

> Runbooks may add repo-specific checks to any section below. Language/framework-specific runbooks (e.g., `review-typescript.md`) are the expected extension mechanism. Runbooks must not remove or relax items here.

## Input Handling

- [ ] All external inputs are validated: type, length, format, and allowed values
- [ ] SQL queries use parameterized statements — no string concatenation for query building
- [ ] Shell commands use argument arrays or proper escaping — no string interpolation into commands
- [ ] File paths are validated against traversal (`../`, symlink following, null bytes)
- [ ] HTML/template output is escaped by default — raw output is explicitly justified
- [ ] URL parameters and headers are validated before use

## Authentication and Authorization

- [ ] New endpoints or routes require authentication (no accidental public exposure)
- [ ] Authorization checks verify resource-level access, not just role membership
- [ ] No privilege escalation via ID manipulation (IDOR) — user can only access their own resources
- [ ] Session and token handling follows repo conventions (expiry, refresh, revocation)
- [ ] Admin/elevated actions have additional verification or audit logging

## Secrets and Credentials

- [ ] No hardcoded secrets, API keys, tokens, or passwords in source code
- [ ] Secrets loaded from environment variables or a secrets manager
- [ ] `.gitignore` excludes secret files (`.env`, credential configs, key files)
- [ ] Log output does not contain secrets, tokens, or credentials (check error messages too)
- [ ] Error responses do not leak internal implementation details (stack traces, DB errors, file paths)

## Injection and Output Safety

- [ ] XSS prevention: user-generated content is escaped before rendering in HTML
- [ ] CSRF protection: state-changing requests require CSRF tokens or equivalent
- [ ] No `exec`, `eval`, or dynamic code execution with user-controlled input
- [ ] No unsafe deserialization of untrusted data (pickle, YAML load, Java serialization)
- [ ] HTTP headers set appropriately (Content-Security-Policy, X-Frame-Options, etc., where applicable)

## Dependency Security

- [ ] No known critical or high CVEs in new or updated dependencies (check advisories)
- [ ] Dependencies pulled from trusted registries (no typosquat risk)
- [ ] Lock files updated — no unpinned transitive dependencies with known issues

## Priority Guidance

| Situation | Typical Priority |
|---|---|
| SQL/command/path injection possible | `critical` |
| Hardcoded secret in source | `critical` |
| Missing auth on new endpoint | `critical` |
| IDOR / privilege escalation possible | `critical` |
| Missing input validation on external input | `high` |
| Error response leaks internals | `medium` |
| Missing CSRF protection | `high` |
| Known CVE in dependency (critical/high severity) | `high` |
| XSS possible via unescaped user content | `critical` |
| Unsafe deserialization of untrusted data | `critical` |
