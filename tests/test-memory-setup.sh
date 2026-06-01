#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tests/lib/assert.sh"

repo="$TEAM_MEMORY_TEST_ROOT/setup-repo"
home="$TEAM_MEMORY_TEST_ROOT/home"
"$ROOT/bin/memory-init" "$repo" >/dev/null
mkdir -p "$home"

HOME="$home" "$repo/setup" --host codex >/dev/null

[ -L "$home/.team-memory" ] || fail "expected ~/.team-memory symlink"
[ -L "$home/.codex/skills/tm-load" ] || fail "expected tm-load Codex skill symlink"
[ -L "$home/.codex/skills/tm-ingest" ] || fail "expected tm-ingest Codex skill symlink"

setup_output=$(HOME="$home" "$repo/bin/memory-setup")
assert_contains "$setup_output" "ok: registry validates"
