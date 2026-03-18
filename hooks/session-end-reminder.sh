#!/usr/bin/env bash
# Haddock session-end reminder hook
# Checks if there's an active session that hasn't been recorded with /haddock:done

set -euo pipefail

# Find the repo root (look for .haddock directory)
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
HADDOCK_DIR="$REPO_ROOT/.haddock"

# Check if Haddock is initialized
if [ ! -f "$HADDOCK_DIR/active" ]; then
  exit 0
fi

ACTIVE_PROJECT=$(cat "$HADDOCK_DIR/active")
PLAN_FILE="$HADDOCK_DIR/projects/$ACTIVE_PROJECT/plan.ndjson"
SESSIONS_FILE="$HADDOCK_DIR/projects/$ACTIVE_PROJECT/sessions.ndjson"

if [ ! -f "$PLAN_FILE" ]; then
  exit 0
fi

# Find sessions that are in_progress or planning
ACTIVE_SESSIONS=$(grep -E '"status"\s*:\s*"(in_progress|planning)"' "$PLAN_FILE" 2>/dev/null || true)

if [ -z "$ACTIVE_SESSIONS" ]; then
  exit 0
fi

# Extract session IDs of active sessions
ACTIVE_IDS=$(echo "$ACTIVE_SESSIONS" | grep -oP '"id"\s*:\s*"\K[^"]+' || true)

if [ -z "$ACTIVE_IDS" ]; then
  exit 0
fi

# Check if any of these sessions already have an outcome recorded
for SID in $ACTIVE_IDS; do
  if [ -f "$SESSIONS_FILE" ]; then
    ALREADY_DONE=$(grep -c "\"session_id\":\"$SID\"" "$SESSIONS_FILE" 2>/dev/null || echo "0")
    if [ "$ALREADY_DONE" -gt 0 ]; then
      continue
    fi
  fi

  # This session is active but not yet recorded
  cat <<EOF
{"context":"You have an active Haddock session ($SID) that hasn't been recorded. Consider running /haddock:done to log your progress before ending this conversation."}
EOF
  exit 0
done
