---
description: Display current plan progress, optionally as a report or portfolio view
---

# /haddock:status

Display the current status of the Haddock plan.

## Arguments

`$ARGUMENTS` — Optional flags:
- `--report`: Generate a stakeholder-friendly narrative report
- `--all`: Show status across all projects (portfolio view)

## Instructions

First, read the Haddock workflow skill from `skills/haddock-workflow/SKILL.md` in the plugin directory.

### Default View (no flags)

1. Read `.haddock/active` to get the active project name
2. Read `.haddock/projects/<name>/plan.ndjson`
3. Parse all sessions and recalculate statuses based on dependencies

Display sessions grouped by status:

```
# Project: my-saas-app

## Progress: 2/6 sessions complete (33%)
████████░░░░░░░░░░░░░░░░ 33%

## Merged (2)
| ID   | Title                    | Stories |
|------|--------------------------|---------|
| S001 | Foundation setup         | 2/2     |
| S002 | Database schema          | 3/3     |

## In Progress (1)
| ID   | Title                    | Stories    | Branch          |
|------|--------------------------|------------|-----------------|
| S003 | Authentication           | 1/2 done   | feat/auth       |

## Ready (1)
| ID   | Title                    | Complexity | Dependencies    |
|------|--------------------------|------------|-----------------|
| S005 | Frontend scaffolding     | medium     | S001            |

## Blocked (2)
| ID   | Title                    | Waiting On          |
|------|--------------------------|---------------------|
| S004 | API endpoints            | S003                |
| S006 | Integration tests        | S004, S005          |

## Summary
- Stories: 12/20 complete
- Deferrals: 1 pending
- Discoveries: 2 logged
- Blockers: 0 active
```

### Report View (`--report`)

1. Also read `.haddock/projects/<name>/sessions.ndjson` for outcome details
2. Generate a stakeholder narrative:

```
# Status Report: my-saas-app
**Date**: 2026-03-18

## What's Done
Foundation and database layers are complete and merged. Authentication
is in progress with JWT token handling done; RBAC is next.

## What's In Progress
Session S003 (Authentication) is actively being worked on. JWT generation
and validation are implemented. Role-based access control is next.

## What's Coming
API endpoints (S004) will start once auth is complete. Frontend
scaffolding (S005) is ready to start independently.

## Risks & Blockers
- Migration runner lacks rollback on partial failure (tech debt, medium severity)
- Project table schema needs team review (deferred from S002)

## Key Discoveries
- Node 20 required for native fetch support (affects S002+)
```

### Portfolio View (`--all`)

1. Read `.haddock/projects/` to list all projects
2. For each project, read its plan.ndjson
3. Display a summary table:

```
# Haddock Portfolio

| Project        | Sessions | Complete | In Progress | Blocked | Ready |
|----------------|----------|----------|-------------|---------|-------|
| my-saas-app    | 6        | 2 (33%)  | 1           | 2       | 1     |
| mobile-app     | 8        | 5 (63%)  | 1           | 1       | 1     |
| data-pipeline  | 4        | 0 (0%)   | 0           | 0       | 2     |

Active project: my-saas-app
```

## Important

- This is a read-only command — never modify any files
- Always recalculate dependency-based statuses before displaying
- If sessions.ndjson has outcomes, use that data to enrich the display (branch names, MR links)
