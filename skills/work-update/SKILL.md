---
name: work-update
description: >
  This skill should be used when the user says "update work", "log progress",
  "check off criteria", "update summary", "mark step done", "save knowledge",
  "document finding", "note decision".
  Update work note, manage knowledge files, and review knowledge structure.
argument-hint: [progress message]
---

# work-update [progress message]

## Step 1: Read state

1. Read `_summary.md` in cwd
2. If not found — tell user, suggest `start work`
3. Read `.work/README.md` to understand current knowledge structure
4. List files in `.work/` to see existing knowledge

## Step 2: Determine update type

From the argument or conversation, classify:

- **Progress log** — simple status update (e.g. "fixed the auth bug")
- **Knowledge capture** — substantial finding, decision, or research (e.g. "the auth flow works via JWT with refresh tokens stored in Redis")
- **Both** — progress that includes significant knowledge

## Step 3: Update progress

- Append to `_summary.md` **Progress Log**: `- YYYY-MM-DD: <progress message>`
- Check off completed acceptance criteria: `- [ ]` -> `- [x]`
- Mark completed plan steps accordingly

## Step 4: Capture knowledge (if applicable)

When the update contains **substantial knowledge** (architecture insight, research finding, debugging conclusion, design decision, API behavior, edge case discovery):

1. **Check existing files** in `.work/` — does this topic already have a file?
2. **If yes**: append to existing file under a new section with date
3. **If no**: create new `.work/<slug>.md` with the knowledge
4. **Update links**: add/update entry in `_summary.md` **Knowledge** section and `.work/README.md` index

Knowledge file template:
```markdown
# <Topic Title>

Created: YYYY-MM-DD

## <Finding/Decision/Research>

<content>
```

## Step 5: Review structure

After every update, review the knowledge structure:

- Any `.work/` file over 100 lines? → Split into focused subtopics
- Any closely related files that should merge? → Consolidate
- Is `_summary.md` **Knowledge** section up to date with all `.work/` files?
- Is `.work/README.md` index accurate?

Report any structural changes made.

## Step 6: Confirm

Report: what was logged, which criteria checked off, which knowledge files created/updated, any structural changes.
