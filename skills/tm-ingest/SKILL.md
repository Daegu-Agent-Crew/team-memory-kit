---
name: tm-ingest
description: Create append-only source records from Codex or Claude Code sessions, meeting notes, research notes, decisions, or manually copied messenger text.
---

# tm-ingest

Before writing a source record, identify the current human member as a GitHub
username listed in `.github/team-memory-members.yml`.

Use:

```bash
bin/memory-ingest \
  --project <project> \
  --member <github> \
  --source-type codex-session \
  --title "<title>" \
  /path/to/source.md
```

Use `--source-type claude-session` when the source is a Claude Code session.

Allowed source types:

- `codex-session`
- `claude-session`
- `messenger-manual`
- `meeting-note`
- `research-note`
- `markdown`
- `decision`
- `repo-note`

After ingesting, run:

```bash
bin/memory-wiki --project <project>
bin/memory-verify
```

Never write secrets, private credentials, private contact details, customer data,
or unrelated private source material into records.
