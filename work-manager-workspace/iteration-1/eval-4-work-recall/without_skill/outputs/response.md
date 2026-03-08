# Where you were

You're on **MILAB-4521 -- Fix auth timeout in gateway**, branch `MILAB-4521-fix-auth-timeout`.

**Problem**: Users hit 504 errors on `/api/auth/refresh` because the gateway has a hardcoded 5s timeout for auth service calls.

## What's done

- Analyzed gateway config, identified hardcoded timeout in `middleware.go` (March 6)
- Integration test for token refresh during slow requests -- written and passing (March 7)

## What's left

Three acceptance criteria remain unchecked:

1. **Make gateway timeout configurable for auth endpoints** -- This is the core fix. You identified `middleware.go` as the location. Next step: replace the hardcoded 5s value with a config parameter (target 30s default).

2. **Add retry logic with exponential backoff** -- Implement retries on the gateway side for auth service calls. Standard pattern: initial delay ~100ms, factor of 2, cap at ~5s, max 3-4 retries.

3. **Verify no 504s in staging load test** -- This comes last, after deploying the fix to staging.

## Recommended next action

Start with **item 1**: make the auth endpoint timeout configurable in `middleware.go`. Once that's in, layer the retry logic (item 2) on top. The test you already wrote should validate both changes.
