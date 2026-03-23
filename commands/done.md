---
description: Record the outcome of the current session and update the plan
---

# /haddock:done

Record the outcome of the current session and update the plan.

## Arguments

`$ARGUMENTS` — Optional session ID. If omitted, find the session currently `in_progress` or `planning`.

## Instructions

First, resolve the haddock root: if `.haddock_root` exists in the current directory, read it to get the path to `.haddock/`. Otherwise, use `.haddock/` in the current directory. Use this resolved path for all `.haddock/` references below.

Read the Haddock workflow skill from `skills/haddock-workflow/SKILL.md` in the plugin directory.

### Step 1: Identify the Session

1. Read `.haddock/active` to get the active project name
2. Read `.haddock/projects/<name>/plan.md`
3. Parse all `## S<NNN> — <title>` sections and their `<!-- haddock: ... -->` metadata
4. If `$ARGUMENTS` contains a session ID, use that session
5. Otherwise, find sessions with `status=in_progress` or `status=planning`
   - If exactly one, use it
   - If multiple, ask the developer which one
   - If none, tell the developer no session is in progress

### Step 2: Auto-capture Context

Gather information automatically:

1. **Branch name**: Check if inside a git repo (`git rev-parse --git-dir 2>/dev/null`). If yes, run `git branch --show-current` to get the current branch. If not in a git repo, skip — branch is optional.
2. **Duration**: If the session's `updated` timestamp shows when planning started, calculate approximate duration. Otherwise ask.
3. **Git changes**: If inside a git repo, run `git log --oneline` on the current branch to understand what was done. If not in a git repo, ask the developer for a summary of what changed instead.

### Step 3: Interactive Outcome Collection

Ask the developer about each of these (skip any that aren't applicable):

1. **Summary**: "What did you accomplish in this session?" (one paragraph)

2. **Stories completed**: Show the session's stories and ask which are done:
   ```
   Which stories are complete?
   1. [S003-01] JWT token generation and validation
   2. [S003-02] Role-based access control
   ```

3. **Stories partial**: Any stories partially completed?

4. **MR/PR link**: "Is there a merge request? Paste the URL or press enter to skip."

5. **New status**: Based on the MR:
   - MR provided and merged → `merged`
   - MR provided but not merged → `in_review`
   - No MR but work is done → `merged`
   - Work abandoned → back to `ready`

6. **Deferrals**: "Was anything deferred to a future session?"
   - For each: description, reason, suggested session ID

7. **Discoveries**: "Did you discover anything that affects other sessions?"
   - For each: description, impact, which sessions are affected

8. **Technical debt**: "Any tech debt to note?"
   - For each: description, severity (low/medium/high)

9. **Blockers**: "Any blockers encountered?"
   - For each: description, which sessions it blocks, is it external?

### Step 4: Append Session Outcome to session.md

1. Read `resources/example-session.md` from the plugin directory for format reference
2. Construct the session entry in haddock markdown format:

   ```markdown
   ## S003 — Authentication and authorization
   **Completed**: 2026-03-10 11:45 UTC | **Duration**: 90 min | **Branch**: `feat/auth` | **PR**: [#3](https://github.com/org/repo/pull/3)

   Implemented JWT-based authentication with role-based access control. All stories completed.

   **Stories completed**: S003-01, S003-02
   **Stories partial**: (none)

   **Discoveries**: (none)

   **Deferrals**: (none)

   **Tech Debt**: (none)

   **Blockers**: (none)

   ---
   ```

3. Append this entry to `.haddock/projects/<name>/session.md`
4. Do NOT modify any existing entries in `session.md` — append only

### Step 5: Update plan.md

1. In the session's `<!-- haddock: ... -->` metadata comment, update `status` to the determined status and update `updated` to now
2. Update individual story checkbox states in the `### Stories` section:
   - Completed stories and their acceptance criteria: change `[ ]` to `[x]`
   - Partial stories: check off only the completed acceptance criteria
3. Write the updated `plan.md` — rewrite the entire file with these changes applied

### Step 6: Recalculate Dependencies

If the session was marked `merged`:

1. Find all sessions in `plan.md` that list this session in their `dependencies`
2. For each dependent, check if ALL its dependencies now have `status=merged`
3. If yes, update that session's metadata from `status=not_started` or `status=blocked` to `status=ready`
4. Update the `updated` timestamp on all modified sessions
5. Rewrite the entire `plan.md` with updated metadata comments

### Step 7: Summary

Show what was recorded:
```
## Session S003 Complete ✓

**Status**: merged
**Duration**: 90 minutes
**Branch**: feat/auth
**Stories**: 2/2 completed

### Deferrals
- OAuth provider integration → suggested for S005

### Next Steps
- 2 sessions now ready: S004 (API endpoints), S005 (OAuth)
- Run /haddock:next to continue
```

If there were deferrals, suggest running `/haddock:replan` to incorporate them.
