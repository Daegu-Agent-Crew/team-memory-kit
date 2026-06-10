#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tests/lib/assert.sh"

repo="$TEAM_MEMORY_TEST_ROOT/status-repo"
"$ROOT/bin/memory-init" "$repo" >/dev/null
repo=$(cd "$repo" >/dev/null 2>&1 && pwd -P)
git -C "$repo" remote add origin git@github.com:owner/team-memory.git

status_output=$("$repo/bin/memory-status")
assert_contains "$status_output" "MEMORY_REPO_ROOT=$repo"
assert_contains "$status_output" "TEAM_MEMORY_KIT_VERSION=$(sed -n '1p' "$ROOT/VERSION")"
assert_contains "$status_output" "MEMORY_VERSION_UPDATED_AT=1970-01-01T00:00:00Z"
assert_contains "$status_output" "MEMORY_VERSION_UPDATED_BY=example-user"
assert_contains "$status_output" "MEMORY_PROJECT=team-memory"
assert_contains "$status_output" "MEMORY_PROJECT_MATCH=alias"
assert_contains "$status_output" "memory-verify: ok"
assert_contains "$status_output" "Git status:"
assert_contains "$status_output" "Wiki files:"
