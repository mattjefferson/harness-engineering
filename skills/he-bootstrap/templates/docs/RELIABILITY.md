# RELIABILITY.md

Capture reliability goals, failure modes, and operational guardrails.

## Reliability Goals
<!-- seed: Uptime targets, SLOs, error budgets from bootstrap Q&A. -->

- Common baseline:
- Define 1-3 critical user flows and their SLOs (availability and latency), plus what "degraded" means.
- Document the steady-state load expectations and the worst-case burst assumptions.

## Failure Modes
<!-- seed: Known failure scenarios, blast radius, recovery patterns. -->

- Common baseline:
- Enumerate the top failure modes (dependency down, timeouts, bad deploy, data/backfill issues, config mistakes).
- For each, record: detection signal, blast radius, and the fastest safe rollback/recovery.

## Monitoring
<!-- seed: Observability stack, alerting, health checks, logging approach. -->

- Common baseline:
- Alert on user-impacting symptoms (SLO burn, error rates, latency), not internal noise.
- Ensure every service has a clear health story (liveness/readiness where applicable).

## Operational Guardrails
<!-- seed: Deploy strategy, rollback procedures, incident response basics. -->

- Common baseline:
- Every change has a rollback path (revert, flag off, config rollback) and a verification step.
- Prefer progressive delivery for risky changes (feature flags, canaries, staged rollouts).
