---
description: Switch the active Haddock project
---

# /haddock:switch

Switch the active Haddock project.

## Arguments

`$ARGUMENTS` — Optional project name. If omitted, list all projects and prompt for selection.

## Instructions

First, read the Haddock workflow skill from `skills/haddock-workflow/SKILL.md` in the plugin directory.

### Step 1: Read Current State

1. Read `.haddock/active` to get the current active project name
2. If `.haddock/active` does not exist, tell the developer to run `/haddock:init` first and stop
3. List directories under `.haddock/projects/`
4. If only one project exists, inform the developer there is nothing to switch to and stop

### Step 2: Check for In-Progress Work

1. Read the current active project's `plan.ndjson`
2. Parse all sessions and check for any with status `in_progress` or `planning`
3. If found, display a non-blocking warning:

```
## Warning: Active Work in Progress

Project "current-project" has sessions in progress:

| ID   | Title            | Status      |
|------|------------------|-------------|
| S003 | Authentication   | in_progress |

This work will still be here when you switch back.
```

### Step 3: Select Target Project

**If `$ARGUMENTS` contains a project name:**

1. Validate that `.haddock/projects/<name>/` exists — if not, list available projects and stop
2. If the name matches the current active project, inform the developer it is already active and stop

**If no argument given:**

1. For each project under `.haddock/projects/`, read its `plan.ndjson` and compute summary stats (total sessions, completed count, in-progress count)
2. Display a numbered selection table:

```
## Haddock Projects

| #  | Project        | Sessions | Complete | Status   |
|----|----------------|----------|----------|----------|
| 1  | my-saas-app    | 6        | 2 (33%)  | *active* |
| 2  | mobile-app     | 8        | 5 (63%)  |          |
| 3  | data-pipeline  | 4        | 0 (0%)   |          |

Which project would you like to switch to? (enter a number)
```

3. Wait for the developer to respond with a number, then select that project
4. If the developer selects the already-active project, inform them it is already active and stop

### Step 4: Perform the Switch

Write the target project name to `.haddock/active`.

### Step 5: Show Target Project Status

Display a brief progress summary of the newly active project:

1. Read the target project's `plan.ndjson`
2. Show progress with a progress bar and session breakdown:

```
# Switched to: mobile-app

## Progress: 5/8 sessions complete (63%)
████████████████░░░░░░░░░ 63%

## In Progress (1)
| ID   | Title            | Stories  |
|------|------------------|----------|
| S006 | Push notifications | 2/3 done |

## Ready (1)
| ID   | Title            | Complexity |
|------|------------------|------------|
| S007 | Offline mode     | high       |

## Blocked (1)
| ID   | Title            | Waiting On |
|------|------------------|------------|
| S008 | Analytics        | S006, S007 |
```

## Important

- Only updates `.haddock/active` — never modify plan, session, or config files
- If the target matches the current active project, inform and stop — do not rewrite the file
- Project name matching is exact (case-sensitive, matching directory name)
- The in-progress warning in Step 2 is informational only, never blocking
