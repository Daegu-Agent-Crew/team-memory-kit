#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tests/lib/assert.sh"

manifest="$ROOT/PRODUCT_MANIFEST"
assert_file_exists "$manifest"

entries=$(sed 's/#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//' "$manifest" | awk 'NF')

assert_manifest_contains() {
  wanted=$1
  printf '%s\n' "$entries" | awk -v wanted="$wanted" '
    $0 == wanted { found = 1 }
    END { exit found ? 0 : 1 }
  ' || fail "expected PRODUCT_MANIFEST to contain exact entry: $wanted"
}

while IFS= read -r entry; do
  [ -n "$entry" ] || continue
  case "$entry" in
    ""|.|..|/*|../*|*/../*|*//*)
      fail "unsafe PRODUCT_MANIFEST entry: $entry"
      ;;
  esac
  case "$entry" in
    */) assert_dir_exists "$ROOT/${entry%/}" ;;
    *) assert_file_exists "$ROOT/$entry" ;;
  esac
done <<EOF_ENTRIES
$entries
EOF_ENTRIES

while IFS= read -r helper; do
  rel=${helper#"$ROOT/"}
  assert_manifest_contains "$rel"
done < <(find "$ROOT/bin" -maxdepth 1 -type f -name 'memory-*' | sort)

while IFS= read -r skill; do
  rel="${skill#"$ROOT/"}/"
  assert_manifest_contains "$rel"
done < <(find "$ROOT/skills" -maxdepth 1 -type d -name 'tm-*' | sort)
