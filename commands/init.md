---
description: Initialize a new Haddock project in the current repository
---

# /haddock:init

Initialize a Haddock project in the current repository.

## Arguments

`$ARGUMENTS` — Project name (required).

## Instructions

First, read the Haddock workflow skill from `skills/haddock-workflow/SKILL.md` in the plugin directory to understand the data model and directory structure.

### Step 1: Determine Storage Location

Check if the current working directory is a git repo by running `git rev-parse --git-dir 2>/dev/null`.

**If yes** (current directory is a git repo): The `haddock_root` is the current directory. Proceed to Step 2.

**If no** (current directory is NOT a git repo):

1. Scan immediate child directories for git repos (check which children contain a `.git` directory)
2. Present the options to the developer:
   ```
   Your working directory is not a git repo. Where should .haddock/ be stored?

   Git repos found (shareable with your team):
   1. ./frontend
   2. ./backend
   3. ./infra

   Other:
   4. Current directory (local only, not shareable)
   5. Cancel
   ```
3. Based on the developer's choice:
   - **Child git repo**: Set `haddock_root` to that child directory path (relative, e.g. `./backend`). Create a `.haddock_root` pointer file in the current working directory containing this path.
   - **Current directory**: Set `haddock_root` to `.`. Warn: "Plan state won't be version-controlled and can't be shared with your team." Do NOT create a `.haddock_root` file (current directory is the default).
   - **Cancel**: Abort init, explain that haddock needs a storage location.

### Step 2: Determine Onboarding Path

Ask the developer which situation applies:

1. **Greenfield** — Starting a new project from scratch
2. **Mid-flight migration** — Project is already in progress, need to import existing state

### Step 3: Execute the Chosen Path

#### Path 1: Greenfield

1. Create the project directory structure under the resolved `haddock_root`:
   ```
   <haddock_root>/.haddock/
   ├── active
   └── projects/
       └── <project-name>/
           ├── config.json
           ├── plan.ndjson
           └── sessions.ndjson
   ```
2. Write the project name to `<haddock_root>/.haddock/active`
3. Create `config.json` with:
   - `name`: the project name from `$ARGUMENTS`
   - `created_at`: current ISO 8601 timestamp
   - `prd_path`: ask the developer for the PRD location (or leave empty)
   - `description`: ask for a brief description
   - Other fields as defaults (null/empty)
4. Create empty `plan.ndjson` and `sessions.ndjson` files
5. Confirm creation and suggest running `/haddock:plan` next

Reference `resources/example-config.json` in the plugin directory for the config format.

#### Path 2: Mid-flight Migration

1. Ask the developer where existing plan information lives:
   - A markdown file with task lists?
   - A previous plan document?
   - Just in their head?
2. Read the provided source material
3. Create the project directory structure (same as greenfield)
4. Parse existing information into sessions:
   - Each logical chunk of work becomes a session in plan.ndjson
   - Already-completed work gets sessions with status `merged`
   - For completed sessions, also create entries in sessions.ndjson with best-effort data
   - In-progress work gets status `in_progress`
   - Future work gets `not_started` or `ready` based on dependencies
5. Show the developer the parsed plan for confirmation before writing
6. Write all files and suggest reviewing with `/haddock:status`

### Step 4: Verify

After creating files:
1. Read back `config.json` to confirm it's valid JSON
2. Confirm the directory structure exists
3. Show a summary of what was created

## Important

- Project names should be lowercase, hyphen-separated (e.g., `my-project`)
- If `.haddock/projects/<name>/` already exists, warn the developer and ask if they want to reinitialize (this will overwrite existing data)
- Always write the active project to `.haddock/active`
- The `.haddock_root` pointer file is only created when `.haddock/` is stored in a child directory (not the current directory). Its content is the relative path to the directory containing `.haddock/` (e.g., `./backend`)
