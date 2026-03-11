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
| `/work start` | Begin new work — creates `_notes/` with `_summary.md` and work notes |
| `/work status` | Show current work status and progress |
| `/work recall` | Re-orient: what was I doing, what's next? |
| `/work recall --deep` | Full synthesis including all work notes |
| `/work recall <topic>` | Show specific work note (e.g. `work recall auth-flow`) |
| `/work update` | Log progress, capture work notes, review structure |
| `/work done` | Mark work complete, check acceptance criteria |
| `/work pr` | Create a PR from current work context |
| `/work install` | Guided setup — plugin, QMD, mise, task scripts, worktrunk |
| `/work help` | This guide |

### Work Notes Hierarchy

```
repo-root/
  _notes/
    _summary.md         # Index — compact overview, links to other _notes/ files
    README.md           # Work notes index and structure rules
    auth-flow.md        # Topic: how auth works
    db-schema.md        # Topic: database design decisions
    perf-findings.md    # Topic: performance research
    ...
```

**Rules:**
- `_notes/_summary.md` = index only (plan, criteria, work notes links)
- `_notes/worklog.md` = append-only progress log
- `_notes/*.md` = one file per topic, under 100 lines each
- Topics split automatically when they grow too large
- Structure is reviewed on every update and session end

### Multi-Repo Workspace

Work always spans **multiple repos with different languages** (Go, TypeScript, Rust, etc.).
The `_notes/_summary.md` tracks repos and their languages in a **Repos** table.
Repo list is mutable — use `mise run task-append` to add repos mid-work.
When repos change, update the table via `/work update`.

### Phases & Agents

Each phase has a **dedicated agent** with restricted tools — mode enforcement is structural, not prompt-based.

```
research → plan → implement
              ↑        ↓
              ←────────←
```

| Phase | Agent | Tools | Cannot do |
|-------|-------|-------|-----------|
| **research** | `work-researcher` | Read, Glob, Grep, Bash (r/o), Explore agents, Write (`_notes/` only) | Edit source code |
| **plan** | `work-planner` | Read, Glob, Grep, Bash (r/o), Write (`_notes/` only) | Edit source, spawn agents |
| **implement** | `work-implementer` | All tools | — |

**Primary deliverables by phase:**
- **research**: `_notes/research-*.md` files (findings saved immediately)
- **plan**: updated `_notes/_summary.md` plan + `_notes/plan-*.md` files (decisions saved immediately)
- **implement**: working code + `_notes/impl-*.md` files (results documented)

Transition via `/work update move to plan` (or similar phrasing).

### Workflow

1. **Start**: checkout a branch, then `/work start` — creates `_notes/` with `_summary.md`, phase = research
2. **Research**: explore, gather context — hooks auto-capture knowledge
3. **Plan**: `/work update move to plan` — build task list, write acceptance criteria, detail approach
4. **Implement**: `/work update move to implement` — write code, run tests
5. **Iterate**: go back to research or plan when needed
6. **Add repos**: `mise run task-append` if you need more repos, then `/work update` to sync
7. **Check in**: `/work recall` to re-orient, `/work recall <topic>` for deep dive
8. **Finish**: `/work done` to verify criteria, then `/work pr`

### How it works

- **Router** (`work-manager`): reads phase from `_notes/_summary.md`, delegates to the right phase agent
- **Phase agents**: each has restricted tools baked into their definition — can't be overridden
- **Hooks**: `UserPromptSubmit` detects new requirements, `Stop` logs progress as safety net

### Tips

- Phase agents save findings as their PRIMARY output — not as a side effect
- Use `/work update` to manually save findings or transition phases
- `_notes/` files are topic-based, not chronological — same topic accumulates in one file
- Edit any file directly if you need to fix something fast
- `/work recall --deep` loads everything for full context (uses more tokens)
