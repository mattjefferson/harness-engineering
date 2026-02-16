# Data Integrity / Privacy Reviewer Checklist

Owns: data integrity, transactions, migrations, privacy, retention, persistence-layer correctness.

> Runbooks may add repo-specific checks to any section below. Language/framework-specific runbooks (e.g., `review-typescript.md`) are the expected extension mechanism. Runbooks must not remove or relax items here.

## Data Integrity

- [ ] Multi-step operations that must succeed or fail together are wrapped in transactions
- [ ] Database migrations are reversible — down migration exists and has been tested
- [ ] CASCADE deletes are intentional and documented — no accidental data loss on parent deletion
- [ ] Database constraints (NOT NULL, UNIQUE, CHECK, FK) match business rules
- [ ] No silent data truncation (string length, numeric overflow, timezone loss)
- [ ] Schema changes are consistent with generated schema context in `docs/generated/` (if present) and migration files
- [ ] Concurrent writes to the same rows are handled (optimistic locking, upsert, or documented exclusion)

## Data Privacy

- [ ] PII is not logged in plaintext (names, emails, addresses, IDs)
- [ ] Sensitive data at rest is encrypted or the decision not to encrypt is documented
- [ ] Data retention lifecycle is defined for new data stores
- [ ] API responses are scoped to the requesting user — no leaking other users' data
- [ ] Deleted data is actually removed (not just soft-deleted and still queryable without auth)
- [ ] Data exports and bulk endpoints don't expose fields beyond what the consumer needs

## Data Transformations

- [ ] Transformations preserve meaning — no silent type coercion, truncation, or precision loss
- [ ] Serialization/deserialization round-trips preserve data integrity
- [ ] Timezone handling is explicit — no implicit local-time assumptions
- [ ] Encoding conversions (UTF-8, Base64, URL-encoding) are correct and consistent

## Query Correctness

- [ ] Queries return correct results at boundaries (first page, last page, empty result set, single result)
- [ ] Pagination, sorting, and filtering handle edge cases (no items, duplicate sort keys, filter matches nothing)
- [ ] N+1 query patterns are avoided for list endpoints
- [ ] Indexes exist for frequently filtered/sorted columns in new tables

## Priority Guidance

| Situation | Typical Priority |
|---|---|
| Data loss possible (CASCADE, missing transaction) | `critical` |
| PII logged in plaintext | `high` |
| Silent data truncation or precision loss | `high` |
| Missing migration reversibility | `high` |
| Soft-delete leaks data without auth | `high` |
| Missing data encryption documentation | `medium` |
| N+1 query on list endpoint | `medium` |
| Missing index on filtered column | `medium` |
| Timezone assumption not documented | `low` |
| Data retention lifecycle undefined | `medium` |
