---
name: haddock-workflow
description: Core workflow knowledge for Haddock — session lifecycle, markdown format, data model, and command relationships
---

# Haddock Workflow Skill

You are working with **Haddock**, a living plan manager that tracks implementation progress through session-scoped plans stored as markdown files.

## Philosophy

A **session** is a discrete, well-scoped unit of work that an agent can complete in a single conversation. Sessions have clear boundaries and a well-defined goal, are completable end-to-end without mid-session human intervention, and are as small as practical — but group related changes when splitting them would create unnecessary overhead. Sessions don't assume a specific output form: some produce PRs, others produce designs, research findings, or config changes. Sessions form a dependency graph that represents the implementation plan.

## Directory Structure

All state lives in `.haddock/` in the project working directory (or a designated git repo):

```
.haddock/
├── active                              # Contains name of active project
└── projects/
    └── <project-name>/
        ├── config.json                 # Project configuration
        ├── plan.md                     # One section per session (the plan)
        └── session.md                  # Append-only log of completed sessions
```

Multiple projects can coexist. The `active` file contains the name of the current project.

### Storage Resolution

When the working directory is not itself a git repo, `.haddock/` may be stored in a child git repo for shareability. Commands find `.haddock/` as follows:

1. Check for a `.haddock_root` file in the current working directory
2. If found, read the path inside it — that directory contains `.haddock/`
3. If not found, use `.haddock/` in the current directory (backwards compatible)

The `.haddock_root` pointer file is created by `/haddock:init` when the user chooses to store `.haddock/` in a child git repo.

## Markdown File Format

### plan.md

`plan.md` is a human- and Copilot-readable markdown file. Each session is a level-2 heading section. Haddock metadata (status, complexity, dependencies) is stored in an HTML comment directly below the heading so it does not clutter the visual layout.

**Structure:**

```markdown
# Plan: <project-name>

## S001 — <title>
<!-- haddock: status=<status> complexity=<complexity> dependencies=<none|S001,S002> updated=<ISO8601> -->

**Goal**: <goal>

**Files**: `file1.ts`, `file2.ts`

### Stories
- [x] **S001-01**: <story title>
  - [x] <acceptance criterion>
  - [x] <acceptance criterion>
- [ ] **S001-02**: <story title>
  - [ ] <acceptance criterion>

---

## S002 — <title>
<!-- haddock: status=ready complexity=medium dependencies=S001 updated=2026-03-01T10:00:00Z -->
...
```

**Parsing rules for plan.md:**
- Each session block starts with a `## S<NNN> — <title>` heading
- The HTML comment `<!-- haddock: ... -->` on the next line holds structured metadata
- `status` is one of: `not_started`, `blocked`, `ready`, `planning`, `in_progress`, `in_review`, `merged`
- `dependencies` is comma-separated session IDs, or `none`
- `**Goal**:` line holds the session goal
- `**Files**:` line lists files as backtick-quoted, comma-separated paths
- `### Stories` subsection contains story lines
- Story lines: `- [x] **S<NNN>-<NN>**: <title>` — `[x]` = done, `[ ]` = not done
- Acceptance criteria: `  - [x] <text>` (two-space indent under story line)
- Sessions are separated by `---` horizontal rules

### session.md

`session.md` is an **append-only** log of completed session outcomes. Each entry is a level-2 heading followed by structured content. Never modify existing entries — only append new ones.

**Structure:**

```markdown
# Session Log: <project-name>

---

## S001 — <title>
**Completed**: 2026-03-02 14:30 UTC | **Duration**: 75 min | **Branch**: `feat/foundation` | **PR**: [#1](https://github.com/org/repo/pull/1)

<summary paragraph>

**Stories completed**: S001-01, S001-02
**Stories partial**: (none)

**Discoveries**:
- Node 20 required for native fetch support — Updates minimum engine requirement (affects: S002)

**Deferrals**:
- Project table schema needs team review — Architecture decision pending (suggested: S002)

**Tech Debt**:
- Migration runner lacks rollback on partial failure (severity: medium)

**Blockers**:
- (none)

---
```

