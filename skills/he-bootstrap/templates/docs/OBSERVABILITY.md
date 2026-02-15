# OBSERVABILITY.md

Capture logging, metrics, tracing, and health check conventions so agents can reason about runtime behavior.

## Logging Strategy
<!-- seed: Structured vs unstructured, log levels, logging library, log format conventions. -->

- Common baseline:
- Prefer structured logs with consistent fields (service, env, request_id/trace_id, user_id when safe).
- Never log secrets; be deliberate about PII.
- Log at boundaries and on errors; avoid noisy per-loop logging in hot paths.

## Metrics
<!-- seed: What's exposed (counters, gauges, histograms), metrics library, query method (e.g., PromQL). -->

- Common baseline:
- Track the golden signals: latency, traffic, errors, saturation.
- Prefer histograms for latency; keep label cardinality low.

## Traces
<!-- seed: Span naming conventions, critical traced paths, trace library (e.g., OpenTelemetry). -->

- Common baseline:
- Propagate trace context across service boundaries.
- Trace the critical paths (requests, background jobs) with stable span names.

## Health Checks
<!-- seed: Endpoints (e.g., /healthz, /readyz), expected responses, liveness vs readiness. -->

- Common baseline:
- Health checks are fast and deterministic; readiness reflects dependency availability when needed.
- Document expected status codes and what "unhealthy" means operationally.

## Agent Access
<!-- seed: How agents can query logs, metrics, and traces at runtime -- CLI commands, API endpoints, dashboard URLs, LogQL/PromQL examples. This section enables agents to self-verify runtime behavior. -->

- Common baseline:
- Provide at least one concrete way to query each signal (logs, metrics, traces) without tribal knowledge.
- Include 1-2 copy-pastable examples per signal once the stack is known (commands, URLs, or queries).
