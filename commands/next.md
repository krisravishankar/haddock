---
description: Select the next session to work on and begin planning it
---

# /haddock:next

Select the next session to work on and begin planning it.

## Arguments

`$ARGUMENTS` — Optional session ID (e.g., `S003`) to select a specific session. If omitted, show available sessions.

## Instructions

First, resolve the haddock root: if `.haddock_root` exists in the current directory, read it to get the path to `.haddock/`. Otherwise, use `.haddock/` in the current directory. Use this resolved path for all `.haddock/` references below.

Read the Haddock workflow skill from `skills/haddock-workflow/SKILL.md` in the plugin directory.

### Step 1: Load State

1. Read `.haddock/active` to get the active project name
2. If no active project, tell the developer to run `/haddock:init` first
3. Read `.haddock/projects/<name>/plan.ndjson`
4. Parse each line as a JSON object into a list of sessions

### Step 2: Evaluate Readiness

Recalculate session statuses based on the dependency graph:

1. For each session, check if all its dependencies have status `merged`
2. If a session has status `not_started` and all deps are `merged` (or no deps), update to `ready`
3. If a session has status `not_started` and any dep is not `merged`, update to `blocked`

**If sessions have phases**, present grouped by phase with status shown inline. Include a phase summary line before each group:

```
## Phase 1: Foundation — ✓ Complete

## Phase 2: Core Features — In Progress

### Ready to Start
| ID   | Title                    | Complexity | Phase               | Stories |
|------|--------------------------|------------|---------------------|---------|
| S003 | Authentication           | high       | 2: Core Features    | 2       |

### In Progress
| ID   | Title                    | Status      | Phase               |
|------|--------------------------|-------------|---------------------|
| S002 | Database schema          | in_progress | 1: Foundation       |

### Blocked
| ID   | Title                    | Waiting On   | Phase               |
|------|--------------------------|--------------|---------------------|
| S004 | API endpoints            | S002, S003   | 2: Core Features    |

## Completed: 1/6 sessions
```

**If no sessions have phases**, present grouped by status (standard view):

```
## Ready to Start
| ID   | Title                    | Complexity | Stories |
|------|--------------------------|------------|---------|
| S003 | Authentication           | high       | 2       |

## In Progress
| ID   | Title                    | Status     |
|------|--------------------------|------------|
| S002 | Database schema          | in_progress|

## Blocked
| ID   | Title                    | Waiting On          |
|------|--------------------------|---------------------|
| S004 | API endpoints            | S002, S003          |

## Completed: 1/6 sessions
```

### Step 3: Session Selection

If `$ARGUMENTS` contains a session ID:
- Validate it exists and has status `ready`
- If not `ready`, explain why (blocked by which sessions, or already in progress)

If no argument:
- If only one session is `ready`, suggest it and ask the developer to confirm
- If multiple are `ready`, present a numbered list for the developer to choose from:
  ```
  Which session would you like to start?
  1. [S003] Authentication (high complexity, 2 stories)
  2. [S005] Frontend scaffolding (medium complexity, 3 stories)
  3. [S007] Dashboard layout (low complexity, 1 story)
  ```
  Wait for the developer to respond with a number, then select that session.
- If none are `ready`, explain what's blocking progress

### Step 4: Begin Session Planning

Once a session is selected:

1. Read the session's stories, acceptance criteria, and file list from plan.ndjson
2. Read any previous session outcomes from sessions.ndjson for context:
   - Look for discoveries that affect this session
   - Check for deferrals that were suggested for this session
   - Note any relevant blockers from prior sessions
3. Present the session scope:
   ```
   ## Session S003: Authentication
   **Goal**: Implement JWT-based auth with role-based access control
   **Complexity**: high
   **Files**: src/auth/jwt.ts, src/auth/middleware.ts, src/auth/roles.ts

   ### Stories
   1. S003-01: JWT token generation and validation
      - [ ] Login endpoint returns JWT
      - [ ] Token validation middleware works
      - [ ] Refresh token flow implemented

   2. S003-02: Role-based access control
      - [ ] Admin and user roles defined
      - [ ] Protected routes enforce roles

   ### Context from Previous Sessions
   - Discovery from S001: Node 20 required for native fetch support
   ```

4. Enter plan mode to create a detailed implementation plan:
   - On Claude Code: use native plan mode
   - On Copilot CLI: use Shift+Tab plan mode
   - The plan should cover:
     - Implementation approach for each story
     - File creation/modification order
     - Key design decisions and trade-offs
     - Potential risks or unknowns

5. Present the plan to the developer for review:
   ```
   ## Implementation Plan

   [The detailed plan content]

   ---
   Does this plan look good? Reply **yes** to proceed, or describe what you'd like to change.
   ```

6. If the developer requests changes, revise the plan and re-present it. Repeat until approved.

7. Once approved, update the session status to `planning` in plan.ndjson:
   - Rewrite plan.ndjson with the session's status changed to `planning`
   - Update the `updated_at` timestamp

### Step 5: Confirm

Tell the developer:
- The approved plan is ready for implementation
- They should begin implementation
- When done, run `/haddock:done` to record the outcome
