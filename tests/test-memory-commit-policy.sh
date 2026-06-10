#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tests/lib/assert.sh"

make_policy_repo() {
  label=$1
  repo="$TEAM_MEMORY_TEST_ROOT/policy-$label"
  "$ROOT/bin/memory-init" "$repo" >/dev/null
  git -C "$repo" config user.email "team-memory-test@example.com"
  git -C "$repo" config user.name "team memory test"
  git -C "$repo" add .
  git -C "$repo" commit -q -m "baseline"
  printf '%s\n' "$repo"
}

write_memory_version() {
  repo=$1
  member=${2:-example-user}
  updated_at=${3:-2026-06-10T12:00:00+09:00}
  mode=${4:-project}
  scope=${5:-team-memory}
  cat > "$repo/MEMORY_VERSION" <<EOF_VERSION
schema_version: 1
snapshot_date: ${updated_at%%T*}
updated_at: $updated_at
updated_by: $member
updated_via: memory-sync
sync_mode: $mode
sync_scope: $scope
EOF_VERSION
}

commit_context() {
  repo=$1
  message=$2
  member=$3
  updated_at=$4
  scope=$5
  mode=$6
  printf '\npolicy context\n' >> "$repo/context/records/projects/.gitkeep"
  git -C "$repo" add .
  git -C "$repo" commit -q -m "$message" -m "Team-Memory-Member: $member
Team-Memory-Updated-At: $updated_at
Team-Memory-Scope: $scope
Team-Memory-Sync-Mode: $mode"
}

repo=$(make_policy_repo "valid")
write_memory_version "$repo"
commit_context "$repo" "memory: update team memory" "example-user" "2026-06-10T12:00:00+09:00" "team-memory" "project"
valid_output=$(cd "$repo" && bin/memory-commit-policy-check --range HEAD 2>&1)
assert_eq "" "$valid_output"

repo=$(make_policy_repo "template-baseline")
baseline_output=$(cd "$repo" && bin/memory-commit-policy-check --range HEAD 2>&1)
assert_eq "" "$baseline_output"

repo=$(make_policy_repo "missing")
printf '\nmissing trailer\n' >> "$repo/context/records/projects/.gitkeep"
git -C "$repo" add .
git -C "$repo" commit -q -m "memory without trailers"
set +e
missing_output=$(cd "$repo" && bin/memory-commit-policy-check --range HEAD 2>&1)
missing_status=$?
set -e
assert_eq "1" "$missing_status"
assert_contains "$missing_output" "missing Team-Memory-Member trailer"

repo=$(make_policy_repo "unknown-member")
write_memory_version "$repo" "unknown-user"
commit_context "$repo" "memory unknown member" "unknown-user" "2026-06-10T12:00:00+09:00" "team-memory" "project"
set +e
unknown_output=$(cd "$repo" && bin/memory-commit-policy-check --range HEAD 2>&1)
unknown_status=$?
set -e
assert_eq "1" "$unknown_status"
assert_contains "$unknown_output" "unknown Team-Memory-Member"

repo=$(make_policy_repo "version-mismatch")
write_memory_version "$repo" "example-user" "2026-06-10T12:00:00+09:00"
commit_context "$repo" "memory mismatch" "example-user" "2026-06-10T13:00:00+09:00" "team-memory" "project"
set +e
mismatch_output=$(cd "$repo" && bin/memory-commit-policy-check --range HEAD 2>&1)
mismatch_status=$?
set -e
assert_eq "1" "$mismatch_status"
assert_contains "$mismatch_output" "updated_at does not match"

repo=$(make_policy_repo "shallow-range")
printf '\nshallow missing trailer\n' >> "$repo/context/records/projects/.gitkeep"
git -C "$repo" add .
git -C "$repo" commit -q -m "memory without trailers"
base=$(git -C "$repo" rev-parse HEAD~1)
head=$(git -C "$repo" rev-parse HEAD)
clone="$TEAM_MEMORY_TEST_ROOT/policy-shallow-clone"
git clone -q --depth 1 "file://$repo" "$clone"
set +e
shallow_output=$(cd "$clone" && bin/memory-commit-policy-check --range "$base..$head" 2>&1)
shallow_status=$?
set -e
assert_eq "2" "$shallow_status"
assert_contains "$shallow_output" "invalid or unavailable range"
