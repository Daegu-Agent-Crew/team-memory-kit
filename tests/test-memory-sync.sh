#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tests/lib/assert.sh"

make_sync_repo() {
  label=$1
  repo="$TEAM_MEMORY_TEST_ROOT/sync-$label"
  "$ROOT/bin/memory-init" "$repo" >/dev/null
  repo=$(cd "$repo" >/dev/null 2>&1 && pwd -P)
  git -C "$repo" config user.email "team-memory-test@example.com"
  git -C "$repo" config user.name "team memory test"
  git -C "$repo" add .
  git -C "$repo" commit -q -m "baseline"
  printf '%s\n' "$repo"
}

write_note() {
  path=$1
  title=$2
  {
    printf '# %s\n\n' "$title"
    printf 'Safe team memory content.\n'
  } > "$path"
}

repo=$(make_sync_repo "noop")
noop_output=$("$repo/bin/memory-sync" --project team-memory --member example-user)
assert_contains "$noop_output" "no team memory changes"
assert_contains "$noop_output" "push not requested"

repo=$(make_sync_repo "project")
note="$TEAM_MEMORY_TEST_ROOT/project-note.md"
write_note "$note" "Project note"
"$repo/bin/memory-ingest" --project team-memory --member example-user --source-type meeting-note --title "Project note" "$note" >/dev/null
"$repo/bin/memory-wiki" --project team-memory >/dev/null
before_count=$(git -C "$repo" rev-list --count HEAD)
project_output=$("$repo/bin/memory-sync" --project team-memory --member example-user)
after_count=$(git -C "$repo" rev-list --count HEAD)
assert_eq "$((before_count + 1))" "$after_count"
assert_contains "$project_output" "push not requested"
project_files=$(git -C "$repo" diff-tree --no-commit-id --name-only -r HEAD)
assert_contains "$project_files" "context/records/projects/team-memory/"
assert_contains "$project_files" "context/wiki/projects/team-memory/current-context.md"
assert_contains "$project_files" "MEMORY_VERSION"
project_message=$(git -C "$repo" log -1 --pretty=%B)
assert_contains "$project_message" "Team-Memory-Member: example-user"
assert_contains "$project_message" "Team-Memory-Sync-Mode: project"

repo=$(make_sync_repo "missing-member")
note="$TEAM_MEMORY_TEST_ROOT/missing-member-note.md"
write_note "$note" "Missing member"
"$repo/bin/memory-ingest" --project team-memory --member example-user --source-type meeting-note --title "Missing member" "$note" >/dev/null
set +e
missing_output=$("$repo/bin/memory-sync" --project team-memory 2>&1)
missing_status=$?
set -e
assert_eq "1" "$missing_status"
assert_contains "$missing_output" "require --member"

