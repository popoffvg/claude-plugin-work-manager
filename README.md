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
- **Task workspace management** (optional): mise tasks for git worktree-based task isolation

## Workflow

```
1. Create workspace     mise run task           # interactive: pick repos, create worktrees
                        cd tasks/MILAB-1234-fix-auth/

2. Start tracking       /work start             # creates _notes/, detects branch, gathers scope

3. Research phase       (ask questions, explore code)
                        → auto-saves findings to _notes/research-*.md

4. Plan phase           /work update move to plan
                        → build task list, acceptance criteria in _notes/

5. Implement phase      /work update move to implement
                        → write code, run tests, results in _notes/impl-*.md

6. Iterate              /work recall            # re-orient: what's done, what's next
                        /work update <message>  # log progress, capture knowledge

7. Finish               /work done              # verify criteria, mark complete
                        /work pr                # create PRs across all affected repos

8. Cleanup              mise run task-remove    # detach worktrees, delete task folder
```

Mise tasks are **optional** — the core plugin (`/work start`, `/work recall`, etc.) works in any git repo.

| Capability | With mise tasks | Without mise tasks |
|------------|----------------|-------------------|
| Branch management | Automatic worktrees per repo | Manual `git checkout -b` |
| Repo isolation | Each task gets its own working tree | Shared working tree, stash to switch |
| Task creation | `mise run task` (interactive fzf) | Create branch + `cd` + `/work start` |
| Task cleanup | `mise run task-remove` (auto worktree detach) | Manual branch deletion |
| MCP config | Auto-copied `.mcp.json` per worktree | Manual setup |
| Multi-repo | Select multiple repos in one step | Set up each repo individually |

## Commands

| Command | Description |
|---------|-------------|
| `/work install` | Guided setup — plugin, QMD, mise, task scripts |
| `/work start` | Initialize a work session — creates `_notes/` with `_summary.md` and work notes |
| `/work status` | Show current work summary |
| `/work recall [topic]` | Re-orient to current work with dynamic knowledge loading |
| `/work recall --deep` | Load everything for comprehensive context |
| `/work update <message>` | Log progress, capture knowledge, or transition phase |
| `/work done` | Mark work as complete |
| `/work pr` | Create PRs for all repos with unpushed commits |
| `/work help` | Show usage guide |

## Architecture

### Router + Phase Agents + Phase Skills

```
User → work-manager (router) → reads phase from _notes/_summary.md
                              → skill commands: executes directly
                              → phase work: delegates to phase agent
                              → transitions: updates _summary.md

Phase agents:
  work-researcher  (green)  — Read, Glob, Grep, Bash (r/o), Explore agents, Write (_notes/ only)
  work-planner     (yellow) — Read, Glob, Grep, Bash (r/o), Write (_notes/ only)
  work-implementer (red)    — All tools, spawns code subagents

Phase skills (loaded by agents on demand):
  work-research   — scope breakdown, exploration workflow, findings template
  work-plan       — acceptance criteria, task lists, work split, decision template
  work-implement  — task execution, test runs, results template, blocker handling
```

**Why three agents?** The `tools` field in agent frontmatter is hard enforcement — the agent physically cannot call tools not listed. A single agent with prompt-based restrictions fails because models ignore behavioral constraints when focused on the user's request.

**Why phase skills?** Skills describe *what to do* (workflow steps, file templates, writing rules, completion signals). Agents define *how to do it* (tool access, delegation strategy). This separation keeps agents lean and allows progressive disclosure — skill content loads only when the phase activates.

**Why notes as deliverable?** Telling an agent "do X, and also save findings" fails — saving becomes a skippable side-effect. Making the notes file the primary output means saving IS the work.

### Phases & Transitions

| Phase | Agent | Primary Deliverable | Can transition to |
|-------|-------|-------------------|-----------|
| **research** | `work-researcher` | `_notes/research-*.md` files | plan |
| **plan** | `work-planner` | `_notes/_summary.md` plan + `_notes/plan-*.md` | implement, research |
| **implement** | `work-implementer` | Working code + `_notes/impl-*.md` | research, plan |

Transitions require explicit user confirmation — use `/work update move to <phase>`.
Exception: implement→research and implement→plan triggered by blockers auto-switch.

### Hooks

