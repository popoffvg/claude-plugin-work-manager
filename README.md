# work-manager

Work lifecycle management plugin for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Start, track, recall, and complete development tasks with automatic progress logging and knowledge capture.

## Features

- **Three-phase workflow**: research → plan → implement, with allowed back-transitions
- **Structural mode enforcement**: each phase has a dedicated agent with restricted tools — no prompt-based honor system
- **Notes as primary deliverable**: phase agents write findings/decisions/results to `_notes/` as their main output, not a side-effect
- **Auto-progress logging**: Session end hook captures what was accomplished and checks off criteria
- **Auto work notes capture**: Hooks detect architecture decisions, debugging findings, and research results
- **Requirement detection**: User prompt hook automatically adds new requirements mentioned mid-session
- **Multi-repo PR creation**: Discovers all repos with unpushed commits and creates PRs

## Architecture

### Router + Phase Agents

```
User → work-manager (router) → reads phase from _notes/_summary.md
                              → delegates to phase agent
                              → handles transitions

Phase agents:
  work-researcher  (green)  — Read, Glob, Grep, Bash (r/o), Explore agents, Write (_notes/ only)
  work-planner     (yellow) — Read, Glob, Grep, Bash (r/o), Write (_notes/ only)
  work-implementer (red)    — All tools, spawns code subagents
```

**Why three agents?** The `tools` field in agent frontmatter is hard enforcement — the agent physically cannot call tools not listed. A single agent with prompt-based restrictions fails because models ignore behavioral constraints when focused on the user's request.

**Why notes as deliverable?** Telling an agent "do X, and also save findings" fails — saving becomes a skippable side-effect. Making the notes file the primary output means saving IS the work.

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
| `/work start` | Initialize a work session — creates `_notes/` with `_summary.md` and work notes |
| `/work status` | Show current work summary |
| `/work recall [topic]` | Re-orient to current work with dynamic knowledge loading |
| `/work recall --deep` | Load everything for comprehensive context |
| `/work update <message>` | Log progress, capture knowledge, or transition phase |
| `/work done` | Mark work as complete |
| `/work pr` | Create PRs for all repos with unpushed commits |
| `/work help` | Show usage guide |

## How It Works

### Phases & Agents

| Phase | Agent | Primary Deliverable | Can go to |
|-------|-------|-------------------|-----------|
| **research** | `work-researcher` | `_notes/research-*.md` files | plan |
| **plan** | `work-planner` | `_notes/_summary.md` plan + `_notes/plan-*.md` | implement, research |
| **implement** | `work-implementer` | Working code + `_notes/impl-*.md` | research, plan |

**Transitions require explicit user confirmation** — use `/work update move to <phase>`.

### Starting work

```
git checkout -b MILAB-1234-fix-auth-timeout
/work start
```

1. Detects work-id from branch name (e.g., `MILAB-1234`)
2. Collaborates on description and acceptance criteria
3. Creates `_notes/` directory with `_summary.md` (compact index)
4. Sets initial phase to **research** → commands go to `work-researcher`

### During work

The router (`work-manager`) reads phase from `_notes/_summary.md` and delegates:
- Research questions → `work-researcher` (can only read, saves to `_notes/`)
- Planning requests → `work-planner` (can only read + write notes, saves decisions)
- Implementation → `work-implementer` (full access, spawns code subagents)

**Automatic** (via hooks):
- `UserPromptSubmit` hook detects new requirements and adds them to criteria/plan
- `Stop` hook logs progress and captures remaining findings to `_notes/`

**Manual**:
- `/work update move to plan` — transition to plan phase
- `/work update fixed the auth timeout` — logs progress
- `/work recall` — synthesizes current state, next steps, relevant knowledge

### Finishing work

```
/work done    # marks status: done, verifies criteria
/work pr      # creates PRs across all affected repos
```

## Work Notes Structure

```
repo-root/
  _notes/
    _summary.md         # Compact index: plan, criteria, progress, links
    README.md           # Work notes index and structure rules
    research-auth.md    # Research: how auth works
    plan-api-design.md  # Plan: API design decision
    impl-auth-ep.md     # Impl: auth endpoint changes
```

**Rules**:
- `_notes/_summary.md` is an index only — links to other `_notes/` files
- One file per topic, kept under 100 lines (auto-split when growing)
- Phase prefix in filenames: `research-`, `plan-`, `impl-`

## Hooks

| Hook | Event | What It Does |
|------|-------|-------------|
| Requirements detector | `UserPromptSubmit` | Adds new requirements to criteria and plan |
| Progress logger | `Stop` | Logs progress, checks criteria, captures remaining work notes |

Both hooks only activate when `_notes/_summary.md` exists in the current directory.

## License

MIT
