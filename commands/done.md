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
2. Read `.haddock/projects/<name>/plan.ndjson`
3. If `$ARGUMENTS` contains a session ID, use that session
4. Otherwise, find sessions with status `in_progress` or `planning`
   - If exactly one, use it
   - If multiple, ask the developer which one
   - If none, tell the developer no session is in progress

### Step 2: Auto-capture Context

Gather information automatically:

1. **Branch name**: Check if inside a git repo (`git rev-parse --git-dir 2>/dev/null`). If yes, run `git branch --show-current` to get the current branch. If not in a git repo, skip — the `branch` field is optional.
2. **Duration**: If the session's `updated_at` shows when planning started, calculate approximate duration. Otherwise ask.
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

### Step 4: Write Session Outcome

1. Read `resources/schema.json` and `resources/example-sessions.ndjson` from the plugin directory for format reference
2. Construct the session outcome JSON object
3. Append one line to `.haddock/projects/<name>/sessions.ndjson`
4. Do NOT modify existing lines in sessions.ndjson — append only

### Step 5: Update Plan

1. Update the session's status in plan.ndjson to the determined status
2. Update individual story statuses based on completed/partial lists
3. Update the `updated_at` timestamp

### Step 6: Recalculate Dependencies

If the session was marked `merged`:

1. Find all sessions that depend on this session
2. For each dependent, check if ALL its dependencies are now `merged`
3. If yes, update that session from `not_started` or `blocked` → `ready`
4. Update `updated_at` on all modified sessions
5. Rewrite the entire plan.ndjson with updated statuses

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
