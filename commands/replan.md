---
description: Revise the implementation plan based on new information or scope changes
---

# /haddock:replan

Revise the implementation plan based on new information, scope changes, or session outcomes.

## Arguments

`$ARGUMENTS` — Description of what changed or new requirements to incorporate (e.g., `"add caching layer"`, `"scope reduced — drop OAuth"`).

## Instructions

First, resolve the haddock root: if `.haddock_root` exists in the current directory, read it to get the path to `.haddock/`. Otherwise, use `.haddock/` in the current directory. Use this resolved path for all `.haddock/` references below.

Read the Haddock workflow skill from `skills/haddock-workflow/SKILL.md` in the plugin directory.

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

### Step 3: Check for Existing Replan in Conversation

Check whether the current conversation already contains proposed plan changes from a prior planning pass (e.g., the developer worked through the replan in native plan mode before running this command).

**If proposed changes are already present in the conversation:**

1. Present the proposed changes back to the developer in diff form (see Step 5 format)
2. Ask: "I found plan changes from earlier in this conversation. Would you like to apply them, or work through the replan fresh?"
3. If the developer wants to apply them, skip to Step 5 (Show the Diff) with those changes
4. If the developer wants to start fresh, continue to Step 4

**If no proposed changes exist in the conversation**, continue to Step 4.

### Step 4: Design the Changes

Enter plan mode to work through the replan:
- On Claude Code: use native plan mode
- On Copilot CLI: use Shift+Tab plan mode

Analyze the change request against the current plan and codebase:

1. Identify which existing sessions are affected by the change
2. Explore relevant parts of the codebase if needed (e.g., new features require understanding where they'd fit)
3. Propose modifications: new sessions, modified sessions, removed sessions, resequencing
4. Follow the replan principles:
   - Treat the entire non-merged plan as malleable — new sessions may need to be inserted before existing ones
   - Output sessions in dependency-topological order
   - Preserve merged sessions exactly
   - Flag changes affecting `in_progress` sessions — warn the developer

### Step 5: Show the Diff

Present changes as a clear diff. If phases exist, include the phase column:

```
## Plan Changes

### Added Sessions
| ID   | Title                    | Complexity | Dependencies | Phase            |
|------|--------------------------|------------|--------------|------------------|
| S007 | Redis caching layer      | medium     | S004         | 2: Core Features |

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

If the change request involves reorganizing phases (adding, removing, or renaming phases, or reassigning sessions between phases), show a **Phase Changes** section:

```
### Phase Changes
| ID   | Title                    | Phase: From          | Phase: To            |
|------|--------------------------|----------------------|----------------------|
| S007 | Redis caching layer      | (new)                | 2: Core Features     |
| S008 | Monitoring dashboard     | 2: Core Features     | 3: Polish            |
```

### Step 6: Confirm and Write

1. Ask the developer to confirm the changes
2. If confirmed, rewrite `.haddock/projects/<name>/plan.ndjson` entirely:
   - Preserve completed sessions (`merged`) exactly as they are
   - Preserve `in_progress`/`in_review`/`planning` sessions (only modify if explicitly part of the change)
   - Apply additions, removals, and modifications
   - Reorder all non-merged sessions into dependency-topological order (depended-upon sessions come first). Among sessions at the same DAG depth, place foundation/infrastructure sessions first. Renumber IDs sequentially after the last merged session ID. Update all dependency references and story IDs to reflect the new numbering.
   - Recalculate all dependency-based statuses
   - Update `updated_at` timestamps on all modified sessions
3. Verify the written file — each line must be valid JSON

### Step 7: Summary

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
- After applying all changes, renumber ALL non-merged sessions in dependency-topological order, starting from the first non-merged ID. Update all internal references (dependencies, story IDs) to match.
- Preserve existing `phase` assignments unless the change request explicitly involves reorganizing phases. When adding new sessions, assign them to a phase if the plan uses phases — ask the developer if it's not obvious.
- Maintain the append-only nature of sessions.ndjson — only plan.ndjson is rewritten
