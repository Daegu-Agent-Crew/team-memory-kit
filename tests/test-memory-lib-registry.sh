#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tests/lib/assert.sh"

repo="$TEAM_MEMORY_TEST_ROOT/lib-registry-repo"
"$ROOT/bin/memory-init" "$repo" >/dev/null

ids=$("$repo/bin/memory-lib-registry" project-ids)
assert_contains "$ids" "team-memory"

entries=$("$repo/bin/memory-lib-registry" repo-entries)
assert_contains "$entries" "owner/team-memory"

resolved=$("$repo/bin/memory-lib-registry" resolve-repo owner/team-memory)
assert_contains "$resolved" "MEMORY_REGISTRY_PROJECT='team-memory'"
assert_contains "$resolved" "MEMORY_REGISTRY_MATCH='alias'"

project_files=$("$repo/bin/memory-lib-registry" project-files team-memory)
assert_contains "$project_files" "context/registry/projects/team-memory.yml"
assert_contains "$project_files" "context/registry/repositories/team-memory.yml"
assert_contains "$project_files" "context/registry/messengers/channels/general.yml"

destinations=$("$repo/bin/memory-lib-registry" project-destinations team-memory)
assert_contains "$destinations" "general"

assert_success "$repo/bin/memory-lib-registry" validate

cat > "$repo/context/registry/repositories/duplicate.yml" <<'EOF_DUP'
slug: duplicate
project: team-memory
aliases:
  - owner/team-memory
EOF_DUP
assert_failure "$repo/bin/memory-lib-registry" validate

rm "$repo/context/registry/repositories/duplicate.yml"
cat > "$repo/context/registry/repositories/unknown.yml" <<'EOF_UNKNOWN'
slug: unknown
project: missing
EOF_UNKNOWN
assert_failure "$repo/bin/memory-lib-registry" validate

rm "$repo/context/registry/repositories/unknown.yml"
cat > "$repo/context/registry/projects/wrong-file.yml" <<'EOF_WRONG'
id: right-id
name: "Wrong file"
EOF_WRONG
assert_failure "$repo/bin/memory-lib-registry" validate
