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

**If `--raw`**: display raw `_notes/_summary.md` content and stop.

**If `topic` provided**: find and display the matching `_notes/<topic>.md` file. Fuzzy-match against filenames if exact match fails.

**If `--deep`**: read `_notes/_summary.md` AND all `_notes/*.md` files, provide a comprehensive synthesis.

**Default mode** (no flags): dynamically load relevant work notes — see Step 3.

## Step 3: Dynamic work notes loading

1. Read `_notes/_summary.md` to get plan and criteria, read `_notes/worklog.md` for progress log
2. List all files in `_notes/` directory
3. Determine **current focus** from:
   - Last 3-5 `_notes/worklog.md` entries (what was done recently)
   - Next unchecked acceptance criterion
   - Next incomplete plan step
4. **Select relevant `_notes/` files** — read only files whose topic relates to the current focus. Skip files about completed/unrelated topics.
5. If no `_notes/` files are relevant or none exist, proceed with `_notes/_summary.md` only.

## Step 4: Identify active agent

Based on the `phase:` field from `_notes/_summary.md` frontmatter, note which agent handles the current phase:

| Phase | Agent | Capabilities |
|-------|-------|-------------|
| research | **work-researcher** | Read-only exploration, saves to `_notes/research-*.md` |
| plan | **work-planner** | Builds task list, writes to `_notes/_summary.md` and `_notes/plan-*.md` |
| implement | **work-implementer** | Full tool access, spawns code subagents |

## Step 5: Synthesize and report

- **Phase**: current phase (research / plan / implement), active agent name, and allowed transitions
- **What**: description + goal
- **Repos**: list repos with languages (check if repo list changed since last session)
- **Current focus**: what you're working on now (derived from phase + plan + progress)
- **Relevant work notes**: key points from dynamically loaded `_notes/` files
- **Acceptance criteria**: done vs pending
- **Last activity**: last 3-5 progress log entries
- **Suggested next step**: based on phase, progress, remaining criteria, and loaded work notes. Suggest phase transition if current phase work seems complete.
- **Other work notes available**: list unloaded `_notes/` files by name (so user can request them)
