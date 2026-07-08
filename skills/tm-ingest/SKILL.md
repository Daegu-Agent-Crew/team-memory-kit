---
name: tm-ingest
description: Create append-only source records from Codex sessions, meeting notes, research notes, decisions, or manually copied messenger text.
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

Allowed source types:

- `codex-session`
- `messenger-manual`
- `meeting-note`
- `research-note`
- `markdown`
- `decision`
- `repo-note`
- `pre-impl-analysis` — output from a `tm-preimpl` blind-spot sweep, brainstorm, or interview session

After ingesting, run:

```bash
bin/memory-wiki --project <project>
bin/memory-verify
```

Never write secrets, private credentials, private contact details, customer data,
or unrelated private source material into records.
