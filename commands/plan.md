---
description: Create an implementation plan from a PRD for the active project
---

# /haddock:plan

Create or regenerate the implementation plan for the active Haddock project.

## Arguments

`$ARGUMENTS` — Optional path to a PRD document. If not provided, the PRD path from config.json is used, or the developer is asked.

## Instructions

First, resolve the haddock root: if `.haddock_root` exists in the current directory, read it to get the path to `.haddock/`. Otherwise, use `.haddock/` in the current directory. Use this resolved path for all `.haddock/` references below.

Read the Haddock workflow skill from `skills/haddock-workflow/SKILL.md` in the plugin directory.

### Step 1: Load Project Context

1. Read `.haddock/active` to get the active project name
2. If no active project, tell the developer to run `/haddock:init` first
3. Read `.haddock/projects/<name>/config.json`
4. Check if `plan.ndjson` already has content — if so, warn that this will overwrite it and confirm

### Step 2: Find and Read the PRD

1. If `$ARGUMENTS` contains a file path, use that as the PRD
2. Otherwise, check `config.json` for `prd_path`
3. If neither exists, ask the developer for the PRD location
4. Read the PRD document thoroughly — understand all requirements, features, and scope
5. Update `config.json` with the PRD path if it was newly provided

### Step 3: Codebase Analysis

Launch the **planner agent** (`agents/planner.agent.md` in the plugin directory) to analyze the codebase. The agent will:

1. Explore the repository structure to understand the architecture
2. Identify existing patterns, frameworks, and conventions
3. Map out the dependency graph of existing code
4. Identify natural session boundaries based on the PRD requirements

Wait for the agent's analysis before proceeding.

### Step 4: Interactive Session Design

Present the proposed session breakdown to the developer as a table:

```
| ID   | Title                    | Complexity | Dependencies | Stories |
|------|--------------------------|------------|--------------|---------|
| S001 | Foundation setup         | low        | —            | 2       |
| S002 | Database schema          | medium     | S001         | 3       |
| ...  | ...                      | ...        | ...          | ...     |
```

For each session, briefly describe:
- The goal
- Key stories and acceptance criteria
- Files that will be touched
- Why it depends on the listed sessions

Ask the developer:
- Does the scope look right?
- Should any sessions be split or merged?
- Are the dependencies correct?
- Any sessions missing?

Iterate until the developer confirms the plan.

### Step 5: Write plan.ndjson

1. Read `resources/schema.json` and `resources/example-plan.ndjson` from the plugin directory for format reference
2. Write one JSON line per session to `.haddock/projects/<name>/plan.ndjson`
3. Assign initial statuses:
   - Sessions with no dependencies → `ready`
   - Sessions with dependencies → `not_started`
4. Set `created_at` and `updated_at` to the current timestamp
5. Ensure each line is valid JSON (no pretty-printing, no trailing commas)

### Step 6: Confirm

1. Read back the written file and verify each line parses as valid JSON
2. Show a final summary:
   - Total sessions and story count
   - Sessions ready to start
   - Estimated complexity distribution
3. Suggest running `/haddock:next` to begin the first session

## Important

- Each session should be a discrete, well-scoped unit of work completable by an agent in a single conversation
- Sessions should have clear, testable acceptance criteria
- The dependency graph should be a DAG (no circular dependencies)
- File lists should be specific — list actual file paths, not directories
- Story IDs follow the pattern `S001-01` (session ID + story number)
