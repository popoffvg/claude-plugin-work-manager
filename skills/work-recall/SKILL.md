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

1. Read `_summary.md` in cwd
2. If not found — derive project name from cwd basename, then search QMD (`collection: "ctx"`) for that project name
   - If QMD returns results: use them as context, summarize what's known, suggest `start work` to create a local summary
   - If QMD returns nothing: tell user no context found, suggest `start work`

## Step 2: Mode selection

**If `--raw`**: display raw `_summary.md` content and stop.

**If `topic` provided**: find and display the matching `.work/<topic>.md` file. Fuzzy-match against filenames if exact match fails.

**If `--deep`**: read `_summary.md` AND all `.work/*.md` files, provide a comprehensive synthesis.

**Default mode** (no flags): dynamically load relevant knowledge — see Step 3.

## Step 3: Dynamic knowledge loading

1. Read `_summary.md` to get plan, criteria, and progress log
2. List all files in `.work/` directory
3. Determine **current focus** from:
   - Last 3-5 progress log entries (what was done recently)
   - Next unchecked acceptance criterion
   - Next incomplete plan step
4. **Select relevant `.work/` files** — read only files whose topic relates to the current focus. Skip files about completed/unrelated topics.
5. If no `.work/` files are relevant or none exist, proceed with `_summary.md` only.

## Step 4: Synthesize and report

- **What**: description + goal
- **Current focus**: what you're working on now (derived from plan + progress)
- **Relevant knowledge**: key points from dynamically loaded `.work/` files
- **Acceptance criteria**: done vs pending
- **Last activity**: last 3-5 progress log entries
- **Suggested next step**: based on progress, remaining criteria, and loaded knowledge
- **Other knowledge available**: list unloaded `.work/` files by name (so user can request them)
