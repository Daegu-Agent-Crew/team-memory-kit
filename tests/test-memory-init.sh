#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tests/lib/assert.sh"

repo="$TEAM_MEMORY_TEST_ROOT/init-repo"
assert_success "$ROOT/bin/memory-init" "$repo"

assert_file_exists "$repo/bin/memory-ingest"
assert_file_exists "$repo/skills/tm-load/SKILL.md"
assert_file_exists "$repo/setup"
assert_file_exists "$repo/MEMORY_VERSION"
assert_file_exists "$repo/.github/team-memory-members.yml"
assert_file_exists "$repo/context/registry/projects/team-memory.yml"
assert_file_exists "$repo/context/registry/repositories/team-memory.yml"
assert_dir_exists "$repo/.git"

assert_failure "$ROOT/bin/memory-init" "$repo"
