---
name: work-help
description: >
  This skill should be used when the user says "work help", "how does work manager work",
  "work usage", "work commands", "what can work do". Shows available commands, workflow, and tips.
---

# work-help

Display the following usage guide to the user:

---

## Work Manager — Usage Guide

### Commands

| Command | What it does |
|---------|-------------|
| `/work start` | Begin new work — creates `_summary.md` + `_memory/` knowledge directory |
| `/work status` | Show current work status and progress |
| `/work recall` | Re-orient: what was I doing, what's next? |
| `/work recall --deep` | Full synthesis including all knowledge files |
| `/work recall <topic>` | Show specific knowledge file (e.g. `work recall auth-flow`) |
| `/work update` | Log progress, capture knowledge, review structure |
| `/work done` | Mark work complete, check acceptance criteria |
| `/work pr` | Create a PR from current work context |
| `/work help` | This guide |

### Knowledge Hierarchy

```
repo-root/
  _summary.md          # Index — compact overview, links to _memory/
  _memory/
    README.md           # Knowledge index and structure rules
    auth-flow.md        # Topic: how auth works
    db-schema.md        # Topic: database design decisions
    perf-findings.md    # Topic: performance research
    ...
```

**Rules:**
- `_summary.md` = index only (plan, criteria, progress log, knowledge links)
- `_memory/*.md` = one file per topic, under 100 lines each
- Topics split automatically when they grow too large
- Structure is reviewed on every update and session end

### Multi-Repo Workspace

Work always spans **multiple repos with different languages** (Go, TypeScript, Rust, etc.).
The `_summary.md` tracks repos and their languages in a **Repos** table.
Repo list is mutable — use `mise run task-append` to add repos mid-work.
When repos change, update the table via `/work update`.

### Phases

Work progresses through three phases tracked in `_summary.md` frontmatter:

```
research → plan → implement
              ↑        ↓
              ←────────←
```

| Phase | Purpose | Can go to |
|-------|---------|-----------|
| **research** | Collect context, explore codebase, gather requirements | plan |
| **plan** | Build task list, write acceptance criteria, detail the approach | implement, research |
| **implement** | Make edits, write code, run tests | research, plan |

**Writing rules:**
- **research + plan**: save **every** finding immediately to `_memory/` — don't accumulate, don't wait for session end. Each discovery, decision, or piece of context gets written as it happens.
- **implement**: write results and implementation log to `_memory/`

Transition via `/work update move to plan` (or similar phrasing).

### Workflow

1. **Start**: checkout a branch, then `/work start` — creates the hierarchy, phase = research
2. **Research**: explore, gather context — hooks auto-capture knowledge
3. **Plan**: `/work update move to plan` — build task list, write acceptance criteria, detail approach
4. **Implement**: `/work update move to implement` — write code, run tests
5. **Iterate**: go back to research or plan when needed
6. **Add repos**: `mise run task-append` if you need more repos, then `/work update` to sync
7. **Check in**: `/work recall` to re-orient, `/work recall <topic>` for deep dive
8. **Finish**: `/work done` to verify criteria, then `/work pr`

### How hooks work

- **UserPromptSubmit**: detects new requirements → updates plan/criteria in `_summary.md`
- **Stop**: logs progress, captures knowledge into `_memory/` files, reviews structure

### Tips

- Knowledge is captured automatically — the Stop hook extracts insights from each session
- Use `/work update` to manually save important findings mid-session
- `_memory/` files are topic-based, not chronological — same topic accumulates in one file
- Edit any file directly if you need to fix something fast
- `/work recall --deep` loads everything for full context (uses more tokens)
