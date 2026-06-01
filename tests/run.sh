#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

export TEAM_MEMORY_TEST_ROOT="${TMPDIR:-/tmp}/team-memory-kit-tests.$$"
mkdir -p "$TEAM_MEMORY_TEST_ROOT"
trap 'rm -rf "$TEAM_MEMORY_TEST_ROOT"' EXIT

for test_file in "$ROOT"/tests/test-*.sh; do
  printf '==> %s\n' "${test_file#"$ROOT"/}"
  bash "$test_file"
done

printf 'all tests passed\n'
