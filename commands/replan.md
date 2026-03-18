# /haddock:replan

Revise the implementation plan based on new information, scope changes, or session outcomes.

## Arguments

`$ARGUMENTS` — Description of what changed or new requirements to incorporate (e.g., `"add caching layer"`, `"scope reduced — drop OAuth"`).

## Instructions

First, read the Haddock workflow skill from `skills/haddock-workflow/SKILL.md` in the plugin directory.

### Step 1: Load Full Context

1. Read `.haddock/active` to get the active project name
2. Read `.haddock/projects/<name>/config.json`
3. Read `.haddock/projects/<name>/plan.ndjson` — the current plan
4. Read `.haddock/projects/<name>/sessions.ndjson` — all session outcomes
5. If the config has a `prd_path`, read the PRD as well

Build a complete picture:
- Which sessions are complete and what was learned
- All discoveries, deferrals, debt, and blockers from session outcomes
- The current dependency graph and status of all sessions

### Step 2: Analyze Change Request

Understand what `$ARGUMENTS` is asking for:
- **Scope addition**: New features or requirements to add
- **Scope reduction**: Features to remove or simplify
- **Resequencing**: Change the order of remaining work
- **Incorporation**: Absorb deferrals/discoveries into the plan
- **Correction**: Fix incorrect estimates, dependencies, or file lists

If `$ARGUMENTS` is empty, look at pending deferrals and discoveries from sessions.ndjson and ask the developer if those should be incorporated.

### Step 3: Launch Planner Agent

Launch the **planner agent** (`agents/planner.agent.md` in the plugin directory) with:
- The current plan state
- The change request
- All session outcomes (discoveries, deferrals, etc.)
- The codebase context

The agent will propose modifications to the plan.

### Step 4: Show the Diff

Present changes as a clear diff:

```
## Plan Changes

### Added Sessions
| ID   | Title                    | Complexity | Dependencies |
|------|--------------------------|------------|--------------|
| S007 | Redis caching layer      | medium     | S004         |

### Modified Sessions
| ID   | Change                                          |
|------|-------------------------------------------------|
| S004 | Added story S004-03: Cache invalidation hooks   |
| S005 | Dependency added: S007                          |

### Removed Sessions
| ID   | Title                    | Reason                    |
|------|--------------------------|---------------------------|
| S006 | OAuth integration        | Descoped per product team |

### Status Changes
| ID   | From          | To            | Reason                    |
|------|---------------|---------------|---------------------------|
| S005 | ready         | blocked       | Now depends on S007       |
```

### Step 5: Confirm and Write

1. Ask the developer to confirm the changes
2. If confirmed, rewrite `.haddock/projects/<name>/plan.ndjson` entirely:
   - Preserve completed sessions (`merged`) exactly as they are
   - Preserve `in_progress`/`in_review`/`planning` sessions (only modify if explicitly part of the change)
   - Apply additions, removals, and modifications
   - Recalculate all dependency-based statuses
   - Update `updated_at` timestamps on all modified sessions
3. Verify the written file — each line must be valid JSON

### Step 6: Summary

```
## Replan Complete

- Added: 1 session
- Modified: 2 sessions
- Removed: 1 session
- Total: 6 sessions (was 6, now 6)

Run /haddock:status to see the updated plan.
```

## Important

- Never modify sessions with status `merged` — they represent completed work
- Be cautious modifying `in_progress` sessions — warn the developer if changes affect active work
- Session IDs for new sessions should continue the existing sequence (if last ID is S006, new ones start at S007)
- Maintain the append-only nature of sessions.ndjson — only plan.ndjson is rewritten
