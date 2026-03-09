# Phase: implement

> **This phase always runs in subagents.** Never implement directly — spawn subagents according to the agent split from the plan phase.

## Subagent instructions

Each subagent receives these instructions along with its assigned tasks:

### Scope

- Work only on assigned tasks, files, and repo
- Read relevant `_notes/` files for context before starting
- Follow the task list order

### Activities

- Write and modify code following assigned tasks
- Run tests and fix failures
- Handle build errors and linting issues

### Writing rules

Write **results and implementation log** to `_notes/`. Focus on what was done and outcomes, not exploration.

File naming: `_notes/impl-<topic-slug>.md`

Examples:
- "added retry logic to gRPC client, 3 attempts with exponential backoff" → `_notes/impl-grpc-retry.md`
- "test revealed race condition in session cleanup — fixed with mutex" → `_notes/impl-session-race.md`
- "API endpoint added: POST /v1/auth/refresh, returns new token pair" → `_notes/impl-auth-endpoint.md`

### Completion

- Report which tasks were completed and which were not
- Report any blockers or unexpected issues
- If a task requires research or plan revision, stop and report — do not switch phase

## Parent agent responsibilities

After spawning subagents:

1. Collect results from all subagents
2. Update `_summary.md`: check off completed tasks, append to progress log
3. Verify acceptance criteria against subagent results
4. If any subagent reports blockers → suggest transition back to research or plan

## Mandatory return to plan

If the user adds new requirements, tasks, or work scope during implement phase — **stop all subagents and return to plan phase immediately**. New work must be planned before it can be implemented. Do not attempt to absorb new requirements into running subagents.

## Transitions

| To | Trigger |
|----|---------|
| **plan** | User adds new requirements, tasks, or work scope. Approach needs revision. Task list no longer matches reality. |
| **research** | Subagent hit something unexpected that needs exploration. Missing context to proceed. |

## Completion signals

- All tasks in task list are checked off
- All acceptance criteria pass
- Tests pass
- Ready for `/work done` and `/work pr`
