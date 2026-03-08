---
type: work
work-id: MILAB-4521
name: Fix auth timeout in gateway
branch: MILAB-4521-fix-auth-timeout
project: MILAB
created: 2026-03-05
status: done
---

# Work: Fix auth timeout in gateway

## Description

Users report 504 errors on /api/auth/refresh when token expires during long-running requests. Root cause: gateway hardcoded 5s timeout for auth service calls.

## Plan

1. Increase gateway timeout to 30s for auth endpoints
2. Add retry logic with exponential backoff
3. Add integration test for token refresh during slow requests

## Acceptance Criteria

- [x] Gateway timeout for auth endpoints is configurable
- [x] Retry logic with exponential backoff implemented
- [x] Integration test covers token refresh scenario
- [x] No 504 errors in staging load test

## Progress Log

- 2026-03-05: Work created
- 2026-03-06: Analyzed gateway config, found hardcoded timeout in middleware.go
- 2026-03-07: Added integration test for token refresh (passing)
- 2026-03-08: Work marked done — all acceptance criteria met
