#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tests/lib/assert.sh"

repo="$TEAM_MEMORY_TEST_ROOT/sync-repo"
"$ROOT/bin/memory-init" "$repo" >/dev/null
git -C "$repo" remote add origin git@github.com:owner/team-memory.git

note="$TEAM_MEMORY_TEST_ROOT/sync-note.md"
cat > "$note" <<'EOF_NOTE'
# Share note

This record exists so sync and share planning have source files.
EOF_NOTE

"$repo/bin/memory-ingest" --project team-memory --member example-user --source-type meeting-note --title "Share plan note" "$note" >/dev/null
"$repo/bin/memory-wiki" --project team-memory >/dev/null

sync_output=$("$repo/bin/memory-sync")
assert_contains "$sync_output" "memory verify ok"
assert_contains "$sync_output" "Next steps:"

share_output=$("$repo/bin/memory-share-plan" --project team-memory --title "Share plan note")
assert_contains "$share_output" "Approval required"
assert_contains "$share_output" "Root Message Draft"
assert_contains "$share_output" "context/records/projects/team-memory/"
