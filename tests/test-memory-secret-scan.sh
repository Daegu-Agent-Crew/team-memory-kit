#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tests/lib/assert.sh"

repo="$TEAM_MEMORY_TEST_ROOT/secret-repo"
"$ROOT/bin/memory-init" "$repo" >/dev/null

clean="$TEAM_MEMORY_TEST_ROOT/clean.md"
cat > "$clean" <<'EOF_CLEAN'
This file has no credential values.
EOF_CLEAN
"$repo/bin/memory-secret-scan" "$clean" >/dev/null

secret="$TEAM_MEMORY_TEST_ROOT/secret.md"
cat > "$secret" <<'EOF_SECRET'
API_KEY=sk-test12345678901234567890
EOF_SECRET
assert_failure "$repo/bin/memory-secret-scan" "$secret"

cat > "$repo/context/policies/denylist.txt" <<'EOF_DENY'
customer-codename
EOF_DENY
denied="$TEAM_MEMORY_TEST_ROOT/denied.md"
cat > "$denied" <<'EOF_DENIED'
This mentions customer-codename and must not enter memory.
EOF_DENIED
assert_failure "$repo/bin/memory-secret-scan" "$denied"
