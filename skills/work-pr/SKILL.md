---
name: work-pr
description: >
  This skill should be used when the user says "work pr", "create PRs",
  "open pull requests for my repos". Create PRs for all repos in the current
  workspace that have unpushed commits.
---

# work-pr

Creates PRs for all repos in the current workspace with unpushed commits.

## Step 1: Discover repos

- If `go.work` exists in cwd, collect all `use ./path` directories
- Otherwise use cwd as the single repo

## Step 2: For each repo — check for unpushed commits

```
git log @{u}..HEAD --oneline 2>/dev/null || git log HEAD --oneline
```
Skip repos with no local commits ahead of upstream.

## Step 3: Run `/pr` in each qualifying repo

Use `gh pr create` from within the repo directory. If a PR already exists for the branch, print its URL and skip.

## Step 4: Report

| Repo | Branch | PR URL / Status |
|------|--------|-----------------|
| foo  | feat/x | https://github.com/... |
| bar  | fix/y  | already existed |
| baz  | main   | skipped (no commits) |

## MANDATORY: Update Notes

**After completing ANY action in this skill, you MUST update `_notes/worklog.md`** with a timestamped entry describing what was done. Format:
```
- YYYY-MM-DD HH:MM: <action summary>
```

Never skip this step. Notes are the primary deliverable, not a side-effect.
