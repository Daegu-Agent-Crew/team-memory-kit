---
name: tm-dashboard
description: Generate dashboard JSON for a public team dashboard page.
---

# tm-dashboard

Run:

```bash
bin/memory-dashboard --output <path>
```

The output is a single JSON file containing:

- `members`: GitHub usernames from the allowlist
- `projects`: all registered projects with status and kind
- `repositories`: all registered repositories with URLs
- `records_by_project`: explicitly public source records grouped by project
- `timeline`: explicitly public source records sorted newest first
- `tasks`: explicitly public records with `task_phase` frontmatter
- `decisions`: explicitly public records with `decision_status` frontmatter
- `wiki`: current wiki content per project

## Public Export

Records are private by default for dashboard export. To include a record in the
dashboard, add one of:

```yaml
visibility: public
```

or:

```yaml
dashboard: true
```

`visibility: private` always wins and excludes the record, even when
`dashboard: true` is also present.

Record body text is not exported by default. To include body text and timeline
summary text, add:

```yaml
dashboard_body: true
```

## Task Records

To create a tracked task, add these frontmatter fields to a public dashboard
record:

```yaml
visibility: public
task_phase: planning
task_status: pending
milestone: M1
assignee: github-username
due: 2026-07-01
```

Allowed `task_status` values: `pending`, `in-progress`, `done`, `blocked`.
If `assignee` is omitted, the dashboard uses the record `member`.

## Decision Records

To create a tracked decision, add:

```yaml
visibility: public
decision_status: active
```

Allowed `decision_status` values: `active`, `revised`, `superseded`,
`reverted`.

After generating the dashboard, copy or commit the JSON to the public dashboard
repository's data directory.
