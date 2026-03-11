---
name: work-implement
description: >
  This skill should be used when the current work phase is "implement".
  Provides the implementation workflow: reading the plan, executing tasks,
  running tests, saving results to _notes/impl-*.md, handling blockers,
  and checking completion criteria.
---

# work-implement

Implement phase workflow. Primary deliverable: working code with results documented in `_notes/impl-*.md`.

## Step 1: Read the plan

Read `_notes/_summary.md` Plan section and work split. Read relevant `_notes/plan-*.md` and `_notes/research-*.md` files for context.

## Step 2: Execute tasks

For each task group from the plan:
- Complete the assigned tasks
- Run tests after changes
- Track: completed tasks, blockers, files changed

Execution rules:
- **Different languages -> separate execution.** Go and TypeScript changes never mix.
- **Independent modules -> parallel execution.**

## Step 3: Save results

After each task group completes:

1. Write results to `_notes/impl-<topic-slug>.md`:
```markdown
# Implementation: <Topic>

Created: YYYY-MM-DD

## Changes Made

- `path/to/file.go:42` — added refresh endpoint
- `path/to/test.go:15` — added integration test

## Test Results

<pass/fail summary>

## Issues Encountered

<blockers, workarounds, surprises>
```

2. Update `_notes/_summary.md`:
   - Check off completed plan steps
   - Check off satisfied acceptance criteria: `- [ ]` -> `- [x]`
   - Append to `_notes/worklog.md`: `- YYYY-MM-DD: <what was done>`
   - Link `_notes/impl-*.md` in Work Notes section

## Step 4: Handle blockers

If blockers or unexpected issues arise:

- **Missing context** -> suggest `/work update move to research`
- **Scope changed** -> suggest `/work update move to plan`
- **Fixable issue** -> fix and continue

## Step 5: Mandatory return to plan

If the user adds **new requirements, tasks, or scope** during implementation:
1. Stop current work
2. Suggest: "New requirements detected. Use `/work update move to plan` to incorporate them before continuing."

Do NOT absorb new requirements into running work.

## Step 6: Check completion

After all tasks complete:
- Verify all plan tasks are checked off
- Verify all acceptance criteria pass
- Run a final test pass if applicable
- Suggest: `/work done` then `/work pr`

## Writing rules

- **File naming**: `_notes/impl-<topic-slug>.md`
- **Save after each task group completes.** Don't wait for everything to finish.
- **Max 100 lines per file.** Split if growing beyond.
- **Update the index.** Every new file must be linked in `_notes/_summary.md` Work Notes section.

## Completion signals

- All plan tasks checked off
- All acceptance criteria pass
- Tests pass
- Ready for `/work done` and `/work pr`
