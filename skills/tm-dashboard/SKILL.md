---
name: tm-dashboard
description: Generate a dashboard.json for the public team dashboard page.
---

# tm-dashboard

Run:

```bash
bin/memory-dashboard --output <path>
```

The output is a single JSON file containing:

- `members` — GitHub usernames from the allowlist
- `projects` — all registered projects with status and kind
- `repositories` — all registered repositories with URLs
- `records_by_project` — source records grouped by project
- `tasks` — records with `task_phase` frontmatter (task tracking)
- `decisions` — records with `decision_status` frontmatter (decision log)
- `wiki` — current wiki content per project

## Task Records

To create a tracked task, add these frontmatter fields to a record:

```yaml
task_phase: planning
task_status: pending
milestone: M1
assignee: github-username
due: 2026-07-01
```

Allowed `task_status` values: `pending`, `in-progress`, `done`, `blocked`

## Decision Records

To create a tracked decision, add:

```yaml
decision_status: active
```

Allowed `decision_status` values: `active`, `revised`, `superseded`, `reverted`

After generating the dashboard, copy or commit the JSON to the public dashboard
repository's data directory.
