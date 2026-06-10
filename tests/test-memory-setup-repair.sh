#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tests/lib/assert.sh"

repo="$TEAM_MEMORY_TEST_ROOT/setup-repair-repo"
home="$TEAM_MEMORY_TEST_ROOT/setup-repair-home"
"$ROOT/bin/memory-init" "$repo" >/dev/null
mkdir -p "$home"

HOME="$home" "$repo/setup" --host codex >/dev/null
[ -L "$home/.team-memory" ] || fail "expected ~/.team-memory link"
[ -L "$home/.codex/skills/tm-load" ] || fail "expected Codex skill link"

HOME="$home" "$repo/setup" --host claude >/dev/null
[ -L "$home/.claude/skills/tm-load/SKILL.md" ] || fail "expected Claude skill markdown link"

rm -rf "$home/.team-memory"
mkdir -p "$home/.team-memory"
set +e
broken_home_output=$(HOME="$home" "$repo/setup" --host codex 2>&1)
broken_home_status=$?
set -e
assert_eq "1" "$broken_home_status"
assert_contains "$broken_home_output" "not a link"

repair_home_output=$(HOME="$home" "$repo/setup" --host codex --repair)
assert_contains "$repair_home_output" "repaired"
[ -L "$home/.team-memory" ] || fail "repair should recreate ~/.team-memory link"

rm -rf "$home/.codex/skills/tm-load"
mkdir -p "$home/.codex/skills/tm-load"
set +e
broken_skill_output=$(HOME="$home" "$repo/setup" --host codex 2>&1)
broken_skill_status=$?
set -e
assert_eq "1" "$broken_skill_status"
assert_contains "$broken_skill_output" "not a link"

repair_skill_output=$(HOME="$home" "$repo/setup" --host codex --repair)
assert_contains "$repair_skill_output" "repaired"
[ -L "$home/.codex/skills/tm-load" ] || fail "repair should recreate Codex skill link"

rm -rf "$home/.team-memory" "$home/.codex"
HOME="$home" "$repo/setup" --host codex --state none >/dev/null
[ ! -e "$home/.team-memory" ] || fail "--state none should not create home link"
[ -L "$home/.codex/skills/tm-load" ] || fail "--state none should still install skills"
