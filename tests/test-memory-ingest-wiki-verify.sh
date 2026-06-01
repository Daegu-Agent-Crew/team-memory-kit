#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tests/lib/assert.sh"

repo="$TEAM_MEMORY_TEST_ROOT/ingest-repo"
"$ROOT/bin/memory-init" "$repo" >/dev/null
git -C "$repo" remote add origin git@github.com:owner/team-memory.git
git -C "$repo" config github.user example-user

note="$TEAM_MEMORY_TEST_ROOT/note.md"
cat > "$note" <<'EOF_NOTE'
# Session note

We decided to keep team memory Git-native and explicit.
EOF_NOTE

record=$("$repo/bin/memory-ingest" --member example-user --source-type codex-session --title "Git native memory decision" "$note")
assert_file_exists "$record"
assert_contains "$(cat "$record")" "source_type: codex-session"

wiki=$("$repo/bin/memory-wiki" --project team-memory)
assert_file_exists "$wiki"
assert_contains "$(cat "$wiki")" "[source: context/records/projects/team-memory/"

verify_output=$("$repo/bin/memory-verify")
assert_contains "$verify_output" "memory verify ok"
