# work-manager

Work lifecycle management plugin for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Start, track, recall, and complete development tasks with automatic progress logging and knowledge capture.

## Features

- **Three-phase workflow**: research → plan → implement, with allowed back-transitions
- **Auto-progress logging**: Session end hook captures what was accomplished and checks off criteria
- **Auto work notes capture**: Hooks detect architecture decisions, debugging findings, and research results — saving them to `_notes/` files
- **Requirement detection**: User prompt hook automatically adds new requirements mentioned mid-session
- **Multi-repo PR creation**: Discovers all repos with unpushed commits and creates PRs

## Setup

### 1. Install the plugin

```bash
claude plugin install popoffvg/claude-plugin-work-manager
```

### 2. Create the settings file

Create `~/.claude/work-manager.local.md` with your configuration:

```yaml
---
qmd_collection: ctx
---
```

**This file is required.** The plugin uses it to know which QMD collection to search when recalling work context from a different directory.

### 3. Verify

Start a new Claude Code session, checkout a feature branch, and run `/work start`. The plugin should detect your branch name and prompt you for work details.

| Setting | Required | Description |
|---------|----------|-------------|
| `qmd_collection` | No | QMD collection name for context search (default: `ctx`) |

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- [QMD MCP server](https://github.com/nicobailey/qmd) — for recalling work context across directories (optional but recommended)

## Commands

| Command | Description |
|---------|-------------|
| `/work start` | Initialize a work session — creates `_summary.md` and `_notes/` structure |
| `/work status` | Show current work summary |
| `/work recall [topic]` | Re-orient to current work with dynamic knowledge loading |
| `/work recall --deep` | Load everything for comprehensive context |
| `/work update <message>` | Log progress, capture knowledge, or transition phase |
| `/work done` | Mark work as complete |
| `/work pr` | Create PRs for all repos with unpushed commits |
| `/work help` | Show usage guide |

## How It Works

### Phases

Work progresses through three phases, tracked in `_summary.md` frontmatter (`phase:`):

| Phase | Purpose | Can go to |
|-------|---------|-----------|
| **research** | Collect context, explore codebase, gather requirements | plan |
| **plan** | Build task list, write acceptance criteria, detail approach | implement, research |
| **implement** | Make edits, write code, run tests | research, plan |

**Writing rules:**
- **research + plan**: save **every** finding immediately to `_notes/` — don't accumulate, don't wait for session end. Each discovery, decision, or piece of context gets written as it happens.
- **implement**: write results and implementation log to `_notes/`

**Transitions require explicit user confirmation** — hooks may suggest a transition but never auto-apply it. Use `/work update move to <phase>` to transition.

**Triggers for transition:**
- **research → plan**: enough context collected, ready to structure the approach
- **plan → implement**: task list and acceptance criteria written, ready to code
- **plan → research**: discovered unknowns during planning
- **implement → plan**: scope changed, need to revise task list
- **implement → research**: hit something unexpected, need to explore

### Starting work

```
git checkout -b MILAB-1234-fix-auth-timeout
/work start
```

1. Detects work-id from branch name (e.g., `MILAB-1234`)
2. Collaborates on description and implementation plan
3. Creates `_summary.md` (compact index) and `_notes/` directory (detailed work notes)
4. Sets initial phase to **research**

### During work

**Automatic** (via hooks):
- `UserPromptSubmit` hook detects new requirements and adds them to criteria/plan
- `Stop` hook logs progress, captures phase-appropriate work notes to `_notes/`, and suggests phase transitions when work doesn't match the current phase

**Manual**:
- `/work update move to plan` — transition to plan phase
- `/work update fixed the auth timeout by increasing Redis TTL` — logs progress
- `/work recall` — synthesizes current state, phase, next steps, relevant knowledge
- `/work recall auth` — loads specific topic from `_notes/`

### Finishing work

```
/work done    # marks status: done, verifies criteria
/work pr      # creates PRs across all affected repos
```

## Work Notes Structure

```
repo-root/
  _summary.md           # Compact index: plan, criteria, progress, links
  _notes/
    README.md           # Work notes index and structure rules
    auth-flow.md        # Topic: how auth works
    db-schema.md        # Topic: database decisions
    perf-findings.md    # Topic: performance research
```

**Rules**:
- `_summary.md` is an index only — links to detailed `_notes/` files
- One file per topic, kept under 100 lines (auto-split when growing)
- Structure reviewed on every update and session end

## Hooks

| Hook | Event | What It Does |
|------|-------|-------------|
| Requirements detector | `UserPromptSubmit` | Adds new requirements to criteria and plan |
| Progress logger | `Stop` | Logs progress, checks criteria, captures work notes |

Both hooks only activate when `_summary.md` exists in the current directory.

## License

MIT
