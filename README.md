<p align="center">
  <img src="logo.svg" alt="Haddock logo — a captain's cap" width="120"/>
</p>

# Haddock

A living plan manager for **Claude Code** and **GitHub Copilot CLI**. Breaks PRDs into focused coding sessions, tracks dependencies between them, and records outcomes as you work. No custom code — just markdown skills, slash commands, and an agent that does the thinking.

## Installation

**Claude Code:**
```bash
/plugin marketplace add krisravishankar/haddock
/plugin install haddock@krisravishankar-haddock
```

**GitHub Copilot CLI:**
```bash
/plugin install krisravishankar/haddock
```

## Quick Start

```bash
# 1. Initialize a project
/haddock:init my-project

# 2. Create a plan from your PRD
/haddock:plan docs/prd.md

# 3. Pick the next ready session
/haddock:next

# 4. Do the work, then record what happened
/haddock:done

# 5. Check progress
/haddock:status
```

## Commands

| Command | Description |
|---------|-------------|
| `/haddock:init <name>` | Initialize a new project — detects git repo, sets up `.haddock/` storage |
| `/haddock:plan [prd-path]` | Analyze codebase + PRD and generate a dependency-ordered session plan |
| `/haddock:next [session-id]` | Show ready sessions, pick one, and enter planning mode |
| `/haddock:done [session-id]` | Record outcome — completed stories, deferrals, discoveries, blockers |
| `/haddock:status [--report\|--all]` | Progress bar, story counts, risks. `--report` for stakeholder view, `--all` for portfolio |
| `/haddock:replan <reason>` | Revise the plan — adds/removes/reorders sessions while preserving merged work |
| `/haddock:switch [project]` | Switch active project in a multi-project setup |
| `/haddock:purge [project\|--all]` | Remove a project or all projects — non-recoverable |
| `/haddock:log [filters]` | Session history with optional `--from`/`--to` date filters |
| `/haddock:sync` | External sync (Phase 2 — not yet implemented) |

## How It Works

**Sessions** are the unit of work. Each session has a goal, stories with acceptance criteria, a list of files it touches, and dependencies on other sessions. Together they form a DAG.

### Session Lifecycle

```
not_started → ready → planning → in_progress → in_review → merged
     ↓                    ↓
  blocked           (back to ready)
```

- **Automatic transitions:** when a session merges, Haddock recalculates downstream readiness — blocked sessions become ready when their dependencies are met.
- **Command-triggered:** `/haddock:next` moves a session to `planning`, `/haddock:done` records the outcome and advances the status.

### The Planner Agent

The built-in planner agent analyzes your codebase (tech stack, architecture, file structure) and your PRD to design sessions. It identifies file-level impacts, flags merge conflict risks, and builds a dependency graph. During replanning, it preserves merged sessions and reorders the rest.

## Storage

All state lives in `.haddock/` in your working directory:

```
.haddock/
├── active                    # Name of the active project
└── projects/<name>/
    ├── config.json           # Project configuration
    ├── plan.ndjson           # Sessions (rewritable)
    └── sessions.ndjson       # Outcomes (append-only)
```

- **NDJSON format** — one JSON object per line, easy to diff and version-control.
- **plan.ndjson** is rewritable (updated by `/haddock:replan`).
- **sessions.ndjson** is append-only — outcomes are never modified.

If your working directory isn't a git repo, `/haddock:init` will help you choose a git-tracked location and create a `.haddock_root` pointer file.

## Data Model

Sessions contain stories (`S001-01`, `S001-02`, …) with acceptance criteria. Outcomes capture what was completed, what was deferred (and why), discoveries that affect the plan, technical debt, and blockers. See `resources/schema.json` for the full JSON Schema.

## License

MIT
