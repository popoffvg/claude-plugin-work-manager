---
name: work-update
description: >
  This skill should be used when the user says "update work", "log progress",
  "check off criteria", "update summary", "mark step done", "save knowledge",
  "document finding", "note decision".
  Update work note, manage work notes, and review notes structure.
argument-hint: [progress message]
---

# work-update [progress message]

## Step 1: Read state

1. Read `_summary.md` in cwd
2. If not found — tell user, suggest `start work`
3. Read `_notes/README.md` to understand current notes structure
4. List files in `_notes/` to see existing work notes

## Step 2: Determine update type

From the argument or conversation, classify:

- **Phase transition** — user says "move to plan", "start implementing", "need more research", etc.
- **Progress log** — simple status update (e.g. "fixed the auth bug")
- **Work note capture** — substantial finding, decision, or research (e.g. "the auth flow works via JWT with refresh tokens stored in Redis")
- **Both** — progress that includes significant findings

## Step 3: Handle phase transition (if applicable)

If the update is a phase transition:

1. Validate the transition is allowed:
   - research → plan
   - plan → implement, plan → research
   - implement → research, implement → plan
2. Show the user what the transition means:
   - **research → plan**: "Enough context collected. Moving to plan: build task list, write acceptance criteria."
   - **plan → implement**: "Plan and criteria are ready. Moving to implement: write code, run tests."
   - **plan → research**: "Unknowns discovered during planning. Moving back to research."
   - **implement → research**: "Hit something unexpected. Moving back to research to explore."
   - **implement → plan**: "Scope changed or approach needs revision. Moving back to plan."
3. **Ask for explicit user confirmation** before applying. Do NOT auto-transition.
4. After user confirms:
   - Update `phase:` in frontmatter
   - Update `## Phase:` section header (e.g. `## Phase: plan`)
   - Bold the current phase in the phases line (e.g. `Phases: research → **plan** → implement`)
   - Append to Progress Log: `- YYYY-MM-DD: Phase transition: <old> → <new>`

If transition is not allowed, tell the user and show valid transitions for current phase.

## Step 4: Update progress

- Append to `_summary.md` **Progress Log**: `- YYYY-MM-DD: <progress message>`
- Check off completed acceptance criteria: `- [ ]` -> `- [x]`
- Mark completed plan steps accordingly

## Step 5: Capture work notes (if applicable)

When the update contains **substantial findings** (architecture insight, research finding, debugging conclusion, design decision, API behavior, edge case discovery):

1. **Check existing files** in `_notes/` — does this topic already have a file?
2. **If yes**: append to existing file under a new section with date
3. **If no**: create new `_notes/<slug>.md` with the findings
4. **Update links**: add/update entry in `_summary.md` **Work Notes** section and `_notes/README.md` index

Work note template:
```markdown
# <Topic Title>

Created: YYYY-MM-DD

## <Finding/Decision/Research>

<content>
```

## Step 6: Review structure

After every update, review the notes structure:

- Any `_notes/` file over 100 lines? → Split into focused subtopics
- Any closely related files that should merge? → Consolidate
- Is `_summary.md` **Work Notes** section up to date with all `_notes/` files?
- Is `_notes/README.md` index accurate?

Report any structural changes made.

## Step 7: Confirm

Report: what was logged, which criteria checked off, which work notes created/updated, any structural changes.
