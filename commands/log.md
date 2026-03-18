# /haddock:log

Display the session history log for the active project.

## Arguments

`$ARGUMENTS` — Optional filters:
- A session ID (e.g., `S002`) to show only that session's outcome
- `--from YYYY-MM-DD` and/or `--to YYYY-MM-DD` for date range filtering

## Instructions

First, read the Haddock workflow skill from `skills/haddock-workflow/SKILL.md` in the plugin directory.

### Step 1: Load Data

1. Read `.haddock/active` to get the active project name
2. Read `.haddock/projects/<name>/sessions.ndjson`
3. Parse each line as a JSON object
4. If the file is empty, inform the developer that no sessions have been completed yet

### Step 2: Apply Filters

- If `$ARGUMENTS` contains a session ID, filter to entries matching that `session_id`
- If `--from` is specified, exclude entries with `completed_at` before that date
- If `--to` is specified, exclude entries with `completed_at` after that date
- If no filters, show all entries

### Step 3: Display Timeline

Show sessions in chronological order:

```
# Session Log: my-saas-app

## S001 — Project Foundation
**Completed**: 2026-03-02 14:30 UTC
**Duration**: 75 minutes
**Branch**: feat/project-foundation
**MR**: https://github.com/org/repo/pull/1
**Stories**: 2/2 complete (S001-01, S001-02)

Set up project scaffolding with TypeScript, configured CI pipeline
with GitHub Actions. All acceptance criteria met.

---

## S002 — Database Schema
**Completed**: 2026-03-05 09:15 UTC
**Duration**: 90 minutes
**Branch**: feat/db-schema
**MR**: pending
**Stories**: 1/2 complete (S002-01) | partial: S002-02

Completed user table schema and migration. Project table deferred
due to schema design questions.

### Deferrals
- Project table schema needs team review on polymorphic associations
  → Reason: Architecture decision pending
  → Suggested: S002 (revisit)

### Tech Debt
- Migration runner lacks rollback on partial failure (medium)

---

**Total**: 2 sessions logged | 165 minutes
```

### Step 4: Summary Stats

At the bottom, show aggregate stats:

```
## Summary
- Sessions completed: 2
- Total time: 165 minutes (avg 82.5 min/session)
- Stories completed: 3
- Deferrals pending: 1
- Discoveries logged: 1
- Tech debt items: 1
- Active blockers: 0
```

## Important

- This is a read-only command — never modify any files
- If a session has been recorded multiple times (e.g., revisited after deferral), show all entries
- Display dates in a human-readable format but keep the raw ISO timestamp accessible
