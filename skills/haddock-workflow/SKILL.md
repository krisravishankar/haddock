---
name: haddock-workflow
description: Core workflow knowledge for Haddock — session lifecycle, NDJSON format, data model, and command relationships
---

# Haddock Workflow Skill

You are working with **Haddock**, a living plan manager that tracks implementation progress through session-scoped plans stored as NDJSON.

## Philosophy

A **session** is the unit of work — a focused coding session (60-120 minutes) with clear scope, defined stories, and tracked outcomes. Sessions form a dependency graph that represents the implementation plan.

## Directory Structure

All state lives in `.haddock/` in the project working directory (or a designated git repo):

```
.haddock/
├── active                              # Contains name of active project
└── projects/
    └── <project-name>/
        ├── config.json                 # Project configuration
        ├── plan.ndjson                 # One line per session (the plan)
        └── sessions.ndjson            # One line per completed session (append-only log)
```

Multiple projects can coexist. The `active` file contains the name of the current project.

### Storage Resolution

When the working directory is not itself a git repo, `.haddock/` may be stored in a child git repo for shareability. Commands find `.haddock/` as follows:

1. Check for a `.haddock_root` file in the current working directory
2. If found, read the path inside it — that directory contains `.haddock/`
3. If not found, use `.haddock/` in the current directory (backwards compatible)

The `.haddock_root` pointer file is created by `/haddock:init` when the user chooses to store `.haddock/` in a child git repo.

## NDJSON Rules

1. **One JSON object per line** — never pretty-print NDJSON files
2. **No trailing commas** — each line is a complete, valid JSON object
3. **plan.ndjson is rewritable** — rewrite the entire file when updating session statuses or replanning
4. **sessions.ndjson is append-only** — only add new lines, never modify existing entries
5. **Validate against schema** — read `resources/schema.json` from the plugin directory for field definitions

## Session Lifecycle

Sessions move through these states. See `references/lifecycle.md` for the full state machine.

```
not_started → ready → planning → in_progress → in_review → merged
                ↓                     ↓
             blocked              (back to ready if abandoned)
```

- A session is `ready` when all its dependencies are `merged`
- A session is `blocked` when any dependency is not yet `merged`
- `/haddock:next` transitions a session from `ready` → `planning`
- The developer transitions `planning` → `in_progress` when implementation begins
- `/haddock:done` transitions to `in_review` or `merged`
- After a session transitions to `merged`, recalculate all downstream sessions' readiness

## Progressive Loading

Not every command needs all data. Load only what's needed:

| Command | Files to read |
|---------|--------------|
| `init` | Nothing (creates files) |
| `plan` | config.json, PRD |
| `replan` | config.json, plan.ndjson, sessions.ndjson, new input |
| `next` | plan.ndjson |
| `done` | plan.ndjson, sessions.ndjson (to append) |
| `status` | plan.ndjson, sessions.ndjson (for `--report`) |
| `log` | sessions.ndjson |
| `sync` | N/A (Phase 2) |

## Command Workflow

The typical workflow is:

1. `/haddock:init <name>` — initialize a project
2. `/haddock:plan` — create the implementation plan from a PRD
3. `/haddock:next` — pick the next session to work on
4. *(do the work)*
5. `/haddock:done` — record what happened
6. Repeat 3-5 until plan is complete
7. `/haddock:replan` — adjust the plan if scope changes
8. `/haddock:status` — check progress at any time
9. `/haddock:log` — review session history

## Validation

When writing NDJSON records:
1. Read `resources/schema.json` from the plugin directory to get field definitions
2. Ensure all required fields are present
3. Use ISO 8601 format for all timestamps
4. Session IDs follow the pattern `S001`, `S002`, etc.
5. Story IDs follow the pattern `S001-01`, `S001-02`, etc.
6. Reference `resources/example-plan.ndjson` and `resources/example-sessions.ndjson` for concrete examples

## File References

- Schema: `resources/schema.json`
- Examples: `resources/example-plan.ndjson`, `resources/example-sessions.ndjson`, `resources/example-config.json`
- Lifecycle details: `skills/haddock-workflow/references/lifecycle.md`
- NDJSON format details: `skills/haddock-workflow/references/ndjson-format.md`
