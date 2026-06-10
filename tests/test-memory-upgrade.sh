#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tests/lib/assert.sh"

repo="$TEAM_MEMORY_TEST_ROOT/upgrade-repo"
"$ROOT/bin/memory-init" "$repo" >/dev/null
repo=$(cd "$repo" >/dev/null 2>&1 && pwd -P)

old_version="2026.01.01.1"
printf '%s\n' "$old_version" > "$repo/VERSION"
cat > "$repo/bin/memory-status" <<'EOF_OLD_STATUS'
#!/usr/bin/env bash
echo old status
EOF_OLD_STATUS
chmod +x "$repo/bin/memory-status"
printf '# old tm-load skill\n' > "$repo/skills/tm-load/SKILL.md"
rm -f "$repo/bin/memory-lib-product" "$repo/bin/memory-upgrade"
rm -rf "$repo/skills/tm-upgrade"
printf '# stale helper\n' > "$repo/bin/memory-old-helper"
chmod +x "$repo/bin/memory-old-helper"
mkdir -p "$repo/skills/tm-old"
printf '# stale skill\n' > "$repo/skills/tm-old/SKILL.md"
printf '\n# private marker\n' >> "$repo/context/policies/denylist.txt"

dry_output=$("$ROOT/bin/memory-upgrade" --dry-run "$repo")
assert_contains "$dry_output" "Would update:"
assert_contains "$dry_output" "PRODUCT_MANIFEST"
assert_contains "$dry_output" "bin/memory-status"
assert_contains "$dry_output" "skills/tm-upgrade/"
assert_contains "$dry_output" "Would prune stale product files:"
assert_contains "$dry_output" "bin/memory-old-helper"
assert_contains "$dry_output" "skills/tm-old/"
assert_contains "$dry_output" "Would not touch:"
assert_eq "$old_version" "$(sed -n '1p' "$repo/VERSION")"
assert_contains "$(sed -n '1p' "$repo/skills/tm-load/SKILL.md")" "old tm-load skill"
assert_file_exists "$repo/bin/memory-old-helper"
assert_file_exists "$repo/skills/tm-old/SKILL.md"

upgrade_output=$("$ROOT/bin/memory-upgrade" "$repo")
assert_contains "$upgrade_output" "memory verify ok"
assert_contains "$upgrade_output" "memory-upgrade: upgraded from $old_version to $(sed -n '1p' "$ROOT/VERSION")"
assert_eq "$(sed -n '1p' "$ROOT/VERSION")" "$(sed -n '1p' "$repo/VERSION")"
assert_eq "$(sed -n '1p' "$ROOT/PRODUCT_MANIFEST")" "$(sed -n '1p' "$repo/PRODUCT_MANIFEST")"
assert_contains "$(sed -n '1,80p' "$repo/bin/memory-status")" "TEAM_MEMORY_KIT_VERSION"
assert_file_exists "$repo/bin/memory-lib-product"
assert_file_exists "$repo/bin/memory-upgrade"
assert_file_exists "$repo/skills/tm-upgrade/SKILL.md"
assert_contains "$(cat "$repo/context/policies/denylist.txt")" "# private marker"
[ ! -e "$repo/bin/memory-old-helper" ] || fail "expected stale helper to be pruned"
[ ! -e "$repo/skills/tm-old" ] || fail "expected stale skill to be pruned"

target_run_version="2026.01.02.1"
printf '%s\n' "$target_run_version" > "$repo/VERSION"
target_run_output=$(cd "$repo" && bin/memory-upgrade --source "$ROOT" .)
assert_contains "$target_run_output" "memory-upgrade: upgraded from $target_run_version to $(sed -n '1p' "$ROOT/VERSION")"
assert_eq "$(sed -n '1p' "$ROOT/VERSION")" "$(sed -n '1p' "$repo/VERSION")"
