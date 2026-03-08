## What

**MILAB-4521 -- Fix auth timeout in gateway** (branch: `MILAB-4521-fix-auth-timeout`)

Users hit 504 errors on `/api/auth/refresh` when tokens expire during long-running requests. Root cause: gateway hardcodes a 5s timeout for auth service calls. Goal is to make the timeout configurable, add retry with backoff, and verify under load.

## Plan

| # | Step | Status |
|---|------|--------|
| 1 | Increase gateway timeout to 30s for auth endpoints | **pending** |
| 2 | Add retry logic with exponential backoff | **pending** |
| 3 | Add integration test for token refresh during slow requests | **done** |

**Current position**: Step 3 is complete. Steps 1 and 2 are next -- the core fix work.

## Acceptance Criteria

| Criterion | Status |
|-----------|--------|
| Gateway timeout for auth endpoints is configurable | pending |
| Retry logic with exponential backoff implemented | pending |
| Integration test covers token refresh scenario | **done** |
| No 504 errors in staging load test | pending |

1 of 4 criteria met.

## Last Activity

- **2026-03-05**: Work created
- **2026-03-06**: Analyzed gateway config, found hardcoded timeout in `middleware.go`
- **2026-03-07**: Added integration test for token refresh (passing)

## Suggested Next Step

You wrote the test first (good) -- now implement the actual fix. **Start with step 1**: make the gateway auth timeout configurable in `middleware.go`. Look for the hardcoded 5s value you identified on March 6 and extract it into a config parameter (defaulting to 30s). Once that's in place, move to step 2 (retry with exponential backoff) and then run the staging load test to close out the remaining criteria.
