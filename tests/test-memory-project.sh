#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tests/lib/assert.sh"

repo="$TEAM_MEMORY_TEST_ROOT/project-repo"
"$ROOT/bin/memory-init" "$repo" >/dev/null
git -C "$repo" remote add origin git@github.com:owner/team-memory.git

project=$("$repo/bin/memory-project")
assert_eq "team-memory" "$project"

shell_output=$("$repo/bin/memory-project" --shell)
assert_contains "$shell_output" "MEMORY_PROJECT='team-memory'"
assert_contains "$shell_output" "MEMORY_PROJECT_MATCH='alias'"

mkdir -p "$repo/context/registry/projects/other" "$repo/context/registry/repositories"
cat > "$repo/context/registry/projects/other.yml" <<'EOF_PROJECT'
id: other
name: "Other"
status: active
kind: "test"
description: "duplicate alias fixture"
EOF_PROJECT
cat > "$repo/context/registry/repositories/other.yml" <<'EOF_REPO'
slug: other
project: other
aliases:
  - owner/team-memory
EOF_REPO

assert_failure "$repo/bin/memory-project" --validate
