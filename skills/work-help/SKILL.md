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
| `/work start` | Begin new work — creates `_summary.md` + `.work/` knowledge directory |
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
  _summary.md          # Index — compact overview, links to .work/
  .work/
    README.md           # Knowledge index and structure rules
    auth-flow.md        # Topic: how auth works
    db-schema.md        # Topic: database design decisions
    perf-findings.md    # Topic: performance research
    ...
```

**Rules:**
- `_summary.md` = index only (plan, criteria, progress log, knowledge links)
- `.work/*.md` = one file per topic, under 100 lines each
- Topics split automatically when they grow too large
- Structure is reviewed on every update and session end

### Workflow

1. **Start**: checkout a branch, then `/work start` — creates the hierarchy
2. **Work**: code normally — hooks auto-capture knowledge and log progress
3. **Check in**: `/work recall` to re-orient, `/work recall <topic>` for deep dive
4. **Finish**: `/work done` to verify criteria, then `/work pr`

### How hooks work

- **UserPromptSubmit**: detects new requirements → updates plan/criteria in `_summary.md`
- **Stop**: logs progress, captures knowledge into `.work/` files, reviews structure

### Tips

- Knowledge is captured automatically — the Stop hook extracts insights from each session
- Use `/work update` to manually save important findings mid-session
- `.work/` files are topic-based, not chronological — same topic accumulates in one file
- Edit any file directly if you need to fix something fast
- `/work recall --deep` loads everything for full context (uses more tokens)
