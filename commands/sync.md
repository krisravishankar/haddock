# /haddock:sync

Synchronize Haddock plan state with external project management tools.

## Arguments

`$ARGUMENTS` — Optional target system (e.g., `jira`).

## Instructions

This command is a **Phase 2 feature** and is not yet implemented.

Inform the developer:

> **Jira sync is coming in Phase 2 of Haddock.**
>
> When available, `/haddock:sync` will:
> - Push session status updates to Jira stories
> - Pull new stories added to the Jira epic
> - Sync acceptance criteria bidirectionally
> - Map Haddock session statuses to Jira workflow states
> - Create Jira subtasks from Haddock stories
>
> **For now, you can:**
> 1. Use `/haddock:status --report` to generate a shareable status report
> 2. Manually update Jira based on `/haddock:log` output
> 3. Export session data from `.haddock/projects/<name>/sessions.ndjson`
>
> To track the Jira epic key for future sync, set it in your project config:
> - Edit `.haddock/projects/<name>/config.json`
> - Set `"jira_epic": "PROJ-123"`