| Hook | Event | What It Does |
|------|-------|-------------|
| Requirements detector | `UserPromptSubmit` | Adds new requirements to criteria and plan |
| Progress logger | `Stop` | Logs progress, checks criteria, captures remaining work notes |

Both hooks only activate when `_notes/_summary.md` exists in the current directory.

### Work Notes Structure

```
_notes/
  _summary.md         # Compact index: plan, criteria, progress, links
  README.md           # Work notes index and structure rules
  worklog.md          # Append-only progress log
  research-auth.md    # Research: how auth works
  plan-api-design.md  # Plan: API design decision
  impl-auth-ep.md     # Impl: auth endpoint changes
```

**Rules**:
- `_notes/_summary.md` is an index only — links to other `_notes/` files
- One file per topic, kept under 100 lines (auto-split when growing)
- Phase prefix in filenames: `research-`, `plan-`, `impl-`

### Task Workspace (mise)

```
workspace-root/                    # your multi-repo workspace
├── .mise.toml                     # mise config with env vars + task_config
├── mise-tasks/                    # task scripts (copied during /work install)
│   ├── task                       # create/list/open/remove task workspaces
│   ├── task-list                  # list and manage tasks
│   ├── task-remove                # remove a task (detach worktrees + delete)
│   └── task-append                # add repos to existing task
├── repo-a/                        # your git repos
├── repo-b/
└── tasks/                         # task worktree folders
    └── MILAB-1234-fix-auth/       # one folder per task (branch name)
        ├── repo-a/                # git worktree
        ├── repo-b/                # git worktree
        ├── _notes/                # work notes (created by /work start)
        │   ├── _summary.md
        │   ├── worklog.md
        │   └── research-*.md
        └── _task.code-workspace   # IDE workspace file
```

## Installation

### Guided install (recommended)

```bash
# Install the plugin
claude plugin install popoffvg/claude-plugin-work-manager

# Or from a local clone
claude plugin add /path/to/work-manager
```

Then start Claude Code and run `/work install` for interactive setup of all components (QMD, mise, task scripts).

### Manual install

#### 1. Install the plugin

```bash
claude plugin install popoffvg/claude-plugin-work-manager
```

#### 2. Create the settings file

Create `~/.claude/work-manager.local.md`:

```yaml
---
qmd_collection: ctx
---
```

#### 3. QMD MCP (recommended)

QMD enables cross-session work context recall. Without it, `/work recall` only finds notes in the current directory.

Add to `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "qmd": {
      "type": "stdio",
      "command": "qmd",
      "args": ["mcp", "--collection", "ctx", "--root", "~/ctx"]
    }
  },
  "permissions": {
    "allow": [
      "mcp__qmd__search", "mcp__qmd__vector_search", "mcp__qmd__deep_search",
      "mcp__qmd__get", "mcp__qmd__multi_get", "mcp__qmd__status"
    ]
  }
}
```

Create the context directory: `mkdir -p ~/ctx/insights`

#### 4. Mise tasks (optional)

Install mise, then copy task scripts to your workspace:

```bash
# Install mise
brew install mise  # or: curl https://mise.run | sh

# Copy task scripts
cp -r ~/.claude/plugins/work-manager/assets/mise-tasks/ /path/to/workspace/mise-tasks/
chmod +x /path/to/workspace/mise-tasks/*
```

Add to your workspace `.mise.toml`:

```toml
[env]
MIL_WORKSPACE_ROOT = "{{config_root}}"
MIL_TASKS_ROOT = "{{config_root}}/tasks"
MIL_REPO_ROOTS = "{{config_root}}"

[task_config]
dir = "mise-tasks"
```

#### 5. Verify

```bash
mise task ls | grep task    # should show task, task-list, task-remove, task-append
```

Start Claude Code, checkout a feature branch, run `/work start`.

## Requirements

| Component | Required | Purpose |
|-----------|----------|---------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | Yes | Plugin host |
| [QMD MCP](https://github.com/nicobailey/qmd) | Recommended | Cross-session context recall |
| [mise](https://mise.jdx.dev/) | Optional | Task workspace management with worktrees |
| [worktrunk](https://worktrunk.dev) (`wt`) | For mise tasks | Git worktree management CLI |
| [fzf](https://github.com/junegunn/fzf) | For mise tasks | Interactive repo/task selection |

**Permission**: Add `"Read(~/.claude/plugins/**)"` to `permissions.allow` in `~/.claude/settings.json`.

## License

MIT
