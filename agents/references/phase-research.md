# Phase: research

## Purpose

Collect context, explore the codebase, gather requirements. Build understanding before planning.

## Activities

- Read source code, documentation, READMEs, doc.go files
- Explore architecture and dependencies
- Identify relevant packages, modules, and entry points
- Gather requirements from specs, tickets, or user descriptions
- Discover edge cases, constraints, and existing patterns
- Understand how similar features are implemented

## Writing rules

Save **every** finding immediately to `_notes/` — don't accumulate, don't wait for session end. Each discovery, decision, or piece of context gets written as it happens.

**One topic = one file.** Split knowledge into separate `.md` files by topic. Never dump multiple unrelated findings into a single file. If a file grows beyond one topic, split it.

Examples:
- "auth uses JWT with refresh tokens in Redis" → `_notes/research-auth-flow.md`
- "pframes handles column mapping via axis tuples" → `_notes/research-pframes-model.md`
- "tests require Docker for integration suite" → `_notes/research-test-setup.md`

File naming: `_notes/research-<topic-slug>.md`

## Transitions

| To | Trigger |
|----|---------|
| **plan** | Enough context collected to structure the approach. Key areas explored, requirements understood. |

## Completion signals

- Can articulate the problem clearly
- Know which repos/packages are involved
- Understand existing patterns and constraints
- No major unknowns remaining (or unknowns are identified and scoped)
