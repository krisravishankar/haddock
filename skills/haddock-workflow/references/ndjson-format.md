# NDJSON Format Reference

## plan.ndjson

Each line is a JSON object representing one session. The file is rewritable (overwrite entirely when updating).

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Session ID, e.g. `"S001"` |
| `title` | string | yes | Short descriptive title |
| `goal` | string | yes | What this session aims to accomplish |
| `status` | sessionStatus | yes | Current lifecycle state |
| `stories` | story[] | yes | Acceptance-criteria-bearing work items |
| `files` | string[] | yes | Files expected to be touched |
| `dependencies` | string[] | yes | Session IDs that must be `merged` first |
| `preconditions` | string[] | no | Human-readable preconditions beyond deps |
| `complexity` | complexity | yes | `"low"`, `"medium"`, or `"high"` |
| `notes` | string | no | Free-form notes |
| `created_at` | datetime | yes | ISO 8601 creation timestamp |
| `updated_at` | datetime | yes | ISO 8601 last-modified timestamp |

### Story Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Story ID, e.g. `"S001-01"` |
| `title` | string | yes | Short description of the work item |
| `acceptance_criteria` | string[] | yes | Testable conditions for completion |
| `status` | sessionStatus | yes | Tracks individual story progress |

### Example Line

```json
{"id":"S001","title":"Project foundation","goal":"Set up project structure","status":"ready","stories":[{"id":"S001-01","title":"Init scaffolding","acceptance_criteria":["Directory structure created","Config files present"],"status":"not_started"}],"files":["package.json","tsconfig.json"],"dependencies":[],"preconditions":[],"complexity":"low","notes":"","created_at":"2026-03-01T10:00:00Z","updated_at":"2026-03-01T10:00:00Z"}
```

## sessions.ndjson

Each line is a JSON object recording the outcome of a completed session. This file is **append-only** — never modify existing lines.

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `session_id` | string | yes | References a session ID from plan.ndjson |
| `completed_at` | datetime | yes | ISO 8601 completion timestamp |
| `branch` | string | no | Git branch name |
| `mr_link` | string | no | Merge/pull request URL |
| `duration_minutes` | integer | no | How long the session took |
| `summary` | string | yes | What was accomplished |
| `stories_completed` | string[] | no | Story IDs fully completed |
| `stories_partial` | string[] | no | Story IDs partially completed |
| `deferrals` | deferral[] | no | Work deferred to future sessions |
| `discoveries` | discovery[] | no | New information discovered during work |
| `debt` | debt[] | no | Technical debt identified |
| `blockers` | blocker[] | no | Blockers encountered |

### Nested Types

**deferral**: `{"description": "...", "reason": "...", "suggested_session": "S005"}`

**discovery**: `{"description": "...", "impact": "...", "affects_sessions": ["S003", "S004"]}`

**debt**: `{"description": "...", "severity": "low|medium|high", "ticket": ""}`

**blocker**: `{"description": "...", "blocks_sessions": ["S004"], "external": false}`

### Example Line

```json
{"session_id":"S001","completed_at":"2026-03-02T14:30:00Z","branch":"feat/foundation","mr_link":"https://github.com/org/repo/pull/1","duration_minutes":75,"summary":"Set up project scaffolding and CI.","stories_completed":["S001-01","S001-02"],"stories_partial":[],"deferrals":[],"discoveries":[],"debt":[],"blockers":[]}
```

## config.json

Single JSON object (not NDJSON). Standard pretty-printed JSON.

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Project name (matches directory name) |
| `created_at` | datetime | yes | ISO 8601 creation timestamp |
| `prd_path` | string | no | Path to the PRD document |
| `repo_root` | string | no | Path to repository root |
| `jira_epic` | string/null | no | Jira epic key (Phase 2) |
| `description` | string | no | Project description |
| `tags` | string[] | no | Tags for categorization |
| `settings` | object | no | Project-specific settings |
