# Session Lifecycle State Machine

## States

| State | Description |
|-------|-------------|
| `not_started` | Initial state. Session exists in the plan but no work has begun. |
| `blocked` | Session cannot start because one or more dependencies are not yet `merged`. |
| `ready` | All dependencies are `merged`. Session is available to be picked up. |
| `planning` | Developer has selected this session via `/haddock:next` and is creating a detailed implementation plan. |
| `in_progress` | Active implementation is underway. |
| `in_review` | Code is submitted for review (MR/PR created). |
| `merged` | Session work is merged. Terminal state. |

## Transitions

```
                    ┌──────────────┐
                    │  not_started │
                    └──────┬───────┘
                           │
              ┌────────────┼────────────┐
              │ (deps met) │            │ (deps unmet)
              ▼            │            ▼
        ┌─────────┐       │      ┌──────────┐
        │  ready   │       │      │ blocked  │
        └────┬─────┘       │      └────┬─────┘
             │             │           │
             │ /next       │           │ (dep merged)
             ▼             │           │
        ┌──────────┐       │           │
        │ planning │◄──────┘───────────┘
        └────┬─────┘
             │
             │ (start coding)
             ▼
        ┌─────────────┐
        │ in_progress  │
        └────┬─────────┘
             │
             │ /done
             ▼
        ┌─────────────┐
        │  in_review   │
        └────┬─────────┘
             │
             │ /done (merged)
             ▼
        ┌──────────┐
        │  merged   │
        └──────────┘
```

## Transition Rules

### Automatic Transitions (system-managed)
- **`not_started` → `ready`**: When all dependencies have status `merged` (or dependencies list is empty)
- **`not_started` → `blocked`**: When any dependency does not have status `merged`
- **`blocked` → `ready`**: When all dependencies reach `merged`

### Command-triggered Transitions
- **`ready` → `planning`**: `/haddock:next` — developer selects session
- **`planning` → `in_progress`**: Developer begins implementation (set by the agent when coding starts)
- **`in_progress` → `in_review`**: `/haddock:done` — with MR link provided but not yet merged
- **`in_progress` → `merged`**: `/haddock:done` — when work is merged or no review needed
- **`in_review` → `merged`**: `/haddock:done` — after MR is merged

### Recalculation After Status Change
When any session transitions to `merged`:
1. Find all sessions that list the newly-merged session in their `dependencies`
2. For each dependent session, check if ALL dependencies are now `merged`
3. If yes, transition that session from `blocked` or `not_started` → `ready`
4. Update `updated_at` timestamp on all modified sessions

## Initial State Assignment
When creating a plan (`/haddock:plan`), assign initial statuses:
- Sessions with no dependencies → `ready`
- Sessions with dependencies → `not_started`
