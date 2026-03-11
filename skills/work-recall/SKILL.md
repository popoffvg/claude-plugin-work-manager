---
name: work-recall
description: >
  This skill should be used when the user says "work recall", "where was I",
  "what was I working on", "resume work". Re-orient to current work — read notes,
  synthesize status, suggest next step.
argument-hint: [--raw]
---

# work-recall [--raw] [--deep] [topic]

## Step 1: Load index

1. Read `_notes/_summary.md` in cwd
2. If not found, also check `_summary.md` in cwd (legacy layout)
3. If still not found — scan immediate subdirectories for `_notes/_summary.md` or `_summary.md`:
   - Use `Glob` with pattern `*/_notes/_summary.md` and `*/_summary.md`
   - If exactly one found — use it (set that subdirectory as the work root for remaining steps)
   - If multiple found — list them and ask user which work context to load
   - If none found — tell user no work context found, suggest `/work start`

## Step 2: Mode selection

**If `--deep`**: read `_notes/_summary.md` AND all `_notes/*.md` files, provide a comprehensive synthesis — see Step 3.

**If `topic` provided**: find and display the matching `_notes/<topic>.md` file. Fuzzy-match against filenames if exact match fails.

**Default mode** (no flags, including `--raw`): display `_notes/_summary.md` content and synthesize — see Step 4.

## Step 3: Deep mode (--deep only)

1. Read `_notes/_summary.md` to get plan and criteria, read `_notes/worklog.md` for progress log
2. List all files in `_notes/` directory
3. Determine **current focus** from:
   - Last 3-5 `_notes/worklog.md` entries (what was done recently)
   - Next unchecked acceptance criterion
   - Next incomplete plan step
4. **Select relevant `_notes/` files** — read only files whose topic relates to the current focus. Skip files about completed/unrelated topics.
5. If no `_notes/` files are relevant or none exist, proceed with `_notes/_summary.md` only.

## Step 4: Synthesize and report

Based on `_notes/_summary.md` only (unless `--deep` was used):

- **Phase**: current phase (research / plan / implement) and allowed transitions
- **What**: description + goal
- **Repos**: list repos with languages
- **Acceptance criteria**: done vs pending
- **Suggested next step**: based on phase, progress, remaining criteria
- **Other work notes available**: list `_notes/` files by name (so user can request them with `work recall <topic>` or `--deep`)

## MANDATORY: Update Notes

**After completing ANY action in this skill, you MUST update `_notes/worklog.md`** with a timestamped entry describing what was done. Format:
```
- YYYY-MM-DD HH:MM: <action summary>
```

Never skip this step. Notes are the primary deliverable, not a side-effect.
