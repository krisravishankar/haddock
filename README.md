# Haddock

A living plan manager plugin for **Claude Code** and **GitHub Copilot CLI**. Manages session-scoped implementation plans for agentic projects, storing state as NDJSON files in `.haddock/` within your repo.

## What It Does

Haddock breaks a PRD into focused coding sessions (60-120 min each), tracks dependencies between them, and records outcomes as you work. No custom code — just markdown skills, slash commands, and an agent that does the thinking.

## Installation

**Claude Code:**
```bash
claude plugin install /path/to/haddock
```

**GitHub Copilot CLI:**
```
/plugin install /path/to/haddock
```

## Commands

| Command | Description |
|---------|-------------|
| `/haddock:init <name>` | Initialize a new project |
| `/haddock:plan [prd-path]` | Create an implementation plan from a PRD |
| `/haddock:next [session-id]` | Select the next session to work on |
| `/haddock:done [session-id]` | Record session outcome |
| `/haddock:status [--report\|--all]` | View plan progress |
| `/haddock:replan <reason>` | Revise the plan based on new info |
| `/haddock:log [filters]` | View session history |
| `/haddock:sync` | Jira sync (Phase 2) |

## Getting Started

```bash
# 1. Initialize a project
/haddock:init my-project

# 2. Create a plan from your PRD
/haddock:plan docs/prd.md

# 3. Start the first session
/haddock:next

# 4. Do the work, then record what happened
/haddock:done

# 5. Check progress
/haddock:status
```

## How It Works

- **Sessions** are the unit of work — each produces a mergeable branch/PR
- Sessions have **stories** with testable acceptance criteria
- Sessions form a **dependency graph** — Haddock tracks what's ready, blocked, or done
- **Outcomes** are recorded after each session: what was completed, deferred, discovered
- The plan is **living** — use `/haddock:replan` to adjust as you learn

## Storage

All state lives in `.haddock/` at the repo root:

```
.haddock/
├── active                    # Name of the active project
└── projects/<name>/
    ├── config.json           # Project configuration
    ├── plan.ndjson           # The plan (one session per line)
    └── sessions.ndjson       # Session outcomes (append-only)
```

Files are NDJSON (one JSON object per line) for easy parsing and diffing.

## License

MIT
