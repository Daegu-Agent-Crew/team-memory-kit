#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tests/lib/assert.sh"

assert_symlink_target() {
  path=$1
  expected=$2
  [ -L "$path" ] || fail "expected symlink: $path"
  actual=$(readlink "$path")
  assert_eq "$expected" "$actual"
}

repo="$TEAM_MEMORY_TEST_ROOT/link-context-repo"
"$ROOT/bin/memory-init" "$repo" >/dev/null
repo=$(cd "$repo" >/dev/null 2>&1 && pwd -P)
git -C "$repo" remote add origin git@github.com:owner/team-memory.git

note="$TEAM_MEMORY_TEST_ROOT/link-note.md"
cat > "$note" <<'EOF_NOTE'
# Link note
EOF_NOTE

"$repo/bin/memory-ingest" --project team-memory --member example-user --source-type meeting-note --title "Link note" "$note" >/dev/null
"$repo/bin/memory-wiki" --project team-memory >/dev/null

output=$("$repo/bin/memory-link-context" --project team-memory)
assert_contains "$output" "linked team-memory context"
assert_symlink_target "$repo/team-memory-context/team-memory/wiki/current-context.md" "$repo/context/wiki/projects/team-memory/current-context.md"
assert_symlink_target "$repo/team-memory-context/team-memory/registry/projects/team-memory.yml" "$repo/context/registry/projects/team-memory.yml"
assert_contains "$(cat "$repo/team-memory-context/team-memory/README.md")" "live symlink mirror"

check_ignore=$(git -C "$repo" check-ignore -v team-memory-context/team-memory/wiki/current-context.md)
assert_contains "$check_ignore" "/team-memory-context/"

second_output=$("$repo/bin/memory-link-context" --project team-memory)
assert_contains "$second_output" "linked team-memory context"
exclude_count=$(grep -c '^/team-memory-context/$' "$repo/.git/info/exclude")
assert_eq "1" "$exclude_count"

app_repo="$TEAM_MEMORY_TEST_ROOT/link-app-repo"
app_worktree="$TEAM_MEMORY_TEST_ROOT/link-app-worktree"
mkdir -p "$app_repo"
git -C "$app_repo" init >/dev/null
git -C "$app_repo" config user.email "team-memory-test@example.com"
git -C "$app_repo" config user.name "team memory test"
printf 'app\n' > "$app_repo/README.md"
git -C "$app_repo" add README.md
git -C "$app_repo" commit -q -m "app baseline"
git -C "$app_repo" worktree add -q -b link-context "$app_worktree"
worktree_output=$("$repo/bin/memory-link-context" --project team-memory --repo-root "$app_worktree")
assert_contains "$worktree_output" "linked team-memory context"
[ -f "$app_worktree/.git" ] || fail "expected linked worktree .git file"
worktree_ignore=$(git -C "$app_worktree" check-ignore -v team-memory-context/team-memory/README.md)
assert_contains "$worktree_ignore" "/team-memory-context/"

dry_repo="$TEAM_MEMORY_TEST_ROOT/link-dry-repo"
"$ROOT/bin/memory-init" "$dry_repo" >/dev/null
dry_repo=$(cd "$dry_repo" >/dev/null 2>&1 && pwd -P)
dry_output=$("$dry_repo/bin/memory-link-context" --project team-memory --dry-run)
assert_contains "$dry_output" "dry-run complete"
[ ! -e "$dry_repo/team-memory-context" ] || fail "dry-run should not create mirror"

collision_repo="$TEAM_MEMORY_TEST_ROOT/link-collision-repo"
"$ROOT/bin/memory-init" "$collision_repo" >/dev/null
collision_repo=$(cd "$collision_repo" >/dev/null 2>&1 && pwd -P)
collision_note="$TEAM_MEMORY_TEST_ROOT/collision-note.md"
cat > "$collision_note" <<'EOF_COLLISION'
# Collision note
EOF_COLLISION
"$collision_repo/bin/memory-ingest" --project team-memory --member example-user --source-type meeting-note --title "Collision note" "$collision_note" >/dev/null
"$collision_repo/bin/memory-wiki" --project team-memory >/dev/null
mkdir -p "$collision_repo/team-memory-context/team-memory/wiki"
printf 'user file\n' > "$collision_repo/team-memory-context/team-memory/wiki/current-context.md"
set +e
collision_output=$("$collision_repo/bin/memory-link-context" --project team-memory 2>&1)
collision_status=$?
set -e
assert_eq "5" "$collision_status"
assert_contains "$collision_output" "refusing to overwrite existing path"
assert_eq "user file" "$(cat "$collision_repo/team-memory-context/team-memory/wiki/current-context.md")"
