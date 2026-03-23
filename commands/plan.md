---
description: Create an implementation plan from a PRD for the active project
---

# /haddock:plan

Create or regenerate the implementation plan for the active Haddock project.

Haddock is a **plan manager**, not a planner — it structures, validates, and tracks plans through the session lifecycle. The developer (with Claude's help) does the actual planning. This command guides that process and manages the result.

## Arguments

`$ARGUMENTS` — Optional path to a PRD document. If not provided, the PRD path from config.json is used, or the developer is asked.

## Instructions

First, resolve the haddock root: if `.haddock_root` exists in the current directory, read it to get the path to `.haddock/`. Otherwise, use `.haddock/` in the current directory. Use this resolved path for all `.haddock/` references below.

Read the Haddock workflow skill from `skills/haddock-workflow/SKILL.md` in the plugin directory.

### Step 1: Load Project Context

1. Read `.haddock/active` to get the active project name
2. If no active project, tell the developer to run `/haddock:init` first
3. Read `.haddock/projects/<name>/config.json`
4. Check if `plan.md` already has sessions beyond the header — if so, warn that this will overwrite them and confirm

### Step 2: Find and Read the PRD

1. If `$ARGUMENTS` contains a file path, use that as the PRD
2. Otherwise, check `config.json` for `prd_path`
3. If neither exists, ask the developer for the PRD location
4. Read the PRD document thoroughly — understand all requirements, features, and scope
5. Update `config.json` with the PRD path if it was newly provided

### Step 3: Check for Existing Session Plan

Check whether the current conversation already contains a session plan from a prior planning pass (e.g., the developer planned in native plan mode before running this command, or Copilot already generated a `plan.md`).

**If a session plan is already present in the conversation or if a `plan.md` already exists with sessions:**

1. Present the existing plan back to the developer in table form (see Step 5 format)
2. Ask: "I found a session plan from earlier in this conversation. Would you like to use it, or start fresh?"
3. If the developer wants to use it, skip to Step 5 (Interactive Refinement)
4. If the developer wants to start fresh, continue to Step 4

**If no session plan exists**, continue to Step 4.

### Step 4: Plan the Sessions

Enter plan mode to analyze the codebase and design sessions:
- On Claude Code: use native plan mode
- On Copilot CLI: use Shift+Tab plan mode

#### 4.1: Codebase Exploration

Use Glob and Read to understand the project:
- Map the top-level directory structure
- Identify the tech stack from config files (package.json, Cargo.toml, go.mod, pyproject.toml, etc.)
- Find entry points, routing, database models, API definitions
- Identify architectural patterns and conventions

Present a brief codebase summary to the developer. **Pause and confirm understanding before proceeding** — the developer may want to steer the analysis ("focus on the auth module", "skip the legacy code", "this area is being rewritten").

#### 4.2: PRD-to-Code Mapping

For each major feature/requirement in the PRD:
- Identify which existing files it touches
- Identify what new files/modules need to be created
- Note shared dependencies between features

#### 4.3: Session Design

Design sessions following the principles in the Haddock workflow skill. Key points:
- Each session is completable by an agent in a single conversation
- Prefer vertical slices over horizontal layers
- Foundation/infrastructure first
- Sessions form a DAG with minimal dependency chains
- Each session has 1-5 stories with testable acceptance criteria
- File lists are specific paths, not directories

#### 4.4: Present Analysis

Present the full analysis:
1. Codebase summary (tech stack, architecture, conventions)
2. Session list with IDs, titles, goals, stories, files, dependencies, complexity
3. Dependency graph visualization
4. Risks and areas of uncertainty

### Step 5: Interactive Refinement

Present the session breakdown to the developer as a table:

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

### Step 6: Write plan.md

1. Read `resources/example-plan.md` from the plugin directory for format reference
2. Write the full plan to `.haddock/projects/<name>/plan.md` in the haddock markdown format:
   - Start with `# Plan: <project-name>`
   - One `## S<NNN> — <title>` section per session
   - Include `<!-- haddock: status=... complexity=... dependencies=... updated=... -->` metadata comment
   - Assign initial statuses:
     - Sessions with no dependencies → `status=ready`
     - Sessions with unmerged dependencies → `status=not_started`
   - Set `updated` to the current ISO 8601 timestamp
   - Include goal, files, and stories with unchecked checkboxes
   - Separate sessions with `---`

### Step 7: Confirm

1. Read back the written file to verify it looks correct
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
