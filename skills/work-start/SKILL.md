---
name: work-start
description: >
  This skill should be used when the user says "start work", "work start",
  "begin work", "initialize work". Start new work — detect branch, gather details,
  plan, save work note with hierarchical work notes structure.
---

# work-start

## Step 1: Detect work ID from branch

Run `git branch --show-current` in cwd. Parse result:

- Branch `MILAB-1234-fix-auth-timeout` -> work-id = `MILAB-1234`, slug = `fix-auth-timeout`
- No git repo or no branch -> ask user for work ID and name

## Step 2: Check for existing work note

Read `_notes/_summary.md` in cwd.

If it exists, show the user a summary and stop — work already registered.

## Step 3: Gather scope from user

Show detected work-id and humanized name. Ask in one prompt:
1. **Description**: what needs to be done (1-3 sentences)
2. **Acceptance criteria**: what done looks like (bullet list)

## Step 3.5: Context discovery

After the user defines scope and tasks, **search memory and context for relevant information**:

1. **Search QMD** (`mcp__qmd__search` and `mcp__qmd__deep_search`) using keywords from the description and acceptance criteria. Search both `ctx` and `z-core` collections.
2. **Search `_notes/`** in nearby work directories for related past work.
3. **Summarize findings** — present what you found: related insights, past decisions, known patterns, gotchas.

Then ask the user to choose a context-gathering strategy:

```
I found some relevant context from memory (see above).
To build a solid plan, I need to understand the codebase. Choose one:

1. **Point me to specific areas** — suggest repos, packages, or files I should research
   (faster, focused)
2. **Broad codebase scan** — I'll search across all repos for relevant code
   (thorough, may take a while)
```

Wait for user's choice, then:
- **Option 1**: Ask clarifying questions about which areas to explore. Save user's pointers to `_notes/research-scope.md`.
- **Option 2**: Use Grep/Glob across workspace repos with keywords from the task description. Save findings to `_notes/research-codebase-scan.md`.

## Step 3.6: Transition to research phase

Context discovery is complete. The work starts in **research** phase — the plan will be built later when transitioning to **plan** phase.

Tell the user:
```
Context gathered and saved. Work starts in **research** phase.
Next steps:
- Explore the areas identified above
- When ready, use `/work update move to plan` to build the implementation plan
```

## Step 4: Detect repos and languages

Scan the workspace for repos (look for subdirectories with `.git`).
For each repo, detect primary language from file extensions, `go.mod`, `package.json`, `Cargo.toml`, etc.

## Step 5: Create work notes structure

Create `_notes/` directory in cwd. This holds all work notes files including the index.

Write `_notes/_summary.md` (the **index** — keep it compact, link to other `_notes/` files):

```markdown
---
type: work
work-id: <id>
name: <human name>
branch: <branch-name>
project: <project derived from work-id prefix>
created: YYYY-MM-DD
status: active
phase: research
---

# Work: <name>

## Phase: research

Phases: **research** → plan → implement

| Phase | Purpose | Can transition to |
|-------|---------|-------------------|
| research | Collect context, explore codebase, gather requirements | plan |
| plan | Build task list, write acceptance criteria, detail the approach | implement, research |
| implement | Make edits, write code, run tests | research, plan |

**Writing rules:**
- **research + plan**: save **every** finding immediately to `_notes/` — don't accumulate, don't wait for session end. Each discovery, decision, or piece of context gets written as it happens.
- **implement**: write results and implementation log into `_notes/` files

> Update `phase:` in frontmatter and this section header when transitioning.

## Description

<description from user — 1-3 sentences>

## Repos

| Repo | Language | Notes |
|------|----------|-------|
| core/pl | Go | backend platform |
| core/platforma | TypeScript | SDK monorepo |

> Repo list is mutable — repos may be added/removed during work (e.g. `mise run task-append`).
> Update this table when the workspace changes.

## Plan

<ordered implementation plan agreed with user>

## Acceptance Criteria

- [ ] <criterion 1>
- [ ] <criterion 2>

## Work Notes

<!-- Links to detail files in _notes/ — added as work progresses -->
- [worklog](worklog.md)
```

Write `_notes/README.md`:

```markdown
# Work Notes Structure

Work: <name> (<work-id>)

## Index

<!-- Auto-maintained list of work notes files -->

## Structure Rules

- Each file covers ONE topic (architecture decision, research finding, debugging session, etc.)
- Filename: `<short-slug>.md` (e.g. `auth-flow.md`, `db-schema.md`, `perf-findings.md`)
- Keep files under 100 lines — split if larger
- _notes/_summary.md is the index; this file indexes all _notes/ work notes
- `worklog.md` is the running progress log — append-only, one line per entry
```

Write `_notes/worklog.md`:

```markdown
# Work Log

- YYYY-MM-DD: Work created
```

## Step 6: Report and explain rules

Print the work file path, `_notes/` directory, detected repos with languages, and confirm structure created.

Then explain the work rules to the user:

```
## How this works

Your work has three phases:

1. **research** (current) — collect context, explore codebase. Every finding gets saved to `_notes/` immediately.
2. **plan** — build task list, write acceptance criteria. Every decision gets saved to `_notes/` immediately.
3. **implement** — write code, run tests. Results and implementation log go to `_notes/`.

Phase transitions:
- research → plan (enough context collected)
- plan → implement (task list and criteria ready)
- plan → research (discovered unknowns)
- implement → plan (scope changed)
- implement → research (hit something unexpected)

Transitions happen only when you say so — I'll never switch phase without your confirmation.
Use `/work update move to <phase>` to transition.
```
