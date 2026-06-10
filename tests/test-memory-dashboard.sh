#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tests/lib/assert.sh"

repo="$TEAM_MEMORY_TEST_ROOT/dashboard-repo"
"$ROOT/bin/memory-init" "$repo" >/dev/null

private_note="$TEAM_MEMORY_TEST_ROOT/private-note.md"
cat > "$private_note" <<'EOF_PRIVATE'
Internal launch note that must stay out of dashboard JSON.
EOF_PRIVATE

"$repo/bin/memory-ingest" \
  --project team-memory \
  --member example-user \
  --source-type markdown \
  --title "Implicit Private Note" \
  "$private_note" >/dev/null

cat > "$repo/context/records/projects/team-memory/2026-06-10-public-task.md" <<'EOF_TASK'
---
schema_version: 1
title: "Public Dashboard Task"
date: 2026-06-10
project: team-memory
member: example-user
source_type: markdown
source_ref: ""
status: raw-record
visibility: public
dashboard_body: true
task_phase: planning
task_status: pending
---
Public task body for dashboard details.
EOF_TASK

cat > "$repo/context/records/projects/team-memory/2026-06-10-public-decision.md" <<'EOF_DECISION'
---
schema_version: 1
title: "Public Dashboard Decision"
date: 2026-06-10
project: team-memory
member: example-user
source_type: decision
source_ref: ""
status: raw-record
dashboard: true
decision_status: active
---
Decision body should not export without dashboard_body.
EOF_DECISION

cat > "$repo/context/records/projects/team-memory/2026-06-10-private-wins.md" <<'EOF_PRIVATE_WINS'
---
schema_version: 1
title: "Private Wins"
date: 2026-06-10
project: team-memory
member: example-user
source_type: markdown
source_ref: ""
status: raw-record
visibility: private
dashboard: true
dashboard_body: true
---
This must stay private even with dashboard true.
EOF_PRIVATE_WINS

dashboard="$repo/dashboard.json"
output=$("$repo/bin/memory-dashboard" --output "$dashboard")
assert_eq "$dashboard" "$output"
assert_file_exists "$dashboard"

json=$(cat "$dashboard")
assert_eq "example-user" "$(jq -r '.members[0]' "$dashboard")"
assert_eq "2" "$(jq -r '.records_by_project["team-memory"] | length' "$dashboard")"
assert_eq "Public task body for dashboard details." "$(jq -r '.records_by_project["team-memory"][] | select(.title == "Public Dashboard Task") | .body' "$dashboard")"
assert_eq "example-user" "$(jq -r '.tasks[] | select(.title == "Public Dashboard Task") | .assignee' "$dashboard")"
assert_eq "active" "$(jq -r '.decisions[] | select(.title == "Public Dashboard Decision") | .status' "$dashboard")"
assert_eq "" "$(jq -r '.decisions[] | select(.title == "Public Dashboard Decision") | .body' "$dashboard")"
assert_not_contains "$json" "Implicit Private Note"
assert_not_contains "$json" "Internal launch note"
assert_not_contains "$json" "Private Wins"
assert_not_contains "$json" "This must stay private"
