---
name: work-start
description: >
  This skill should be used when the user says "start work", "work start",
  "begin work", "initialize work". Start new work — detect branch, gather details,
  plan, save work note with hierarchical knowledge structure.
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

## Step 4: Create knowledge structure

Create `.work/` directory in cwd. This holds all detailed knowledge files.

Write `_summary.md` in cwd (the **index** — keep it compact, link to `.work/` files):

```markdown
---
type: work
work-id: <id>
name: <human name>
branch: <branch-name>
project: <project derived from work-id prefix>
created: YYYY-MM-DD
status: active
---

# Work: <name>

## Description

<description from user — 1-3 sentences>

## Plan

<ordered implementation plan agreed with user>

## Acceptance Criteria

- [ ] <criterion 1>
- [ ] <criterion 2>

## Knowledge

<!-- Links to detail files in .work/ — added as knowledge grows -->

## Progress Log

- YYYY-MM-DD: Work created
```

Write `.work/README.md`:

```markdown
# Knowledge Structure

Work: <name> (<work-id>)

## Index

<!-- Auto-maintained list of knowledge files -->

## Structure Rules

- Each file covers ONE topic (architecture decision, research finding, debugging session, etc.)
- Filename: `<short-slug>.md` (e.g. `auth-flow.md`, `db-schema.md`, `perf-findings.md`)
- Keep files under 100 lines — split if larger
- _summary.md links here; this file indexes all .work/ content
```

## Step 5: Report

Print the work file path, `.work/` directory, and confirm structure created.