**Parsing rules for session.md:**
- Each entry starts with `## S<NNN> — <title>`
- Metadata line: `**Completed**: <date> | **Duration**: <n> min | **Branch**: <branch> | **PR**: <link>`
- Summary is the paragraph immediately following the metadata line
- Sections: `**Stories completed**`, `**Stories partial**`, `**Discoveries**`, `**Deferrals**`, `**Tech Debt**`, `**Blockers**`
- List items under each section use `- ` prefix
- Entries are separated by `---` horizontal rules
- Omit sections that have no content (or write `(none)` as a placeholder)

## Session Design Principles

When planning sessions — whether through `/haddock:plan`, native plan mode, or any other planning flow — follow these principles so the output is compatible with haddock's plan management:

**Session scoping:**
- Each session should be a discrete, well-scoped unit of work that an agent can complete in a single conversation
- Sessions have clear boundaries and a well-defined goal, completable end-to-end without mid-session human intervention
- Sessions should be as small as practical, but group related changes when splitting them would create unnecessary overhead or coordination cost
- Sessions don't assume a specific output form — some produce PRs, others produce designs, research findings, or config changes
- Prefer vertical slices (end-to-end for one feature) over horizontal layers
- Foundation/infrastructure sessions come first

**Dependency ordering:**
- Sessions form a directed acyclic graph (DAG)
- A session should only depend on sessions whose output it directly needs
- Minimize dependency chains — prefer wide graphs over deep ones
- Identify which sessions can be parallelized

**Story design:**
- Each session has 1-5 stories with testable acceptance criteria
- Acceptance criteria should be specific and verifiable
- Stories within a session should be ordered by implementation sequence

**File identification:**
- List specific files each session will touch (actual paths, not directories)
- Identify files that multiple sessions share (potential conflicts)
- Flag areas where session boundaries might cause merge conflicts

**Output format:**
- Session IDs: `S001`, `S002`, etc.
- Story IDs: `S001-01`, `S001-02`, etc.
- Each session needs: id, title, goal, stories, files, dependencies, complexity (low/medium/high)
- See `resources/example-plan.md` for the exact format

If you are planning in native plan mode and intend to use `/haddock:plan` afterward to write the plan, structure your output to match these conventions — the command will detect and use your existing session plan.

## Session Lifecycle

Sessions move through these states. See `references/lifecycle.md` for the full state machine.

```
not_started → ready → planning → in_progress → in_review → merged
                ↓                     ↓
             blocked              (back to ready if abandoned)
```

- A session is `ready` when all its dependencies are `merged`
- A session is `blocked` when any dependency is not yet `merged`
- `/haddock:next` transitions a session from `ready` → `planning`
- The developer transitions `planning` → `in_progress` when implementation begins
- `/haddock:done` transitions to `in_review` or `merged`
- After a session transitions to `merged`, recalculate all downstream sessions' readiness

## Progressive Loading

Not every command needs all data. Load only what's needed:

| Command | Files to read |
|---------|--------------|
| `init` | Nothing (creates files) |
| `plan` | config.json, PRD |
| `replan` | config.json, plan.md, session.md, new input |
| `next` | plan.md |
| `done` | plan.md, session.md (to append) |
| `status` | plan.md, session.md (for `--report`) |
| `log` | session.md |
| `purge` | plan.md (for summary stats before deletion) |
| `sync` | N/A (Phase 2) |

## Command Workflow

The typical workflow is:

1. `/haddock:init <name>` — initialize a project
2. `/haddock:plan` — create the implementation plan from a PRD
3. `/haddock:next` — pick the next session to work on
4. *(do the work)*
5. `/haddock:done` — record what happened
6. Repeat 3-5 until plan is complete
7. `/haddock:replan` — adjust the plan if scope changes
8. `/haddock:status` — check progress at any time
9. `/haddock:log` — review session history
10. `/haddock:purge` — remove a project or all projects when no longer needed

**Plan-mode-first flow:** Developers who prefer to plan in native plan mode (Shift+Tab) can do so before running `/haddock:plan`. The command will detect the session plan from the conversation and offer to use it directly, skipping the exploration phase. This also works with `/haddock:replan` — plan the changes in plan mode first, then run the command to apply them.

Copilot CLI's plan mode produces a `plan.md` file whose structure is compatible with haddock's format. When Copilot has already generated a `plan.md`, haddock commands read and manage it directly rather than creating a separate representation.

## File References

- Examples: `resources/example-plan.md`, `resources/example-session.md`, `resources/example-config.json`
- Lifecycle details: `skills/haddock-workflow/references/lifecycle.md`
