# /haddock:init

Initialize a Haddock project in the current repository.

## Arguments

`$ARGUMENTS` — Project name (required). If it looks like a Jira epic key (e.g., `PROJ-123`), this is a Jira import (Phase 2 — see below).

## Instructions

First, read the Haddock workflow skill from `skills/haddock-workflow/SKILL.md` in the plugin directory to understand the data model and directory structure.

### Step 1: Determine Onboarding Path

Ask the developer which situation applies:

1. **Greenfield** — Starting a new project from scratch
2. **Mid-flight migration** — Project is already in progress, need to import existing state
3. **Jira import** — If `$ARGUMENTS` matches a Jira epic key pattern (`[A-Z]+-\d+`)

### Step 2: Execute the Chosen Path

#### Path 1: Greenfield

1. Create the project directory structure:
   ```
   .haddock/
   ├── active
   └── projects/
       └── <project-name>/
           ├── config.json
           ├── plan.ndjson
           └── sessions.ndjson
   ```
2. Write the project name to `.haddock/active`
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

#### Path 3: Jira Import

This feature is planned for **Phase 2**. Inform the developer:

> Jira integration is coming in Phase 2 of Haddock. For now, you can:
> 1. Use `/haddock:init <project-name>` for a greenfield setup
> 2. Export your Jira epic to a document and use the mid-flight migration path
>
> Phase 2 will support direct Jira sync via `/haddock:sync`.

### Step 3: Verify

After creating files:
1. Read back `config.json` to confirm it's valid JSON
2. Confirm the directory structure exists
3. Show a summary of what was created

## Important

- Project names should be lowercase, hyphen-separated (e.g., `my-project`)
- If `.haddock/projects/<name>/` already exists, warn the developer and ask if they want to reinitialize (this will overwrite existing data)
- Always write the active project to `.haddock/active`
