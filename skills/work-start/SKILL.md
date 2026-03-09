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

Read `_summary.md` in cwd.

If it exists, show the user a summary and stop — work already registered.

## Step 3: Gather details and plan

Show detected work-id and humanized name. Ask in one prompt:
1. **Description**: what needs to be done (1-3 sentences)
2. **Acceptance criteria**: what done looks like (bullet list)

Then **collaborate on the plan**:
- Ask clarifying questions about ambiguities
- Propose concrete implementation steps, files/packages to touch, risks
- Let user refine before confirming

Proceed only after explicit user approval.

## Step 4: Detect repos and languages

Scan the workspace for repos (look for subdirectories with `.git`).
For each repo, detect primary language from file extensions, `go.mod`, `package.json`, `Cargo.toml`, etc.

## Step 5: Create work notes structure

Create `_notes/` directory in cwd. This holds all work notes files.

Write `_summary.md` in cwd (the **index** — keep it compact, link to `_notes/` files):

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

## Progress Log

- YYYY-MM-DD: Work created
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
- _summary.md links here; this file indexes all _notes/ work notes
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