repo=$(make_sync_repo "paths")
note="$TEAM_MEMORY_TEST_ROOT/paths-note.md"
write_note "$note" "Paths note"
record=$("$repo/bin/memory-ingest" --project team-memory --member example-user --source-type meeting-note --title "Paths note" "$note")
rel_record=${record#"$repo/"}
before_count=$(git -C "$repo" rev-list --count HEAD)
paths_output=$("$repo/bin/memory-sync" --paths "$rel_record" --member example-user)
after_count=$(git -C "$repo" rev-list --count HEAD)
assert_eq "$((before_count + 1))" "$after_count"
assert_contains "$paths_output" "push not requested"
paths_files=$(git -C "$repo" diff-tree --no-commit-id --name-only -r HEAD)
assert_contains "$paths_files" "$rel_record"
assert_contains "$paths_files" "MEMORY_VERSION"
paths_message=$(git -C "$repo" log -1 --pretty=%B)
assert_contains "$paths_message" "Team-Memory-Sync-Mode: paths"

repo=$(make_sync_repo "unsafe-path")
set +e
unsafe_output=$("$repo/bin/memory-sync" --paths notes.txt --member example-user 2>&1)
unsafe_status=$?
set -e
assert_eq "2" "$unsafe_status"
assert_contains "$unsafe_output" "refusing unsafe sync path"

repo=$(make_sync_repo "policy-refused")
printf 'blocked-term\n' >> "$repo/context/policies/denylist.txt"
set +e
policy_refused_output=$("$repo/bin/memory-sync" --project team-memory --member example-user 2>&1)
policy_refused_status=$?
set -e
assert_eq "5" "$policy_refused_status"
assert_contains "$policy_refused_output" "context/policies/denylist.txt"

repo=$(make_sync_repo "policy-paths")
printf 'blocked-term\n' >> "$repo/context/policies/denylist.txt"
before_count=$(git -C "$repo" rev-list --count HEAD)
policy_paths_output=$("$repo/bin/memory-sync" --paths context/policies/denylist.txt --member example-user)
after_count=$(git -C "$repo" rev-list --count HEAD)
assert_eq "$((before_count + 1))" "$after_count"
assert_contains "$policy_paths_output" "push not requested"
policy_paths_files=$(git -C "$repo" diff-tree --no-commit-id --name-only -r HEAD)
assert_contains "$policy_paths_files" "context/policies/denylist.txt"
assert_contains "$policy_paths_files" "MEMORY_VERSION"

repo=$(make_sync_repo "directory-path")
set +e
directory_output=$("$repo/bin/memory-sync" --paths context/registry/projects --member example-user 2>&1)
directory_status=$?
set -e
assert_eq "2" "$directory_status"
assert_contains "$directory_output" "only accepts files"

repo=$(make_sync_repo "unrelated-dirty")
note="$TEAM_MEMORY_TEST_ROOT/unrelated-note.md"
write_note "$note" "Unrelated note"
"$repo/bin/memory-ingest" --project team-memory --member example-user --source-type meeting-note --title "Unrelated note" "$note" >/dev/null
mkdir -p "$repo/docs"
printf 'dirty docs\n' > "$repo/docs/unrelated.md"
set +e
refused_output=$("$repo/bin/memory-sync" --project team-memory --member example-user 2>&1)
refused_status=$?
set -e
assert_eq "5" "$refused_status"
assert_contains "$refused_output" "docs/unrelated.md"

repo=$(make_sync_repo "staged")
printf 'staged note\n' > "$repo/notes.txt"
git -C "$repo" add notes.txt
set +e
staged_output=$("$repo/bin/memory-sync" --project team-memory --member example-user 2>&1)
staged_status=$?
set -e
assert_eq "4" "$staged_status"
assert_contains "$staged_output" "staged files outside the sync plan"

repo=$(make_sync_repo "deleted-registry")
rm "$repo/context/registry/messengers/channels/general.yml"
before_count=$(git -C "$repo" rev-list --count HEAD)
deleted_registry_output=$("$repo/bin/memory-sync" --project team-memory --member example-user)
after_count=$(git -C "$repo" rev-list --count HEAD)
assert_eq "$((before_count + 1))" "$after_count"
assert_contains "$deleted_registry_output" "push not requested"
deleted_registry_files=$(git -C "$repo" diff-tree --no-commit-id --name-only -r HEAD)
assert_contains "$deleted_registry_files" "context/registry/messengers/channels/general.yml"

repo=$(make_sync_repo "all")
mkdir -p "$repo/docs"
printf 'all docs\n' > "$repo/docs/all.md"
printf 'all-policy-term\n' >> "$repo/context/policies/denylist.txt"
before_count=$(git -C "$repo" rev-list --count HEAD)
all_output=$("$repo/bin/memory-sync" --all --member example-user)
after_count=$(git -C "$repo" rev-list --count HEAD)
assert_eq "$((before_count + 1))" "$after_count"
assert_contains "$all_output" "push not requested"
all_files=$(git -C "$repo" diff-tree --no-commit-id --name-only -r HEAD)
assert_contains "$all_files" "docs/all.md"
assert_contains "$all_files" "context/policies/denylist.txt"
