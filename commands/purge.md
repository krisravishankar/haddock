---
description: Remove a project or all projects — non-recoverable
---

# /haddock:purge

Remove a Haddock project or all projects. This is a destructive, non-recoverable operation.

## Arguments

`$ARGUMENTS` — Optional project name or `--all` flag:
- `<project-name>`: Remove a specific project
- `--all`: Remove all projects and the `.haddock/` directory
- *(no argument)*: Remove the active project

## Instructions

First, resolve the haddock root: if `.haddock_root` exists in the current directory, read it to get the path to `.haddock/`. Otherwise, use `.haddock/` in the current directory. Use this resolved path for all `.haddock/` references below.

Read the Haddock workflow skill from `skills/haddock-workflow/SKILL.md` in the plugin directory.

---

### `--all` Flow

If `$ARGUMENTS` is `--all`:

#### Step 1: Inventory All Projects

1. List all directories under `.haddock/projects/`
2. If no projects exist, inform the developer there is nothing to purge and stop
3. For each project, read its `plan.ndjson` and compute summary stats
4. Display a portfolio summary table:

```
## Projects to be purged

| Project        | Sessions | Complete | Stories |
|----------------|----------|----------|---------|
| my-saas-app    | 6        | 2 (33%)  | 20      |
| mobile-app     | 8        | 5 (63%)  | 15      |
| data-pipeline  | 4        | 0 (0%)   | 8       |

Total: 3 projects, 18 sessions, 43 stories
```

#### Step 2: Confirm Deletion

Display a non-recoverable warning and require explicit confirmation:

```
⚠️  This will permanently delete the entire .haddock/ directory
    and all project data. This action cannot be undone.

Type "purge all" to confirm:
```

Wait for the developer to respond. Only proceed if they type exactly `purge all`. If they type anything else, abort.

#### Step 3: Delete Everything

1. Delete the entire `.haddock/` directory
2. If a `.haddock_root` pointer file exists in the current working directory, delete it as well

#### Step 4: Confirm

```
All Haddock data has been removed.
Run /haddock:init to start fresh.
```

---

### Single Project Flow

If `$ARGUMENTS` is a project name or empty:

#### Step 1: Identify the Target Project

1. If `$ARGUMENTS` contains a project name, use that
2. If no argument given, read `.haddock/active` to get the active project name
3. If `.haddock/active` does not exist and no argument was given, tell the developer to run `/haddock:init` first and stop
4. Validate that `.haddock/projects/<name>/` exists — if not, list available projects and stop

#### Step 2: Show What Will Be Deleted

1. Read the project's `plan.ndjson` and parse all sessions
2. Count sessions by status and total stories
3. Display a summary of what will be deleted:

```
## Project to be purged: my-saas-app

Contents:
- config.json
- plan.ndjson — 6 sessions (2 merged, 1 in progress, 3 not started)
- sessions.ndjson — 2 recorded outcomes

Total: 20 stories across 6 sessions
```

#### Step 3: Confirm Deletion

Display a non-recoverable warning and require explicit confirmation:

```
⚠️  This will permanently delete .haddock/projects/my-saas-app/
    and all its data. This action cannot be undone.

Type "purge my-saas-app" to confirm:
```

Wait for the developer to respond. Only proceed if they type exactly `purge <project-name>`. If they type anything else, abort.

#### Step 4: Delete the Project

Delete the `.haddock/projects/<name>/` directory.

#### Step 5: Update Active Project

1. Read `.haddock/active` to check if the purged project was the active project
2. If it was:
   - List remaining directories under `.haddock/projects/`
   - If other projects remain, write the first remaining project name to `.haddock/active` and inform the developer: `Active project switched to "<name>".`
   - If no projects remain, delete the `.haddock/active` file

#### Step 6: Confirm

```
## Project "my-saas-app" purged ✓

Deleted: .haddock/projects/my-saas-app/
```

If the active project was switched, include which project is now active. If no projects remain, suggest running `/haddock:init` to start fresh.

## Important

- This command is destructive and non-recoverable — always require explicit typed confirmation
- Never delete files outside of `.haddock/` — project source code, PRDs, and other files are not touched
- The confirmation must match exactly (`purge all` or `purge <project-name>`) — reject partial or incorrect input
- When purging `--all`, also remove the `.haddock_root` pointer file if it exists
- When purging a single project, do not remove `.haddock_root` even if no projects remain — the root location is still valid for future use
