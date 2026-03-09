# Phase: plan

## Purpose

Build a concrete task list, write acceptance criteria, detail the implementation approach. Turn research into actionable steps.

## Activities

- Write acceptance criteria (clear, testable conditions for "done")
- Break work into ordered task list with concrete steps
- Identify files and functions to modify
- Design interfaces, data flows, or API changes
- Document decisions and trade-offs in `_memory/`
- Estimate scope and identify risks

## Writing rules

Save **every** finding immediately to `_memory/` — don't accumulate, don't wait for session end. Each decision, trade-off, or design detail gets written as it happens.

File naming: `_memory/plan-<topic-slug>.md`

Examples:
- "chose gRPC over REST because of streaming requirement" → `_memory/plan-api-design.md`
- "need to modify 3 packages: auth, session, middleware" → `_memory/plan-scope.md`
- "risk: migration may break existing clients" → `_memory/plan-risks.md`

## Transitions

| To | Trigger |
|----|---------|
| **implement** | Task list and acceptance criteria are written. Approach is clear. Ready to code. |
| **research** | Discovered unknowns during planning that need exploration before proceeding. |

## Parallel execution planning

During planning, analyze how to split implementation work across parallel subagents. This plan is executed when transitioning to implement phase.

### Decision criteria

1. **Different languages → different agents.** If the task touches Go and TypeScript, plan a Go agent and a TypeScript agent. Each agent works in its own repo/language scope.

2. **Same language → analyze splitting potential.** Within one language, check if tasks are independent enough to split:
   - Independent packages/modules with no shared state → separate agents
   - Separate files with no cross-dependencies → separate agents
   - Tightly coupled changes (shared interfaces, types used across files) → one agent

### How to plan the split

1. Group tasks by repo/language
2. For each language group, check if tasks can be further split (independent modules, no shared types)
3. Document the agent split in `_summary.md` Plan section: which agent handles which tasks, which files, which repo
4. Each agent gets the relevant `_memory/` context for its scope

### Example

Task list: add auth endpoint (Go), update SDK client (TypeScript), add auth tests (Go)

→ Agent 1 (Go): add auth endpoint + add auth tests (same package, coupled)
→ Agent 2 (TypeScript): update SDK client (independent repo)

Both will run in parallel during implement phase.

## Completion signals

- Acceptance criteria are written and specific
- Task list is ordered and actionable
- Each task identifies concrete files/functions to touch
- Agent split is documented (which agents, which tasks, which repos)
- No unresolved design questions blocking implementation
