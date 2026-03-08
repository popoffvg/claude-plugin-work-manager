# work-manager

Work lifecycle management plugin for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Start, track, recall, and complete development tasks with automatic progress logging and knowledge capture.

## Features

- **Task lifecycle**: Start -> work -> update -> done -> PR, all tracked in `_summary.md`
- **Auto-progress logging**: Session end hook captures what was accomplished and checks off criteria
- **Auto-knowledge capture**: Hooks detect architecture decisions, debugging findings, and research results — saving them to `.work/` files
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
| `/work start` | Initialize a work session — creates `_summary.md` and `.work/` structure |
| `/work status` | Show current work summary |
| `/work recall [topic]` | Re-orient to current work with dynamic knowledge loading |
| `/work recall --deep` | Load everything for comprehensive context |
| `/work update <message>` | Log progress and/or capture knowledge |
| `/work done` | Mark work as complete |
| `/work pr` | Create PRs for all repos with unpushed commits |
| `/work help` | Show usage guide |

## How It Works

### Starting Work

```
git checkout -b MILAB-1234-fix-auth-timeout
/work start
```

1. Detects work-id from branch name (e.g., `MILAB-1234`)
2. Collaborates on description, acceptance criteria, and implementation plan
3. Creates `_summary.md` (compact index) and `.work/` directory (detailed knowledge)

### During Work

**Automatic** (via hooks):
- `UserPromptSubmit` hook detects new requirements in your messages and adds them to criteria/plan
- `Stop` hook logs progress, checks off completed criteria, and captures knowledge to `.work/` files

**Manual**:
- `/work update fixed the auth timeout by increasing Redis TTL` — logs progress
- `/work recall` — synthesizes current state, next steps, relevant knowledge
- `/work recall auth` — loads specific topic from `.work/`

### Finishing Work

```
/work done    # marks status: done, verifies criteria
/work pr      # creates PRs across all affected repos
```

## Knowledge Structure

```
repo-root/
  _summary.md           # Compact index: plan, criteria, progress, links
  .work/
    README.md           # Knowledge index and structure rules
    auth-flow.md        # Topic: how auth works
    db-schema.md        # Topic: database decisions
    perf-findings.md    # Topic: performance research
```

**Rules**:
- `_summary.md` is an index only — links to detailed `.work/` files
- One file per topic, kept under 100 lines (auto-split when growing)
- Structure reviewed on every update and session end

## Hooks

| Hook | Event | What It Does |
|------|-------|-------------|
| Requirements detector | `UserPromptSubmit` | Adds new requirements to criteria and plan |
| Progress logger | `Stop` | Logs progress, checks criteria, captures knowledge |

Both hooks only activate when `_summary.md` exists in the current directory.

## License

MIT
