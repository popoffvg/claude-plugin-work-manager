---
name: work-plan
description: >
  This skill should be used when the current work phase is "plan".
  Provides the planning workflow: reading research notes, building acceptance
  criteria, creating ordered task lists with parallelization strategy, saving
  design decisions to _notes/plan-*.md, and transition to implement phase.
---

# work-plan

Plan phase workflow. Primary deliverable: updated `_notes/_summary.md` with concrete plan and `_notes/plan-*.md` files with design decisions.

## Step 1: Read research

Read all `_notes/research-*.md` files. Summarize what is known before proposing a plan.

## Step 2: Build the plan

Work with the user to create:

**Acceptance criteria** — clear, testable conditions for "done":
```markdown
## Acceptance Criteria
- [ ] Auth endpoint returns 401 for expired tokens
- [ ] Refresh token rotation works with Redis TTL
- [ ] SDK client handles token refresh transparently
```

**Ordered task list** — concrete steps with file references:
```markdown
## Plan
1. Add refresh endpoint to `core/pl/pkg/auth/handler.go`
2. Implement token rotation in `core/pl/pkg/auth/token.go`
3. Update SDK client in `core/platforma/sdk/src/auth.ts`
4. Add integration tests in `core/pl/pkg/auth/handler_test.go`
```

**Parallelization strategy** — how to split work:
```markdown
### Work Split
- Group 1 (Go): Tasks 1, 2, 4 — core/pl auth package
- Group 2 (TypeScript): Task 3 — core/platforma SDK
```

Split rules:
- **Different languages -> separate groups.** Go and TypeScript never mix.
- **Independent modules -> parallel groups.**
- Each group should be self-contained with clear inputs/outputs.

## Step 3: Save decisions (PRIMARY DELIVERABLE)

Write design decisions, trade-offs, and rationale to `_notes/plan-*.md`:

File template:
```markdown
# Plan: <Topic>

Created: YYYY-MM-DD

## Decision

<what was decided>

## Rationale

<why this approach over alternatives>

## Trade-offs

- Pro: <benefit>
- Con: <cost>
```

File naming: `_notes/plan-<topic-slug>.md`

Examples:
- "chose gRPC over REST" -> `_notes/plan-api-design.md`
- "need to modify 3 packages" -> `_notes/plan-scope.md`
- "migration risk" -> `_notes/plan-risks.md`

## Step 4: Update _summary.md

After plan is agreed:
- Write the full plan to `_notes/_summary.md` Plan section
- Write acceptance criteria to `_notes/_summary.md` Acceptance Criteria section
- Link all `_notes/plan-*.md` files in Work Notes section
- Append to `_notes/worklog.md`: `- YYYY-MM-DD: Plan completed`

## Step 5: Suggest transition

When the plan is ready:
```
[PLAN] Plan is complete. Task list, acceptance criteria, and work split are documented.
When ready, use `/work update move to implement` to begin coding.
```

If unknowns surface during planning:
```
[PLAN] Discovered unknowns: <list>. Suggest `/work update move to research` to explore before continuing.
```

## Writing rules

- **One topic = one file.** Each design decision or trade-off gets its own file.
- **File naming**: `_notes/plan-<topic-slug>.md`
- **Save immediately.** Write each decision as it's made — don't wait for the full plan.
- **Max 100 lines per file.** Split if growing beyond.
- **Update the index.** Every new file must be linked in `_notes/_summary.md` Work Notes section.

## Completion signals

- Acceptance criteria are specific and testable
- Task list is ordered with concrete file references
- Work split is documented (which groups, which tasks, which repos)
- No unresolved design questions blocking implementation
