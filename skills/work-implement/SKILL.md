---
name: work-implement
description: >
  This skill should be used when the work-manager router delegates implement-phase work
  to the work-implementer agent. Provides the implementation workflow: reading the plan,
  delegating code changes to general-purpose subagents, running tests, saving results
  to _notes/impl-*.md, and checking completion criteria.
---

# work-implement

Implement phase workflow. Primary deliverable: working code with results documented in `_notes/impl-*.md`.

## STRICT: Subagent delegation rules

**Never work directly.** All work MUST be delegated to subagents:

| Work type | Subagent type | Mode |
|-----------|--------------|------|
| **Code changes** (edit, write, refactor, fix) | `general-purpose` | foreground or `run_in_background: true` for parallel |
| **Log analysis, codebase exploration, reading** | `Explore` | `run_in_background: true` |

**FORBIDDEN actions — never do these directly:**
- Do NOT call Edit, Write (except `_notes/*.md`), or Bash (except git status/log)
- Do NOT read source code files directly — spawn an Explore subagent
- Do NOT run tests directly — include test runs in the general-purpose subagent prompt

**Only direct actions allowed:**
- Read/write `_notes/*.md` including `_notes/_summary.md` (work state management)
- Spawn subagents via Agent tool
- Communicate with the user

## Step 1: Receive task from router

Receive from work-manager:
- The user's request
- Current `_notes/_summary.md` content (with plan, criteria, agent split)
- Relevant `_notes/` files

## Step 2: Read the plan

Read `_notes/_summary.md` Plan section and agent split. Read relevant `_notes/plan-*.md` and `_notes/research-*.md` files for context.

## Step 3: Execute via subagents

### For code changes -> `general-purpose`

```
Agent(
  subagent_type: "general-purpose",
  prompt: "
    ## Context
    - Work ID: <id>
    - Repo: <repo>
    - Language: <lang>

    ## Assigned tasks
    <tasks from plan>

    ## Background (from _notes/)
    <relevant findings>

    ## Instructions
    - Complete the assigned tasks
    - Run tests after changes
    - Report: completed tasks, blockers, files changed
  "
)
```

### For log analysis, reading code, exploration -> `Explore`

```
Agent(
  subagent_type: "Explore",
  run_in_background: true,
  prompt: "
    Find <what> in <where>.
    Report: key files, patterns, relevant code, log output summary.
  "
)
```

### Splitting rules

- **Different languages -> different agents.** Go and TypeScript changes always go to separate agents.
- **Independent modules -> parallel agents.** Use `run_in_background: true` for independent work.
- **Logs/exploration mid-implementation -> Explore agent.** Never read logs or explore codebase directly.

## Step 4: Collect results and save

After each subagent completes:

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

## Step 5: Handle blockers

If a subagent reports blockers or unexpected issues:

- **Missing context** -> suggest `/work update move to research`
- **Scope changed** -> suggest `/work update move to plan`
- **Fixable issue** -> fix and continue

## Step 6: Mandatory return to plan

If the user adds **new requirements, tasks, or scope** during implementation:
1. Stop current work
2. Suggest: "New requirements detected. Use `/work update move to plan` to incorporate them before continuing."

Do NOT absorb new requirements into running subagents.

## Step 7: Check completion

After all subagents complete:
- Verify all plan tasks are checked off
- Verify all acceptance criteria pass
- Run a final test pass if applicable
- Suggest: `/work done` then `/work pr`

## Writing rules

- **File naming**: `_notes/impl-<topic-slug>.md`
- **Save after each subagent completes.** Don't wait for all agents to finish.
- **Max 100 lines per file.** Split if growing beyond.
- **Update the index.** Every new file must be linked in `_notes/_summary.md` Work Notes section.

## Completion signals

- All plan tasks checked off
- All acceptance criteria pass
- Tests pass
- Ready for `/work done` and `/work pr`
